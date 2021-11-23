global function CodeCallback_MapInit

void function CodeCallback_MapInit()
{
	AddCallback_EntitiesDidLoad( InitComplexRings )
}

void function InitComplexRings()
{
	entity rings = GetEntByScriptName( "rings_pristine" )
	thread PlayAnim( rings, "animated_slow" )
}