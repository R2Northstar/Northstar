untyped

global function VR_Init
global function VR_GroundTroopsDeathCallback

struct {
	string vr_settings = ""
} file

function VR_Init( string settings = "", bool enableDropships = false )
{
	if ( reloadingScripts )
		return

	if ( !enableDropships )
		FlagSet( "DisableDropships" )

	file.vr_settings = settings

	//AddDeathCallback( "npc_soldier", VR_GroundTroopsDeathCallback )
	//AddDeathCallback( "npc_spectre", VR_GroundTroopsDeathCallback )
	//AddDeathCallback( "npc_marvin", VR_GroundTroopsDeathCallback )
	//AddDeathCallback( "player", VR_GroundTroopsDeathCallback )
	AddCallback_EntitiesDidLoad( EntitiesDidLoad )
}

void function EntitiesDidLoad()
{
	if ( file.vr_settings.find( "no_evac" ) != null )
		svGlobal.evacEnabled = false

	if ( file.vr_settings.find( "no_npc" ) != null )
	{
		disable_npcs()
	}

	if ( file.vr_settings.find( "no_titan" ) != null )
	{
		Riff_ForceTitanAvailability( eTitanAvailability.Never )
		FlagSet( "PilotBot" )
	}
}

void function VR_GroundTroopsDeathCallback( entity guy, var damageInfo )
{
	EmitSoundAtPosition( TEAM_UNASSIGNED, guy.GetOrigin(), "Object_Dissolve" )

	if ( ShouldDoDissolveDeath( guy, damageInfo ) )
		guy.Dissolve( ENTITY_DISSOLVE_CHAR, Vector( 0, 0, 0 ), 0 )
}

function ShouldDoDissolveDeath( guy, damageInfo )
{
	if ( !guy.IsPlayer() )
		return true

	// can't dissolve players when they're not playing the game, otherwise when the game starts again they're invisible
	local gs = GetGameState()
	if ( gs != eGameState.Playing && gs != eGameState.SuddenDeath && gs != eGameState.Epilogue )
	{
		printt( "Skipping player dissolve death because game is not active ( player:", guy, ")" )
		return false
	}

	return true
}