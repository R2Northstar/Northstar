global function CodeCallback_MapInit

void function CodeCallback_MapInit()
{
	AddCallback_EntitiesDidLoad( CreateEvacNodes )
}

void function CreateEvacNodes()
{
	AddEvacNode( GetEnt( "evac01" ) )
	AddEvacNode( GetEnt( "evac2" ) )
	AddEvacNode( GetEnt( "evac3" ) )
	AddEvacNode( GetEnt( "evac4" ) )
	AddEvacNode( GetEnt( "evac5" ) )
	AddEvacNode( GetEnt( "evac6" ) )
	AddEvacNode( GetEnt( "evac7" ) )

	SetEvacSpaceNode( GetEnt( "intro_spacenode" ) )

	// spectator cams
	array<vector> positions = [
		Vector( -475.129913, 1480.167847, 527.363953 ),
		Vector( 1009.315186, 3999.888916, 589.914917 ),
		Vector( 2282.868896, -1363.706543, 846.18866 ),
		Vector( 1911.771606, -752.053101, 664.741821 ),
		Vector( 1985.563232, -1205.455078, 677.444763 ),
		Vector( -59.625496, -1858.108887, 811.592407 ),
		Vector( -1035.991211, -671.11438, 824.180908 )
	]
	array<vector> angles = [
		Vector( 8.84156, 219.338501, 0 ),
		Vector( 22.109896, -40.449619, 0 ),
		Vector( 23.945116, -146.680725, -0.0 ),
		Vector( 9.95526, 138.721191, 0.0 ),
		Vector( 13.809734, -239.877441, 0.0 ),
		Vector( 20.55629, -252.775146, 0.0 ),
		Vector( 16.220453, -24.51107, 0.0 )
	]

	for ( int i = 0; i < positions.len(); i++ )
	{
		entity spec_cam = CreateEntity( "info_target" )

		spec_cam.SetOrigin( positions[ i ] )
		spec_cam.SetAngles( angles[ i ] )
		spec_cam.kv.spawnFlags = SF_INFOTARGET_ALWAYS_TRANSMIT_TO_CLIENT

		DispatchSpawn( spec_cam )

		SetTargetName( spec_cam, "spec_cam" + ( i + 1 ) )

		spec_cam.DisableHibernation()
	}
}
