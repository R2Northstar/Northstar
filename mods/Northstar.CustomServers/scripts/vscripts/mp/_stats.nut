global function Stats_Init
global function AddStatCallback
global function Stats_SaveStatDelayed
global function PlayerStat_GetCurrentInt
global function PlayerStat_GetCurrentFloat
global function UpdatePlayerStat
global function IncrementPlayerDidPilotExecutionWhileCloaked
global function UpdateTitanDamageStat
global function UpdateTitanWeaponDamageStat
global function UpdateTitanCoreEarnedStat
global function PreScoreEventUpdateStats
global function PostScoreEventUpdateStats
global function Stats_OnPlayerDidDamage

void function Stats_Init()
{

}

void function AddStatCallback(string statCategory, string statAlias, string statSubAlias, void functionref(entity, float, string) callback, string subRef)
{

}

void function Stats_SaveStatDelayed(entity player, string statCategory, string statAlias, string statSubAlias)
{

}

int function PlayerStat_GetCurrentInt(entity player, string statCategory, string statAlias, string statSubAlias)
{
	return 0
}

float function PlayerStat_GetCurrentFloat(entity player, string statCategory, string statAlias, string statSubAlias)
{
	return 0
}

void function UpdatePlayerStat(entity player, string statCategory, string subStat, int count = 0)
{

}

void function IncrementPlayerDidPilotExecutionWhileCloaked(entity player)
{

}

void function UpdateTitanDamageStat(entity attacker, float savedDamage, var damageInfo)
{

}

void function UpdateTitanWeaponDamageStat(entity attacker, float savedDamage, var damageInfo)
{

}

void function UpdateTitanCoreEarnedStat( entity player, entity titan )
{

}

void function PreScoreEventUpdateStats(entity attacker, entity ent)
{

}

void function PostScoreEventUpdateStats(entity attacker, entity ent)
{

}

void function Stats_OnPlayerDidDamage(entity player, var damageInfo)
{

}
