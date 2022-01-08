global function GamemodeAt_Init
global function RateSpawnpoints_AT

void function GamemodeAt_Init()
{

}

void function RateSpawnpoints_AT( int checkclass, array<entity> spawnpoints, int team, entity player )
{
	RateSpawnpoints_Generic( checkclass, spawnpoints, team, player ) // temp 
}