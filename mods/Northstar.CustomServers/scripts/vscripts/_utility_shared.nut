untyped

globalize_all_functions

const DEV_DRAWALLTRIGGERS = 0

global const CHARGE_TOOL = "sp_weapon_arc_tool"

global const TRIG_FLAG_NONE				= 0
global const TRIG_FLAG_PLAYERONLY		= 0x0001
global const TRIG_FLAG_NPCONLY			= 0x0002
global const TRIG_FLAG_NOCONTEXTBUSY	= 0x0004
global const TRIG_FLAG_ONCE				= 0x0008
global const TRIG_FLAG_EXCLUSIVE		= 0x0010 // can only be triggered by entities passed in at creation
global const TRIG_FLAG_DEVDRAW			= 0x0020
global const TRIG_FLAG_START_DISABLED	= 0x0040
global const TRIG_FLAG_NO_PHASE_SHIFT	= 0x0080
global const float MAP_EXTENTS = 128*128
/*
const TRIG_FLAG_	= 0x0080
const TRIG_FLAG_	= 0x0100*/

global const TRIGGER_INTERNAL_SIGNAL = "OnTrigger"

global const CALCULATE_SEQUENCE_BLEND_TIME = -1.0

global struct ArrayDistanceEntry
{
	float distanceSqr
	entity ent
	vector origin
}

global struct GravityLandData
{
	array<vector> points
	TraceResults& traceResults
	float elapsedTime
}

global struct FirstPersonSequenceStruct
{
	string firstPersonAnim = ""
	string thirdPersonAnim = ""
	string firstPersonAnimIdle = ""
	string thirdPersonAnimIdle = ""
	string relativeAnim = ""
	string attachment = ""
	bool teleport = false
	bool noParent = false
	float blendTime = CALCULATE_SEQUENCE_BLEND_TIME
	float firstPersonBlendOutTime = -1.0
	bool noViewLerp = false
	bool hideProxy = false
	void functionref( entity ) viewConeFunction = null
	vector ornull origin = null
	vector ornull angles = null
	bool enablePlanting = false
	float setInitialTime = 0.0	//set the starting point of the animation in seconds
	bool useAnimatedRefAttachment = false //Position entity using ref every frame instead of using root motion
	bool renderWithViewModels = false
	bool gravity = false // force gravity command on sequence
	bool playerPushable = false
	array< string > thirdPersonCameraAttachments = []
	bool thirdPersonCameraVisibilityChecks = false
	entity thirdPersonCameraEntity = null
	bool snapPlayerFeetToEyes = true
}

global struct FrontRightDotProductsStruct
{
	float forwardDot = 0.0
	float rightDot = 0.0
}

global struct RaySphereIntersectStruct
{
	bool result
	float enterFrac
	float leaveFrac
}

void function Utility_Shared_Init()
{
	RegisterSignal( TRIGGER_INTERNAL_SIGNAL )
	RegisterSignal( "devForcedWin" )

	#document( "IsAlive", "Returns true if the given ent is not null, and is alive." )
	#document( "ArrayWithin", "Remove ents from array that are out of range" )
}

#if DEV
// short cut for the console
// script gp()[0].Die( gp()[1] )
array<entity> function gp()
{
	return GetPlayerArray()
}
#endif

void function InitWeaponScripts()
{
	SmartAmmo_Init()

	// WEAPON SCRIPTS
	ArcCannon_Init()
	Grenade_FileInit()
	Vortex_Init()

//	#if SERVER
//		PrecacheProjectileEntity( "grenade_frag" )
//		PrecacheProjectileEntity( "crossbow_bolt" )
//	#endif

	MpWeaponDroneBeam_Init()
	MpWeaponDroneRocket_Init()
	MpWeaponDronePlasma_Init()
	MpWeaponTurretPlasma_Init()
	MpWeaponTurretLaser_Init()
	MpWeaponSuperSpectre_Init()
	MpWeaponGunshipLauncher_Init()
	MpWeaponFragDrone_Init()
	MpAbilityShifter_Init()
	MpTitanabilityBubbleShield_Init()
	MpTitanabilityAmpedWall_Init()
	MpTitanabilityFusionCore_Init()
	MpTitanweapon40mm_Init()
	MpTitanWeaponpredatorcannon_Init()
	MpTitanweaponRocketeetRocketStream_Init()
	MpTitanweaponMeteor_Init()
	MpTitanWeapon_SniperInit()
	MpTitanweaponVortexShield_Init()
	MpTitanweaponXo16_Init()
	MpWeaponDefender_Init()
	MpWeaponDmr_Init()
	MpWeaponProximityMine_Init()
	MpWeaponRocketLauncher_Init()
	MpWeaponNPCRocketLauncher_Init()
	MpWeaponSatchel_Init()
	MpWeaponSmartPistol_Init()
	MpWeaponSniper_Init()
	MpWeaponLSTAR_Init()
	MpTitanWeaponParticleAccelerator_Init()
	MpWeaponMegaTurret_Init()
	MpWeaponZipline_Init()
	SpWeaponHoldBeam_Init()
	MpTitanweaponArcBall_Init()
	MpWeaponDeployableCover_Init()
	MpTitanAbilityBasicBlock_Init()
	MpTitanAbilityLaserTrip_Init()
	MpTitanWeaponArcWave_Init()
	MpTitanWeaponFlameWave_Init()
	MpWeaponAlternatorSMG_Init()
	MpWeaponGreandeElectricSmoke_Init()
	MpWeaponGrenadeGravity_Init()
	MpWeaponDeployableCloakfield_Init()
	MpWeaponTether_Init()
	MpWeaponTripWire_Init()
	MpTitanAbilitySmartCore_Init()
	MpTitanAbilitySlowTrap_Init()
	MpTitanAbilityPowerShot_Init()
	MpTitanAbilityAmmoSwap_Init()
	MpTitanAbilityRocketeerAmmoSwap_Init()
	MpTitanAbilityHeatShield_Init()
	SonarGrenade_Init()
	MpTitanAbilityGunShield_Init()
	MpTitanWeaponLaserLite_Init()
	MpTitanWeaponSword_Init()
	MpTitanAbilityHover_Init()
	MpTitanWeaponTrackerRockets_Init()
	MpTitanWeaponStunLaser_Init()
	MpTitanWeaponShoulderRockets_Init()
	MpTitanAbilitySmoke_Init()
	#if MP
	MpWeaponArcTrap_Init()
	#endif

	#if SERVER
		BallLightning_Init()
	#endif
}

float function GetCurrentPlaylistVarFloat( string val, float useVal )
{
	var result = GetCurrentPlaylistVarOrUseValue( val, useVal + "" )
	if ( result == null || result == "" )
		return 0.0

	return float( result )
}

void function SetSkinForTeam( entity ent, int team )
{
	if ( team == TEAM_IMC )
		ent.SetSkin( 0 )
	else if ( team == TEAM_MILITIA )
		ent.SetSkin( 1 )
}

void function TableDump( table Table, int depth = 0 )
{
	if ( depth > 4 )
		return

	foreach ( k, v in Table )
	{
		printl( "Key: " + k + " Value: " + v )
		if ( type( v ) == "table" && depth )
			TableDump( expect table( v ), depth + 1 )
	}
}

/*entity function GetVortexWeapon( entity player )
{
	for ( int weaponIndex = 0; weaponIndex < 2; weaponIndex++ )
	{
		entity weapon = player.GetOffhandWeapon( weaponIndex )
		if ( !IsValid( weapon ) )
			continue
		if ( weapon.GetWeaponClassName() != "mp_titanweapon_vortex_shield" )
			continue
		return weapon
	}

	Assert( false, "Vortex weapon not found!" )
	unreachable
}*/

entity function GetClosest( array<entity> entArray, vector origin, float maxdist = -1.0 )
{
	Assert( entArray.len() > 0 )

	entity bestEnt = entArray[ 0 ]
	float bestDistSqr = DistanceSqr( bestEnt.GetOrigin(), origin )

	for ( int i = 1; i < entArray.len(); i++ )
	{
		entity newEnt = entArray[ i ]
		float newDistSqr = LengthSqr( newEnt.GetOrigin() - origin )

		if ( newDistSqr < bestDistSqr )
		{
			bestEnt = newEnt
			bestDistSqr = newDistSqr
		}
	}

	if ( maxdist >= 0.0 )
	{
		if ( bestDistSqr > maxdist * maxdist )
			return null
	}

	return bestEnt
}

entity function GetClosest2D( array<entity> entArray, vector origin, float maxdist = -1.0 )
{
	Assert( entArray.len() > 0, "Empty array!" )

	entity bestEnt = entArray[ 0 ]
	float bestDistSqr = DistanceSqr( bestEnt.GetOrigin(), origin )

	for ( int i = 1; i < entArray.len(); i++ )
	{
		entity newEnt = entArray[ i ]
		float newDistSqr = Length2DSqr( newEnt.GetOrigin() - origin )

		if ( newDistSqr < bestDistSqr )
		{
			bestEnt = newEnt
			bestDistSqr = newDistSqr
		}
	}

	if ( maxdist >= 0.0 )
	{
		if ( bestDistSqr > maxdist * maxdist )
			return null
	}

	return bestEnt
}

bool function GameModeHasCapturePoints()
{
	#if CLIENT
		return clGlobal.hardpointStringIDs.len() > 0
	#elseif SERVER
		return svGlobal.hardpointStringIDs.len() > 0
	#endif
}

entity function GetFarthest( array<entity> entArray, vector origin )
{
	Assert( entArray.len() > 0, "Empty array!" )

	entity bestEnt = entArray[0]
	float bestDistSqr = DistanceSqr( bestEnt.GetOrigin(), origin )

	for ( int i = 1; i < entArray.len(); i++ )
	{
		entity newEnt = entArray[ i ]
		float newDistSqr = DistanceSqr( newEnt.GetOrigin(), origin )

		if ( newDistSqr > bestDistSqr )
		{
			bestEnt = newEnt
			bestDistSqr = newDistSqr
		}
	}

	return bestEnt
}

int function GetClosestIndex( array<entity> Array, vector origin )
{
	Assert( Array.len() > 0 )

	int index = 0
	float distSqr = LengthSqr( Array[ index ].GetOrigin() - origin )

	entity newEnt
	float newDistSqr
	for ( int i = 1; i < Array.len(); i++ )
	{
		newEnt = Array[ i ]
		newDistSqr = LengthSqr( newEnt.GetOrigin() - origin )

		if ( newDistSqr < distSqr )
		{
			index = i
			distSqr = newDistSqr
		}
	}

	return index
}

// nothing in the game uses the format "Table.r/g/b/a"... wtf is the point of this function
table function StringToColors( string colorString, string delimiter = " " )
{
	PerfStart( PerfIndexShared.StringToColors + SharedPerfIndexStart )
	array<string> tokens = split( colorString, delimiter )

	Assert( tokens.len() >= 3 )

	table Table = {}
	Table.r <- int( tokens[0] )
	Table.g <- int( tokens[1] )
	Table.b <- int( tokens[2] )

	if ( tokens.len() == 4 )
		Table.a <- int( tokens[3] )
	else
		Table.a <- 255

	PerfEnd( PerfIndexShared.StringToColors + SharedPerfIndexStart )
	return Table
}

// TODO: Set return type to array<int> when SetColor() accepts this type
function ColorStringToArray( string colorString )
{
	array<string> tokens = split( colorString, " " )

	Assert( tokens.len() >= 3 && tokens.len() <= 4 )

	array colorArray
	foreach ( token in tokens )
		colorArray.append( int( token ) )

	return colorArray
}

// Evaluate a generic order ( coefficientArray.len() - 1 ) polynomial
// e.g. to evaluate (Ax + B), call EvaluatePolynomial(x, A, B)
// Note that EvaluatePolynomial(x) returns 0 and
// EvaluatePolynomial(x, A) returns A, which are technically correct
// but perhaps not what you expect
float function EvaluatePolynomial( float x, array<float> coefficientArray )
{
	float sum = 0.0

	for ( int i = 0; i < coefficientArray.len() - 1; ++i )
		sum += coefficientArray[ i ] * pow( x, coefficientArray.len() -1 - i )

	if ( coefficientArray.len() >= 1 )
		sum += coefficientArray[ coefficientArray.len() - 1 ]

	return sum
}

void function WaitForever()
{
	#if SERVER
		svGlobal.levelEnt.WaitSignal( "forever" )
	#elseif CLIENT
		clGlobal.levelEnt.WaitSignal( "forever" )
	#endif
}

#if SERVER

bool function ShouldDoReplay( entity player, entity attacker, float replayTime, int methodOfDeath )
{
	if ( ShouldDoReplayIsForcedByCode() )
	{
		print( "ShouldDoReplay(): Doing a replay because code forced it." );
		return true
	}

	if ( GetCurrentPlaylistVarInt( "replay_disabled", 0 ) == 1 )
	{
		print( "ShouldDoReplay(): Not doing a replay because 'replay_disabled' is enabled in the current playlist.\n" );
		return false
	}

	switch( methodOfDeath )
	{
		case eDamageSourceId.human_execution:
		case eDamageSourceId.titan_execution:
		{
			print( "ShouldDoReplay(): Not doing a replay because the player died from an execution.\n" );
			return false
		}
	}

	if ( level.nv.replayDisabled )
	{
		print( "ShouldDoReplay(): Not doing a replay because replays are disabled for the level.\n" );
		return false
	}

	if ( Time() - player.p.connectTime <= replayTime ) //Bad things happen if we try to do a kill replay that lasts longer than the player entity existing on the server
	{
		print( "ShouldDoReplay(): Not doing a replay because the player is not old enough.\n" );
		return false
	}

	if ( player == attacker )
	{
		print( "ShouldDoReplay(): Not doing a replay because the attacker is the player.\n" );
		return false
	}

	if ( player.IsBot() == true )
	{
		print( "ShouldDoReplay(): Not doing a replay because the player is a bot.\n" );
		return false
	}

	return AttackerShouldTriggerReplay( attacker )
}

// Don't let things like killbrushes show replays
bool function AttackerShouldTriggerReplay( entity attacker )
{
	if ( !IsValid( attacker ) )
	{
		print( "AttackerShouldTriggerReplay(): Not doing a replay because the attacker is not valid.\n" )
		return false
	}

	if ( attacker.IsPlayer() )
	{
		print( "AttackerShouldTriggerReplay(): Doing a replay because the attacker is a player.\n" )
		return true
	}

	if ( attacker.IsNPC() )
	{
		print( "AttackerShouldTriggerReplay(): Doing a replay because the attacker is an NPC.\n" )
		return true
	}

	print( "AttackerShouldTriggerReplay(): Not doing a replay by default.\n" )
	return false
}
#endif // #if SERVER

vector function RandomVec( float range )
{
	// could rewrite so it doesnt make a box of random.
	vector vec = Vector( 0, 0, 0 )
	vec.x = RandomFloatRange( -range, range )
	vec.y = RandomFloatRange( -range, range )
	vec.z = RandomFloatRange( -range, range )

	return vec
}

function ArrayValuesToTableKeys( arr )
{
	Assert( type( arr ) == "array", "Not an array" )

	local resultTable = {}
	for ( int i = 0; i < arr.len(); ++ i)
	{
		resultTable[ arr[ i ] ] <- 1
	}

	return resultTable
}

function TableKeysToArray( tab )
{
	Assert( type( tab ) == "table", "Not a table" )

	local resultArray = []
	resultArray.resize( tab.len() )
	int currentArrayIndex = 0
	foreach ( key, val in tab )
	{
		resultArray[ currentArrayIndex ] = key
		++currentArrayIndex
	}

	return resultArray
}

function TableRandom( Table )
{
	Assert( type( Table ) == "table", "Not a table" )

	local Array = []

	foreach ( entry, contents in Table )
	{
		Array.append( contents )
	}

	return Array.getrandom()
}

int function RandomWeightedIndex( array Array )
{
	int count = Array.len()
	Assert( count != 0, "Array is empty" )

	int sum = int( ( count * ( count + 1 ) ) / 2.0 )		// ( n * ( n + 1 ) ) / 2
	int randInt = RandomInt( sum )
	for ( int i = 0 ; i < count ; i++ )
	{
		int rangeForThisIndex = count - i
		if ( randInt < rangeForThisIndex )
			return i

		randInt -= rangeForThisIndex
	}

	Assert( 0 )
	unreachable
}

bool function IsValid_ThisFrame( entity ent )
{
	if ( ent == null )
		return false

	return expect bool( ent.IsValidInternal() )
}

bool function IsAlive( entity ent )
{
	if ( ent == null )
		return false
	if ( !ent.IsValidInternal() )
		return false

	return ent.IsEntAlive()
}

#if DEV && SERVER
void function vduon()
{
	PlayConversationToAll( "TitanReplacement" )
}

void function playconvtest( string conv )
{
	entity player = GetPlayerArray()[0]
	array<entity> guys = GetAllSoldiers()
	if ( !guys.len() )
	{
		printt( "No AI!!" )
		return
	}
	entity guy = GetClosest( guys, player.GetOrigin() )
	if ( conv in player.s.lastAIConversationTime )
		delete player.s.lastAIConversationTime[ conv ]

	printt( "Play ai conversation " + conv )
	PlaySquadConversationToAll( conv, guy )
}
#endif //DEV

void function FighterExplodes( entity ship )
{
	vector origin = ship.GetOrigin()
	vector angles = ship.GetAngles()
	EmitSoundAtPosition( TEAM_UNASSIGNED, origin, "AngelCity_Scr_RedeyeWeaponExplos" )
	#if SERVER
		PlayFX( FX_HORNET_DEATH, origin )
	#else
		int fxid = GetParticleSystemIndex( FX_HORNET_DEATH )
		StartParticleEffectInWorld( fxid, origin, angles )
	#endif
}

vector function PositionOffsetFromEnt( entity ent, float offsetX, float offsetY, float offsetZ )
{
	vector angles = ent.GetAngles()
	vector origin = ent.GetOrigin()
	origin += AnglesToForward( angles ) * offsetX
	origin += AnglesToRight( angles ) * offsetY
	origin += AnglesToUp( angles ) * offsetZ
	return origin
}

vector function PositionOffsetFromOriginAngles( vector origin, vector angles, float offsetX, float offsetY, float offsetZ )
{
	origin += AnglesToForward( angles ) * offsetX
	origin += AnglesToRight( angles ) * offsetY
	origin += AnglesToUp( angles ) * offsetZ
	return origin
}


bool function IsMenuLevel()
{
	return IsLobby()
}

function Dump( package, depth = 0 )
{
	if ( depth > 6 )
		return

	foreach ( k, v in package )
	{
		for ( int i = 0; i < depth; i++ )
			print( "    ")

		if ( IsTable( package ) )
			printl( "Key: " + k + " Value: " + v )
		if ( IsArray( package ) )
			printl( "Index: " + k + " Value: " + v )

		if ( IsTable( v ) || IsArray( v ) )
			Dump( v, depth + 1 )
	}
}

bool function UseShortNPCTitles()
{
	return GetCurrentPlaylistVarInt( "npc_short_titles", 0 ) ? true : false
}

string function GetShortNPCTitle( int team )
{
	return GetTeamName( team )
}

bool function IsIMCOrMilitiaTeam( int team )
{
	return team == TEAM_MILITIA || team == TEAM_IMC
}

int function GetOtherTeam( int team )
{
	if ( team == TEAM_IMC )
		return TEAM_MILITIA

	if ( team == TEAM_MILITIA )
		return TEAM_IMC

	Assert( false, "Trying to GetOtherTeam() for team: " + team + " that is neither Militia nor IMC" )
	unreachable
}

float function VectorDot_PlayerToOrigin( entity player, vector targetOrigin )
{
	vector playerEyePosition = player.EyePosition()
	vector vecToEnt = ( targetOrigin - playerEyePosition )
	vecToEnt.Norm()

	// GetViewVector() only works on the player
	float dotVal = vecToEnt.Dot( player.GetViewVector() )
	return dotVal
}

float function VectorDot_DirectionToOrigin( entity player, vector direction, vector targetOrigin )
{
	vector playerEyePosition = player.EyePosition()
	vector vecToEnt = ( targetOrigin - playerEyePosition )
	vecToEnt.Norm()

	// GetViewVector() only works on the player
	float dotVal = DotProduct( vecToEnt, direction )
	return dotVal
}

void function WaitUntilWithinDistance( entity player, entity titan, float dist )
{
	float distSqr = dist * dist
	for ( ;; )
	{
		if ( !IsAlive( titan ) )
			return

		if ( IsAlive( player ) )
		{
			if ( DistanceSqr( player.GetOrigin(), titan.GetOrigin() ) <= distSqr )
				return
		}
		wait 0.1
	}
}

void function WaitUntilBeyondDistance( entity player, entity titan, float dist )
{
	float distSqr = dist * dist
	for ( ;; )
	{
		if ( !IsAlive( titan ) )
			return

		if ( IsAlive( player ) )
		{
			if ( DistanceSqr( player.GetOrigin(), titan.GetOrigin() ) > distSqr )
				return
		}
		wait 0.1
	}
}

bool function IsModelViewer()
{
	return GetMapName() == "mp_model_viewer"
}


//----------------------------------//
//	Tweening functions				//
// Pass in a fraction 0.0 - 1.0		//
// Get a fraction back 0.0 - 1.0	//
//----------------------------------//

// simple linear tweening - no easing, no acceleration
float function Tween_Linear( float frac )
{
	Assert( frac >= 0.0 && frac <= 1.0 )
	return frac
}

// quadratic easing out - decelerating to zero velocity
float function Tween_QuadEaseOut( float frac )
{
	Assert( frac >= 0.0 && frac <= 1.0 )
	return -1.0 * frac*(frac-2)
}

// exponential easing out - decelerating to zero velocity
float function Tween_ExpoEaseOut( float frac )
{
	Assert( frac >= 0.0 && frac <= 1.0 )
	return -pow( 2.0, -10.0 * frac ) + 1.0
}

float function Tween_ExpoEaseIn( float frac )
{
	Assert( frac >= 0.0 && frac <= 1.0 )
	return pow( 2, 10 * ( frac - 1 ) );
}

bool function LegalOrigin( vector origin )
{
	if ( fabs( origin.x ) > MAX_WORLD_COORD )
		return false

	if ( fabs( origin.y ) > MAX_WORLD_COORD )
		return false

	if ( fabs( origin.z ) > MAX_WORLD_COORD )
		return false

	return true
}

vector function AnglesOnSurface( surfaceNormal, playerVelocity )
{
	playerVelocity.Norm()
	vector right = CrossProduct( playerVelocity, surfaceNormal )
	vector forward = CrossProduct( surfaceNormal, right )
	vector angles = VectorToAngles( forward )
	angles.z = atan2( right.z, surfaceNormal.z ) * RAD_TO_DEG

	return angles
}

vector function ClampToWorldspace( vector origin )
{
	// temp solution for start positions that are outside the world bounds
	origin.x = clamp( origin.x, -MAX_WORLD_COORD, MAX_WORLD_COORD )
	origin.y = clamp( origin.y, -MAX_WORLD_COORD, MAX_WORLD_COORD )
	origin.z = clamp( origin.z, -MAX_WORLD_COORD, MAX_WORLD_COORD )

	return origin
}

function UseReturnTrue( user, usee )
{
	return true
}

function ControlPanel_CanUseFunction( playerUser, controlPanel )
{
	expect entity( playerUser )
	expect entity( controlPanel )

	// Does a simple cone FOV check from the screen to the player's eyes
	int maxAngleToAxisAllowedDegrees = 60

	vector playerEyePos = playerUser.EyePosition()
	int attachmentIndex = controlPanel.LookupAttachment( "PANEL_SCREEN_MIDDLE" )

	Assert( attachmentIndex != 0 )
	vector controlPanelScreenPosition = controlPanel.GetAttachmentOrigin( attachmentIndex )
	vector controlPanelScreenAngles = controlPanel.GetAttachmentAngles( attachmentIndex )
	vector controlPanelScreenForward = AnglesToForward( controlPanelScreenAngles )

	vector screenToPlayerEyes = Normalize( playerEyePos - controlPanelScreenPosition )

	return DotProduct( screenToPlayerEyes, controlPanelScreenForward ) > deg_cos( maxAngleToAxisAllowedDegrees )
}

function SentryTurret_CanUseFunction( playerUser, sentryTurret )
{
	expect entity( playerUser )
	expect entity( sentryTurret )

	// Does a simple cone FOV check from the screen to the player's eyes
	int maxAngleToAxisAllowedDegrees = 90

	vector playerEyePos = playerUser.EyePosition()
	int attachmentIndex = sentryTurret.LookupAttachment( "turret_player_use" )

	Assert( attachmentIndex != 0 )
	vector sentryTurretUsePosition = sentryTurret.GetAttachmentOrigin( attachmentIndex )
	vector sentryTurretUseAngles = sentryTurret.GetAttachmentAngles( attachmentIndex )
	vector sentryTurretUseForward = AnglesToForward( sentryTurretUseAngles )

	vector useToPlayerEyes = Normalize( playerEyePos - sentryTurretUsePosition )

	return DotProduct( useToPlayerEyes, sentryTurretUseForward ) > deg_cos( maxAngleToAxisAllowedDegrees )
}

void function ArrayRemoveInvalid( array<entity> ents )
{
	for ( int i = ents.len() - 1; i >= 0; i-- )
	{
		if ( !IsValid( ents[ i ] ) )
			ents.remove( i )
	}
}

bool function HasDamageStates( entity ent )
{
	if ( !IsValid( ent ) )
		return false
	return ( "damageStateInfo" in ent.s )
}

bool function HasHitData( entity ent )
{
	return ( "hasHitData" in ent.s && expect bool( ent.s.hasHitData ) )
}

FrontRightDotProductsStruct function GetFrontRightDots( entity baseEnt, entity relativeEnt, string optionalTag = "" )
{
	if ( optionalTag != "" )
	{
		int attachIndex = baseEnt.LookupAttachment( optionalTag )
		vector origin = baseEnt.GetAttachmentOrigin( attachIndex )
		vector angles = baseEnt.GetAttachmentAngles( attachIndex )
		angles.x = 0
		angles.z = 0
		vector forward = AnglesToForward( angles )
		vector right = AnglesToRight( angles )

		vector targetOrg = relativeEnt.GetOrigin()
		vector vecToEnt = ( targetOrg - origin )
//		printt( "vecToEnt ", vecToEnt )
		vecToEnt.z = 0

		vecToEnt.Norm()


		FrontRightDotProductsStruct result
		result.forwardDot = DotProduct( vecToEnt, forward )
		result.rightDot = DotProduct( vecToEnt, right )

		// red: forward for incoming ent
		//DebugDrawLine( origin, origin + vecToEnt * 150, 255, 0, 0, true, 5 )

		// green: tag forward
		//DebugDrawLine( origin, origin + forward * 150, 0, 255, 0, true, 5 )

		// blue: tag right
		//DebugDrawLine( origin, origin + right * 150, 0, 0, 255, true, 5 )
		return result
	}

	vector targetOrg = relativeEnt.GetOrigin()
	vector origin = baseEnt.GetOrigin()
	vector vecToEnt = ( targetOrg - origin )
	vecToEnt.Norm()

	FrontRightDotProductsStruct result
	result.forwardDot = vecToEnt.Dot( baseEnt.GetForwardVector() )
	result.rightDot = vecToEnt.Dot( baseEnt.GetRightVector() )
	return result
}



array<vector> function GetAllPointsOnBezier( array<vector> points, int numSegments, float debugDrawTime = 0.0 )
{
	Assert( points.len() >= 2 )
	Assert( numSegments > 0 )
	array<vector> curvePoints = []

	// Debug draw the points used for the curve
	if ( debugDrawTime )
	{
		for ( int i = 0; i < points.len() - 1; i++ )
			DebugDrawLine( points[i], points[i + 1], 150, 150, 150, true, debugDrawTime )
	}

	for ( int i = 0; i < numSegments; i++ )
	{
		float t = ( i.tofloat() / ( numSegments.tofloat() - 1.0 ) ).tofloat()
		curvePoints.append( GetSinglePointOnBezier( points, t ) )
	}

	return curvePoints
}

vector function GetSinglePointOnBezier( array<vector> points, float t )
{
	// evaluate a point on a bezier-curve. t goes from 0 to 1.0

	array<vector> lastPoints = clone points
	for(;;)
	{
		array<vector> newPoints = []
		for ( int i = 0; i < lastPoints.len() - 1; i++ )
			newPoints.append( lastPoints[i] + ( lastPoints[i+1] - lastPoints[i] ) * t )

		if ( newPoints.len() == 1 )
			return newPoints[0]

		lastPoints = newPoints
	}

	unreachable
}

bool function GetDoomedState( entity ent )
{
	entity soul = ent.GetTitanSoul()
	if ( !IsValid( soul ) )
		return false

	return soul.IsDoomed()
}

bool function TitanCoreInUse( entity player )
{
	Assert( player.IsTitan() )

	if ( !IsAlive( player ) )
		return false

	return Time() < SoulTitanCore_GetExpireTime( player.GetTitanSoul() )
}


// Return float or null
function GetTitanCoreTimeRemaining( entity player )
{
	if ( !player.IsTitan() )
		return null

	entity soul = player.GetTitanSoul()

	if ( !soul )
		return null

	return SoulTitanCore_GetExpireTime( soul ) - Time()
}

bool function CoreAvailableDuringDoomState()
{
	return true
}

bool function HasAntiTitanWeapon( entity guy )
{
	foreach ( weapon in guy.GetMainWeapons() )
	{
		if ( weapon.GetWeaponType() == WT_ANTITITAN )
			return true
	}
	return false
}

float function GetTitanCoreActiveTime( entity player )
{
	entity weapon = player.GetOffhandWeapon( OFFHAND_EQUIPMENT )

	if ( !IsValid( weapon ) )
	{
		printt( "WARNING: tried to get core active time, but core weapon was invalid." )
		printt( "titan is alive? " + IsAlive( player ) )
		return 5.0 // default
	}

	return GetTitanCoreDurationFromWeapon( weapon )
}

float function GetTitanCoreChargeTime( entity player )
{
	entity weapon = player.GetOffhandWeapon( OFFHAND_EQUIPMENT )

	if ( !IsValid( weapon ) )
	{
		printt( "WARNING: tried to get core charge time, but core weapon was invalid." )
		printt( "titan is alive? " + IsAlive( player ) )
		return 1.0 // default
	}

	return GetTitanCoreChargeTimeFromWeapon( weapon )
}

float function GetTitanCoreChargeTimeFromWeapon( entity weapon )
{
	return expect float( weapon.GetWeaponInfoFileKeyField( "chargeup_time" ) )
}

float function GetTitanCoreBuildTimeFromWeapon( entity weapon )
{
	return expect float( weapon.GetWeaponInfoFileKeyField( "core_build_time" ).tofloat() )
}

float function GetTitanCoreDurationFromWeapon( entity weapon )
{
	float coreDuration = weapon.GetCoreDuration()

	entity player = weapon.GetWeaponOwner()
	if ( IsValid( player ) && player.IsPlayer() )
	{
		if ( PlayerHasPassive( player, ePassives.PAS_MARATHON_CORE ) )
			coreDuration *= TITAN_CORE_MARATHON_CORE_MULTIPLIER
	}

	return coreDuration
}

float function GetCoreBuildTime( entity titan )
{
	if ( titan.IsPlayer() )
		titan = GetTitanFromPlayer( titan )

	Assert( titan != null )

	entity coreWeapon = titan.GetOffhandWeapon( OFFHAND_EQUIPMENT )

	if ( !IsValid( coreWeapon ) )
	{
		//printt( "WARNING: tried to set build timer, but core weapon was invalid." )
		//printt( "titan is alive? " + IsAlive( titan ) )
		return 200.0 // default
	}


	return GetTitanCoreBuildTimeFromWeapon( coreWeapon )
}

string function GetCoreShortName( entity titan )
{
	entity coreWeapon = titan.GetOffhandWeapon( OFFHAND_EQUIPMENT )

	if ( !IsValid( coreWeapon ) )
	{
		printt( "WARNING: tried to get core name, but core weapon was invalid." )
		printt( "titan is alive? " + IsAlive( titan ) )
		return "#HUD_READY"
	}

	string name = expect string( coreWeapon.GetWeaponInfoFileKeyField( "shortprintname" ) )
	return name
}

string ornull function GetCoreOSConversationName( entity titan, string event )
{
	entity coreWeapon = titan.GetOffhandWeapon( OFFHAND_EQUIPMENT )

	if ( !IsValid( coreWeapon ) )
	{
		printt( "WARNING: tried to get core sound for " + event + ", but core weapon was invalid." )
		printt( "titan is alive? " + IsAlive( titan ) )
		return null
	}

	var alias = coreWeapon.GetWeaponInfoFileKeyField( "dialog_" + event )

	if ( alias == null )
		return null

	expect string( alias )

	return alias
}

entity function GetTitanFromPlayer( entity player )
{
	Assert( player.IsPlayer() )
	if ( player.IsTitan() )
		return player

	return player.GetPetTitan()
}

int function GetNuclearPayload( entity player )
{
	if ( !GetDoomedState( player ) )
		return 0

	int payload = 0
	if ( PlayerHasPassive( player, ePassives.PAS_NUCLEAR_CORE ) )
		payload += 2

	if ( PlayerHasPassive( player, ePassives.PAS_BUILD_UP_NUCLEAR_CORE ) )
		payload += 1

	return payload
}

entity function GetCloak( entity ent )
{
	return GetOffhand( ent, "mp_ability_cloak" )
}

entity function GetOffhand( entity ent, string classname )
{
	entity offhand = ent.GetOffhandWeapon( OFFHAND_LEFT )
	if ( IsValid( offhand ) && offhand.GetWeaponClassName() == classname )
		return offhand

	offhand = ent.GetOffhandWeapon( OFFHAND_RIGHT )
	if ( IsValid( offhand ) && offhand.GetWeaponClassName() == classname )
		return offhand

	return null
}

bool function IsCloaked( entity ent )
{
	return ent.IsCloaked( true ) //pass true to ignore flicker time -
}

float function TimeSpentInCurrentState()
{
	return Time() - expect float( level.nv.gameStateChangeTime )
}

float function DotToAngle( float dot )
{
	return acos( dot ) * RAD_TO_DEG
}

float function AngleToDot( float angle )
{
	return cos( angle * DEG_TO_RAD )
}

int function GetGameState()
{
	return expect int( GetServerVar( "gameState" ) )
}

bool function GamePlaying()
{
	return GetGameState() == eGameState.Playing
}

bool function GamePlayingOrSuddenDeath()
{
	int gameState = GetGameState()
	return gameState == eGameState.Playing || gameState == eGameState.SuddenDeath
}

bool function IsOdd( int num )
{
	return ( num % 2 ) == 1
}

bool function IsEven( int num )
{
	return !IsOdd( num )
}

vector function VectorReflectionAcrossNormal( vector vec, vector normal )
{
	return ( vec - normal * ( 2 * DotProduct( vec, normal ) ) )
}

// Return an array of entities ordered from farthest to closest to the specified origin
array<entity> function ArrayFarthest( array<entity> entArray, vector origin )
{
	array<ArrayDistanceEntry> allResults = ArrayDistanceResults( entArray, origin )

	allResults.sort( DistanceCompareFarthest )

	array<entity> returnEntities

	foreach ( result in allResults )
		returnEntities.append( result.ent )

	// the actual distances aren't returned
	return returnEntities
}

// Return an array of vectors ordered from closest to furthest from the specified origin
array<vector> function ArrayFarthestVector( array<vector> vecArray, vector origin )
{
	array<ArrayDistanceEntry> allResults = ArrayDistanceResultsVector( vecArray, origin )

	allResults.sort( DistanceCompareFarthest )

	array<vector> returnVecs

	foreach ( result in allResults )
		returnVecs.append( result.origin )

	return returnVecs
}

// Return an array of entities ordered from closest to furthest from the specified origin
array<entity> function ArrayClosest( array<entity> entArray, vector origin )
{
	array<ArrayDistanceEntry> allResults = ArrayDistanceResults( entArray, origin )

	allResults.sort( DistanceCompareClosest )

	array<entity> returnEntities

	foreach ( result in allResults )
		returnEntities.append( result.ent )

	return returnEntities
}

// Return an array of vectors ordered from closest to furthest from the specified origin
array<vector> function ArrayClosestVector( array<vector> vecArray, vector origin )
{
	array<ArrayDistanceEntry> allResults = ArrayDistanceResultsVector( vecArray, origin )

	allResults.sort( DistanceCompareClosest )

	array<vector> returnVecs

	foreach ( result in allResults )
		returnVecs.append( result.origin )

	return returnVecs
}

array<entity> function ArrayClosestWithinDistance( array<entity> entArray, vector origin, float maxDistance )
{
	array<ArrayDistanceEntry> allResults = ArrayDistanceResults( entArray, origin )
	float maxDistSq = maxDistance * maxDistance

	allResults.sort( DistanceCompareClosest )

	array<entity> returnEntities

	foreach ( result in allResults )
	{
		if ( result.distanceSqr > maxDistSq )
			break

		returnEntities.append( result.ent )
	}

	return returnEntities
}

array<vector> function ArrayClosestVectorWithinDistance( array<vector> vecArray, vector origin, float maxDistance )
{
	array<ArrayDistanceEntry> allResults = ArrayDistanceResultsVector( vecArray, origin )
	float maxDistSq = maxDistance * maxDistance

	allResults.sort( DistanceCompareClosest )

	array<vector> returnVecs

	foreach ( result in allResults )
	{
		if ( result.distanceSqr > maxDistSq )
			break

		returnVecs.append( result.origin )
	}

	return returnVecs
}

// Return an array of entities ordered from closest to furthest from the specified origin, ignoring z
array<entity> function ArrayClosest2D( array<entity> entArray, vector origin )
{
	array<ArrayDistanceEntry> allResults = ArrayDistance2DResults( entArray, origin )

	allResults.sort( DistanceCompareClosest )

	array<entity> returnEntities

	foreach ( result in allResults )
		returnEntities.append( result.ent )

	return returnEntities
}

// Return an array of entities ordered from closest to furthest from the specified origin, ignoring z
array<vector> function ArrayClosest2DVector( array<vector> entArray, vector origin )
{
	array<ArrayDistanceEntry> allResults = ArrayDistance2DResultsVector( entArray, origin )

	allResults.sort( DistanceCompareClosest )

	array<vector> returnVecs

	foreach ( result in allResults )
		returnVecs.append( result.origin )

	return returnVecs
}

array<entity> function ArrayClosest2DWithinDistance( array<entity> entArray, vector origin, float maxDistance )
{
	array<ArrayDistanceEntry> allResults = ArrayDistance2DResults( entArray, origin )
	float maxDistSq = maxDistance * maxDistance

	allResults.sort( DistanceCompareClosest )

	array<entity> returnEntities

	foreach ( result in allResults )
	{
		if ( result.distanceSqr > maxDistSq )
			break

		returnEntities.append( result.ent )
	}

	return returnEntities
}

// Return an array of entities ordered from closest to furthest from the specified origin, ignoring z
array<vector> function ArrayClosest2DVectorWithinDistance( array<vector> entArray, vector origin, float maxDistance )
{
	array<ArrayDistanceEntry> allResults = ArrayDistance2DResultsVector( entArray, origin )
	float maxDistSq = maxDistance * maxDistance

	allResults.sort( DistanceCompareClosest )

	array<vector> returnVecs

	foreach ( result in allResults )
	{
		if ( result.distanceSqr > maxDistSq )
			break

		returnVecs.append( result.origin )
	}

	return returnVecs
}

bool function ArrayEntityWithinDistance( array<entity> entArray, vector origin, float distance )
{
	float distSq = distance * distance
	foreach( entity ent in entArray )
	{
		if ( DistanceSqr( ent.GetOrigin(), origin ) <= distSq )
			return true
	}
	return false
}

function TableRemove( Table, entry )
{
	Assert( typeof Table == "table" )

	foreach ( index, tableEntry in Table )
	{
		if ( tableEntry == entry )
		{
			Table[ index ] = null
		}
	}
}

function TableInvert( Table )
{
	table invertedTable = {}
	foreach ( key, value in Table )
		invertedTable[ value ] <- key

	return invertedTable
}

int function DistanceCompareClosest( ArrayDistanceEntry a, ArrayDistanceEntry b )
{
	if ( a.distanceSqr > b.distanceSqr )
		return 1
	else if ( a.distanceSqr < b.distanceSqr )
		return -1

	return 0;
}

int function DistanceCompareFarthest( ArrayDistanceEntry a, ArrayDistanceEntry b )
{
	if ( a.distanceSqr < b.distanceSqr )
		return 1
	else if ( a.distanceSqr > b.distanceSqr )
		return -1

	return 0;
}

array<ArrayDistanceEntry> function ArrayDistanceResults( array<entity> entArray, vector origin )
{
	array<ArrayDistanceEntry> allResults

	foreach ( ent in entArray )
	{
		ArrayDistanceEntry entry

		vector entOrigin = ent.GetOrigin()
		if ( IsSpawner( ent ) )
		{
			var spawnKVs = ent.GetSpawnEntityKeyValues()
			entOrigin = StringToVector( string( spawnKVs.origin ) )
		}
		entry.distanceSqr = DistanceSqr( entOrigin, origin )
		entry.ent = ent
		entry.origin = entOrigin

		allResults.append( entry )
	}

	return allResults
}

array<ArrayDistanceEntry> function ArrayDistanceResultsVector( array<vector> vecArray, vector origin )
{
	array<ArrayDistanceEntry> allResults

	foreach ( vec in vecArray )
	{
		ArrayDistanceEntry entry

		entry.distanceSqr = DistanceSqr( vec, origin )
		entry.ent = null
		entry.origin = vec

		allResults.append( entry )
	}

	return allResults
}

array<ArrayDistanceEntry> function ArrayDistance2DResults( array<entity> entArray, vector origin )
{
	array<ArrayDistanceEntry> allResults

	foreach ( ent in entArray )
	{
		ArrayDistanceEntry entry

		vector entOrigin = ent.GetOrigin()

		entry.distanceSqr = Distance2DSqr( entOrigin, origin )
		entry.ent = ent
		entry.origin = entOrigin

		allResults.append( entry )
	}

	return allResults
}

array<ArrayDistanceEntry> function ArrayDistance2DResultsVector( array<vector> vecArray, vector origin )
{
	array<ArrayDistanceEntry> allResults

	foreach ( vec in vecArray )
	{
		ArrayDistanceEntry entry

		entry.distanceSqr = Distance2DSqr( vec, origin )
		entry.ent = null
		entry.origin = vec

		allResults.append( entry )
	}

	return allResults
}

GravityLandData function GetGravityLandData( vector startPos, vector parentVelocity, vector objectVelocity, float timeLimit, bool bDrawPath = false, float bDrawPathDuration = 0.0, array pathColor = [ 255, 255, 0 ] )
{
	GravityLandData returnData

	Assert( timeLimit > 0 )

	float MAX_TIME_ELAPSE = 6.0
	float timeElapsePerTrace = 0.1

	float sv_gravity = 750.0
	float ent_gravity = 1.0
	float gravityScale = 1.0

	vector traceStart = startPos
	vector traceEnd = traceStart
	float traceFrac
	int traceCount = 0

	objectVelocity += parentVelocity

	while( returnData.elapsedTime <= timeLimit )
	{
		objectVelocity.z -= ( ent_gravity * sv_gravity * timeElapsePerTrace * gravityScale )

		traceEnd += objectVelocity * timeElapsePerTrace
		returnData.points.append( traceEnd )
		if ( bDrawPath )
			DebugDrawLine( traceStart, traceEnd, pathColor[0], pathColor[1], pathColor[2], false, bDrawPathDuration )

		traceFrac = TraceLineSimple( traceStart, traceEnd, null )
		traceCount++
		if ( traceFrac < 1.0 )
		{
			returnData.traceResults = TraceLine( traceStart, traceEnd, null, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )
			return returnData
		}
		traceStart = traceEnd
		returnData.elapsedTime += timeElapsePerTrace
	}

	return returnData
}

float function GetPulseFrac( rate = 1, startTime = 0 )
{
	return (1 - cos( ( Time() - startTime ) * (rate * (2*PI)) )) / 2
}

bool function IsPetTitan( titan )
{
	Assert( titan.IsTitan() )

	return titan.GetTitanSoul().GetBossPlayer()	!= null
}

vector function StringToVector( string vecString, string delimiter = " " )
{
	array<string> tokens = split( vecString, delimiter )

	Assert( tokens.len() >= 3 )

	return Vector( float( tokens[0] ), float( tokens[1] ), float( tokens[2] ) )
}

float function GetShieldHealthFrac( entity ent )
{
	if ( !IsAlive( ent ) )
		return 0.0

	if ( HasSoul( ent ) )
	{
	entity soul = ent.GetTitanSoul()
		if ( IsValid( soul ) )
			ent = soul
	}

	int shieldHealth = ent.GetShieldHealth()
	int shieldMaxHealth = ent.GetShieldHealthMax()

	if ( shieldMaxHealth == 0 )
		return 0.0

	return float( shieldHealth ) / float( shieldMaxHealth )
}

vector function HackGetDeltaToRef( vector origin, vector angles, entity ent, string anim )
{
	AnimRefPoint animStartPos = ent.Anim_GetStartForRefPoint( anim, origin, angles )

	vector delta = origin - animStartPos.origin
	return origin + delta
}

vector function HackGetDeltaToRefOnPlane( vector origin, vector angles, entity ent, string anim, vector up )
{
	AnimRefPoint animStartPos = ent.Anim_GetStartForRefPoint( anim, origin, angles )

	vector delta 		= origin - animStartPos.origin
	vector nDelta 		= Normalize( delta )
	vector xProd 		= CrossProduct( nDelta, up )
	vector G 			= CrossProduct( up, xProd )
	vector planarDelta 	= G * DotProduct( delta, G )
	vector P 			= origin + planarDelta

//	DebugDrawLine( origin + delta, origin, 255, 0, 0, true, 1.0 )
//	DebugDrawLine( P, origin, 0,255, 100, true, 1.0 )

	return P
}

TraceResults function GetViewTrace( entity ent )
{
	vector traceStart = ent.EyePosition()
	vector traceEnd = traceStart + (ent.GetPlayerOrNPCViewVector() * 56756) // longest possible trace given our map size limits
	array<entity> ignoreEnts = [ ent ]

	return TraceLine( traceStart, traceEnd, ignoreEnts, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )
}

function GetModSourceID( modString )
{
	foreach ( name, id in getconsttable().eModSourceId )
	{
		if ( string( name ) == modString )
			return id
	}

	return null
}

void function ArrayRemoveDead( array<entity> entArray )
{
	for ( int i = entArray.len() - 1; i >= 0; i-- )
	{
		if ( !IsAlive( entArray[ i ] ) )
			entArray.remove( i )
	}
}

array<entity> function GetSortedPlayers( IntFromEntityCompare compareFunc, int team )
{
	array<entity> players

	if ( team )
		players = GetPlayerArrayOfTeam( team )
	else
		players = GetPlayerArray()

	players.sort( compareFunc )

	return players
}


// Sorts by kills and resolves ties in this order: fewest deaths, most titan kills, most assists
int function CompareKills( entity a, entity b )
{
	int aVal = a.GetPlayerGameStat( PGS_KILLS )
	int bVal = b.GetPlayerGameStat( PGS_KILLS )

	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	aVal = a.GetPlayerGameStat( PGS_DEATHS )
	bVal = b.GetPlayerGameStat( PGS_DEATHS )

	if ( aVal > bVal )
		return 1
	else if ( aVal < bVal )
		return -1

	aVal = a.GetPlayerGameStat( PGS_TITAN_KILLS )
	bVal = b.GetPlayerGameStat( PGS_TITAN_KILLS )

	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	aVal = a.GetPlayerGameStat( PGS_ASSISTS )
	bVal = b.GetPlayerGameStat( PGS_ASSISTS )

	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	return 0
}

// Sorts by kills and resolves ties in this order: fewest deaths, most titan kills, most assists
int function CompareAssaultScore( entity a, entity b )
{
	int aVal = a.GetPlayerGameStat( PGS_ASSAULT_SCORE )
	int bVal = b.GetPlayerGameStat( PGS_ASSAULT_SCORE )

	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	return 0
}

int function CompareScore( entity a, entity b )
{
	int aVal = a.GetPlayerGameStat( PGS_SCORE )
	int bVal = b.GetPlayerGameStat( PGS_SCORE )

	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	return 0
}

int function CompareAssault( entity a, entity b )
{
	int aVal = a.GetPlayerGameStat( PGS_ASSAULT_SCORE )
	int bVal = b.GetPlayerGameStat( PGS_ASSAULT_SCORE )

	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	return 0
}

int function CompareDefense( entity a, entity b )
{
	int aVal = a.GetPlayerGameStat( PGS_DEFENSE_SCORE )
	int bVal = b.GetPlayerGameStat( PGS_DEFENSE_SCORE )

	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	return 0
}

int function CompareLTS( entity a, entity b )
{
	int result = CompareTitanKills( a, b )
	if ( result != 0 )
		return result

	int aVal = a.GetPlayerGameStat( PGS_ASSAULT_SCORE )
	int bVal = b.GetPlayerGameStat( PGS_ASSAULT_SCORE )

	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	return 0
}

int function CompareCP( entity a, entity b )
{
	// Capture Point sorting. Sort priority = assault + defense > pilot kills > titan kills > death

	{
		int aVal = a.GetPlayerGameStat( PGS_ASSAULT_SCORE )
		int bVal = b.GetPlayerGameStat( PGS_ASSAULT_SCORE )

		aVal += a.GetPlayerGameStat( PGS_DEFENSE_SCORE )
		bVal += b.GetPlayerGameStat( PGS_DEFENSE_SCORE )

		if ( aVal < bVal )
			return 1
		else if ( aVal > bVal )
			return -1
	}

	// 3) Pilot Kills
	{
		int aVal = a.GetPlayerGameStat( PGS_KILLS )
		int bVal = b.GetPlayerGameStat( PGS_KILLS )

		if ( aVal < bVal )
			return 1
		else if ( aVal > bVal )
			return -1
	}

	// 3) Titan Kills
	{
		int aVal = a.GetPlayerGameStat( PGS_TITAN_KILLS )
		int bVal = b.GetPlayerGameStat( PGS_TITAN_KILLS )

		if ( aVal < bVal )
			return 1
		else if ( aVal > bVal )
			return -1
	}

	// 4) Deaths
	{
		int aVal = a.GetPlayerGameStat( PGS_DEATHS )
		int bVal = b.GetPlayerGameStat( PGS_DEATHS )

		if ( aVal < bVal )
			return -1
		else if ( aVal > bVal )
			return 1
	}

	return 0
}


int function CompareCTF( entity a, entity b )
{
	// Capture the flag sorting. Sort priority = flag captures > flag returns > pilot kills > titan kills > death

	// 1) Flag Captures
	int result = CompareAssault( a, b )
	if ( result != 0 )
		return result

	// 2) Flag Returns
	result = CompareDefense( a, b )
	if ( result != 0 )
		return result

	// 3) Pilot Kills
	int aVal = a.GetPlayerGameStat( PGS_KILLS )
	int bVal = b.GetPlayerGameStat( PGS_KILLS )

	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	// 3) Titan Kills
	aVal = a.GetPlayerGameStat( PGS_TITAN_KILLS )
	bVal = b.GetPlayerGameStat( PGS_TITAN_KILLS )

	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	// 4) Deaths
	aVal = a.GetPlayerGameStat( PGS_DEATHS )
	bVal = b.GetPlayerGameStat( PGS_DEATHS )

	if ( aVal < bVal )
		return -1
	else if ( aVal > bVal )
		return 1

	return 0
}

int function CompareSpeedball( entity a, entity b )
{
	// Capture the flag sorting. Sort priority = pilot kills > flag captures > death

	// 1) Pilot Kills
	int aVal = a.GetPlayerGameStat( PGS_KILLS )
	int bVal = b.GetPlayerGameStat( PGS_KILLS )

	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	// 2) Flag Captures
	int result = CompareAssault( a, b )
	if ( result != 0 )
		return result

	// 3) Deaths
	aVal = a.GetPlayerGameStat( PGS_DEATHS )
	bVal = b.GetPlayerGameStat( PGS_DEATHS )

	if ( aVal < bVal )
		return -1
	else if ( aVal > bVal )
		return 1

	return 0
}

int function CompareMFD( entity a, entity b )
{
	// 1) Marks Killed
	int result = CompareAssault( a, b )
	if ( result != 0 )
		return result

	// 2) Marks Outlasted
 	result = CompareDefense( a, b )
	if ( result != 0 )
		return result

	// 3) Pilot Kills
	int aVal = a.GetPlayerGameStat( PGS_KILLS )
	int bVal = b.GetPlayerGameStat( PGS_KILLS )

	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	// 4) Titan Kills
	aVal = a.GetPlayerGameStat( PGS_TITAN_KILLS )
	bVal = b.GetPlayerGameStat( PGS_TITAN_KILLS )

	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	// 5) Deaths
	aVal = a.GetPlayerGameStat( PGS_DEATHS )
	bVal = b.GetPlayerGameStat( PGS_DEATHS )

	if ( aVal < bVal )
		return -1
	else if ( aVal > bVal )
		return 1

	return 0
}

int function CompareScavenger( entity a, entity b )
{
	// 1) Ore Captured
	int result = CompareAssault( a, b )
	if ( result != 0 )
		return result

	// 2) Pilot Kills
	int aVal = a.GetPlayerGameStat( PGS_KILLS )
	int bVal = b.GetPlayerGameStat( PGS_KILLS )

	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	// 3) Titan Kills
	aVal = a.GetPlayerGameStat( PGS_TITAN_KILLS )
	bVal = b.GetPlayerGameStat( PGS_TITAN_KILLS )

	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	// 4) Deaths
	aVal = a.GetPlayerGameStat( PGS_DEATHS )
	bVal = b.GetPlayerGameStat( PGS_DEATHS )

	if ( aVal < bVal )
		return -1
	else if ( aVal > bVal )
		return 1

	return 0
}

int function CompareFW( entity a, entity b )
{
	// Capture Point sorting. Sort priority = assault + defense > pilot kills > titan kills > death

	{
		int aVal = a.GetPlayerGameStat( PGS_ASSAULT_SCORE )
		int bVal = b.GetPlayerGameStat( PGS_ASSAULT_SCORE )

		aVal += a.GetPlayerGameStat( PGS_DEFENSE_SCORE )
		bVal += b.GetPlayerGameStat( PGS_DEFENSE_SCORE )

		if ( aVal < bVal )
			return 1
		else if ( aVal > bVal )
			return -1
	}

	// 3) Pilot Kills
	{
		int aVal = a.GetPlayerGameStat( PGS_KILLS )
		int bVal = b.GetPlayerGameStat( PGS_KILLS )

		if ( aVal < bVal )
			return 1
		else if ( aVal > bVal )
			return -1
	}

	// 3) Titan Kills
	{
		int aVal = a.GetPlayerGameStat( PGS_TITAN_KILLS )
		int bVal = b.GetPlayerGameStat( PGS_TITAN_KILLS )

		if ( aVal < bVal )
			return 1
		else if ( aVal > bVal )
			return -1
	}

	// 4) Deaths
	{
		int aVal = a.GetPlayerGameStat( PGS_DEATHS )
		int bVal = b.GetPlayerGameStat( PGS_DEATHS )

		if ( aVal < bVal )
			return -1
		else if ( aVal > bVal )
			return 1
	}

	return 0
}

int function CompareHunter( entity a, entity b )
{
	// Capture Point sorting. Sort priority = assault + defense > pilot kills > titan kills > death

	{
		int aVal = a.GetPlayerGameStat( PGS_ASSAULT_SCORE )
		int bVal = b.GetPlayerGameStat( PGS_ASSAULT_SCORE )

		aVal += a.GetPlayerGameStat( PGS_DEFENSE_SCORE )
		bVal += b.GetPlayerGameStat( PGS_DEFENSE_SCORE )

		if ( aVal < bVal )
			return 1
		else if ( aVal > bVal )
			return -1
	}

	// 3) Pilot Kills
	{
		int aVal = a.GetPlayerGameStat( PGS_KILLS )
		int bVal = b.GetPlayerGameStat( PGS_KILLS )

		if ( aVal < bVal )
			return 1
		else if ( aVal > bVal )
			return -1
	}

	// 3) Titan Kills
	{
		int aVal = a.GetPlayerGameStat( PGS_TITAN_KILLS )
		int bVal = b.GetPlayerGameStat( PGS_TITAN_KILLS )

		if ( aVal < bVal )
			return 1
		else if ( aVal > bVal )
			return -1
	}

	// 4) Deaths
	{
		int aVal = a.GetPlayerGameStat( PGS_DEATHS )
		int bVal = b.GetPlayerGameStat( PGS_DEATHS )

		if ( aVal < bVal )
			return -1
		else if ( aVal > bVal )
			return 1
	}

	return 0
}

// Sorts by kills, deaths and then cash
int function CompareATCOOP( entity a, entity b )
{
	int aVal = a.GetPlayerGameStat( PGS_KILLS )
	int bVal = b.GetPlayerGameStat( PGS_KILLS )

	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	aVal = a.GetPlayerGameStat( PGS_DEATHS )
	bVal = b.GetPlayerGameStat( PGS_DEATHS )

	if ( aVal > bVal )
		return 1
	else if ( aVal < bVal )
		return -1

	aVal = a.GetPlayerGameStat( PGS_SCORE )
	bVal = b.GetPlayerGameStat( PGS_SCORE )

	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	return 0
}

int function CompareFD( entity a, entity b )
{
	int aVal = a.GetPlayerGameStat( PGS_DETONATION_SCORE )
	int bVal = b.GetPlayerGameStat( PGS_DETONATION_SCORE )

	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	return 0
}

int function CompareTitanKills( entity a, entity b )
{
	int aVal = a.GetPlayerGameStat( PGS_TITAN_KILLS )
	int bVal = b.GetPlayerGameStat( PGS_TITAN_KILLS )

	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	return 0
}

bool function TitanEjectIsDisabled()
{
	return GetGlobalNetBool( "titanEjectEnabled" ) == false
}

bool function IsHitEffectiveVsTitan( entity victim, int damageType )
{
	Assert( victim.IsTitan() )

	if ( victim.IsPlayer() )
	{
		if ( PlayerHasPassive( victim, ePassives.PAS_BERSERKER ) )
			return false
	}

	if ( !( damageType & DF_CRITICAL ) && ( damageType & DF_BULLET || damageType & DF_MAX_RANGE ) )
		return false

	return true
}

bool function IsHitEffectiveVsNonTitan( entity victim, int damageType )
{
	if ( damageType & DF_BULLET || damageType & DF_MAX_RANGE )
		return false;

	return true
}

bool function IsPilot( entity ent )
{
	if ( !IsValid( ent ) )
		return false

	if ( !ent.IsPlayer() )
		return false

	if ( ent.IsTitan() )
		return false

	return true
}

bool function IsPilotDecoy( entity ent )
{
	if ( !IsValid( ent ) )
		return false

	if ( ent.GetClassName() != "player_decoy" )
		return false

	return true
}

string function HardpointIDToString( int id )
{
	array<string> hardpointIDString = [ "a", "b", "c" ]

	Assert( id >= 0 && id < hardpointIDString.len() )

	return hardpointIDString[ id ]
}

string function Dev_TeamIDToString( id )
{
	if ( id == TEAM_IMC )
		return "IMC"
	if ( id == TEAM_MILITIA )
		return "MIL"

	return "UNASSIGNED/UNKNOWN TEAM NAME"
}

array<entity> function ArrayWithin( array<entity> Array, vector origin, float maxDist )
{
	float maxDistSqr = maxDist * maxDist

	array<entity> resultArray = []
	foreach ( ent in Array )
	{
		float distSqr = DistanceSqr( origin, ent.GetOrigin() )
		if ( distSqr <= maxDistSqr )
			resultArray.append( ent )
	}
	return resultArray
}

function GetTitanChassis( entity titan )
{
	if ( !("titanChassis" in titan.s ) )
	{
		if ( HasSoul( titan ) )
		{
			entity soul = titan.GetTitanSoul()
			titan.s.titanChassis <- GetSoulTitanSubClass( soul )
		}
		else
		{
			return "Invalid Chassis"
		}
	}

	return titan.s.titanChassis
}

vector function ClampVectorToCube( vector vecStart, vector vec, vector cubeOrigin, float cubeSize )
{
	float halfCubeSize = cubeSize * 0.5
	vector cubeMins = < -halfCubeSize, -halfCubeSize, -halfCubeSize >
	vector cubeMaxs = < halfCubeSize, halfCubeSize, halfCubeSize >

	return ClampVectorToBox( vecStart, vec, cubeOrigin, cubeMins, cubeMaxs )
}

vector function ClampVectorToBox( vector vecStart, vector vec, vector cubeOrigin, vector cubeMins, vector cubeMaxs )
{
	float smallestClampScale = 1.0
	vector vecEnd = vecStart + vec

	smallestClampScale = ClampVectorComponentToCubeMax( cubeOrigin.x, cubeMaxs.x, vecStart.x, vecEnd.x, vec.x, smallestClampScale )
	smallestClampScale = ClampVectorComponentToCubeMax( cubeOrigin.y, cubeMaxs.y, vecStart.y, vecEnd.y, vec.y, smallestClampScale )
	smallestClampScale = ClampVectorComponentToCubeMax( cubeOrigin.z, cubeMaxs.z, vecStart.z, vecEnd.z, vec.z, smallestClampScale )
	smallestClampScale = ClampVectorComponentToCubeMin( cubeOrigin.x, cubeMins.x, vecStart.x, vecEnd.x, vec.x, smallestClampScale )
	smallestClampScale = ClampVectorComponentToCubeMin( cubeOrigin.y, cubeMins.y, vecStart.y, vecEnd.y, vec.y, smallestClampScale )
	smallestClampScale = ClampVectorComponentToCubeMin( cubeOrigin.z, cubeMins.z, vecStart.z, vecEnd.z, vec.z, smallestClampScale )

	return vec * smallestClampScale
}

float function ClampVectorComponentToCubeMax( float cubeOrigin, float cubeSize, float vecStart, float vecEnd, float vec, float smallestClampScale )
{
	float max = cubeOrigin + cubeSize
	float clearance = fabs( vecStart - max )
	if ( vecEnd > max )
	{
		float scale = fabs( clearance / ( ( vecStart + vec ) - vecStart ) )
		if ( scale > 0 && scale < smallestClampScale )
			return scale
	}

	return smallestClampScale
}

float function ClampVectorComponentToCubeMin( float cubeOrigin, float cubeSize, float vecStart, float vecEnd, float vec, float smallestClampScale )
{
	float min = cubeOrigin - cubeSize
	float clearance = fabs( min - vecStart )
	if ( vecEnd < min )
	{
		float scale = fabs( clearance / ( ( vecStart + vec ) - vecStart ) )
		if ( scale > 0 && scale < smallestClampScale )
			return scale
	}

	return smallestClampScale
}

bool function PointInCapsule( vector vecBottom, vector vecTop, float radius, vector point )
{
	return GetDistanceFromLineSegment( vecBottom, vecTop, point ) <= radius
}

bool function PointInCylinder( vector vecBottom, vector vecTop, float radius, vector point )
{
	if ( GetDistanceFromLineSegment( vecBottom, vecTop, point ) > radius )
		return false

	vector bottomVec = Normalize( vecTop - vecBottom )
	vector pointToBottom = Normalize( point - vecBottom )

	vector topVec = Normalize( vecBottom - vecTop )
	vector pointToTop = Normalize( point - vecTop )

	if ( DotProduct( bottomVec, pointToBottom ) < 0 )
		return false

	if ( DotProduct( topVec, pointToTop ) < 0.0 )
		return false

	return true
}

float function AngleDiff( float ang, float targetAng )
{
	float delta = ( targetAng - ang ) % 360.0
	if ( targetAng > ang )
	{
		if ( delta >= 180.0 )
			delta -= 360.0;
	}
	else
	{
		if ( delta <= -180.0 )
			delta += 360.0;
	}
	return delta
}


float function ClampAngle( float ang )
{
	while( ang > 360 )
		ang -= 360
	while( ang < 0 )
		ang += 360
	return ang
}

float function ClampAngle180( float ang )
{
	while( ang > 180 )
		ang -= 180
	while( ang < -180 )
		ang += 180
	return ang
}

vector function ShortestRotation( vector ang, vector targetAng )
{
	return Vector( AngleDiff( ang.x, targetAng.x ), AngleDiff( ang.y, targetAng.y ), AngleDiff( ang.z, targetAng.z ) )
}

int function GetWinningTeam()
{
	if ( level.nv.winningTeam != null )
		return expect int( level.nv.winningTeam )

	if ( IsFFAGame() )
		return GetWinningTeam_FFA()

	if ( IsRoundBased() )
	{
		if ( GameRules_GetTeamScore2( TEAM_IMC ) > GameRules_GetTeamScore2( TEAM_MILITIA ) )
			return TEAM_IMC

		if ( GameRules_GetTeamScore2( TEAM_MILITIA ) > GameRules_GetTeamScore2( TEAM_IMC ) )
			return TEAM_MILITIA
	}
	else
	{
		if ( GameRules_GetTeamScore( TEAM_IMC ) > GameRules_GetTeamScore( TEAM_MILITIA ) )
			return TEAM_IMC

		if ( GameRules_GetTeamScore( TEAM_MILITIA ) > GameRules_GetTeamScore( TEAM_IMC ) )
			return TEAM_MILITIA
	}

	return TEAM_UNASSIGNED
}

int function GetWinningTeam_FFA()
{
	if ( level.nv.winningTeam != null )
		return expect int( level.nv.winningTeam )

	int maxScore = 0
	int playerTeam
	int currentScore
	int winningTeam = TEAM_UNASSIGNED

	foreach( player in GetPlayerArray() )
	{
		playerTeam = player.GetTeam()
		if ( IsRoundBased() )
			currentScore = GameRules_GetTeamScore2( playerTeam )
		else
			currentScore = GameRules_GetTeamScore( playerTeam )

		if ( currentScore == maxScore) //Treat multiple teams as having the same score as no team winning
			winningTeam = TEAM_UNASSIGNED

		if ( currentScore > maxScore )
		{
			maxScore = currentScore
			winningTeam = playerTeam
		}
	}

	return winningTeam

}

void function EmitSkyboxSoundAtPosition( vector positionInSkybox, string sound, float skyboxScale = 0.001, bool clamp = false )
{
	if ( IsServer() )
		clamp = true // sounds cannot play outside 16k limit on server
	vector position = SkyboxToWorldPosition( positionInSkybox, skyboxScale, clamp )
	EmitSoundAtPosition( TEAM_UNASSIGNED, position, sound )
}

vector function SkyboxToWorldPosition( vector positionInSkybox, float skyboxScale = 0.001, bool clamp = true )
{
	Assert( skyboxScale > 0 )
	Assert( "skyboxCamOrigin" in level )

	vector position = Vector( 0.0, 0.0, 0.0 )
	vector skyOrigin = expect vector( level.skyboxCamOrigin )

	#if CLIENT
		position = ( positionInSkybox - skyOrigin ) * ( 1.0 / skyboxScale )

		if ( clamp )
		{
			entity localViewPlayer = GetLocalViewPlayer()
			Assert( localViewPlayer )
			vector localViewPlayerOrg = localViewPlayer.GetOrigin()

			position = localViewPlayerOrg + ClampVectorToCube( localViewPlayerOrg, position - localViewPlayerOrg, Vector( 0.0, 0.0, 0.0 ), 32000.0 )
		}
	#else
		position = ( positionInSkybox - skyOrigin ) * ( 1.0 / skyboxScale )

		if ( clamp )
			position = ClampVectorToCube( Vector( 0.0, 0.0, 0.0 ), position, Vector( 0.0, 0.0, 0.0 ), 32000.0 )
	#endif // CLIENT

	return position
}

void function FadeOutSoundOnEntityAfterDelay( entity ent, string soundAlias, float delay, float fadeTime )
{
	if ( !IsValid( ent ) )
		return

	ent.EndSignal( "OnDestroy" )
	wait delay
	FadeOutSoundOnEntity( ent, soundAlias, fadeTime )
}

function GetRandomKeyFromWeightedTable( Table )
{
	local weightTotal = 0.0
	foreach ( key, value in Table )
	{
		weightTotal += value
	}

	local randomValue = RandomFloat( weightTotal )

	foreach ( key, value in Table )
	{
		if ( randomValue <= weightTotal && randomValue >= weightTotal - value)
			 return key
		weightTotal -= value
	}
}

bool function IsMatchOver()
{
	if ( IsRoundBased() && level.nv.gameEndTime )
		return true
	else if ( !IsRoundBased() && level.nv.gameEndTime && Time() > level.nv.gameEndTime )
		return true

	return false
}

bool function IsScoringNonStandard()
{
	return expect bool( level.nv.nonStandardScoring )
}

bool function IsRoundBased()
{
	return expect bool( level.nv.roundBased )
}

int function GetRoundsPlayed()
{
	return expect int( level.nv.roundsPlayed )
}

bool function IsEliminationBased()
{
	return Riff_EliminationMode() != eEliminationMode.Default
}

bool function IsPilotEliminationBased()
{
	return ( Riff_EliminationMode() == eEliminationMode.Pilots || Riff_EliminationMode() == eEliminationMode.PilotsTitans )
}

bool function IsTitanEliminationBased()
{
	return ( Riff_EliminationMode() == eEliminationMode.Titans || Riff_EliminationMode() == eEliminationMode.PilotsTitans )
}

bool function IsSingleTeamMode()
{
	return ( 1 == GetCurrentPlaylistVarInt( "max_teams", 2 ) )
}

void function __WarpInEffectShared( vector origin, vector angles, string sfx, float preWaitOverride = -1.0 )
{
	float preWait = 2.0
	float sfxWait = 0.1
	float totalTime = WARPINFXTIME

	if ( sfx == "" )
		sfx = "dropship_warpin"

	if ( preWaitOverride >= 0.0 )
		wait preWaitOverride
	else
		wait preWait  //this needs to go and the const for warpin fx time needs to change - but not this game - the intro system is too dependent on it

	#if CLIENT
		int fxIndex = GetParticleSystemIndex( FX_GUNSHIP_CRASH_EXPLOSION_ENTRANCE )
		StartParticleEffectInWorld( fxIndex, origin, angles )
	#else
		entity fx = PlayFX( FX_GUNSHIP_CRASH_EXPLOSION_ENTRANCE, origin, angles )
		fx.FXEnableRenderAlways()
		fx.DisableHibernation()
	#endif // CLIENT

	wait sfxWait
	EmitSoundAtPosition( TEAM_UNASSIGNED, origin, sfx )

	wait totalTime - preWait - sfxWait
}

void function __WarpOutEffectShared( entity dropship )
{
	int attach = dropship.LookupAttachment( "origin" )
	vector origin = dropship.GetAttachmentOrigin( attach )
	vector angles = dropship.GetAttachmentAngles( attach )

	#if CLIENT
		int fxIndex = GetParticleSystemIndex( FX_GUNSHIP_CRASH_EXPLOSION_EXIT )
		StartParticleEffectInWorld( fxIndex, origin, angles )
	#else
		entity fx = PlayFX( FX_GUNSHIP_CRASH_EXPLOSION_EXIT, origin, angles )
		fx.FXEnableRenderAlways()
		fx.DisableHibernation()
	#endif // CLIENT

	EmitSoundAtPosition( TEAM_UNASSIGNED, origin, "dropship_warpout" )
}

bool function IsSwitchSidesBased()
{
	return (level.nv.switchedSides != null)
}

int function HasSwitchedSides() //This returns an int instead of a bool! Should rewrite
{
	return expect int( level.nv.switchedSides )
}

bool function IsFirstRoundAfterSwitchingSides()
{
	if ( !IsSwitchSidesBased() )
		return false

	if ( IsRoundBased() )
		return  level.nv.switchedSides > 0 && GetRoundsPlayed() == level.nv.switchedSides
	else
		return  level.nv.switchedSides > 0

	unreachable
}

void function CamBlendFov( entity cam, float oldFov, float newFov, float transTime, float transAccel, float transDecel )
{
	if ( !IsValid( cam ) )
		return

	cam.EndSignal( "OnDestroy" )

	float currentTime = Time()
	float startTime = currentTime
	float endTime = startTime + transTime

	while ( endTime > currentTime )
	{
		float interp = Interpolate( startTime, endTime - startTime, transAccel, transDecel )
		cam.SetFOV( GraphCapped( interp, 0.0, 1.0, oldFov, newFov ) )
		wait( 0.0 )
		currentTime = Time()
	}
}

void function CamFollowEnt( entity cam, entity ent, float duration, vector offset = <0.0, 0.0, 0.0>, string attachment = "", bool isInSkybox = false )
{
	if ( !IsValid( cam ) )
		return

	cam.EndSignal( "OnDestroy" )

	vector camOrg = Vector( 0.0, 0.0, 0.0 )

	vector targetPos = Vector( 0.0, 0.0, 0.0 )
	float currentTime = Time()
	float startTime = currentTime
	float endTime = startTime + duration
	vector diff = Vector( 0.0, 0.0, 0.0 )
	int attachID = ent.LookupAttachment( attachment )

	while ( endTime > currentTime )
	{
		camOrg = cam.GetOrigin()

		if ( attachID <= 0 )
			targetPos = ent.GetOrigin()
		else
			targetPos = ent.GetAttachmentOrigin( attachID )

		if ( isInSkybox )
			targetPos = SkyboxToWorldPosition( targetPos )
		diff = ( targetPos + offset ) - camOrg

		cam.SetAngles( VectorToAngles( diff ) )

		wait( 0.0 )

		currentTime = Time()
	}
}

void function CamFacePos( entity cam, vector pos, float duration )
{
	if ( !IsValid( cam ) )
		return

	cam.EndSignal( "OnDestroy" )

	float currentTime = Time()
	float startTime = currentTime
	float endTime = startTime + duration
	vector diff = Vector( 0.0, 0.0, 0.0 )

	while ( endTime > currentTime )
	{
		diff = pos - cam.GetOrigin()

		cam.SetAngles( VectorToAngles( diff ) )

		wait( 0.0 )

		currentTime = Time()
	}
}

void function CamBlendFromFollowToAng( entity cam, entity ent, vector endAng, float transTime, float transAccel, float transDecel )
{
	if ( !IsValid( cam ) )
		return

	cam.EndSignal( "OnDestroy" )

	vector camOrg = cam.GetOrigin()

	float currentTime = Time()
	float startTime = currentTime
	float endTime = startTime + transTime

	while ( endTime > currentTime )
	{
		vector diff = ent.GetOrigin() - camOrg
		vector anglesToEnt = VectorToAngles( diff )

		float frac = Interpolate( startTime, endTime - startTime, transAccel, transDecel )

		vector newAngs = anglesToEnt + ShortestRotation( anglesToEnt, endAng ) * frac

		cam.SetAngles( newAngs )

		wait( 0.0 )

		currentTime = Time()
	}
}

void function CamBlendFromPosToPos( entity cam, vector startPos, vector endPos, float transTime, float transAccel, float transDecel )
{
	if ( !IsValid( cam ) )
		return

	cam.EndSignal( "OnDestroy" )

	float currentTime = Time()
	float startTime = currentTime
	float endTime = startTime + transTime
	vector diff = endPos - startPos

	while ( endTime > currentTime )
	{
		float frac = Interpolate( startTime, endTime - startTime, transAccel, transDecel )

		vector newAngs = startPos + diff * frac

		cam.SetOrigin( newAngs )

		wait( 0.0 )

		currentTime = Time()
	}
}

void function CamBlendFromAngToAng( entity cam, vector startAng, vector endAng, float transTime, float transAccel, float transDecel )
{
	if ( !IsValid( cam ) )
		return

	cam.EndSignal( "OnDestroy" )

	float currentTime = Time()
	float startTime = currentTime
	float endTime = startTime + transTime

	while ( endTime > currentTime )
	{
		float frac = Interpolate( startTime, endTime - startTime, transAccel, transDecel )

		vector newAngs = startAng + ShortestRotation( startAng, endAng ) * frac

		cam.SetAngles( newAngs )

		wait( 0.0 )

		currentTime = Time()
	}
}

int function AddBitMask( int bitsExisting, int bitsToAdd )
{
	return bitsExisting | bitsToAdd
}

int function RemoveBitMask( int bitsExisting, int bitsToRemove )
{
	return bitsExisting & ( ~bitsToRemove )
}

bool function HasBitMask( int bitsExisting, int bitsToCheck )
{
	int bitsCommon = bitsExisting & bitsToCheck
	return bitsCommon == bitsToCheck
}

float function GetDeathCamLength( entity player )
{
	if ( !GamePlayingOrSuddenDeath() )
		return DEATHCAM_TIME_SHORT
	else
		return DEATHCAM_TIME

	unreachable
}

float function GetRespawnButtonCamTime( player )
{
	if ( !GamePlayingOrSuddenDeath() )
		return DEATHCAM_TIME_SHORT + RESPAWN_BUTTON_BUFFER
	else
		return DEATHCAM_TIME + RESPAWN_BUTTON_BUFFER

	unreachable
}

float function GetKillReplayAfterTime( player )
{
	if ( IsSingleplayer() )
		return 4.0

	if ( !GamePlayingOrSuddenDeath() )
		return KILL_REPLAY_AFTER_KILL_TIME_SHORT

	return KILL_REPLAY_AFTER_KILL_TIME
}

function IntroPreviewOn()
{
	local bugnum = GetBugReproNum()
	switch( bugnum )
	{
		case 1337:
		case 13371:
		case 13372:
		case 13373:
		case 1338:
		case 13381:
		case 13382:
		case 13383:
			return bugnum

		default:
			return null
	}
}

bool function EntHasModelSet( entity ent )
{
	asset modelName = ent.GetModelName()

	if ( modelName == $"" || modelName == $"?" )
		return false

	return true
}

string function GenerateTitanOSAlias( entity player, string aliasSuffix )
{
	//HACK: Temp fix for blocker bug. Fixing correctly next.
	if ( IsSingleplayer() )
	{
		return "diag_gs_titanBt_" + aliasSuffix
	}
	else
	{
		entity titan
		if ( player.IsTitan() )
			titan = player
		else
			titan = player.GetPetTitan()

		Assert( IsValid( titan ) )
		string titanCharacterName = GetTitanCharacterName( titan )
		string primeTitanString = ""

		if ( IsTitanPrimeTitan( titan ) )
			primeTitanString = "_prime"

		string modifiedAlias = "diag_gs_titan" + titanCharacterName + primeTitanString + "_" + aliasSuffix
		return modifiedAlias
	}
	unreachable
}

void function AddCallback_OnUseEntity( entity ent, callbackFunc )
{
	AssertParameters( callbackFunc, 2, "ent, player" )

	if ( !( "onUseEntityCallbacks" in ent.s ) )
		ent.s.onUseEntityCallbacks <- []

	Assert( !ent.s.onUseEntityCallbacks.contains( callbackFunc ), "Already added " + FunctionToString( callbackFunc ) + " with AddCalback_OnUseEntity" )
	ent.s.onUseEntityCallbacks.append( callbackFunc )
}

void function SetWaveSpawnType( int spawnType )
{
	shGlobal.waveSpawnType = spawnType
}

int function GetWaveSpawnType()
{
	return shGlobal.waveSpawnType
}

void function SetWaveSpawnInterval( float interval )
{
	shGlobal.waveSpawnInterval = interval
}

float function GetWaveSpawnInterval()
{
	return shGlobal.waveSpawnInterval
}

bool function IsArcTitan( entity npc )
{
	return npc.GetAISettingsName() == "npc_titan_arc"
}

bool function IsNukeTitan( entity npc )
{
	return npc.GetAISettingsName() == "npc_titan_nuke"
}

bool function IsMortarTitan( entity npc )
{
	return npc.GetAISettingsName() == "npc_titan_mortar"
}

bool function IsFragDrone( entity npc )
{
	#if SERVER
		return npc.GetClassName() == "npc_frag_drone"
	#endif

	#if CLIENT
		return npc.GetSignifierName() == "npc_frag_drone"
	#endif
}

bool function IsSniperSpectre( entity npc )
{
	return false
}

bool function IsVortexSphere( entity ent )
{
	return ( ent.GetClassName() == "vortex_sphere" )
}

bool function PointIsWithinBounds( vector point, vector mins, vector maxs )
{
	Assert( mins.x < maxs.x )
	Assert( mins.y < maxs.y )
	Assert( mins.z < maxs.z )

	return ( ( point.z >= mins.z && point.z <= maxs.z ) &&
			 ( point.x >= mins.x && point.x <= maxs.x ) &&
			 ( point.y >= mins.y && point.y <= maxs.y ) )
}

int function GetSpStartIndex()
{
	//HACK -> this should use some other code driven thing, not GetBugReproNum
	int index = GetBugReproNum()

	if ( index < 0 )
		return 0

	return index
}

// return all living soldiers
array<entity> function GetAllSoldiers()
{
	return GetNPCArrayByClass( "npc_soldier" )
}

int function GameTeams_GetNumLivingPlayers( int teamIndex = TEAM_ANY )
{
	int noOfLivingPlayers = 0

	array<entity> players
	if ( teamIndex == TEAM_ANY )
		players = GetPlayerArray()
	else
		players = GetPlayerArrayOfTeam( teamIndex )

	foreach ( player in players )
	{
		if ( !IsAlive( player ) )
			continue

		++noOfLivingPlayers
	}

	return noOfLivingPlayers
}

bool function GameTeams_TeamHasDeadPlayers( int team )
{
	array<entity> teamPlayers = GetPlayerArrayOfTeam( team )
	foreach ( entity teamPlayer in teamPlayers )
	{
		if ( !IsAlive( teamPlayer ) )
			return true
	}
	return false
}

typedef EntitiesDidLoadCallbackType void functionref()
array<EntitiesDidLoadCallbackType> _EntitiesDidLoadTypedCallbacks

void function RunCallbacks_EntitiesDidLoad()
{
	// reloading the level so don't do callbacks
	if ( "forcedReloading" in level )
		return

	foreach ( callback in _EntitiesDidLoadTypedCallbacks )
	{
		thread callback()
	}
}

void function AddCallback_EntitiesDidLoad( EntitiesDidLoadCallbackType callback )
{
	_EntitiesDidLoadTypedCallbacks.append( callback )
}

bool function IsTitanNPC( entity ent )
{
	return ent.IsTitan() && ent.IsNPC()
}

entity function InflictorOwner( entity inflictor )
{
	if ( IsValid( inflictor ) )
	{
		entity inflictorOwner = inflictor.GetOwner()
		if ( IsValid( inflictorOwner ) )
			inflictor = inflictorOwner
	}

	return inflictor
}

bool function IsPlayerControlledSpectre( entity ent )
{
	return ent.GetClassName() == "npc_spectre" && ent.GetBossPlayer() != null
}

bool function IsPlayerControlledTurret( entity ent )
{
	return IsTurret( ent ) && ent.GetBossPlayer() != null
}

bool function TitanShieldDecayEnabled()
{
	return ( GetCurrentPlaylistVarInt( "titan_shield_decay", 0 ) == 1 )
}

bool function TitanShieldRegenEnabled()
{
	return ( GetCurrentPlaylistVarInt( "titan_shield_regen", 0 ) == 1 )
}

bool function DoomStateDisabled()
{
	return ( GetCurrentPlaylistVarString( "titan_doomstate_variation", "default" ) == "disabled" || GetCurrentPlaylistVarString( "titan_doomstate_variation", "default" ) == "lastsegment" )
}

bool function NoWeaponDoomState()
{
	return ( GetCurrentPlaylistVarString( "titan_doomstate_variation", "default" ) == "noweapon" )
}

entity function GetPetTitanOwner( entity titan )
{
	array<entity> players = GetPlayerArray()
	entity foundPlayer
	foreach ( player in players )
	{
		if ( player.GetPetTitan() == titan )
		{
			Assert( foundPlayer == null, player + " and " + foundPlayer + " both own " + titan )
			foundPlayer = player
		}
	}

	return foundPlayer
}

entity function GetSoulFromPlayer( entity player )
{
	Assert( player.IsPlayer(), "argument should be a player" )

	if ( player.IsTitan() )
		return player.GetTitanSoul()
	else if ( IsValid( player.GetPetTitan() ) )
		return player.GetPetTitan().GetTitanSoul()

	return null
}

string function GetPlayerBodyType( player )
{
	return expect string( player.GetPlayerSettingsField( "weaponClass" ) )
}


void function SetTeam( entity ent, int team )
{
	#if CLIENT
		ent.Code_SetTeam( team )
	#else
		if ( ent.IsPlayer() )
		{
			ent.Code_SetTeam( team )
		}
		else if ( ent.IsNPC() )
		{
			int currentTeam = ent.GetTeam()
			bool alreadyAssignedValidTeam = ( currentTeam == TEAM_IMC || currentTeam == TEAM_MILITIA )

			ent.Code_SetTeam( team )

			if ( ent.GetModelName() == $"" )
				return

			FixupTitle( ent )

			if ( IsGrunt( ent ) || IsSpectre( ent ) )
			{
				if ( IsMultiplayer() )
				{
					int eHandle = ent.GetEncodedEHandle()

					array<entity> players = GetPlayerArray()
					foreach ( player in players )
					{
						Remote_CallFunction_Replay( player, "ServerCallback_UpdateOverheadIconForNPC", eHandle )
					}
				}
			}
			else if ( IsShieldDrone( ent ) )
			{
				if ( team == 0 )
				{
					// anybody can use neutral shield drone
					ent.SetUsable()
				}
				else
				{
					// only friendlies use a team shield drone
					ent.SetUsableByGroup( "friendlies pilot" )
				}
			}

			table modelTable = ent.CreateTableFromModelKeyValues()

			if ( !( "teamSkin" in modelTable ) )
				return

			if ( alreadyAssignedValidTeam && ( !( "swapTeamOnLeech" in modelTable.teamSkin ) ) )
				return

			SetSkinForTeam( ent, team )
		}
		else
		{
			ent.Code_SetTeam( team )
		}
	#endif
}

void function PrintTraceResults( TraceResults results )
{
	printt( "TraceResults: " )
	printt( "=========================" )
	printt( "hitEnt: " + results.hitEnt )
	printt( "endPos: " + results.endPos )
	printt( "surfaceNormal: " + results.surfaceNormal )
	printt( "surfaceName: " + results.surfaceName )
	printt( "fraction: " + results.fraction )
	printt( "fractionLeftSolid: " + results.fractionLeftSolid )
	printt( "hitGroup: " + results.hitGroup )
	printt( "startSolid: " + results.startSolid )
	printt( "allSolid: " + results.allSolid )
	printt( "hitSky: " + results.hitSky )
	printt( "contents: " + results.contents )
	printt( "=========================" )
}

bool function PROTO_AlternateDoomedState()
{
	return ( GetCurrentPlaylistVarInt( "infinite_doomed_state", 1 ) == 1 )
}

bool function PROTO_VariableRegenDelay()
{
	return ( GetCurrentPlaylistVarInt( "variable_regen_delay", 1 ) == 1 )
}

bool function PROTO_AutoTitansDisabled()
{
	return ( GetCurrentPlaylistVarInt( "always_enable_autotitans", 1 ) == 0 )
}

bool function TitanDamageRewardsTitanCoreTime()
{
	if ( GetCurrentPlaylistVarInt( "titan_core_from_titan_damage", 0 ) != 0 )
		return true
	return false
}

vector function ClampToMap( vector pos )
{
	return IterateAxis( pos, LimitAxisToMapExtents )
}

vector function IterateAxis( vector pos, float functionref( float ) func )
{
	pos.x = func( pos.x )
	pos.y = func( pos.y )
	pos.z = func( pos.z )
	return pos
}

float function LimitAxisToMapExtents( float axisVal )
{
	if ( axisVal >= MAP_EXTENTS )
		axisVal = MAP_EXTENTS - 1
	else if ( axisVal <= -MAP_EXTENTS )
		axisVal = -( MAP_EXTENTS - 1 )
	return axisVal
}

bool function PilotSpawnOntoTitanIsEnabledInPlaylist( entity player )
{
	if ( GetCurrentPlaylistVarInt( "titan_spawn_deploy_enabled", 0 ) != 0 )
		return true
	return false
}

bool function PlayerCanSpawnIntoTitan( entity player )
{
	if ( !PilotSpawnOntoTitanIsEnabledInPlaylist( player ) )
		return false

	entity titan = player.GetPetTitan()

	if ( !IsAlive( titan ) )
		return false

	if ( GetDoomedState( titan ) )
		return false

	if ( titan.ContextAction_IsActive() )
		return false

	return false // turned off until todd figures out how to enable
}

array< vector > function EntitiesToOrigins( array< entity > ents )
{
	array<vector> origins

	foreach ( ent in ents )
	{
		origins.append( ent.GetOrigin() )
	}

	return origins
}

vector function GetMedianOriginOfEntities( array<entity> ents )
{
	array<vector> origins = EntitiesToOrigins( ents )
	return GetMedianOrigin( origins )
}

vector function GetMedianOrigin( array<vector> origins )
{
	if ( origins.len() == 1 )
		return origins[0]

	vector median

	int middleIndex1
	int middleIndex2

	if ( IsEven( origins.len() ) )
	{
		middleIndex1 = origins.len() / 2
		middleIndex2 = middleIndex1
	}
	else
	{
		middleIndex1 = int( floor( origins.len() / 2.0 ) )
		middleIndex2 = middleIndex1 + 1
	}

	origins.sort( CompareVecX )
	median.x = ( origins[ middleIndex1 ].x + origins[ middleIndex2 ].x ) / 2.0

	origins.sort( CompareVecY )
	median.y = ( origins[ middleIndex1 ].y + origins[ middleIndex2 ].y ) / 2.0

	origins.sort( CompareVecZ )
	median.z = ( origins[ middleIndex1 ].z + origins[ middleIndex2 ].z ) / 2.0

	return median
}

int function CompareVecX( vector a, vector b )
{
	if ( a.x > b.x )
		return 1

	return -1
}

int function CompareVecY( vector a, vector b )
{
	if ( a.y > b.y )
		return 1

	return -1
}

int function CompareVecZ( vector a, vector b )
{
	if ( a.z > b.z )
		return 1

	return -1
}

float function GetFractionAlongPath( array<entity> nodes, vector p )
{
	float totalDistance = GetPathDistance( nodes )

	// See which segment we are currently on (closest to)
	int closestSegment = -1
	float closestDist = 9999
	for( int i = 0 ; i < nodes.len() - 1; i++ )
	{
		float dist = GetDistanceSqrFromLineSegment( nodes[i].GetOrigin(), nodes[i + 1].GetOrigin(), p )
		if ( closestSegment < 0 || dist < closestDist )
		{
			closestSegment = i
			closestDist = dist
		}
	}
	Assert( closestSegment >= 0 )
	Assert( closestSegment < nodes.len() - 1 )

	// Get the distance along the path already traveled
	float distTraveled = 0.0
	for( int i = 0 ; i < closestSegment; i++ )
	{
		//DebugDrawLine( nodes[i].GetOrigin(), nodes[i + 1].GetOrigin(), 255, 255, 0, true, 0.1 )
		distTraveled += Distance( nodes[i].GetOrigin(), nodes[i+1].GetOrigin() )
	}

	// Add the distance traveled on current segment
	vector closestPointOnSegment = GetClosestPointOnLineSegment( nodes[closestSegment].GetOrigin(), nodes[closestSegment + 1].GetOrigin(), p )
	//DebugDrawLine( nodes[closestSegment].GetOrigin(), closestPointOnSegment, 255, 255, 0, true, 0.1 )
	distTraveled += Distance( nodes[closestSegment].GetOrigin(), closestPointOnSegment )

	return clamp( distTraveled / totalDistance, 0.0, 1.0 )
}

float function GetPathDistance( array<entity> nodes )
{
	float totalDist = 0.0
	for( int i = 0 ; i < nodes.len() - 1; i++ )
	{
		//DebugDrawSphere( nodes[i].GetOrigin(), 16.0, 255, 0, 0, true, 0.1 )
		totalDist += Distance( nodes[i].GetOrigin(), nodes[i+1].GetOrigin() )
	}
	//DebugDrawSphere( nodes[nodes.len() -1].GetOrigin(), 16.0, 255, 0, 0, true, 0.1 )

	return totalDist
}

void function WaittillAnimDone( entity animatingEnt )
{
	waitthread WaittillAnimDone_Thread( animatingEnt )
}

void function WaittillAnimDone_Thread( entity animatingEnt )
{
	if ( animatingEnt.IsPlayer() )
		animatingEnt.EndSignal( "OnDestroy" )

	animatingEnt.EndSignal( "OnAnimationInterrupted" )
	animatingEnt.WaitSignal( "OnAnimationDone" )
}

array<entity> function GetEntityLinkChain( entity startNode )
{
	Assert( IsValid( startNode ) )
	array<entity> nodes
	nodes.append( startNode )
	while(true)
	{
		entity nextNode = nodes[nodes.len() - 1].GetLinkEnt()
		if ( !IsValid( nextNode ) )
			break
		nodes.append( nextNode )
	}
	return nodes
}

float function HealthRatio( entity ent )
{
	int health = ent.GetHealth()
	int maxHealth = ent.GetMaxHealth()
	return float( health ) / maxHealth
}

vector function GetPointOnPathForFraction( array<entity> nodes, float frac )
{
	Assert( frac >= 0 )

	float totalPathDist = GetPathDistance( nodes )
	float distRemaining = totalPathDist * frac
	vector point = nodes[0].GetOrigin()

	for( int i = 0 ; i < nodes.len() - 1; i++ )
	{
		float segmentDist = Distance( nodes[i].GetOrigin(), nodes[i+1].GetOrigin() )
		if ( segmentDist <= distRemaining )
		{
			// Add the whole segment
			distRemaining -= segmentDist
			point = nodes[i+1].GetOrigin()
		}
		else
		{
			// Fraction ends somewhere in this segment
			vector dirVec = Normalize( nodes[i+1].GetOrigin() - nodes[i].GetOrigin() )
			point = nodes[i].GetOrigin() + ( dirVec * distRemaining )
			distRemaining = 0
		}
		if ( distRemaining <= 0 )
			break
	}

	if ( frac > 1.0 && distRemaining > 0 )
	{
		vector dirVec = Normalize( nodes[nodes.len() - 1].GetOrigin() - nodes[nodes.len() - 2].GetOrigin() )
		point = nodes[nodes.len() - 1].GetOrigin() + ( dirVec * distRemaining )
	}

	return point
}

bool function PlayerBlockedByTeamEMP( entity player )
{
	return ( player.nv.empEndTime > Time() )
}

#if SERVER
void function Embark_Allow( entity player )
{
	player.SetTitanEmbarkEnabled( true )
}

void function Embark_Disallow( entity player )
{
	player.SetTitanEmbarkEnabled( false )
}

void function Disembark_Allow( entity player )
{
	player.SetTitanDisembarkEnabled( true )
}

void function Disembark_Disallow( entity player )
{
	player.SetTitanDisembarkEnabled( false )
}
#endif

bool function CanEmbark( entity player )
{
	return player.GetTitanEmbarkEnabled()
}

bool function CanDisembark( entity player )
{
	return player.GetTitanDisembarkEnabled()
}

string function GetDroneType( entity npc )
{
	return expect string( npc.Dev_GetAISettingByKeyField( "drone_type" ) )
}

vector function FlattenVector( vector vec )
{
	return Vector( vec.x, vec.y, 0 )
}

vector function FlattenAngles( vector angles )
{
	return Vector( 0, angles.y, 0 )
}

bool function IsHumanSized( entity ent )
{
	if ( ent.IsPlayer() )
		return ent.IsHuman()

	if ( ent.IsNPC() )
	{

		if ( ent.GetAIClass() == AIC_SMALL_TURRET )
			return true

		string bodyType = ent.GetBodyType()
		return bodyType == "human" || bodyType == "marvin"
	}

	return false
}

bool function IsDropship( entity ent )
{
#if SERVER
	return ent.GetClassName() == "npc_dropship"
#elseif CLIENT
	if ( !ent.IsNPC() )
		return false
	//Probably should not use GetClassName, but npc_dropship isn't a class so can't use instanceof?
	return ( ent.GetClassName() == "npc_dropship" || ent.GetSignifierName() == "npc_dropship" )
#endif
}

bool function IsSpecialist( entity ent )
{
	return IsGrunt( ent ) && ent.IsMechanical()
}

bool function IsGrunt( entity ent )
{
#if SERVER
	return ent.IsNPC() && ent.GetClassName() == "npc_soldier"
#elseif CLIENT
	return ent.IsNPC() && ent.GetSignifierName() == "npc_soldier"
#endif
}

bool function IsMarvin( entity ent )
{
	return ent.IsNPC() && ent.GetAIClass() == AIC_MARVIN
}

bool function IsSpectre( entity ent )
{
	return ent.IsNPC() && ent.GetAIClass() == AIC_SPECTRE
}

bool function IsWorldSpawn( entity ent )
{
	#if SERVER
		return ent.GetClassName() == "worldspawn"
	#elseif CLIENT
		return ent.GetSignifierName() == "worldspawn"
	#endif
}

bool function IsEnvironment( entity ent )
{
	#if SERVER
		return ent.GetClassName() == "trigger_hurt"
	#elseif CLIENT
		return ent.GetSignifierName() == "trigger_hurt"
	#endif
}

bool function IsSuperSpectre( entity ent )
{
#if SERVER
	return ent.GetClassName() == "npc_super_spectre"
#elseif CLIENT
	return ent.GetSignifierName() == "npc_super_spectre"
#endif
}

bool function IsAndroidNPC( entity ent )
{
	return ( IsSpectre( ent ) || IsStalker( ent ) || IsMarvin( ent ) )
}

bool function IsStalker( entity ent )
{
	return ent.IsNPC() && ( ent.GetAIClass() == AIC_STALKER || ent.GetAIClass() == AIC_STALKER_CRAWLING )
}

bool function IsProwler( entity ent )
{
#if SERVER
	return ent.GetClassName() == "npc_prowler"
#elseif CLIENT
	return ent.GetSignifierName() == "npc_prowler"
#endif
}

bool function IsAirDrone( entity ent )
{
#if SERVER
	return ent.GetClassName() == "npc_drone"
#elseif CLIENT
	return ent.GetSignifierName() == "npc_drone"
#endif
}

bool function IsPilotElite( entity ent )
{
#if SERVER
	return ent.GetClassName() == "npc_pilot_elite"
#elseif CLIENT
	return ent.GetSignifierName() == "npc_pilot_elite"
#endif
}

bool function IsAttackDrone( entity ent )
{
	return ( ent.IsNPC() && !ent.IsNonCombatAI() && IsAirDrone( ent ) )
}

bool function IsGunship( entity ent )
{
#if SERVER
	return ent.GetClassName() == "npc_gunship"
#elseif CLIENT
	return ent.GetSignifierName() == "npc_gunship"
#endif
}

bool function IsMinion( entity ent )
{
	if ( IsGrunt( ent ) )
		return true

	if ( IsSpectre( ent ) )
		return true

	return false
}

bool function IsShieldDrone( entity ent )
{
#if SERVER
	if ( ent.GetClassName() != "npc_drone" )
		return false
#elseif CLIENT
	if ( ent.GetSignifierName() != "npc_drone" )
		return false
#endif

	return GetDroneType( ent ) == "drone_type_shield"
}

#if SERVER
bool function IsTick( entity ent )
{
	return (ent.IsNPC() && (ent.GetAIClass() == AIC_FRAG_DRONE))
}

bool function IsNPCTitan( entity ent )
{
	return ent.IsNPC() && ent.IsTitan()
}
#endif

bool function NPC_GruntChatterSPEnabled( entity npc )
{
	if ( !IsSingleplayer() )
		return false

	if ( !npc.IsNPC() )
		return false

	if ( npc.GetClassName() != "npc_soldier" )
		return false

	return true
}

RaySphereIntersectStruct function IntersectRayWithSphere( vector rayStart, vector rayEnd, vector sphereOrigin, float sphereRadius )
{
	RaySphereIntersectStruct intersection

	vector vecSphereToRay = rayStart - sphereOrigin

	vector vecRayDelta = rayEnd - rayStart
	float a = DotProduct( vecRayDelta, vecRayDelta )

	if ( a == 0.0 )
	{
		intersection.result = LengthSqr( vecSphereToRay ) <= sphereRadius * sphereRadius
		intersection.enterFrac = 0.0
		intersection.leaveFrac = 0.0
		return intersection
	}

	float b = 2 * DotProduct( vecSphereToRay, vecRayDelta )
	float c = DotProduct( vecSphereToRay, vecSphereToRay ) - sphereRadius * sphereRadius
	float discrim = b * b - 4 * a * c
	if ( discrim < 0.0 )
	{
		intersection.result = false
		return intersection
	}

	discrim = sqrt( discrim )
	float oo2a = 0.5 / a
	intersection.enterFrac = ( - b - discrim ) * oo2a
	intersection.leaveFrac = ( - b + discrim ) * oo2a

	if ( ( intersection.enterFrac > 1.0 ) || ( intersection.leaveFrac < 0.0 ) )
	{
		intersection.result = false
		return intersection
	}

	if ( intersection.enterFrac < 0.0 )
		intersection.enterFrac = 0.0
	if ( intersection.leaveFrac > 1.0 )
		intersection.leaveFrac = 1.0

	intersection.result = true
	return intersection
}

table function GetTableFromString( string inString )
{
	if ( inString.len() > 0 )
		return expect table( getconsttable()[ inString ] )

	return {}
}

int function GetWeaponDamageNear( entity weapon, entity victim )
{
	entity weaponOwner = weapon.GetWeaponOwner()
	if ( weaponOwner.IsNPC() )
	{
		if ( victim.GetArmorType() == ARMOR_TYPE_HEAVY )
			return weapon.GetWeaponSettingInt( eWeaponVar.npc_damage_near_value_titanarmor )
		else
			return weapon.GetWeaponSettingInt( eWeaponVar.npc_damage_near_value )
	}
	else
	{
		if ( victim.GetArmorType() == ARMOR_TYPE_HEAVY )
			return weapon.GetWeaponSettingInt( eWeaponVar.damage_near_value_titanarmor )
		else
			return weapon.GetWeaponSettingInt( eWeaponVar.damage_near_value )
	}

	unreachable
}

void function PrintFirstPersonSequenceStruct( FirstPersonSequenceStruct fpsStruct )
{
	printt( "Printing FirstPersonSequenceStruct:" )

	printt( "firstPersonAnim: " + fpsStruct.firstPersonAnim )
	printt( "thirdPersonAnim: " + fpsStruct.thirdPersonAnim )
	printt( "firstPersonAnimIdle: " + fpsStruct.firstPersonAnimIdle )
	printt( "thirdPersonAnimIdle: " + fpsStruct.thirdPersonAnimIdle )
	printt( "relativeAnim: " + fpsStruct.relativeAnim )
	printt( "attachment: " + fpsStruct.attachment )
	printt( "teleport: " + fpsStruct.teleport )
	printt( "noParent: " + fpsStruct.noParent )
	printt( "blendTime: " + fpsStruct.blendTime )
	printt( "noViewLerp: " + fpsStruct.noViewLerp )
	printt( "hideProxy: " + fpsStruct.hideProxy )
	printt( "viewConeFunction: " + string( fpsStruct.viewConeFunction ) )
	printt( "origin: " + string( fpsStruct.origin ) )
	printt( "angles: " + string ( fpsStruct.angles ) )
	printt( "enablePlanting: " + fpsStruct.enablePlanting )
	printt( "setInitialTime: " + fpsStruct.setInitialTime )
	printt( "useAnimatedRefAttachment: " + fpsStruct.useAnimatedRefAttachment )
	printt( "renderWithViewModels: " + fpsStruct.renderWithViewModels )
	printt( "gravity: " + fpsStruct.gravity )

}

void function WaitSignalOrTimeout( entity ent, float timeout, string signal1, string signal2 = "", string signal3 = "" )
{
	Assert( IsValid( ent ) )

	ent.EndSignal( signal1 )

	if ( signal2 != "" )
		ent.EndSignal( signal2 )

	if ( signal3 != "" )
		ent.EndSignal( signal3 )

	wait( timeout )
}

array<vector> function GetShortestLineSegmentConnectingLineSegments( vector line1Point1, vector line1Point2, vector line2Point1, vector line2Point2 )
{
	// From Paul Bourke's algorithm "The shortest line between two lines in 3D" at http://paulbourke.net/geometry/pointlineplane/

	vector p1 = line1Point1
	vector p2 = line1Point2
	vector p3 = line2Point1
	vector p4 = line2Point2
	vector p13 = p1 - p3
	vector p21 = p2 - p1
	vector p43 = p4 - p3

	if ( Length( p43 ) < 1.0 )
	{
		array<vector> resultVectors
		resultVectors.append( p4 )
		resultVectors.append( p3 )
		return resultVectors
	}

	if ( Length( p21 ) < 1.0 )
	{
		array<vector> resultVectors
		resultVectors.append( p2 )
		resultVectors.append( p1 )
		return resultVectors
	}

	float d1343 = p13.x * p43.x + p13.y * p43.y + p13.z * p43.z
	float d4321 = p43.x * p21.x + p43.y * p21.y + p43.z * p21.z
	float d1321 = p13.x * p21.x + p13.y * p21.y + p13.z * p21.z
	float d4343 = p43.x * p43.x + p43.y * p43.y + p43.z * p43.z
	float d2121 = p21.x * p21.x + p21.y * p21.y + p21.z * p21.z


	float denom = d2121 * d4343 - d4321 * d4321
	Assert( fabs( denom ) > 0.01 )
	float numer = d1343 * d4321 - d1321 * d4343

	float mua = numer / denom
	float mub = (d1343 + d4321 * (mua)) / d4343

	vector resultVec1
	vector resultVec2
	resultVec1.x = p1.x + mua * p21.x
	resultVec1.y = p1.y + mua * p21.y
	resultVec1.z = p1.z + mua * p21.z
	resultVec2.x = p3.x + mub * p43.x
	resultVec2.y = p3.y + mub * p43.y
	resultVec2.z = p3.z + mub * p43.z

	array<vector> resultVectors
	resultVectors.append( resultVec1 )
	resultVectors.append( resultVec2 )
	return resultVectors
}

vector function GetClosestPointToLineSegments( vector line1Point1, vector line1Point2, vector line2Point1, vector line2Point2 )
{
	array<vector> results = GetShortestLineSegmentConnectingLineSegments( line1Point1, line1Point2, line2Point1, line2Point2 )
	Assert( results.len() == 2 )
	return ( results[0] + results[1] ) / 2.0
}


bool function PlayerCanSee( entity player, entity ent, bool doTrace, float degrees )
{
	float minDot = deg_cos( degrees )

	// On screen?
	float dot = DotProduct( Normalize( ent.GetWorldSpaceCenter() - player.EyePosition() ), player.GetViewVector() )
	if ( dot < minDot )
		return false

	// Can trace to it?
	if ( doTrace )
	{
		TraceResults trace = TraceLine( player.EyePosition(), ent.GetWorldSpaceCenter(), null, TRACE_MASK_BLOCKLOS, TRACE_COLLISION_GROUP_NONE )
		if ( trace.hitEnt == ent || trace.fraction >= 0.99 )
			return true
		else
			return false
	}
	else
		return true

	Assert( 0, "shouldn't ever get here")
	unreachable
}

bool function PlayerCanSeePos( entity player, vector pos, bool doTrace, float degrees )
{
	float minDot = deg_cos( degrees )
	float dot = DotProduct( Normalize( pos - player.EyePosition() ), player.GetViewVector() )
	if ( dot < minDot )
		return false

	if ( doTrace )
	{
		TraceResults trace = TraceLine( player.EyePosition(), pos, null, TRACE_MASK_BLOCKLOS, TRACE_COLLISION_GROUP_NONE )
		if ( trace.fraction < 0.99 )
			return false
	}

	return true
}

bool function VectorsFacingSameDirection( vector v1, vector v2, float degreesThreshold )
{
	float minDot = deg_cos( degreesThreshold )
	float dot = DotProduct( Normalize( v1 ), Normalize( v2 ) )
	return ( dot >= minDot )
}

vector function GetRelativeDelta( vector origin, entity ref, string attachment = "" )
{
	vector pos
	vector right
	vector forward
	vector up

	if ( attachment != "" )
	{
		int attachID = ref.LookupAttachment( attachment )
		pos 	= ref.GetAttachmentOrigin( attachID )
		vector angles = ref.GetAttachmentAngles( attachID )
		right 	= AnglesToRight( angles )
		forward = AnglesToForward( angles )
		up 		= AnglesToUp( angles )
	}
	else
	{
		pos 	= ref.GetOrigin()
		right 	= ref.GetRightVector()
		forward = ref.GetForwardVector()
		up 		= ref.GetUpVector()
	}

	vector x = GetClosestPointOnLineSegment( pos + right * -16384, 		pos + right * 16384, origin )
	vector y = GetClosestPointOnLineSegment( pos + forward * -16384, 	pos + forward * 16384, origin )
	vector z = GetClosestPointOnLineSegment( pos + up * -16384, 		pos + up * 16384, origin )

	float distx = Distance(pos, x)
	float disty = Distance(pos, y)
	float distz = Distance(pos, z)

	if ( DotProduct( x - pos, right ) < 0 )
		distx *= -1
	if ( DotProduct( y - pos, forward ) < 0 )
		disty *= -1
	if ( DotProduct( z - pos, up ) < 0 )
		distz *= -1

	return Vector( distx, disty, distz )
}

#if SERVER
float function GetRoundTimeLimit_ForGameMode()
{
	#if DEV
		if ( level.devForcedTimeLimit )
		{
			//Make it needed to be called multiple times for RoundBasedGameModes
			level.devForcedTimeLimit = 0
			return 0.1
		}
	#endif

	#if MP
	if ( GameState_GetTimeLimitOverride() >= 0 )
		return GameState_GetTimeLimitOverride()
	#endif

	if ( !GameMode_IsDefined( GAMETYPE ) )
		return GetCurrentPlaylistVarFloat( "roundtimelimit", 10 )
	else
		return GameMode_GetRoundTimeLimit( GAMETYPE )

	unreachable
}
#endif

bool function HasIronRules()
{
	bool result = (GetCurrentPlaylistVarInt( "iron_rules", 0 ) != 0)
	return result
}

vector function GetWorldOriginFromRelativeDelta( vector delta, entity ref )
{
	vector right 	= ref.GetRightVector() 	* delta.x
	vector forward 	= ref.GetForwardVector() 	* delta.y
	vector up 		= ref.GetUpVector() 		* delta.z

	return ref.GetOrigin() + right + forward + up
}

bool function IsHardcoreGameMode()
{
	return GetCurrentPlaylistVarInt( "gm_hardcore_settings", 0 ) == 1
}

bool function PlayerHasWeapon( entity player, string weaponName )
{
	array<entity> weapons = player.GetMainWeapons()
	weapons.extend( player.GetOffhandWeapons() )

	foreach ( weapon in weapons )
	{
		if ( weapon.GetWeaponClassName() == weaponName )
			return true
	}

	return false
}

bool function PlayerCanUseWeapon( entity player, string weaponClass )
{
	return ( ( player.IsTitan() && weaponClass == "titan" ) || ( !player.IsTitan() && weaponClass == "human" ) )
}

string function GetTitanCharacterName( entity titan )
{
	Assert( titan.IsTitan() )

	string setFile

	if ( titan.IsPlayer() )
	{
		setFile = titan.GetPlayerSettings()
	}
	else
	{
		string aiSettingsFile = titan.GetAISettingsName()
		setFile = expect string( Dev_GetAISettingByKeyField_Global( aiSettingsFile, "npc_titan_player_settings" ) )
	}

	return GetTitanCharacterNameFromSetFile( setFile )
}

bool function IsTitanPrimeTitan( entity titan )
{
	Assert( titan.IsTitan() )
	string setFile

	if ( titan.IsPlayer() )
	{
		setFile = titan.GetPlayerSettings()
	}
	else
	{
		string aiSettingsFile = titan.GetAISettingsName()
		setFile = expect string( Dev_GetAISettingByKeyField_Global( aiSettingsFile, "npc_titan_player_settings" ) )
	}

	return  Dev_GetPlayerSettingByKeyField_Global( setFile, "isPrime" ) == 1

}