untyped

global function ToneController_Init

global function UpdateToneSettings

global function SetAutoExposureMin
global function SetAutoExposureMax
global function SetAutoExposureCompensation
global function SetAutoExposureCompensationBias
global function SetAutoExposureRate
global function UseDefaultAutoExposure
global function SetBloomScale

function ToneController_Init()
{
	level.toneController <- CreateEntity( "env_tonemap_controller" )
	DispatchSpawn( level.toneController )

	AddCallback_EntitiesDidLoad( UpdateToneSettings )
}

void function UpdateToneSettings()
{
	string mapName = GetMapName()

	UseDefaultAutoExposure()

	switch ( mapName )
	{
		case "mp_angel_city":
			SetAutoExposureMin( 1.11 )
			SetAutoExposureMax( 1.5 )
			break;

		case "mp_boneyard":
			SetAutoExposureMin( 1.3 )
			SetAutoExposureMax( 2.3 )
			break;

		case "mp_lagoon":
			SetAutoExposureMin( 0.8 )
			SetAutoExposureMax( 2.0 )
			break;

		case "mp_o2":
			SetAutoExposureMin( 1.0 )
			SetAutoExposureMax( 2.0 )
			break;

		case "mp_fracture":
			SetAutoExposureMin( 1.25 )
			SetAutoExposureMax( 4.0 )
			break;

		case "mp_training_ground":
			SetAutoExposureMin( 0.6 )
			SetAutoExposureMax( 2.5 )
			break;

		case "mp_relic":
			SetAutoExposureMin( 0.9 )
			SetAutoExposureMax( 2.0 )
			break;

		case "mp_smugglers_cove":
			SetAutoExposureMin( 0.5 )
			SetAutoExposureMax( 0.7 )
			break;

		case "mp_swampland":
			SetAutoExposureMin( 0.5 )
			SetAutoExposureMax( 0.8 )
			break;

		case "mp_runoff":
			SetAutoExposureMin( 0.5 )
			SetAutoExposureMax( 1.0 )
			break;

		case "mp_wargames":
			SetAutoExposureMin( 1.0 )
			SetAutoExposureMax( 1.75 )
			break;

		case "mp_harmony_mines":
			SetAutoExposureMin( 1.0 )
			SetAutoExposureMax( 1.75 )
			break;

		case "mp_switchback":
			SetAutoExposureMin( 1.0 )
			SetAutoExposureMax( 1.75 )
			break;

		case "mp_sandtrap":
			SetAutoExposureMin( 0.5 )
			SetAutoExposureMax( 1.15 )
			break;

		case "mp_taube_rock_photo_test":
			SetAutoExposureMin( 1.2 )
			SetAutoExposureMax( 2.0 )
			SetBloomScale (1.0)
			break;

		case "mp_taube_forest_test":
			SetAutoExposureMin( 1.2 )
			SetAutoExposureMax( 2.0 )
			SetBloomScale (1.0)
			break;

		case "mp_pbr_ball_test":
			SetAutoExposureMin( 1.2 )
			SetAutoExposureMax( 2.0 )
			break;

		case "mp_mendoko_taube_style":
			SetBloomScale (1.0)
			break;

		case "mp_kodai_josh_style_01":
			SetBloomScale (1.0)
			break;

		case "mp_fake_sky_taube_01":
			SetBloomScale (1.0)
			break;

		case "sp_beacon_taube_style":
			SetBloomScale (1.0)
			break;

		case "sp_trainer":
			SetBloomScale( 0.2 )
			SetAutoExposureMin( 0.8 )
			SetAutoExposureMax( 0.8 )
			break

		case "sp_beacon":
			SetAutoExposureMax( 5.0 )
			break;

		case "sp_beacon_spoke0":
			SetAutoExposureMax( 5.0 )
			break;

		default:
			UseDefaultAutoExposure()
			break
	}
}



function SetAutoExposureMin( float value )
{
	level.toneController.Fire( "SetAutoExposureMin", value )
}

function SetAutoExposureMax( float value )
{
	level.toneController.Fire( "SetAutoExposureMax", value )
}

function SetAutoExposureCompensation( float value )
{
	level.toneController.Fire( "SetAutoExposureCompensation", value )
}

function SetAutoExposureCompensationBias( float value )
{
	level.toneController.Fire( "SetAutoExposureCompensationBias", value )
}

function SetAutoExposureRate( float value )
{
	level.toneController.Fire( "SetAutoExposureRate", value )
}

function UseDefaultAutoExposure()
{
	level.toneController.Fire( "UseDefaultAutoExposure" )
}

function SetBloomScale( float value )
{
	level.toneController.Fire( "SetBloomScale", value )
}
