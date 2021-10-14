global function BobMap_InitTempProps

void function BobMap_InitTempProps()
{
	PrecacheModel( $"models/vistas/planet_blue_sun.mdl" )
	CreatePropDynamic( $"models/vistas/planet_blue_sun.mdl", GetEnt( "skybox_cam_level" ).GetOrigin(), GetEnt( "skybox_cam_level" ).GetAngles() )
}