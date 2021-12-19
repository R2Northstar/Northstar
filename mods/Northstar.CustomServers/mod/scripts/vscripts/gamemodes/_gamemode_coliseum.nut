untyped

global function GamemodeColiseum_Init
global function GamemodeColiseum_CustomIntro

// outro anims
// winner anims are for the winner, loser anims are for the loser
const array< array<string> > OUTROANIMS_WINNER = [
	[ "pt_coliseum_winner_gunkick", "pt_coliseum_winner_compassion", "pt_coliseum_winner_drinking" ], // winner lost 0 rounds
	[ "pt_coliseum_winner_respect", "pt_coliseum_winner_headlock", "pt_coliseum_winner_authority" ], // winner lost 1 round
	[ "pt_coliseum_winner_punch", "pt_coliseum_winner_kick", "pt_coliseum_winner_stomp" ] // winner lost 2 rounds
]

const array< array<string> > OUTROANIMS_LOSER = [
	[ "pt_coliseum_loser_gunkick", "pt_coliseum_loser_compassion", "pt_coliseum_loser_drinking" ], // winner lost 0 rounds
    [ "pt_coliseum_loser_respect", "pt_coliseum_loser_headlock", "pt_coliseum_loser_authority" ], // winner lost 1 round
    [ "pt_coliseum_loser_punch", "pt_coliseum_loser_kick", "pt_coliseum_loser_stomp" ], // winner lost 2 rounds
]

struct {
	bool hasShownIntroScreen
} file

void function GamemodeColiseum_Init()
{
	// gamemode settings
	SetRoundBased( true )
	SetRespawnsEnabled( false )
	SetShouldUseRoundWinningKillReplay( true )
	Riff_ForceTitanAvailability( eTitanAvailability.Never )
	Riff_ForceBoostAvailability( eBoostAvailability.Disabled )
	Riff_ForceSetEliminationMode( eEliminationMode.Pilots )
	SetLoadoutGracePeriodEnabled( false ) // prevent modifying loadouts with grace period
	
	ClassicMP_SetCustomIntro( ClassicMP_DefaultNoIntro_Setup, ClassicMP_DefaultNoIntro_GetLength() )
	AddCallback_GameStateEnter( eGameState.Prematch, ShowColiseumIntroScreen )
	AddCallback_OnPlayerRespawned( GivePlayerColiseumLoadout )
	
	ClassicMP_SetEpilogue( SetupColiseumEpilogue )
}

// stub function referenced in sh_gamemodes_mp
void function GamemodeColiseum_CustomIntro( entity player )
{
}

void function ShowColiseumIntroScreen()
{
	if ( !file.hasShownIntroScreen )
		thread ShowColiseumIntroScreenThreaded()
	
	file.hasShownIntroScreen = true
}

void function ShowColiseumIntroScreenThreaded()
{
	wait 5

	foreach ( entity player in GetPlayerArray() )
	{
		array<entity> otherTeam = GetPlayerArrayOfTeam( GetOtherTeam( player.GetTeam() ) )
		
		int winstreak = 0
		int wins = 0 
		int losses = 0
		
		if ( otherTeam.len() != 0 )
		{
			entity enemy = otherTeam[ 0 ]
		
			winstreak = enemy.GetPersistentVarAsInt( "coliseumWinStreak" )
			wins = enemy.GetPersistentVarAsInt( "coliseumTotalWins" )
			losses = enemy.GetPersistentVarAsInt( "coliseumTotalLosses" )
		}
	
		Remote_CallFunction_NonReplay( player, "ServerCallback_ColiseumIntro", winstreak, wins, losses ) // stub numbers atm because lazy
	}
}

void function GivePlayerColiseumLoadout( entity player )
{
	if ( GetCurrentPlaylistVarInt( "coliseum_loadouts_enabled", 1 ) == 0 )
		return

	// create loadout struct
	PilotLoadoutDef coliseumLoadout = clone GetActivePilotLoadout( player )
	
	/* from playlists.txt
	coliseum_primary 						"mp_weapon_lstar"
    coliseum_primary_attachment				""
    coliseum_primary_mod1					""
    coliseum_primary_mod2					""
    coliseum_primary_mod3					""
    coliseum_secondary 						"mp_weapon_softball"
    coliseum_secondary_mod1					""
    coliseum_secondary_mod2					""
    coliseum_secondary_mod3					""
    coliseum_weapon3 						""
    coliseum_weapon3_mod1					""
    coliseum_weapon3_mod2					""
    coliseum_weapon3_mod3					""
    coliseum_melee							"melee_pilot_emptyhanded"
    coliseum_special						"mp_ability_heal"
    coliseum_ordnance						"mp_weapon_frag_drone"
    coliseum_passive1						"pas_fast_health_regen"
    coliseum_passive2						"pas_wallhang"*/
		
	coliseumLoadout.primary = GetColiseumItem( "primary" )
	coliseumLoadout.primaryMods = [ GetColiseumItem( "primary_attachment" ), GetColiseumItem( "primary_mod1" ), GetColiseumItem( "primary_mod2" ), GetColiseumItem( "primary_mod3" ) ]
	coliseumLoadout.primaryAttachments = [] // will likely crash if we dont do this
	                                                                         
	coliseumLoadout.secondary = GetColiseumItem( "secondary" )               
	coliseumLoadout.secondaryMods = [ GetColiseumItem( "secondary_mod1" ), GetColiseumItem( "secondary_mod2" ), GetColiseumItem( "secondary_mod3" ) ]
	
	coliseumLoadout.weapon3 = GetColiseumItem( "weapon3" )
	coliseumLoadout.weapon3Mods = [ GetColiseumItem( "weapon3_mod1" ), GetColiseumItem( "weapon3_mod2" ), GetColiseumItem( "weapon3_mod3" ) ]
	
	coliseumLoadout.melee = GetColiseumItem( "melee" )
	coliseumLoadout.special = GetColiseumItem( "special" )
	coliseumLoadout.ordnance = GetColiseumItem( "ordnance" )
	coliseumLoadout.passive1 = GetColiseumItem( "passive1" )
	coliseumLoadout.passive2 = GetColiseumItem( "passive2" )
	
	coliseumLoadout.setFile = GetSuitAndGenderBasedSetFile( "coliseum", coliseumLoadout.race == RACE_HUMAN_FEMALE ? "female" : "male" )
	
	GivePilotLoadout( player, coliseumLoadout )
}

string function GetColiseumItem( string name )
{
	return expect string ( GetCurrentPlaylistVar( "coliseum_" + name ) )
}

void function SetupColiseumEpilogue()
{
	AddCallback_GameStateEnter( eGameState.Epilogue, RunColiseumOutro )
}

void function RunColiseumOutro()
{
	// also since this runs on game end, do winstreak stuff
	foreach ( entity player in GetPlayerArray() )
	{
		if ( GetWinningTeam() == player.GetTeam() )
		{
			player.SetPersistentVar( "coliseumTotalWins", player.GetPersistentVarAsInt( "coliseumTotalWins" ) + 1 )
			player.SetPersistentVar( "coliseumWinStreak", player.GetPersistentVarAsInt( "coliseumWinStreak" ) + 1 )
		}
		else
		{
			player.SetPersistentVar( "coliseumTotalWins", maxint( player.GetPersistentVarAsInt( "coliseumTotalWins" ) - 1, 0 ) )
			player.SetPersistentVar( "coliseumWinStreak", 0 )
		}
	}

	entity outroAnimPoint = GetEnt( "intermission" )
	array<entity> winningPlayers = GetPlayerArrayOfTeam( GetWinningTeam() )
	
	if ( GetPlayerArray().len() > 0 && IsValid( outroAnimPoint ) && GetWinningTeam() != -1 && winningPlayers.len() != 0 ) // this will fail if we don't have players or a spot to do it
		thread RunColiseumOutroThreaded( outroAnimPoint.GetOrigin(), winningPlayers[ 0 ] )
	else
		SetGameState( eGameState.Postmatch )
}

void function RunColiseumOutroThreaded( vector point, entity winningPlayer )
{
	OnThreadEnd( function() : ()
	{
		SetGameState( eGameState.Postmatch )
	})
	
	winningPlayer.EndSignal( "OnDestroy" )

	// pick winner and loser anims
	int numLost = GameRules_GetTeamScore( GetOtherTeam( GetWinningTeam() ) )
	int animIndex = RandomInt( OUTROANIMS_WINNER[ numLost ].len() )
	string winnerAnim = OUTROANIMS_WINNER[ numLost ][ animIndex ]
	string loserAnim = OUTROANIMS_LOSER[ numLost ][ animIndex ]
	
	foreach ( entity player in GetPlayerArray() )
	{
		if ( !IsAlive( player ) )
			player.RespawnPlayer( null )
		
		AddCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD )
		ScreenFadeFromBlack( player, 0.5 )
		player.SetOrigin( point )
		player.SetNameVisibleToEnemy( false )
		player.SetNameVisibleToFriendly( false )
		// for some reason this just doesn't use the mp music system, so have to manually play this
		// odd game
		EmitSoundOnEntityOnlyToPlayer( player, player, "music_mp_speedball_game_win" )
				
		FirstPersonSequenceStruct outroSequence
		outroSequence.thirdPersonCameraAttachments = [ "VDU" ]
		outroSequence.blendTime = 0.25
		outroSequence.attachment = "ref"
		outroSequence.enablePlanting = true
		outroSequence.playerPushable = false
		
		// for when we kill any active weapons if not needed for anim
		entity playerWeapon = player.GetActiveWeapon()
		
		if ( player.GetTeam() == GetWinningTeam() )
		{
			if ( IsValid( playerWeapon ) )
				playerWeapon.Destroy()
		
			outroSequence.thirdPersonAnim = winnerAnim
			outroSequence.noParent = true
			outroSequence.gravity = true
			thread FirstPersonSequence( outroSequence, player )
		}
		else
		{
			// need weapon for this anim in particular
			if ( IsValid( playerWeapon ) && loserAnim != "pt_coliseum_loser_gunkick" )
				playerWeapon.Destroy()
		
			outroSequence.thirdPersonAnim = loserAnim
			outroSequence.useAnimatedRefAttachment = true
			thread FirstPersonSequence( outroSequence, player, winningPlayer )
		}
	}

	// all outro anims should be the same length ideally
	wait winningPlayer.GetSequenceDuration( winnerAnim ) - 0.75
	
	foreach ( entity player in GetPlayerArray() )
		ScreenFadeToBlackForever( player, 0.75 )
	
	wait 0.75
}