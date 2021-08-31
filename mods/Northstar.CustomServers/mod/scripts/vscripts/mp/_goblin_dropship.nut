untyped

global function GoblinDropship_Init

#if MP
	global function GetZiplineDropshipSpawns
#endif //MP
global function RunDropshipDropoff
global function DropshipFindDropNodes
global function AnaylsisFuncDropshipFindDropNodes
global function AddTurret
global function SetDropTableSpawnFuncs

const LINEGEN_DEBUG = 0
global const bool FLIGHT_PATH_DEBUG = false
const LINEGEN_TIME = 600.0

const OPTIMAL_ZIPNODE_DIST_SQRD = 16384 //128 sqrd
//	4096 	64 sqrd
//	65536 	256 sqrd

struct
{
	array<entity> ziplineDropshipSpawns

	table < var, var > dropshipSound = {
		[ TEAM_IMC ] = {
			[ DROPSHIP_STRAFE ]						= "Goblin_IMC_TroopDeploy_Flyin",
			[ DROPSHIP_VERTICAL ]					= "Goblin_Dropship_Flyer_Attack_Vertical_Succesful",
			[ DROPSHIP_FLYER_ATTACK_ANIM_VERTICAL ]	= "Goblin_Flyer_Dropshipattack_Vertical",
			[ DROPSHIP_FLYER_ATTACK_ANIM ]			= "Goblin_Flyer_Dropshipattack"
		},
		[ TEAM_MILITIA ] = {
			[ DROPSHIP_STRAFE ]						= "Crow_MCOR_TroopDeploy_Flyin",
			[ DROPSHIP_VERTICAL ]					= "Crow_Dropship_Flyer_Attack_Vertical_Succesful",
			[ DROPSHIP_FLYER_ATTACK_ANIM_VERTICAL ]	= "Crow_Flyer_Dropshipattack_Vertical",
			[ DROPSHIP_FLYER_ATTACK_ANIM ]			= "Crow_Flyer_Dropshipattack"
		}
	}

} file

function GoblinDropship_Init()
{
	RegisterSignal( "OnDropoff" )
	RegisterSignal( "embark" )
	RegisterSignal( "WarpedIn" )
	PrecacheImpactEffectTable( "dropship_dust" )

	AddCallback_EntitiesDidLoad( EntitiesDidLoad )
}

void function EntitiesDidLoad()
{
	//Generate a list of valid zipline dropship drop off points.
	#if MP
		BuildZiplineDropshipSpawnPoints()
	#endif //MP
}

#if MP
void function BuildZiplineDropshipSpawnPoints()
{
	array<entity> spawnPoints = SpawnPoints_GetDropPod()
	file.ziplineDropshipSpawns = []

	foreach ( entity spawnPoint in spawnPoints )
	{
		if ( !DropshipCanZiplineDropAtSpawnPoint( spawnPoint ) )
			continue

		file.ziplineDropshipSpawns.append( spawnPoint )
	}

	//Assert( file.dropshipSpawns.len() > 0, "No valid zipline dropship spawns exist in this map." )
}

//Function returns an array of level droppod spawns that have been pretested to ensure they have the space for zipline deployments.
array<entity> function GetZiplineDropshipSpawns()
{
	return clone file.ziplineDropshipSpawns
}
#endif //MP

bool function AnaylsisFuncDropshipFindDropNodes( FlightPath flightPath, vector origin, float yaw )
{
	return DropshipFindDropNodes( flightPath, origin, yaw, "both", false, IsLegalFlightPath ).len() != 0
}

// run from TryAnalysisAtOrigin
table<string,table<string,NodeFP> > function DropshipFindDropNodes( FlightPath flightPath, vector origin, float yaw, string side = "both", ignoreCollision = false, bool functionref( FlightPath, vector, vector, vector, bool = 0 ) legalFlightFunc = null, bool amortize = false )
{
	// find nodes to deploy to
	table<string,table<string,NodeFP> > foundNodes

	vector angles = Vector( 0, yaw, 0 )
	vector forward = AnglesToForward( angles )
	vector right = AnglesToRight( angles )
	Point start = GetWarpinPosition( flightPath.model, flightPath.anim, origin, angles )
	if ( fabs( start.origin.x ) > MAX_WORLD_COORD )
		return {}
	if ( fabs( start.origin.y ) > MAX_WORLD_COORD )
		return {}
	if ( fabs( start.origin.z ) > MAX_WORLD_COORD )
		return {}

	if ( !ignoreCollision )
	{
		if ( !legalFlightFunc( flightPath, origin, forward, right, FLIGHT_PATH_DEBUG && !IsActiveNodeAnalysis() ) )
			return {}
	}

	Point deployPoint = GetPreviewPoint( flightPath )
	vector deployOrigin = GetOriginFromPoint( deployPoint, origin, forward, right )
	vector deployAngles = GetAnglesFromPoint( deployPoint, angles )
	float deployYaw = deployAngles.y

	// flatten it
	deployAngles.x = 0
	deployAngles.z = 0

	float pitch = 50
	vector deployRightAngles = AnglesCompose( deployAngles, Vector( 0, -90, 0 ) )
	deployRightAngles = AnglesCompose( deployRightAngles, Vector( pitch, 0, 0 ) )

	vector deployLeftAngles = AnglesCompose( deployAngles, Vector( 0, 90, 0 ) )
	deployLeftAngles = AnglesCompose( deployLeftAngles, Vector( pitch, 0, 0 ) )

	table<int,NodeFP> nodeTable
	bool foundRightNodes = false
	bool foundLeftNodes = false

	if ( side == "right" || side == "both" || side == "either" )
	{
		nodeTable = FindDropshipDeployNodes( deployOrigin, deployRightAngles, amortize )
		if ( LINEGEN_DEBUG )
		{
			foreach( node in nodeTable )
				DebugDrawLine( deployOrigin, node.origin, 200, 200, 200, true, 30.0 )
		}

		if ( nodeTable.len() )
		{
			if ( amortize )
				WaitFrame()
			foundRightNodes = FindBestDropshipNodesForSide( foundNodes, nodeTable, "right", flightPath, origin, forward, right, angles, deployOrigin, deployRightAngles, amortize )
		}

		if ( !foundRightNodes && side != "either" )
			return {}

		if ( amortize )
			WaitFrame()
	}

	if ( side == "left" || side == "both" || side == "either" )
	{
		nodeTable = FindDropshipDeployNodes( deployOrigin, deployLeftAngles, amortize )
		if ( nodeTable.len() )
		{
			if ( amortize )
				WaitFrame()
			foundLeftNodes = FindBestDropshipNodesForSide( foundNodes, nodeTable, "left", flightPath, origin, forward, right, angles, deployOrigin, deployLeftAngles, amortize )
		}

		if ( !foundLeftNodes && side != "either" )
			return {}
	}

	if ( !foundRightNodes && !foundLeftNodes )
		return {}

	if ( LINEGEN_DEBUG || FLIGHT_PATH_DEBUG )
	{
		DrawArrow( origin, angles, 15.0, 250 )
		float time = 500.0
		foreach ( side, nodes in foundNodes )
		{
			//DebugDrawText( nodes.centerNode.origin + Vector(0,0,55), nodes.centerNode.fraction + "", true, time )
			//DebugDrawText( nodes.centerNode.origin, "" + nodes.centerNode.dot, true, time )
			DebugDrawLine( nodes.centerNode.origin, nodes.centerNode.attachOrigin, 120, 255, 120, true, time )
			DebugDrawCircle( nodes.centerNode.origin, Vector( 0,0,0 ), 15, 120, 255, 120, true, time )

			//DebugDrawText( nodes.leftNode.origin + Vector(0,0,55), nodes.leftNode.fraction + "", true, time )
			//DebugDrawText( nodes.leftNode.origin, "" + nodes.leftNode.dot, true, time )
			DebugDrawLine( nodes.leftNode.origin, nodes.leftNode.attachOrigin, 255, 120, 120, true, time )
			DebugDrawCircle( nodes.leftNode.origin, Vector( 0,0,0 ), 15, 255, 120, 120, true, time )

			//DebugDrawText( nodes.rightNode.origin + Vector(0,0,55), nodes.rightNode.fraction + "", true, time )
			//DebugDrawText( nodes.rightNode.origin, "" + nodes.rightNode.dot, true, time )
			DebugDrawLine( nodes.rightNode.origin, nodes.rightNode.attachOrigin, 120, 120, 255, true, time )
			DebugDrawCircle( nodes.rightNode.origin, Vector( 0,0,0 ), 15, 120, 120, 255, true, time )

			//DebugDrawLine( nodes.rightNode.origin, nodes.centerNode.origin, 200, 200, 200, true, time )
			//DebugDrawText( nodes.rightNode.origin + Vector(0,0,20), "dist: " + Distance( nodes.rightNode.origin, nodes.centerNode.origin ), true, time )
			//DebugDrawLine( nodes.leftNode.origin, nodes.centerNode.origin, 200, 200, 200, true, time )
			//DebugDrawText( nodes.leftNode.origin + Vector(0,0,20), "dist: " + Distance( nodes.leftNode.origin, nodes.centerNode.origin ), true, time )

			//DebugDrawLine( origin, origin + deployForward * 200, 50, 255, 50, true, time )

	//		foreach ( node in nodes.rightNodes )
	//		{
	//			DebugDrawText( node.origin + Vector(0,0,25), "R", true, 15 )
	//		}
	//
	//		foreach ( node in nodes.leftNodes )
	//		{
	//			DebugDrawText( node.origin + Vector(0,0,25), "L", true, 15 )
	//		}
		}

//		IsLegalFlightPath( flightPath, origin, forward, right, true )
	}

	return foundNodes
}


table<int,NodeFP> function FindDropshipDeployNodes( vector deployOrigin, vector deployAngles, bool amortize = false )
{
	vector deployForward = AnglesToForward( deployAngles )

	vector end = deployOrigin + deployForward * 3000
	TraceResults result = TraceLine( deployOrigin, end, null, TRACE_MASK_NPCWORLDSTATIC )

	if ( LINEGEN_DEBUG )
	{
		DebugDrawLine( deployOrigin, result.endPos, 255, 255, 255, true, LINEGEN_TIME )
		DebugDrawText( result.endPos + Vector( 0,0,10 ), "test", true, LINEGEN_TIME )
		DebugDrawCircle( result.endPos, Vector( 0,0,0 ), 35, 255, 255, 255, true, LINEGEN_TIME )
	}
	// no hit?
	if ( result.fraction >= 1.0 )
		return {}

	int node = GetNearestNodeToPos( result.endPos )
	if ( node == -1 )
		return {}

	if ( LINEGEN_DEBUG )
	{
		DebugDrawText( GetNodePos( node ) + Vector(0,0,10), "nearest node", true, 15.0 )
		DebugDrawCircle( GetNodePos( node ), Vector( 0,0,0 ), 20, 60, 60, 255, true, LINEGEN_TIME )
	}

	array<vector> neighborPositions = NavMesh_GetNeighborPositions( GetNodePos( node ), HULL_HUMAN, 20 )

	if ( amortize )
		WaitFrame()

	table<int,NodeFP> nodeTable = {}
	int uniqueID = -2
	foreach ( pos in neighborPositions )
	{
		NodeFP attachPoint
		attachPoint.origin = pos
		attachPoint.uniqueID = uniqueID

		nodeTable[ uniqueID ] <- attachPoint
		uniqueID--
	}

	return nodeTable
}

void function AddDirectionVec( array<NodeFP> nodeArray, vector origin )
{
	// different direction vecs because we want a node to the left, center, and straight
	foreach ( node, tab in nodeArray )
	{
		vector vec
		vec = tab.origin - origin
		vec.Norm()
		tab.vec = vec
	}
}

void function AddDirectionVecFromDir( array<NodeFP> nodeArray, vector origin, vector dir )
{
	// different direction vecs because we want a node to the left, center, and straight
	foreach ( node, tab in nodeArray )
	{
		vector vec
		vec = ( tab.origin + dir * 50 ) - origin
		vec.Norm()
		tab.vec = vec
	}
}

bool function FindBestDropshipNodesForSide( table<string,table<string,NodeFP> > foundNodes, table<int,NodeFP> nodeTable, string side, FlightPath flightPath, vector origin, vector forward, vector right, vector angles, vector deployOrigin, vector deployAngles, bool amortize )
{
	vector deployForward = AnglesToForward( deployAngles )
	vector deployRight = AnglesToRight( deployAngles )

	float RatioForLeftRight = 0.2
	vector RightDeployForward = ( ( deployForward * ( 1.0 - RatioForLeftRight ) ) + ( deployRight * RatioForLeftRight * -1 ) )
	RightDeployForward.Norm()
	vector LeftDeployForward = ( ( deployForward * ( 1.0 - RatioForLeftRight ) ) + ( deployRight * RatioForLeftRight ) )
	LeftDeployForward.Norm()

	if ( amortize )
		WaitFrame()

	foundNodes[ side ] <- {}
	array<AttachPoint> attachPoints = GetAttachPoints( flightPath, side )

	array<NodeFP> centerNodes = GetNodeArrayFromTable( nodeTable )
	AddDirectionVec( centerNodes, deployOrigin )
	NodeFP centerNode = GetBestDropshipNode( attachPoints[2], centerNodes, origin, deployForward, forward, right, angles, NullNodeFP )
	if ( centerNode == NullNodeFP )
		return false
	delete nodeTable[ centerNode.uniqueID ]

	if ( amortize )
		WaitFrame()

	array<NodeFP> leftNodes = GetCulledNodes( nodeTable, deployRight * -1 )
	AddDirectionVecFromDir( leftNodes, deployOrigin, deployRight * -1 )
	NodeFP leftNode = GetBestDropshipNode( attachPoints[1], leftNodes, origin, RightDeployForward, forward, right, angles, centerNode )
	if ( leftNode == NullNodeFP )
		return false
	delete nodeTable[ leftNode.uniqueID ]

	if ( amortize )
		WaitFrame()

	array<NodeFP> rightNodes = GetCulledNodes( nodeTable, deployRight )
	AddDirectionVecFromDir( rightNodes, deployOrigin, deployRight )
	NodeFP rightNode = GetBestDropshipNode( attachPoints[0], rightNodes, origin, LeftDeployForward, forward, right, angles, centerNode )
	if ( rightNode == NullNodeFP )
		return false

	table<string,NodeFP> Table
	Table.centerNode <- centerNode
	Table.leftNode <- leftNode
	Table.rightNode <- rightNode

	//Table.rightNodes <- rightNodes // for debug
	//Table.leftNodes <- leftNodes // for debug

	foundNodes[ side ] = Table
	return true
}

array<NodeFP> function GetNodeArrayFromTable( table<int,NodeFP> nodeTable )
{
	array<NodeFP> Array
	foreach ( Table in nodeTable )
	{
		Array.append( Table )
	}

	return Array
}

array<NodeFP> function GetCulledNodes( table<int,NodeFP> nodeTable, vector right )
{
	table<int,NodeFP> leftNodes
	// get the nodes on the left
	foreach ( nod, tab in nodeTable )
	{
		float dot = DotProduct( tab.vec, right )
		if ( dot >= 0.0 )
		{
			leftNodes[ nod ] <- tab
		}
	}

	return GetNodeArrayFromTable( leftNodes )
}

NodeFP function GetBestDropshipNode( AttachPoint attachPoint, array<NodeFP> nodeArray, vector origin, vector deployForward, vector forward, vector right, vector angles, NodeFP centerNode, bool showdebug = false )
{
	foreach ( node in nodeArray )
	{
		node.dot = DotProduct( node.vec, deployForward )
		if ( showdebug )
		{
			DebugDrawText( node.origin, "dot: " + node.dot, true, 15.0 )
			int green = 0
			int red = 255
			if ( node.dot > 0.9 )
			{
				float frac = ( 1.0 - node.dot ) / 0.1
				frac = 1.0 - frac

				green = int( frac * 255 )
				red -= green
			}

			DebugDrawLine( node.origin, node.origin + ( node.vec * -1000 ), red, green, 0, true, 15.0 )
			DebugDrawCircle( node.origin, Vector( 0,0,0 ), 25, red, green, 0, true, 15.0 )
		}
	}

	if ( !nodeArray.len() )
		return NullNodeFP

	vector attachOrigin = GetOriginFromAttachPoint( attachPoint, origin, forward, right )
	vector attachAngles = GetAnglesFromAttachPoint( attachPoint, angles )
	vector attachForward = AnglesToForward( attachAngles )
	vector attachRight = AnglesToRight( attachAngles )

	FlightPath offsetAnalysis = GetAnalysisForModel( TEAM_IMC_GRUNT_MODEL, ZIPLINE_IDLE_ANIM )
	Point offsetPoint = GetPreviewPoint( offsetAnalysis )
	vector offsetOrigin = GetOriginFromPoint( offsetPoint, attachOrigin, attachForward, attachRight )
//	DebugDrawLine( offsetOrigin, attachOrigin, 255, 255, 0, true, 15 )

	nodeArray.sort( SortHighestDot )

	vector mins = GetBoundsMin( HULL_HUMAN )
	vector maxs = GetBoundsMax( HULL_HUMAN )

	array<NodeFP> passedNodes

	for ( int i = 0; i < nodeArray.len(); i++ )
	{
		NodeFP node = nodeArray[i]

		// beyond the allowed dot
		if ( node.dot < 0.3 )
			return NullNodeFP

		// trace to see if the ai could drop to the node from here
		TraceResults result = TraceHull( offsetOrigin, node.origin, mins, maxs, null, TRACE_MASK_NPCWORLDSTATIC, TRACE_COLLISION_GROUP_NONE )
		if ( result.fraction < 1.0 )
			continue //return

		// trace to insure that there will be a good place to hook the zipline
		if ( !GetHookOriginFromNode( offsetOrigin, node.origin, attachOrigin ) )
			continue

		node.fraction = result.fraction
		node.attachOrigin = offsetOrigin
		node.attachName = attachPoint.name

		if ( centerNode != NullNodeFP )
		{
			//test for distance, not too close, not too far
			local distSqr = DistanceSqr( centerNode.origin, node.origin )
			node.rating = fabs( OPTIMAL_ZIPNODE_DIST_SQRD - distSqr )
			passedNodes.append( node )
			continue
		}

		return node
	}

	if ( centerNode != NullNodeFP && passedNodes.len() )
	{
		passedNodes.sort( SortLowestRating )
		return passedNodes[ 0 ]
	}

	return NullNodeFP
}

int function SortHighestDot( NodeFP a, NodeFP b )
{
	if ( a.dot > b.dot )
		return -1

	if ( a.dot < b.dot )
		return 1

	return 0
}

int function SortLowestRating( NodeFP a, NodeFP b )
{
	if ( a.rating > b.rating )
		return 1

	if ( a.rating < b.rating )
		return -1

	return 0
}

void function SetDropTableSpawnFuncs( CallinData drop, entity functionref( int, vector, vector ) spawnFunc, int count )
{
	array<entity functionref( int, vector, vector )> spawnFuncArray
	//spawnFuncArray.resize( count, spawnFunc )
	for ( int i = 0; i < count; i++ )
	{
		spawnFuncArray.append( spawnFunc )
	}
	drop.npcSpawnFuncs = spawnFuncArray
}

asset function GetTeamDropshipModel( int team, bool hero = false )
{
	if ( hero )
	{
		if ( team == TEAM_IMC )
			return GetFlightPathModel( "fp_dropship_hero_model" )
		else
			return GetFlightPathModel( "fp_crow_hero_model" )
	}
	else
	{
		if ( team == TEAM_IMC )
			return GetFlightPathModel( "fp_dropship_model" )
		else
			return GetFlightPathModel( "fp_crow_model" )
	}

	unreachable
}

//This function tests to see if the given spawn point has enough clearance for a dropship to deploy zipline grunts.
bool function DropshipCanZiplineDropAtSpawnPoint( entity spawnPoint )
{
	CallinData drop
	drop.origin 		= spawnPoint.GetOrigin()
	drop.yaw 			= spawnPoint.GetAngles().y
	drop.dist 			= 768
	SetCallinStyle( drop, eDropStyle.ZIPLINE_NPC )
	int style 			= drop.style

	bool validSpawn = false
	array<string> anims = GetRandomDropshipDropoffAnims()

	string animation
	FlightPath flightPath

	foreach ( anim in anims )
	{
		animation = anim
		flightPath = GetAnalysisForModel( DROPSHIP_MODEL, anim )

		if ( style == eDropStyle.NONE )
		{
			if ( !drop.yawSet )
			{
				style = eDropStyle.NEAREST
			}
			else
			{
				style = eDropStyle.NEAREST_YAW
			}
		}

		validSpawn = TestSpawnPointForStyle( flightPath, drop )

		if ( validSpawn )
			return true
	}

	return false
}

function RunDropshipDropoff( CallinData Table )
{
	vector origin 		= Table.origin
	float yaw 			= Table.yaw
	int team 			= Table.team
	entity owner 		= Table.owner
	string squadname 	= Table.squadname
	string side 		= Table.side
	array<entity functionref( int, vector, vector )> npcSpawnFuncs =	Table.npcSpawnFuncs
	int style 			= Table.style
	int health = 		7800

	if ( Table.dropshipHealth != 0 )
		health = Table.dropshipHealth
	Table.success = false

	if ( Flag( "DisableDropships" ) )
		return

	if ( team == 0 )
	{
		if ( owner )
			team = owner.GetTeam()
		else
			team = 0
	}

	SpawnPointFP spawnPoint
	array<string> anims = GetRandomDropshipDropoffAnims()

	// Override anim, level scripter takes responsibility for it working in this location or not
	if ( Table.anim != "" )
	{
		anims.clear()
		anims.append( Table.anim )
	}

	string animation
	FlightPath flightPath
	bool wasPlayerOwned = IsValid( owner ) && IsValidPlayer( owner )

	foreach ( anim in anims )
	{
		animation = anim
		flightPath = GetAnalysisForModel( DROPSHIP_MODEL, anim )

		if ( style == eDropStyle.NONE )
		{
			if ( !Table.yawSet )
			{
				style = eDropStyle.NEAREST
			}
			else
			{
				style = eDropStyle.NEAREST_YAW
			}
		}

		spawnPoint = GetSpawnPointForStyle( flightPath, Table )

		if ( spawnPoint.valid )
			break
	}

	if ( !spawnPoint.valid )
	{
		printt( "Couldn't find good spawn location for dropship" )
		return
	}

	Table.success = true

	entity ref = CreateScriptRef()
	if ( Table.forcedPosition )
	{
		ref.SetOrigin( Table.origin )
		ref.SetAngles( Vector( 0, Table.yaw, 0 ) )
	}
	else
	{
		ref.SetOrigin( spawnPoint.origin )
		ref.SetAngles( spawnPoint.angles )
	}

	// used for when flyers attack dropships
	if ( "nextDropshipAttackedByFlyers" in level && level.nextDropshipAttackedByFlyers )
		animation = FlyersAttackDropship( ref, animation )

	Assert( IsNewThread(), "Must be threaded off" )

	DropTable dropTable

	if ( Table.dropTable.valid )
	{
		dropTable = Table.dropTable
	}
	else
	{
		bool ignoreCollision = true // = style == eDropStyle.FORCED
		thread FindDropshipZiplineNodes( dropTable, flightPath, ref.GetOrigin(), ref.GetAngles(), side, ignoreCollision, true )
	}

	asset model = GetTeamDropshipModel( team )
	waitthread WarpinEffect( model, animation, ref.GetOrigin(), ref.GetAngles() )
	entity dropship = CreateDropship( team, ref.GetOrigin(), ref.GetAngles() )
	SetSpawnOption_SquadName( dropship, squadname )
	dropship.kv.solid = SOLID_VPHYSICS
	DispatchSpawn( dropship )
	Table.dropship = dropship
	//dropship.SetPusher( true )
	dropship.SetHealth( health )
	dropship.SetMaxHealth( health )
	Table.dropship = dropship
	dropship.EndSignal( "OnDeath" )
	dropship.Signal( "WarpedIn" )
	ref.Signal( "WarpedIn" )
	Signal( Table, "WarpedIn" )

	AddDropshipDropTable( dropship, dropTable ) // this is where the ai will drop to

	if ( IsValid( owner ) )
	{
		dropship.SetCanCloak( false )
		dropship.SetOwner( owner )
		if ( owner.IsPlayer() )
			dropship.SetBossPlayer( owner )
	}

	local dropshipSound = GetTeamDropshipSound( team, animation )
	if ( Table.customSnd != "" )
		dropshipSound = Table.customSnd

	OnThreadEnd(
		function() : ( dropship, ref, Table, dropshipSound )
		{
			ref.Destroy()
			if ( IsValid( dropship ) )
				StopSoundOnEntity( dropship, dropshipSound )
			if ( IsAlive( dropship ) )
			{
				dropship.Destroy()
			}

			Signal( Table, "OnDropoff", { guys = null } )
		}
	)

	array<entity> guys
	if ( !wasPlayerOwned || IsValidPlayer( owner ) )
	{
		guys = CreateNPCSForDropship( dropship, Table.npcSpawnFuncs, side )

		foreach ( guy in guys )
		{
			if ( IsAlive( guy ) )
			{
				if ( IsValidPlayer( owner ) )
				{
					NPCFollowsPlayer( guy, owner )
				}
			}
		}
	}

	//thread DropshipMissiles( dropship )
	dropship.Hide()
	EmitSoundOnEntity( dropship, dropshipSound ) //HACK: Note that the anims can play sounds too! For R3 just make it consistent so it's all played in script or all played in anims
	thread ShowDropship( dropship )
	thread PlayAnimTeleport( dropship, animation, ref, 0 )

	ArrayRemoveDead( guys )

	Signal( Table, "OnDropoff", { guys = guys } )

	WaittillAnimDone( dropship )
	wait 2.0
}

void function FindDropshipZiplineNodes( DropTable dropTable, FlightPath flightPath, vector origin, vector angles, string side = "both", bool ignoreCollision = false, bool amortize = false )
{
	dropTable.nodes = DropshipFindDropNodes( flightPath, origin, angles.y, side, ignoreCollision, IsLegalFlightPath_OverTime, amortize )
	dropTable.valid = true
}

function ShowDropship( dropship )
{
	dropship.EndSignal( "OnDestroy" )
	wait 0.16
	dropship.Show()
}

entity function AddTurret( entity dropship, int team, string turretWeapon, string attachment, int health = 700 )
{
	entity turret = CreateEntity( "npc_turret_sentry" )
	turret.kv.TurretRange = 1500
	turret.kv.AccuracyMultiplier = 1.0
	turret.kv.FieldOfView = 0.4
	turret.kv.FieldOfViewAlert = 0.4
	SetSpawnOption_Weapon( turret, turretWeapon )
	turret.SetOrigin( Vector(0,0,0) )
	turret.SetTitle( "#NPC_DROPSHIP" )
	turret.s.skipTurretFX <- true
	DispatchSpawn( turret )

	SetTargetName( turret, "DropshipTurret" )
	turret.SetHealth( health)
	turret.SetMaxHealth( health )
	turret.Hide()
	//turret.Show()
	entity weapon = turret.GetActiveWeapon()
	weapon.Hide()
	SetTeam( turret, team )
	turret.SetParent( dropship, attachment, false )
	turret.EnableTurret()
	turret.SetOwner( dropship.GetOwner() )
	turret.SetAimAssistAllowed( false )

	entity bossPlayer = dropship.GetBossPlayer()
	if ( IsValidPlayer( bossPlayer ) )
		turret.SetBossPlayer( dropship.GetBossPlayer() )

	HideName( turret )
	return turret
}

function GetTeamDropshipSound( team, animation )
{
	Assert( team in file.dropshipSound )
	Assert( animation in file.dropshipSound[ team ] )

	return file.dropshipSound[ team ][ animation ]
}