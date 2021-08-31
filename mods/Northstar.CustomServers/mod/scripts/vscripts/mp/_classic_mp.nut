untyped
global function ClassicMp_Init
global function ClassicMP_TryDefaultIntroSetup // called in mp_sh_init
global function ClassicMP_SetCustomIntro
global function ClassicMP_OnIntroStarted
global function ClassicMP_OnIntroFinished
global function ClassicMP_GetIntroLength
global function GetClassicMPMode

struct {
	void functionref() introSetupFunc
	float introLength
} file

void function ClassicMp_Init()
{
	// literally nothing to do here atm lol
}

void function ClassicMP_TryDefaultIntroSetup()
{
	if ( file.introSetupFunc == null )
	{	
		if ( IsFFAGame() )
			ClassicMP_SetCustomIntro( ClassicMP_DefaultNoIntro_Setup, ClassicMP_DefaultNoIntro_GetLength() )
		else
			ClassicMP_SetCustomIntro( ClassicMP_DefaultDropshipIntro_Setup, DROPSHIP_INTRO_LENGTH )
	}

	thread DelayedDoDefaultIntroSetup()
}

void function DelayedDoDefaultIntroSetup()
{
	// wait a frame for CodeCallback_MapInit to run which generally sets custom intros
	WaitFrame()
	file.introSetupFunc()
}

void function ClassicMP_SetCustomIntro( void functionref() setupFunc, float introLength )
{
	file.introSetupFunc = setupFunc
	file.introLength = introLength
}

void function ClassicMP_OnIntroStarted()
{
	print( "started intro!" )
	SetServerVar( "gameStartTime", Time() + file.introLength )
	SetServerVar( "roundStartTime", Time() + file.introLength )
}

void function ClassicMP_OnIntroFinished()
{
	print( "intro finished!" )
	SetGameState( eGameState.Playing )
}

float function ClassicMP_GetIntroLength() 
{
	return file.introLength
}

bool function GetClassicMPMode()
{
	return GetCurrentPlaylistVarInt( "classic_mp", 1 ) == 1
}