untyped
global function CodeCallback_MapInit

const float PLATFORM_TRAVEL_TIME = 20.0

struct {
	array<entity> platformMoverNodes
	entity platformMover
} file

void function CodeCallback_MapInit()
{
	AddCallback_EntitiesDidLoad( BobMap_EntitiesDidLoad )
}

void function BobMap_EntitiesDidLoad()
{
	BobMap_InitTempProps()
	
	file.platformMoverNodes = GetEntityLinkChain( GetEntByScriptName( "mp_bob_movingplatform_node_0" ) )
	file.platformMover = GetEntByScriptName( "mp_bob_movingplatform" )
	file.platformMover.SetOrigin( file.platformMoverNodes[ 0 ].GetOrigin() )
	
	entity platformProp = CreatePropDynamic( file.platformMover.GetValueForModelKey(), file.platformMover.GetOrigin(), file.platformMover.GetAngles() )
	platformProp.SetParent( file.platformMover )
	
	thread MovingPlatformThink()
}

void function MovingPlatformThink()
{
	int currentNodeIdx = 0
	while ( true )
	{
		file.platformMover.SetOrigin( file.platformMoverNodes[ currentNodeIdx % file.platformMoverNodes.len() ].GetOrigin() )
		file.platformMover.MoveTo( file.platformMoverNodes[ ++currentNodeIdx % file.platformMoverNodes.len() ].GetOrigin(), PLATFORM_TRAVEL_TIME, 0, 0 )
	}
}