untyped
global function CodeCallback_MapInit

struct {
	bool introStartTime
} file

void function CodeCallback_MapInit()
{
	AddEvacNode( GetEnt( "evac_location1" ) )
	AddEvacNode( GetEnt( "evac_location2" ) )
	AddEvacNode( GetEnt( "evac_location3" ) )
	AddEvacNode( GetEnt( "evac_location4" ) )
	
	SetEvacSpaceNode( GetEnt( "end_spacenode" ) )
	
	// currently disabled: intro
	// if ( !IsFFAGame() )
	// 	ClassicMP_SetLevelIntro( WargamesIntroSetup, 25.0 )
}

// intro stuff
void function WargamesIntroSetup()
{
	AddCallback_OnClientConnected( WargamesIntro_OnClientConnected )
	AddCallback_OnClientDisconnected( WargamesIntro_OnClientDisconnected )
	
	AddCallback_GameStateEnter( eGameState.Prematch, OnPrematchStart )
}

void function WargamesIntro_OnClientConnected( entity player )
{

}

void function WargamesIntro_OnClientDisconnected( entity player )
{

}

void function OnPrematchStart()
{
	ClassicMP_OnIntroStarted()
	file.introStartTime = Time()
}