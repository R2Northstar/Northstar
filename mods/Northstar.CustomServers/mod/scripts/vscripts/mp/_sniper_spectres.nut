untyped

const MAXNODES_PER_SNIPERSPOT 	= 4
const MAX_SNIPERSPOTS 			= 30 // for speed of iterating through the array
const SNIPERSPOT_RADIUSCHECK 	= 200
const SNIPERSPOT_HEIGHTCHECK 	= 160
const SNIPERNODE_TOOCLOSE_SQR	= 2500//50x50

global function SniperSpectres_Init
global function TowerDefense_AddSniperLocation
global function Dev_AddSniperLocation
global function DebugDrawSniperLocations
global function Sniper_MoveToNewLocation
global function Sniper_FreeSniperNodeOnDeath
global function SniperCloak
global function SniperDeCloak


function SniperSpectres_Init()
{
	FlagInit( "TD_SniperLocationsInit" )

	level.TowerDefense_SniperNodes <- []

	AddCallback_EntitiesDidLoad( EntitiesDidLoad )
}

void function EntitiesDidLoad()
{
	thread SniperLocationsInit()
}

/************************************************************************************************\

########  #######   #######  ##        ######
   ##    ##     ## ##     ## ##       ##    ##
   ##    ##     ## ##     ## ##       ##
   ##    ##     ## ##     ## ##        ######
   ##    ##     ## ##     ## ##             ##
   ##    ##     ## ##     ## ##       ##    ##
   ##     #######   #######  ########  ######

\************************************************************************************************/
function TowerDefense_AddSniperLocation( origin, yaw, heightCheck = SNIPERSPOT_HEIGHTCHECK )
{
	Assert( !Flag( "TD_SniperLocationsInit" ), "sniper locations added too late" )
	Assert( ( level.TowerDefense_SniperNodes.len() < MAX_SNIPERSPOTS ), "adding too many snper locations, max is " + MAX_SNIPERSPOTS )

	local loc = CreateSniperLocation( origin, yaw, heightCheck )

	level.TowerDefense_SniperNodes.append( loc )
}

function Dev_AddSniperLocation( origin, yaw, heightCheck = SNIPERSPOT_HEIGHTCHECK )
{
	thread __AddSniperLocationInternal( origin, yaw, heightCheck )
}

function __AddSniperLocationInternal( origin, yaw, heightCheck )
{
	local loc = CreateSniperLocation( origin, yaw, heightCheck )
	SniperLocationSetup( loc )
	DebugDrawSingleSniperLocation( loc, 4.0 )
}

function DebugDrawSniperLocations()
{
	foreach ( loc in level.TowerDefense_SniperNodes )
		DebugDrawSingleSniperLocation( loc, 600.0 )
}

function DebugDrawSingleSniperLocation( loc, float time )
{
	if ( !loc.maxGuys )
	{
		DebugDrawSniperSpot( expect vector( loc.pos ), [ 32.0, 40.0, 48.0 ], 255, 0, 0, time, loc.yaw )
		return
	}

	DebugDrawSniperSpot( expect vector( loc.pos ), [ 28.0 ], 20, 20, 20, time, loc.yaw )

	foreach ( node in loc.coverNodes )
		DebugDrawSniperSpot( expect vector( node.pos ), [ 16.0, 24.0, 32.0 ], 50, 50, 255, time, null, loc.pos )

	foreach ( node in loc.extraNodes )
		DebugDrawSniperSpot( expect vector( node.pos ), [ 14.0, 22.0, 30.0 ], 255, 0, 255, time, null, loc.pos )
}

function DebugDrawSniperSpot( vector pos, array<float> radii, int r, int g, int b, float time, yaw = null, pos2 = null )
{
	foreach ( radius in radii )
		DebugDrawCircle( pos, Vector( 0, 0, 0 ), radius, r, g, b, true, time )

	if ( yaw != null )
	{
		local angles 	= Vector( 0, yaw, 0 )
		local forward 	= AnglesToForward( angles )
		local right 	= AnglesToRight( angles )
		local length 	= radii[ radii.len() - 1 ]
		local endPos 	= pos + ( forward * ( length * 1.75 ) )
		local rightPos 	= pos + ( right * length )
		local leftPos 	= pos + ( right * -length )
		DebugDrawLine( pos, 		endPos, r, g, b, true, time )
		DebugDrawLine( rightPos, 	endPos, r, g, b, true, time )
		DebugDrawLine( leftPos, 	endPos, r, g, b, true, time )

		local ring = GetDesirableRing( pos, yaw )
		DebugDrawCircle( expect vector( ring.pos ), Vector( 0, 0, 0 ), expect float( ring.radius ), r, g, b, true, time )
	}

	if ( pos2 != null )
		DebugDrawLine( pos, pos2, r, g, b, true, time )
}

/************************************************************************************************\

########     ###    ######## ##     ## #### ##    ##  ######
##     ##   ## ##      ##    ##     ##  ##  ###   ## ##    ##
##     ##  ##   ##     ##    ##     ##  ##  ####  ## ##
########  ##     ##    ##    #########  ##  ## ## ## ##   ####
##        #########    ##    ##     ##  ##  ##  #### ##    ##
##        ##     ##    ##    ##     ##  ##  ##   ### ##    ##
##        ##     ##    ##    ##     ## #### ##    ##  ######

\************************************************************************************************/
//HACK -> this should probably move into code
function Sniper_MoveToNewLocation( entity sniper )
{
	sniper.EndSignal( "OnDeath" )
	sniper.EndSignal( "OnDestroy" )

	delaythread( 2 ) SniperCloak( sniper )

	//go searching for nodes that are up somewhere
	local sniperNode = GetRandomSniperNodeWithin( sniper, 3000 )

	Sniper_FreeSniperNode( sniper )//free his current node
	Sniper_TakeSniperNode( sniper, sniperNode )
	Sniper_AssaultLocation( sniper, sniperNode )

	WaitSignal( sniper, "OnFinishedAssault", "OnDeath", "OnDestroy", "AssaultTimeOut" )

	SniperDeCloak( sniper )
}

function Sniper_TakeSniperNode( sniper, sniperNode )
{
	Assert( sniper.s.sniperNode == null ) // didn't free the last one
	sniper.s.sniperNode = sniperNode

	Assert( sniperNode.locked == false )// someone else already has it?
	sniperNode.locked = true

	local loc = sniperNode.loc
	loc.numGuys++
}

function Sniper_FreeSniperNode( sniper )
{
	local sniperNode = sniper.s.sniperNode
	if ( sniperNode == null )
		return

	sniper.s.sniperNode = null

	local loc = sniperNode.loc
	loc.numGuys--
	sniperNode.locked = false
}

function Sniper_FreeSniperNodeOnDeath( entity sniper )
{
	sniper.WaitSignal( "OnDeath" )
	Sniper_FreeSniperNode( sniper )
}

void function SniperCloak( entity sniper )
{
	if ( !IsAlive( sniper ) )
		return

	if ( !sniper.CanCloak() )
		return

	sniper.kv.allowshoot = 0
	sniper.SetCloakDuration( 3.0, -1, 0 )
	sniper.Minimap_Hide( TEAM_IMC, null )
	sniper.Minimap_Hide( TEAM_MILITIA, null )
}

void function SniperDeCloak( entity sniper )
{
	if ( !IsAlive( sniper ) )
		return

	sniper.kv.allowshoot = 1
	sniper.SetCloakDuration( 0, 0, 1.5 )
	sniper.Minimap_AlwaysShow( TEAM_IMC, null )
	sniper.Minimap_AlwaysShow( TEAM_MILITIA, null )
}

function Sniper_AssaultLocation( sniper, sniperNode )
{
	Assert( sniper.s.sniperNode == sniperNode ) // didn't get the right one

	local origin 	= sniperNode.pos
	local loc 		= sniperNode.loc
	local angles 	= Vector( 0, loc.yaw, 0 )

	Assert( "assaultPoint" in sniper.s )
	sniper.AssaultPoint( origin )
	sniper.DisableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE )
}

function GetRandomSniperNodeWithin( sniper, maxDist )
{
	Assert( level.TowerDefense_SniperNodes.len() >= 2 )

	local origin = sniper.GetOrigin()
	local locations = SniperNodeWithin( level.TowerDefense_SniperNodes, origin, maxDist )

	if ( locations.len() )
		locations.randomize()

	local goalNode = FindFreeSniperNode( locations )
	if ( goalNode != null )
		return goalNode

	//if we get here it's because there are no free nodes within the maxDist
	locations = SniperNodeClosest( level.TowerDefense_SniperNodes, origin )

	goalNode = FindFreeSniperNode( locations )
	Assert ( goalNode != null )

	return goalNode
}

function FindFreeSniperNode( locations )
{
	foreach( loc in locations )
	{
		//is if filled up?
		if ( loc.numGuys >= loc.maxGuys )
			continue

		//grab the first unlocked cover node
		foreach ( node in loc.coverNodes )
		{
			if ( node.locked )
				continue

			return node
		}

		//ok then grab the first unlocked extra node
		foreach ( node in loc.extraNodes )
		{
			if ( node.locked )
				continue

			return node
		}
	}

	return null
}

//ArrayWithin() copy
function SniperNodeWithin( Array, origin, maxDist )
{
	maxDist *= maxDist

	local resultArray = []
	foreach( loc in Array )
	{
		local testspot = null
		testspot = loc.pos

		local dist = DistanceSqr( origin, testspot )
		if ( dist <= maxDist )
			resultArray.append( loc )
	}
	return resultArray
}

//ArrayClosest() copy
function SniperNodeClosest( Array, origin )
{
	Assert( type( Array ) == "array" )
	local allResults = SniperArrayDistanceResults( Array, origin )

	allResults.sort( SniperArrayDistanceCompare )

	local returnEntities = []

	foreach ( index, result in allResults )
	{
		returnEntities.insert( index, result.loc )
	}

	// the actual distances aren't returned
	return returnEntities
}

function SniperArrayDistanceResults( Array, origin )
{
	Assert( type( Array ) == "array" )
	local allResults = []

	foreach ( loc in Array )
	{
		local results = {}
		local testspot = null

		testspot = loc.pos

		results.distanceSqr <- LengthSqr( testspot - origin )
		results.loc <- loc
		allResults.append( results )
	}

	return allResults
}

function SniperArrayDistanceCompare( a, b )
{
	if ( a.distanceSqr > b.distanceSqr )
		return 1
	else if ( a.distanceSqr < b.distanceSqr )
		return -1

	return 0;
}



/************************************************************************************************\

########  ########  ########          ######     ###    ##        ######
##     ## ##     ## ##               ##    ##   ## ##   ##       ##    ##
##     ## ##     ## ##               ##        ##   ##  ##       ##
########  ########  ######   ####### ##       ##     ## ##       ##
##        ##   ##   ##               ##       ######### ##       ##
##        ##    ##  ##               ##    ## ##     ## ##       ##    ##
##        ##     ## ########          ######  ##     ## ########  ######

\************************************************************************************************/
function CreateSniperLocation( origin, yaw, heightCheck )
{
	local loc = {}
	loc.pos 		<- origin
	loc.yaw 		<- yaw
	loc.heightCheck <- heightCheck
	loc.numGuys		<- 0
	loc.maxGuys 	<- 0
	loc.coverNodes 	<- []
	loc.extraNodes	<- []

	return loc
}

function CreateSniperNode( location, origin )
{
	local node = {}
	node.locked <- false
	node.loc 	<- location
	node.pos 	<- origin

	return node
}

function SniperLocationsInit()
{
	FlagSet( "TD_SniperLocationsInit" )
	local time = Time()

	foreach ( loc in level.TowerDefense_SniperNodes )
	{
		SniperLocationSetup( loc )
		wait 0.1 //space out all the slow stuff so it doesn't happen on the same frame
	}

	printt( "<<<<<***********************************************************>>>>>" )
	printt( "SniperLocationsInit() took ", Time() - time, " seconds to complete" )
	printt( "<<<<<***********************************************************>>>>>" )
}

function SniperLocationSetup( loc )
{
	array<vector> extraPos = GetNeighborPositionsAroundSniperLocation( expect vector( loc.pos ), expect float( loc.yaw ), expect float( loc.heightCheck ), MAXNODES_PER_SNIPERSPOT )
	foreach ( origin in extraPos )
	{
		local node = CreateSniperNode( loc, origin )
		loc.extraNodes.append( node )
	}

	loc.maxGuys = loc.coverNodes.len() + loc.extraNodes.len()
	if ( loc.maxGuys == 0 )
		printt( "sniper spot at [ " + loc.pos + " ] has no nodes around it within " + SNIPERSPOT_RADIUSCHECK + " units." )
	Assert( loc.maxGuys <= MAXNODES_PER_SNIPERSPOT )
}

array<vector> function GetNeighborPositionsAroundSniperLocation( vector pos, float yaw, float heightCheck, int max )
{
	local height 			= pos.z
	local isSpectre 		= true
	local radius 			= SNIPERSPOT_RADIUSCHECK
	array<vector> goalPos 	= []

	array<vector> neighborPos = NavMesh_GetNeighborPositions( pos, HULL_HUMAN, MAXNODES_PER_SNIPERSPOT )
	neighborPos	= SortPositionsByClosestToPos( neighborPos, pos, yaw )
	foreach ( origin in neighborPos )
	{
		if ( fabs( origin.z - height ) > heightCheck )
			continue

		if ( !IsMostDesireablePos( origin, pos, yaw ) )
			continue

		if ( IsPosTooCloseToOtherPositions( origin, goalPos ) )
			continue

		goalPos.append( origin )
		if ( goalPos.len() == max )
			break
	}

	return goalPos
}

array<vector> function SortPositionsByClosestToPos( array<vector> neighborPos, vector pos, float yaw )
{
	table ring 		= GetDesirableRing( pos, yaw )
	vector testPos 	= expect vector( ring.pos )

	array<vector> returnOrigins = ArrayClosestVector( neighborPos, testPos )
	return returnOrigins
}

bool function IsPosTooCloseToOtherPositions( vector testPos, array<vector> positions )
{
	foreach ( pos in positions )
	{
		if ( DistanceSqr( pos, testPos ) <= SNIPERNODE_TOOCLOSE_SQR )
			return true
	}
	return false
}

function IsMostDesireablePos( testPos, sniperPos, yaw )
{
	/*
	what this function does is actually draw a circle out infront of the position based on the yaw.
	then it checks to see if the node is within that circle.
	Since most sniper positions are on EDGES of buildings, windows, etc, this techinique helps grab more nodes along the edge
	*/

	table ring 		= GetDesirableRing( sniperPos, yaw )
	local radiusSqr = ring.radius * ring.radius

	if ( Distance2DSqr( testPos, ring.pos ) <= radiusSqr )
		return true

	return false
}

table function GetDesirableRing( pos, yaw )
{
	local dist 		= 200
	local radius 	= 300

	local vec 		= AnglesToForward( Vector( 0, yaw, 0 ) ) * dist
	local testPos 	= pos + vec

	table ring = {}
	ring.pos <- testPos
	ring.radius <- radius
	return ring
}






