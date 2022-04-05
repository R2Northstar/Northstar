global function CodeCallback_MapInit

void function CodeCallback_MapInit()
{
	AddCallback_EntitiesDidLoad( CreateEvacNodes )
}

void function CreateEvacNodes()
{
	AddEvacNode( CreateScriptRef( < -475.129913, 1480.167847, 527.363953 >, < 8.841560, 219.338501, 0 > ) )
	AddEvacNode( CreateScriptRef( < 1009.315186, 3999.888916, 589.914917 >, < 23.945116, -146.680725, 0 > ) )
	AddEvacNode( CreateScriptRef( < 2282.868896, -1363.706543, 846.188660 >, < 23.945116, -146.680725, 0 > ) )
	AddEvacNode( CreateScriptRef( < 1911.771606, -752.053101, 664.741821 >, < 9.955260, 138.721191, 0 > ) )
	AddEvacNode( CreateScriptRef( < 1985.563232, -1205.455078, 677.444763 >, < 13.809734, -239.877441, 0 > ) )
	AddEvacNode( CreateScriptRef( < -59.625496, -1858.108887, 811.592407 >, < 20.556290, -252.775146, 0 > ) )
	AddEvacNode( CreateScriptRef( < -1035.991211, -671.114380, 824.180908 >, < 16.220453, -24.511070, 0 > ) )
	
	SetEvacSpaceNode( GetEnt( "intro_spacenode" ) )
}