untyped

global function PIN_GameStart
global function SetGameState
global function GameState_EntitiesDidLoad
global function WaittillGameStateOrHigher

global function SetShouldUsePickLoadoutScreen
global function SetSwitchSidesBased
global function SetSuddenDeathBased
global function SetShouldUseRoundWinningKillReplay
global function SetRoundWinningKillReplayKillClasses
global function SetRoundWinningKillReplayAttacker
global function SetWinner
global function SetTimeoutWinnerDecisionFunc
global function AddTeamScore

global function GameState_GetTimeLimitOverride
global function IsRoundBasedGameOver
global function ShouldRunEvac
global function GiveTitanToPlayer
global function GetTimeLimit_ForGameMode

struct {
	// used for togglable parts of gamestate
	bool usePickLoadoutScreen
	bool switchSidesBased
	bool suddenDeathBased
	int functionref() timeoutWinnerDecisionFunc
	
	// for waitingforplayers
	int numPlayersFullyConnected
	
	bool hasSwitchedSides
	
	int announceRoundWinnerWinningSubstr
	int announceRoundWinnerLosingSubstr
		
	bool roundWinningKillReplayTrackPilotKills = true 
	bool roundWinningKillReplayTrackTitanKills = false
	
	entity roundWinningKillReplayVictim
	entity roundWinningKillReplayAttacker
	int roundWinningKillReplayMethodOfDeath
	float roundWinningKillReplayTimeOfDeath
	float roundWinningKillReplayHealthFrac
} file

void function PIN_GameStart()
{
	// todo: using the pin telemetry function here is weird and was done veeery early on before i knew how this all worked, should use a different one

	// called from InitGameState
	//FlagInit( "ReadyToStartMatch" )
	
	SetServerVar( "switchedSides", 0 )
	SetServerVar( "winningTeam", -1 )
		
	AddCallback_GameStateEnter( eGameState.WaitingForCustomStart, GameStateEnter_WaitingForCustomStart )
	AddCallback_GameStateEnter( eGameState.WaitingForPlayers, GameStateEnter_WaitingForPlayers )
	AddCallback_OnClientConnected( WaitingForPlayers_ClientConnected )
	AddCallback_OnClientDisconnected( WaitingForPlayers_ClientDisconnected )
	
	AddCallback_GameStateEnter( eGameState.PickLoadout, GameStateEnter_PickLoadout )
	AddCallback_GameStateEnter( eGameState.Prematch, GameStateEnter_Prematch )
	AddCallback_GameStateEnter( eGameState.Playing, GameStateEnter_Playing )
	AddCallback_GameStateEnter( eGameState.WinnerDetermined, GameStateEnter_WinnerDetermined )
	AddCallback_GameStateEnter( eGameState.SwitchingSides, GameStateEnter_SwitchingSides )
	AddCallback_GameStateEnter( eGameState.SuddenDeath, GameStateEnter_SuddenDeath )
	AddCallback_GameStateEnter( eGameState.Postmatch, GameStateEnter_Postmatch )
	
	AddCallback_OnClientConnected( SetSkyCam ) // had no idea where to put this lol
	AddCallback_OnPlayerKilled( OnPlayerKilled )
	AddDeathCallback( "npc_titan", OnTitanKilled )
}

void function SetGameState( int newState )
{
	SetServerVar( "gameStateChangeTime", Time() )
	SetServerVar( "gameState", newState )
	svGlobal.levelEnt.Signal( "GameStateChanged" )

	// added in AddCallback_GameStateEnter
	foreach ( callbackFunc in svGlobal.gameStateEnterCallbacks[ newState ] )
		callbackFunc()
}

void function GameState_EntitiesDidLoad()
{
	// nothing of importance to put here, this is referenced in _gamestate though so need it
}

void function WaittillGameStateOrHigher( int gameState )
{
	while ( GetGameState() < gameState )
		svGlobal.levelEnt.WaitSignal( "GameStateChanged" )
}


// logic for individual gamestates:


// eGameState.WaitingForCustomStart
void function GameStateEnter_WaitingForCustomStart()
{
	// unused in release, comments indicate this was supposed to be used for an e3 demo
	// perhaps games in this demo were manually started by an employee? no clue really
}


// eGameState.WaitingForPlayers
void function GameStateEnter_WaitingForPlayers()
{
	foreach ( entity player in GetPlayerArray() )
		WaitingForPlayers_ClientConnected( player )
		
	thread WaitForPlayers( GetPendingClientsCount() + file.numPlayersFullyConnected ) // like 90% sure there should be a way to get number of loading clients on server but idk it
}

void function WaitForPlayers( int wantedNum )
{
	// note: atm if someone disconnects as this happens the game will just wait forever
	print( "WaitForPlayers(): " + wantedNum + " players" )	
	float endTime = Time() + 120.0
	
	while ( endTime > Time() )
	{	
		if ( file.numPlayersFullyConnected >= wantedNum )
			break
			
		WaitFrame()
	}
	
	print( "done waiting!" )
	
	wait 1.0 // bit nicer
	
	if ( file.usePickLoadoutScreen )
		SetGameState( eGameState.PickLoadout )
	else
		SetGameState( eGameState.Prematch ) 
}

void function WaitingForPlayers_ClientConnected( entity player )
{
	if ( GetGameState() == eGameState.WaitingForPlayers )
		ScreenFadeToBlackForever( player, 0.0 )
		
	file.numPlayersFullyConnected++
}

void function WaitingForPlayers_ClientDisconnected( entity player )
{
	file.numPlayersFullyConnected--
}


// eGameState.PickLoadout
void function GameStateEnter_PickLoadout()
{
	thread GameStateEnter_PickLoadout_Threaded()
}

void function GameStateEnter_PickLoadout_Threaded()
{	
	float pickloadoutLength = 20.0 // may need tweaking
	SetServerVar( "minPickLoadOutTime", Time() + pickloadoutLength )
	
	// titan selection menu can change minPickLoadOutTime so we need to wait manually until we hit the time
	while ( Time() < GetServerVar( "minPickLoadOutTime" ) )
		WaitFrame()
	
	SetGameState( eGameState.Prematch )
}


// eGameState.Prematch
void function GameStateEnter_Prematch()
{	
	int timeLimit = GameMode_GetTimeLimit( GAMETYPE ) * 60
	if ( file.switchSidesBased )
		timeLimit /= 2 // endtime is half of total per side
		
	SetServerVar( "gameEndTime", Time() + timeLimit + ClassicMP_GetIntroLength() )
	SetServerVar( "roundEndTime", Time() + ClassicMP_GetIntroLength() + GameMode_GetRoundTimeLimit( GAMETYPE ) * 60 )
}


// eGameState.Playing
void function GameStateEnter_Playing()
{
	thread GameStateEnter_Playing_Threaded()
}

void function GameStateEnter_Playing_Threaded()
{
	WaitFrame() // ensure timelimits are all properly set

	while ( GetGameState() == eGameState.Playing )
	{
		// could cache these, but what if we update it midgame?
		float endTime
		if ( IsRoundBased() )
			endTime = expect float( GetServerVar( "roundEndTime" ) )
		else
			endTime = expect float( GetServerVar( "gameEndTime" ) )
	
		// time's up!
		if ( Time() >= endTime )
		{
			int winningTeam
			if ( file.timeoutWinnerDecisionFunc != null )
				winningTeam = file.timeoutWinnerDecisionFunc()
			else
				winningTeam = GameScore_GetWinningTeam()
			
			if ( file.switchSidesBased && !file.hasSwitchedSides )
				SetGameState( eGameState.SwitchingSides )
			else if ( file.suddenDeathBased && winningTeam == TEAM_UNASSIGNED ) // suddendeath if we draw and suddendeath is enabled and haven't switched sides
				SetGameState( eGameState.SuddenDeath )
			else
				SetWinner( winningTeam )
		}
		
		WaitFrame()
	}
}


// eGameState.WinnerDetermined
// these are likely innacurate
const float ROUND_END_FADE_KILLREPLAY = 1.0
const float ROUND_END_DELAY_KILLREPLAY = 3.0 
const float ROUND_END_FADE_NOKILLREPLAY = 8.0
const float ROUND_END_DELAY_NOKILLREPLAY = 10.0 

void function GameStateEnter_WinnerDetermined()
{	
	thread GameStateEnter_WinnerDetermined_Threaded()
}

void function GameStateEnter_WinnerDetermined_Threaded()
{
	WaitFrame() // wait a frame so other scripts can setup killreplay stuff

	entity replayAttacker = file.roundWinningKillReplayAttacker
	bool doReplay = Replay_IsEnabled() && Evac_IsEnabled() && IsRoundWinningKillReplayEnabled() && IsValid( replayAttacker )
	
	float replayLength = 2.0 // extra delay if no replay
	if ( doReplay )
	{
		replayLength = min( ROUND_WINNING_KILL_REPLAY_LENGTH_OF_REPLAY, Time() - replayAttacker.s.respawnTime ) // 7.5s unless player lifetime < that
		SetServerVar( "roundWinningKillReplayEntHealthFrac", file.roundWinningKillReplayHealthFrac )
	}
	
	foreach ( entity player in GetPlayerArray() )
		thread PlayerWatchesRoundWinningKillReplay( player, doReplay, replayLength )
	
	wait replayLength + ROUND_WINNING_KILL_REPLAY_SCREEN_FADE_TIME
	
	if ( IsRoundBased() )
	{
		svGlobal.levelEnt.Signal( "RoundEnd" )
		SetServerVar( "roundsPlayed", GetServerVar( "roundsPlayed" ) + 1 )
		
		if ( max( GameRules_GetTeamScore( TEAM_IMC ), GameRules_GetTeamScore( TEAM_MILITIA ) ) >= GameMode_GetRoundScoreLimit( GAMETYPE ) )
			SetGameState( eGameState.Postmatch )
		else if ( file.switchSidesBased && !file.hasSwitchedSides )
			SetGameState( eGameState.SwitchingSides )
		else if ( file.usePickLoadoutScreen )
			SetGameState( eGameState.PickLoadout )
		else
			SetGameState ( eGameState.Prematch )
	}
	else
	{
		if ( Evac_IsEnabled() )
			SetGameState( eGameState.Epilogue )
		else
			SetGameState( eGameState.Postmatch )
	}
}

void function PlayerWatchesRoundWinningKillReplay( entity player, bool doReplay, float replayLength )
{
	player.FreezeControlsOnServer()
	
	int winningTeam = GetWinningTeam()
	int announcementSubstr
	if ( winningTeam != TEAM_UNASSIGNED )
		announcementSubstr = player.GetTeam() == winningTeam ? file.announceRoundWinnerWinningSubstr : file.announceRoundWinnerLosingSubstr
		
	if ( IsRoundBased() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_AnnounceRoundWinner", winningTeam, announcementSubstr, ROUND_WINNING_KILL_REPLAY_SCREEN_FADE_TIME, GameRules_GetTeamScore2( TEAM_MILITIA ), GameRules_GetTeamScore2( TEAM_IMC ) )
	else
		Remote_CallFunction_NonReplay( player, "ServerCallback_AnnounceWinner", winningTeam, announcementSubstr, ROUND_WINNING_KILL_REPLAY_SCREEN_FADE_TIME )
		
	if ( IsRoundBased() || !Evac_IsEnabled() ) // if we're doing evac, then no fades or killreplay
	{
		ScreenFadeToBlackForever( player, ROUND_WINNING_KILL_REPLAY_SCREEN_FADE_TIME )
		wait ROUND_WINNING_KILL_REPLAY_SCREEN_FADE_TIME
		
		// do this after screen goes black so people can't see the titan dying
		// don't use .die since that makes explosions and that
		// todo: need a function specifically for cleaning up npcs and stuff on round end, this is imperfect
		if ( IsAlive( player.GetPetTitan() ) )
			player.GetPetTitan().Destroy()
			
		if ( doReplay )
		{
			player.SetPredictionEnabled( false ) // prediction fucks with replays
			
			entity attacker = file.roundWinningKillReplayAttacker
			player.SetKillReplayDelay( Time() - replayLength, THIRD_PERSON_KILL_REPLAY_ALWAYS )
			player.SetKillReplayInflictorEHandle( attacker.GetEncodedEHandle() )
			player.SetKillReplayVictim( file.roundWinningKillReplayVictim )
			player.SetViewIndex( attacker.GetIndexForEntity() )
			player.SetIsReplayRoundWinning( true )
			
			if ( replayLength >= ROUND_WINNING_KILL_REPLAY_LENGTH_OF_REPLAY - 0.5 ) // only do fade if close to full length replay
			{
				// this doesn't work because fades don't work on players that are in a replay, unsure how official servers do this
				wait replayLength - 2.0
				ScreenFadeToBlackForever( player, 2.0 )
	
				wait 2.0
			}
			else
				wait replayLength
		}
		else
			wait replayLength // this will just be extra delay if no replay
			
		player.SetPredictionEnabled( true )
		player.ClearReplayDelay()
		player.ClearViewEntity()
		player.UnfreezeControlsOnServer()
	}
}


// eGameState.SwitchingSides
void function GameStateEnter_SwitchingSides()
{
	thread GameStateEnter_SwitchingSides_Threaded()
}

void function GameStateEnter_SwitchingSides_Threaded()
{
	entity replayAttacker = file.roundWinningKillReplayAttacker
	bool doReplay = Replay_IsEnabled() && IsRoundWinningKillReplayEnabled() && IsValid( replayAttacker ) && !IsRoundBased() // for roundbased modes, we've already done the replay
	
	float replayLength = SWITCHING_SIDES_DELAY_REPLAY // extra delay if no replay
	if ( doReplay )
	{
		replayLength = min( SWITCHING_SIDES_DELAY, Time() - replayAttacker.s.respawnTime ) // 6s unless player lifetime < that
		SetServerVar( "roundWinningKillReplayEntHealthFrac", file.roundWinningKillReplayHealthFrac )
	}
	
	foreach ( entity player in GetPlayerArray() )
		thread PlayerWatchesSwitchingSidesKillReplay( player, doReplay, replayLength )

	wait SWITCHING_SIDES_DELAY_REPLAY + replayLength
	
	file.hasSwitchedSides = true
	SetServerVar( "switchedSides", 1 )
	file.roundWinningKillReplayAttacker = null // reset this after replay
	
	if ( file.usePickLoadoutScreen )
		SetGameState( eGameState.PickLoadout )
	else
		SetGameState ( eGameState.Prematch )
}

void function PlayerWatchesSwitchingSidesKillReplay( entity player, bool doReplay, float replayLength )
{
	player.FreezeControlsOnServer()

	ScreenFadeToBlackForever( player, SWITCHING_SIDES_DELAY_REPLAY ) // automatically cleared 
	wait SWITCHING_SIDES_DELAY_REPLAY
	
	// do this after screen goes black so people can't see the titan dying
	// don't use .die since that makes explosions and that
	if ( IsAlive( player.GetPetTitan() ) )
		player.GetPetTitan().Destroy()
	
	if ( doReplay )
	{
		player.SetPredictionEnabled( false ) // prediction fucks with replays
	
		entity attacker = file.roundWinningKillReplayAttacker
		player.SetKillReplayDelay( Time() - replayLength, THIRD_PERSON_KILL_REPLAY_ALWAYS )
		player.SetKillReplayInflictorEHandle( attacker.GetEncodedEHandle() )
		player.SetKillReplayVictim( file.roundWinningKillReplayVictim )
		player.SetViewIndex( attacker.GetIndexForEntity() )
		player.SetIsReplayRoundWinning( true )
		
		if ( replayLength >= SWITCHING_SIDES_DELAY - 0.5 ) // only do fade if close to full length replay
		{
			// this doesn't work because fades don't work on players that are in a replay, unsure how official servers do this
			wait replayLength - ROUND_WINNING_KILL_REPLAY_SCREEN_FADE_TIME
			ScreenFadeToBlackForever( player, ROUND_WINNING_KILL_REPLAY_SCREEN_FADE_TIME )

			wait ROUND_WINNING_KILL_REPLAY_SCREEN_FADE_TIME
		}
		else
			wait replayLength
	}
	else
		wait SWITCHING_SIDES_DELAY_REPLAY // extra delay if no replay
	
	player.SetPredictionEnabled( true )
	player.ClearReplayDelay()
	player.ClearViewEntity()
	player.UnfreezeControlsOnServer()
}


// eGameState.SuddenDeath
void function GameStateEnter_SuddenDeath()
{
	// disable respawns, suddendeath calling is done on a kill callback
	SetRespawnsEnabled( false )
}

void function GameStateEnter_SuddenDeath_Threaded()
{
	while ( GetGameState() == eGameState.SuddenDeath )
	{
		// todo this really ought to work for ffa in the future
		int imcPlayers
		int militiaPlayers
		
		foreach ( entity player in GetPlayerArray() )
		{
			if ( IsAlive( player ) )
			{
				if ( player.GetTeam() == TEAM_IMC )
					imcPlayers++
				else
					militiaPlayers++
			}
		}
		
		if ( imcPlayers == 0 )
			SetWinner( TEAM_MILITIA )
		else if ( militiaPlayers == 0 )
			SetWinner( TEAM_IMC )
		
		WaitFrame()
	}
}


// eGameState.Postmatch
void function GameStateEnter_Postmatch()
{
	foreach ( entity player in GetPlayerArray() )
	{
		player.FreezeControlsOnServer()
		thread ForceFadeToBlack( player )
	}
		
	thread GameStateEnter_Postmatch_Threaded()
}

void function GameStateEnter_Postmatch_Threaded()
{
	wait GAME_POSTMATCH_LENGTH

	GameRules_EndMatch()
}

void function ForceFadeToBlack( entity player )
{
	// hack until i figure out what deathcam stuff is causing fadetoblacks to be cleared
	while ( true )
	{
		WaitFrame()
		ScreenFadeToBlackForever( player, 0.0 )
	}
}


// shared across multiple gamestates
void function SetSkyCam( entity player )
{
	entity skycam = GetEnt( "skybox_cam_level" )
	
	if ( skycam != null )
		player.SetSkyCamera( skycam )
}

void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if ( !GamePlayingOrSuddenDeath() )
		return

	// set round winning killreplay info here if no custom replaydelay
	if ( file.roundWinningKillReplayTrackPilotKills )
	{
		file.roundWinningKillReplayVictim = victim
		file.roundWinningKillReplayAttacker = attacker
		file.roundWinningKillReplayMethodOfDeath = DamageInfo_GetDamageSourceIdentifier( damageInfo )
		file.roundWinningKillReplayTimeOfDeath = Time()
		file.roundWinningKillReplayHealthFrac = GetHealthFrac( attacker )
	}

	// note: pilotstitans is just win if enemy team runs out of either pilots or titans
	if ( IsPilotEliminationBased() || GetGameState() == eGameState.SuddenDeath )
	{
		if ( GetPlayerArrayOfTeam_Alive( victim.GetTeam() ).len() == 0 )
		{
			// for ffa we need to manually get the last team alive 
			if ( IsFFAGame() )
			{
				array<int> teamsWithLivingPlayers
				foreach ( entity player in GetPlayerArray_Alive() )
				{
					if ( !teamsWithLivingPlayers.contains( player.GetTeam() ) )
						teamsWithLivingPlayers.append( player.GetTeam() )
				}
				
				if ( teamsWithLivingPlayers.len() == 1 )
					SetWinner( teamsWithLivingPlayers[ 0 ], "#GAMEMODE_ENEMY_PILOTS_ELIMINATED", "#GAMEMODE_FRIENDLY_PILOTS_ELIMINATED" )
				else if ( teamsWithLivingPlayers.len() == 0 ) // failsafe: only team was the dead one
					SetWinner( TEAM_UNASSIGNED, "#GAMEMODE_ENEMY_PILOTS_ELIMINATED", "#GAMEMODE_FRIENDLY_PILOTS_ELIMINATED" ) // this is fine in ffa
			}
			else
				SetWinner( GetOtherTeam( victim.GetTeam() ), "#GAMEMODE_ENEMY_PILOTS_ELIMINATED", "#GAMEMODE_FRIENDLY_PILOTS_ELIMINATED" )
		}
	}
	
	if ( ( Riff_EliminationMode() == eEliminationMode.Titans || Riff_EliminationMode() == eEliminationMode.PilotsTitans ) && victim.IsTitan() ) // need an extra check for this
			OnTitanKilled( victim, damageInfo )
}

void function OnTitanKilled( entity victim, var damageInfo )
{
	if ( !GamePlayingOrSuddenDeath() )
		return

	// set round winning killreplay info here if no custom replaydelay
	if ( file.roundWinningKillReplayTrackTitanKills )
	{
		entity attacker = DamageInfo_GetAttacker( damageInfo )
	
		file.roundWinningKillReplayVictim = victim
		file.roundWinningKillReplayAttacker = attacker
		file.roundWinningKillReplayMethodOfDeath = DamageInfo_GetDamageSourceIdentifier( damageInfo )
		file.roundWinningKillReplayTimeOfDeath = Time()
		file.roundWinningKillReplayHealthFrac = GetHealthFrac( attacker )
	}

	// note: pilotstitans is just win if enemy team runs out of either pilots or titans
	if ( IsTitanEliminationBased() )
	{
		int livingTitans
		foreach ( entity titan in GetTitanArrayOfTeam( victim.GetTeam() ) )
			livingTitans++
	
		if ( livingTitans == 0 )
		{
			// for ffa we need to manually get the last team alive 
			if ( IsFFAGame() )
			{
				array<int> teamsWithLivingTitans
				foreach ( entity titan in GetTitanArray() )
				{
					if ( !teamsWithLivingTitans.contains( titan.GetTeam() ) )
						teamsWithLivingTitans.append( titan.GetTeam() )
				}
				
				if ( teamsWithLivingTitans.len() == 1 )
					SetWinner( teamsWithLivingTitans[ 0 ], "#GAMEMODE_ENEMY_TITANS_DESTROYED", "#GAMEMODE_FRIENDLY_TITANS_DESTROYED" )
				else if ( teamsWithLivingTitans.len() == 0 ) // failsafe: only team was the dead one
					SetWinner( TEAM_UNASSIGNED, "#GAMEMODE_ENEMY_TITANS_DESTROYED", "#GAMEMODE_FRIENDLY_TITANS_DESTROYED" ) // this is fine in ffa
			}
			else
				SetWinner( GetOtherTeam( victim.GetTeam() ), "#GAMEMODE_ENEMY_TITANS_DESTROYED", "#GAMEMODE_FRIENDLY_TITANS_DESTROYED" )
		}
	}
}



// stuff for gamemodes to call

void function SetShouldUsePickLoadoutScreen( bool shouldUse )
{
	file.usePickLoadoutScreen = shouldUse
}

void function SetSwitchSidesBased( bool switchSides )
{
	file.switchSidesBased = switchSides
}

void function SetSuddenDeathBased( bool suddenDeathBased )
{
	file.suddenDeathBased = suddenDeathBased
}

void function SetShouldUseRoundWinningKillReplay( bool shouldUse )
{
	SetServerVar( "roundWinningKillReplayEnabled", shouldUse )
}

// is this necessary? idk really
void function SetRoundWinningKillReplayKillClasses( bool pilot, bool titan )
{
	file.roundWinningKillReplayTrackPilotKills = pilot
	file.roundWinningKillReplayTrackTitanKills = titan // player kills in titans should get tracked anyway, might be worth renaming this
}

void function SetRoundWinningKillReplayAttacker( entity target )
{
	file.roundWinningKillReplayAttacker = target
}

void function SetWinner( int team, string winningReason = "", string losingReason = "" )
{	
	SetServerVar( "winningTeam", team )
	
	if ( winningReason.len() == 0 )
		file.announceRoundWinnerWinningSubstr = 0
	else
		file.announceRoundWinnerWinningSubstr = GetStringID( winningReason )
	
	if ( losingReason.len() == 0 )
		file.announceRoundWinnerLosingSubstr = 0
	else
		file.announceRoundWinnerLosingSubstr = GetStringID( losingReason )
	
	if ( IsRoundBased() )
	{	
		if ( team != TEAM_UNASSIGNED )
		{
			GameRules_SetTeamScore( team, GameRules_GetTeamScore( team ) + 1 )
			GameRules_SetTeamScore2( team, GameRules_GetTeamScore2( team ) + 1 )
		}
		
		SetGameState( eGameState.WinnerDetermined )
	}
	else
		SetGameState( eGameState.WinnerDetermined )
}

void function AddTeamScore( int team, int amount )
{
	GameRules_SetTeamScore( team, GameRules_GetTeamScore( team ) + amount )
	GameRules_SetTeamScore2( team, GameRules_GetTeamScore2( team ) + amount )
	
	int scoreLimit
	if ( IsRoundBased() )
		scoreLimit = GameMode_GetRoundScoreLimit( GAMETYPE )
	else
		scoreLimit = GameMode_GetScoreLimit( GAMETYPE )
		
	int score = GameRules_GetTeamScore( team )
	if ( score >= scoreLimit || GetGameState() == eGameState.SuddenDeath )
		SetWinner( team )
	else if ( ( file.switchSidesBased && !file.hasSwitchedSides ) && score >= ( scoreLimit.tofloat() / 2.0 ) )
		SetGameState( eGameState.SwitchingSides )
}

void function SetRoundWinningKillReplayInfo( entity victim, entity attacker, int methodOfDeath, float timeOfDeath ) // can't just pass in a damageinfo because they seem to die over time somehow
{
	file.roundWinningKillReplayVictim = victim
	file.roundWinningKillReplayAttacker = attacker
	file.roundWinningKillReplayMethodOfDeath = methodOfDeath
	file.roundWinningKillReplayTimeOfDeath = timeOfDeath
	if ( attacker != null )
		file.roundWinningKillReplayHealthFrac = GetHealthFrac( attacker )
}

void function SetTimeoutWinnerDecisionFunc( int functionref() callback )
{
	file.timeoutWinnerDecisionFunc = callback
}

// idk

float function GameState_GetTimeLimitOverride()
{
	return 100
}

bool function IsRoundBasedGameOver()
{
	return false
}

bool function ShouldRunEvac()
{
	return true
}

void function GiveTitanToPlayer(entity player)
{

}

float function GetTimeLimit_ForGameMode()
{
	return 100.0
}