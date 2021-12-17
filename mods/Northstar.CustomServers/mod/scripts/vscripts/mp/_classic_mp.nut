untyped
global function ClassicMp_Init
global function ClassicMP_TryDefaultIntroSetup 

// intro setups
global function	ClassicMP_SetLevelIntro
global function ClassicMP_SetCustomIntro
global function ClassicMP_SetupIntro

// intro funcs
global function ClassicMP_OnIntroStarted
global function ClassicMP_OnIntroFinished
global function ClassicMP_GetIntroLength

// epilogue setups
global function ClassicMP_ForceDisableEpilogue
global function ClassicMP_SetEpilogue
global function ClassicMP_SetupEpilogue
global function ClassicMP_ShouldRunEpilogue

global function GetClassicMPMode

struct {
	// level intros have a lower priority than custom intros
	// level intros are used only if a custom intro was not specified
	void functionref() levelIntroSetupFunc
	float levelIntroLength

	void functionref() customIntroSetupFunc
	float customIntroLength
	
	bool epilogueForceDisabled = false
	bool shouldRunEpilogueInRoundBasedMode = false
	void functionref() epilogueSetupFunc
} file

void function ClassicMp_Init()
{
	// default level intros
	if ( IsFFAGame() )
		ClassicMP_SetLevelIntro( ClassicMP_DefaultNoIntro_Setup, ClassicMP_DefaultNoIntro_GetLength() )
	else
		ClassicMP_SetLevelIntro( ClassicMP_DefaultDropshipIntro_Setup, DROPSHIP_INTRO_LENGTH )
}

// stub func, called in mp_sh_init
void function ClassicMP_TryDefaultIntroSetup()
{

}

void function ClassicMP_SetLevelIntro( void functionref() setupFunc, float introLength )
{
	file.levelIntroSetupFunc = setupFunc
	file.levelIntroLength = introLength
}

void function ClassicMP_SetCustomIntro( void functionref() setupFunc, float introLength )
{
	file.customIntroSetupFunc = setupFunc
	file.customIntroLength = introLength
}

void function ClassicMP_SetupIntro()
{
	if ( file.customIntroSetupFunc != null )
		file.customIntroSetupFunc()
	else 
		file.levelIntroSetupFunc()
}

void function ClassicMP_OnIntroStarted()
{
	print( "started intro!" )
	
	float introLength = ClassicMP_GetIntroLength()
	SetServerVar( "gameStartTime", Time() + introLength )
	SetServerVar( "roundStartTime", Time() + introLength )
}

void function ClassicMP_OnIntroFinished()
{
	print( "intro finished!" )
	SetGameState( eGameState.Playing )
}

float function ClassicMP_GetIntroLength() 
{
	if ( file.customIntroSetupFunc != null )
		return file.customIntroLength

	return file.levelIntroLength
}

void function ClassicMP_ForceDisableEpilogue( bool disabled )
{
	file.epilogueForceDisabled = disabled
}

void function ClassicMP_SetEpilogue( void functionref() setupFunc )
{
	file.epilogueSetupFunc = setupFunc
}

void function ClassicMP_SetupEpilogue()
{
	if ( file.epilogueSetupFunc == null ) // default is evac
		ClassicMP_SetEpilogue( EvacEpilogueSetup )
	
	file.epilogueSetupFunc()
}

bool function GetClassicMPMode()
{
	return GetCurrentPlaylistVarInt( "classic_mp", 1 ) == 1
}

bool function ClassicMP_ShouldRunEpilogue()
{
	// note: there is a run_evac playlist var, but it's unused, and default 0, so use a new one
	return !file.epilogueForceDisabled && GetClassicMPMode() && GetCurrentPlaylistVarInt( "run_epilogue", 1 ) == 1
}