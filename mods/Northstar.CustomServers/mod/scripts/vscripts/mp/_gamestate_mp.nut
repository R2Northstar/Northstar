untyped

global function PIN_GameStart
global function SetGameState
global function GameState_EntitiesDidLoad
global function WaittillGameStateOrHigher
global function AddCallback_OnRoundEndCleanup

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
		
	float roundWinningKillReplayTime
	entity roundWinningKillReplayVictim
	entity roundWinningKillReplayAttacker
	int roundWinningKillReplayMethodOfDeath
	float roundWinningKillReplayTimeOfDeath
	float roundWinningKillReplayHealthFrac
	
	array<void functionref()> roundEndCleanupCallbacks
} file

void function PIN_GameStart()
{
	// todo: using the pin telemetry function here, weird and was done veeery early on before i knew how this all worked, should use a different one

	// called from InitGameState
	//FlagInit( "ReadyToStartMatch" )
	
	SetServerVar( "switchedSides", 0 )
	SetServerVar( "winningTeam", -1 )
		
	AddCallback_GameStateEnter( eGameState.WaitingForCustomStart, GameStateEnter_WaitingForCustomStart )
	AddCallback_GameStateEnter( eGameState.WaitingForPlayers, GameStateEnter_WaitingForPlayers )
	AddCallback_OnClientConnected( WaitingForPlayers_ClientConnected )
	
	AddCallback_GameStateEnter( eGameState.PickLoadout, GameStateEnter_PickLoadout )
	AddCallback_GameStateEnter( eGameState.Prematch, GameStateEnter_Prematch )
	AddCallback_GameStateEnter( eGameState.Playing, GameStateEnter_Playing )
	AddCallback_GameStateEnter( eGameState.WinnerDetermined, GameStateEnter_WinnerDetermined )
	AddCallback_GameStateEnter( eGameState.SwitchingSides, GameStateEnter_SwitchingSides )
	AddCallback_GameStateEnter( eGameState.SuddenDeath, GameStateEnter_SuddenDeath )
	AddCallback_GameStateEnter( eGameState.Postmatch, GameStateEnter_Postmatch )
	
	AddCallback_OnPlayerKilled( OnPlayerKilled )
	AddDeathCallback( "npc_titan", OnTitanKilled )
	
	RegisterSignal( "CleanUpEntitiesForRoundEnd" )
}

void function SetGameState( int newState )
{
	if ( newState == GetGameState() )
		return

	SetServerVar( "gameStateChangeTime", Time() )
	SetServerVar( "gameState", newState )
	svGlobal.levelEnt.Signal( "GameStateChanged" )

	// added in AddCallback_GameStateEnter
	foreach ( callbackFunc in svGlobal.gameStateEnterCallbacks[ newState ] )
		callbackFunc()
}

void function GameState_EntitiesDidLoad()
{
	if ( GetClassicMPMode() )
		ClassicMP_SetupIntro()
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
		
	thread WaitForPlayers() // like 90% sure there should be a way to get number of loading clients on server but idk it
}

void function WaitForPlayers( )
{
	// note: atm if someone disconnects as this happens the game will just wait forever
	float endTime = Time() + 30.0
	
	while ( ( GetPendingClientsCount() != 0 && endTime > Time() ) || GetPlayerArray().len() == 0 )
		WaitFrame()
	
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
	
	if ( !GetClassicMPMode() )
		thread StartGameWithoutClassicMP()
}

void function StartGameWithoutClassicMP()
{
	foreach ( entity player in GetPlayerArray() )
		if ( IsAlive( player ) )
			player.Die()

	WaitFrame() // wait for callbacks to finish
	
	// need these otherwise game will complain
	SetServerVar( "gameStartTime", Time() )
	SetServerVar( "roundStartTime", Time() )
	
	foreach ( entity player in GetPlayerArray() )
	{
		RespawnAsPilot( player )
		ScreenFadeFromBlack( player, 0 )
	}
	
	SetGameState( eGameState.Playing )
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
				winningTeam = GetWinningTeam()
			
			if ( winningTeam == -1 )
				winningTeam = TEAM_UNASSIGNED 
			
			if ( file.switchSidesBased && !file.hasSwitchedSides && !IsRoundBased() ) // in roundbased modes, we handle this in setwinner
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
	// do win announcement
	int winningTeam = GetWinningTeam()
	if ( winningTeam == -1 )
		winningTeam = TEAM_UNASSIGNED
		
	foreach ( entity player in GetPlayerArray() )
	{
		int announcementSubstr
		if ( winningTeam != TEAM_UNASSIGNED )
			announcementSubstr = player.GetTeam() == winningTeam ? file.announceRoundWinnerWinningSubstr : file.announceRoundWinnerLosingSubstr
	
		if ( IsRoundBased() )
			Remote_CallFunction_NonReplay( player, "ServerCallback_AnnounceRoundWinner", winningTeam, announcementSubstr, ROUND_WINNING_KILL_REPLAY_SCREEN_FADE_TIME, GameRules_GetTeamScore2( TEAM_MILITIA ), GameRules_GetTeamScore2( TEAM_IMC ) )
		else
			Remote_CallFunction_NonReplay( player, "ServerCallback_AnnounceWinner", winningTeam, announcementSubstr, ROUND_WINNING_KILL_REPLAY_SCREEN_FADE_TIME )
	}
	
	WaitFrame() // wait a frame so other scripts can setup killreplay stuff

	entity replayAttacker = file.roundWinningKillReplayAttacker
	bool doReplay = Replay_IsEnabled() && IsRoundWinningKillReplayEnabled() && IsValid( replayAttacker )
				 && Time() - file.roundWinningKillReplayTime <= ROUND_WINNING_KILL_REPLAY_LENGTH_OF_REPLAY
 	
	float replayLength = 2.0 // extra delay if no replay
	if ( doReplay )
	{
		bool killcamsWereEnabled = KillcamsEnabled()
		if ( killcamsWereEnabled ) // dont want killcams to interrupt stuff
			SetKillcamsEnabled( false )
	
		replayLength = ROUND_WINNING_KILL_REPLAY_LENGTH_OF_REPLAY
		if ( "respawnTime" in replayAttacker.s && Time() - replayAttacker.s.respawnTime < replayLength )
			replayLength += Time() - expect float ( replayAttacker.s.respawnTime )
		
		SetServerVar( "roundWinningKillReplayEntHealthFrac", file.roundWinningKillReplayHealthFrac )
		
		foreach ( entity player in GetPlayerArray() )
			thread PlayerWatchesRoundWinningKillReplay( player, replayLength )
	
		wait ROUND_WINNING_KILL_REPLAY_SCREEN_FADE_TIME
		CleanUpEntitiesForRoundEnd() // fade should be done by this point, so cleanup stuff now when people won't see
		wait replayLength 
		
		WaitFrame() // prevent a race condition with PlayerWatchesRoundWinningKillReplay
		file.roundWinningKillReplayAttacker = null // clear this
		
		if ( killcamsWereEnabled )
			SetKillcamsEnabled( true )
	}
	else if ( IsRoundBased() || !ClassicMP_ShouldRunEpilogue() )
	{
		// these numbers are temp and should really be based on consts of some kind
		foreach( entity player in GetPlayerArray() )
		{
			player.FreezeControlsOnServer()
			ScreenFadeToBlackForever( player, 4.0 )
		}
		
		wait ROUND_WINNING_KILL_REPLAY_LENGTH_OF_REPLAY
		CleanUpEntitiesForRoundEnd() // fade should be done by this point, so cleanup stuff now when people won't see
		
		foreach( entity player in GetPlayerArray() )
			player.UnfreezeControlsOnServer()
	}
	
	if ( IsRoundBased() )
	{
		svGlobal.levelEnt.Signal( "RoundEnd" )
		int roundsPlayed = expect int ( GetServerVar( "roundsPlayed" ) )
		SetServerVar( "roundsPlayed", roundsPlayed + 1 )
		
		int winningTeam = GetWinningTeam()
		if ( winningTeam == -1 )
			winningTeam = TEAM_UNASSIGNED 
		
		int highestScore = GameRules_GetTeamScore( winningTeam )
		int roundScoreLimit = GameMode_GetRoundScoreLimit( GAMETYPE )
		
		if ( highestScore >= roundScoreLimit )
		{
			if ( ClassicMP_ShouldRunEpilogue() )
			{
				ClassicMP_SetupEpilogue()
				SetGameState( eGameState.Epilogue )
			}
			else
				SetGameState( eGameState.Postmatch )
		}
		else if ( file.switchSidesBased && !file.hasSwitchedSides && highestScore >= ( roundScoreLimit.tofloat() / 2.0 ) ) // round up
			SetGameState( eGameState.SwitchingSides ) // note: switchingsides will handle setting to pickloadout and prematch by itself
		else if ( file.usePickLoadoutScreen )
			SetGameState( eGameState.PickLoadout )
		else
			SetGameState ( eGameState.Prematch )
	}
	else
	{
		if ( ClassicMP_ShouldRunEpilogue() )
		{
			ClassicMP_SetupEpilogue()
			SetGameState( eGameState.Epilogue )
		}
		else
			SetGameState( eGameState.Postmatch )
	}
}

void function PlayerWatchesRoundWinningKillReplay( entity player, float replayLength )
{
	// end if player dcs 
	player.EndSignal( "OnDestroy" )
	
	player.FreezeControlsOnServer()
	ScreenFadeToBlackForever( player, ROUND_WINNING_KILL_REPLAY_SCREEN_FADE_TIME )
	wait ROUND_WINNING_KILL_REPLAY_SCREEN_FADE_TIME
	
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
		
	player.SetPredictionEnabled( true )
	player.ClearReplayDelay()
	player.ClearViewEntity()
	player.UnfreezeControlsOnServer()
}


// eGameState.SwitchingSides
void function GameStateEnter_SwitchingSides()
{
	thread GameStateEnter_SwitchingSides_Threaded()
}

void function GameStateEnter_SwitchingSides_Threaded()
{
	bool killcamsWereEnabled = KillcamsEnabled()
	if ( killcamsWereEnabled ) // dont want killcams to interrupt stuff
		SetKillcamsEnabled( false )
		
	WaitFrame() // wait a frame so callbacks can set killreplay info

	entity replayAttacker = file.roundWinningKillReplayAttacker
	bool doReplay = Replay_IsEnabled() && IsRoundWinningKillReplayEnabled() && IsValid( replayAttacker ) && !IsRoundBased() // for roundbased modes, we've already done the replay
				 && Time() - file.roundWinningKillReplayTime <= SWITCHING_SIDES_DELAY
	
	float replayLength = SWITCHING_SIDES_DELAY_REPLAY // extra delay if no replay
	if ( doReplay )
	{		
		replayLength = SWITCHING_SIDES_DELAY
		if ( "respawnTime" in replayAttacker.s && Time() - replayAttacker.s.respawnTime < replayLength )
			replayLength += Time() - expect float ( replayAttacker.s.respawnTime )
			
		SetServerVar( "roundWinningKillReplayEntHealthFrac", file.roundWinningKillReplayHealthFrac )
	}
	
	foreach ( entity player in GetPlayerArray() )
		thread PlayerWatchesSwitchingSidesKillReplay( player, doReplay, replayLength )

	wait SWITCHING_SIDES_DELAY_REPLAY
	CleanUpEntitiesForRoundEnd() // fade should be done by this point, so cleanup stuff now when people won't see
	wait replayLength
	
	if ( killcamsWereEnabled )
		SetKillcamsEnabled( true )
	
	file.hasSwitchedSides = true
	svGlobal.levelEnt.Signal( "RoundEnd" ) // might be good to get a new signal for this? not 100% necessary tho i think
	SetServerVar( "switchedSides", 1 )
	file.roundWinningKillReplayAttacker = null // reset this after replay
	
	if ( file.usePickLoadoutScreen )
		SetGameState( eGameState.PickLoadout )
	else
		SetGameState ( eGameState.Prematch )
}

void function PlayerWatchesSwitchingSidesKillReplay( entity player, bool doReplay, float replayLength )
{
	player.EndSignal( "OnDestroy" )
	player.FreezeControlsOnServer()

	ScreenFadeToBlackForever( player, SWITCHING_SIDES_DELAY_REPLAY ) // automatically cleared 
	wait SWITCHING_SIDES_DELAY_REPLAY
	
	if ( doReplay )
	{
		player.SetPredictionEnabled( false ) // prediction fucks with replays
	
		// delay seems weird for switchingsides? ends literally the frame the flag is collected
	
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
	// todo: check if this is still necessary
	player.EndSignal( "OnDestroy" )

	// hack until i figure out what deathcam stuff is causing fadetoblacks to be cleared
	while ( true )
	{
		WaitFrame()
		ScreenFadeToBlackForever( player, 0.0 )
	}
}


// shared across multiple gamestates

void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if ( !GamePlayingOrSuddenDeath() )
		return

	// set round winning killreplay info here if we're tracking pilot kills
	// todo: make this not count environmental deaths like falls, unsure how to prevent this
	if ( file.roundWinningKillReplayTrackPilotKills && victim != attacker && attacker != svGlobal.worldspawn && IsValid( attacker ) )
	{
		file.roundWinningKillReplayTime = Time()
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

	// set round winning killreplay info here if we're tracking titan kills
	// todo: make this not count environmental deaths like falls, unsure how to prevent this
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( file.roundWinningKillReplayTrackTitanKills && victim != attacker && attacker != svGlobal.worldspawn && IsValid( attacker ) )
	{
		file.roundWinningKillReplayTime = Time()
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

void function AddCallback_OnRoundEndCleanup( void functionref() callback )
{
	file.roundEndCleanupCallbacks.append( callback )
}

void function CleanUpEntitiesForRoundEnd()
{
	// this function should clean up any and all entities that need to be removed between rounds, ideally at a point where it isn't noticable to players
	SetPlayerDeathsHidden( true ) // hide death sounds and such so people won't notice they're dying
	
	foreach ( entity player in GetPlayerArray() )
	{
		ClearTitanAvailable( player )
		
		if ( IsAlive( player ) )
			player.Die( svGlobal.worldspawn, svGlobal.worldspawn, { damageSourceId = eDamageSourceId.round_end } )
		
		if ( IsAlive( player.GetPetTitan() ) )
			player.GetPetTitan().Destroy()
	}
	
	foreach ( entity npc in GetNPCArray() )
		if ( IsValid( npc ) )
			npc.Destroy() // need this because getnpcarray includes the pettitans we just killed at this point
	
	// destroy weapons
	ClearDroppedWeapons()
		
	foreach ( entity battery in GetEntArrayByClass_Expensive( "item_titan_battery" ) )
		battery.Destroy()
	
	// allow other scripts to clean stuff up too
	svGlobal.levelEnt.Signal( "CleanUpEntitiesForRoundEnd" ) 
	foreach ( void functionref() callback in file.roundEndCleanupCallbacks )
		callback()
	
	SetPlayerDeathsHidden( false )
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

void function SetRoundWinningKillReplayKillClasses( bool pilot, bool titan )
{
	file.roundWinningKillReplayTrackPilotKills = pilot
	file.roundWinningKillReplayTrackTitanKills = titan // player kills in titans should get tracked anyway, might be worth renaming this
}

void function SetRoundWinningKillReplayAttacker( entity attacker )
{
	file.roundWinningKillReplayTime = Time()
	file.roundWinningKillReplayHealthFrac = GetHealthFrac( attacker )
	file.roundWinningKillReplayAttacker = attacker
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
	
	if ( GamePlayingOrSuddenDeath() )
	{
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

void function GiveTitanToPlayer( entity player )
{

}

float function GetTimeLimit_ForGameMode()
{
	return 100.0
}