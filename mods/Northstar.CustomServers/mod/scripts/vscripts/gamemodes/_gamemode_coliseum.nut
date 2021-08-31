untyped

global function GamemodeColiseum_Init
global function GamemodeColiseum_CustomIntro

bool hasShownIntroScreen = false

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
	SetWeaponDropsEnabled( false )
	
	ClassicMP_SetCustomIntro( ClassicMP_DefaultNoIntro_Setup, ClassicMP_DefaultNoIntro_GetLength() )
	AddCallback_GameStateEnter( eGameState.Prematch, ShowColiseumIntroScreen )
	AddCallback_OnPlayerRespawned( GivePlayerColiseumLoadout )
}

// stub function referenced in sh_gamemodes_mp
void function GamemodeColiseum_CustomIntro( entity player )
{}

void function ShowColiseumIntroScreen()
{
	if ( !hasShownIntroScreen )
		thread ShowColiseumIntroScreenThreaded()
	
	hasShownIntroScreen = true
}

void function ShowColiseumIntroScreenThreaded()
{
	wait 5

	foreach ( entity player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player,  "ServerCallback_ColiseumIntro", 1, 1, 1 ) // stub numbers atm because lazy
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

// todo this needs the outro: unsure what anims it uses