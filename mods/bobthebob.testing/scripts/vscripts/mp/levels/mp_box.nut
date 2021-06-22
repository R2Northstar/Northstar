/*global function CodeCallback_MapInit
global function SpawnGamemodeObjects

void function CodeCallback_MapInit()
{
	AddCallback_EntitiesDidLoad( SpawnGamemodeObjects )
}

void function SpawnGamemodeObjects()
{	
	thread SpawnGamemodeObjects_Threaded()

}

void function SpawnGamemodeObjects_Threaded()
{
	WaitEndFrame()
	entity liveFireFlagSpawn = CreateEntity( "script_ref" )
	liveFireFlagSpawn.kv.editorclass = "info_speedball_flag"
	liveFireFlagSpawn.kv.origin = < 0.0, -382.0, 60.0 >
	liveFireFlagSpawn.kv.angles = < 0, 0, 0 >
	DispatchSpawn( liveFireFlagSpawn )
	liveFireFlagSpawn.kv.editorclass = "info_speedball_flag"
}*/