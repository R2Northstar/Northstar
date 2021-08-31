untyped

global function ShouldSlamzoomSpawn
global function SlammzoomSpawn

const SLAMZOOM_WHOOSH_SOUND = "UI_InGame_MarkedForDeath_PlayerUnmarked"
const SLAMZOOM_COLOR_CORRECTION = "materials/correction/player_electric_damage.raw"

function ShouldSlamzoomSpawn()
{
	return ( GetCurrentPlaylistVarInt( "enable_slamzoom_spawn", 0 ) == 1 )
}

function SlammzoomSpawn( entity player, vector origin, vector angles, entity friendlyPilot = null )
{
	player.EndSignal( "OnDestroy" )
	player.SetOrigin( origin )
	player.SnapEyeAngles( angles )

	vector landorigin = player.EyePosition()

	// slamzoom
	int slamzoom_height = 4000
	float slamzoom_time1 = 0.5
	float slamzoom_time2 = 0.7
	float slamzoom_rotate_time = 0.3
	int slamzoom_angle = 90
	int enter_angle = 90 - slamzoom_angle

	vector start_angles = Vector( -90-enter_angle, angles.y, 0 )
	vector start_vector = AnglesToForward( start_angles )

	// origin = origin + Vector(0,0,48)

	entity camera = CreateTitanDropCamera( origin + start_vector * slamzoom_height, Vector( slamzoom_angle, angles.y, 0.0) )
	camera.Fire( "Enable", "!activator", 0, player )

	entity mover = CreateScriptMover()
	if ( IsValid( camera ) )
	{
		// camera can be invalid for a moment when server shuts down
		mover.SetOrigin( camera.GetOrigin() )
		mover.SetAngles( camera.GetAngles() )
		camera.SetParent( mover )
	}

	OnThreadEnd(
		function() : ( mover, camera )
		{
			if ( IsValid( mover ) )
				mover.Destroy()
			if ( IsValid( camera ) )
				camera.Destroy()
		}
	)

	player.isSpawning = mover
	mover.MoveTo( mover.GetOrigin() + (start_vector * 100), slamzoom_time1, slamzoom_time1*0.4, slamzoom_time1*0.4 )
	wait slamzoom_time1
	EmitSoundOnEntityOnlyToPlayer( player, player, SLAMZOOM_WHOOSH_SOUND )
	mover.MoveTo( landorigin, slamzoom_time2, slamzoom_time2*0.5, slamzoom_time2*0.2 )
	wait slamzoom_time2 - slamzoom_rotate_time
	mover.RotateTo( angles, slamzoom_rotate_time, slamzoom_rotate_time*0.2, slamzoom_rotate_time*0.2 )
	wait slamzoom_rotate_time
	player.isSpawning = null
	wait 0.1
	if ( IsValid( camera ) )
	{
		// camera can be invalid for a moment when server shuts down
		camera.FireNow( "Disable", "!activator", null, player )
	}

	if ( IsValid( friendlyPilot ) )
	{
		MessageToPlayer( friendlyPilot, eEventNotifications.FriendlyPlayerSpawnedOnYou, player )
		MessageToPlayer( player, eEventNotifications.SpawnedOnFriendlyPlayer, friendlyPilot )
	}

	if ( ShouldGivePlayerInfoOnSpawn() )
	 	thread GivePlayerInfoOnSpawn( player )

	player.SetOrigin( origin )
	player.SnapEyeAngles( angles )
	player.RespawnPlayer( null )
}