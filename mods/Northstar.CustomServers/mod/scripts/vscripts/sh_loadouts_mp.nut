// despite the name this is NOT a shared script, it only runs on the server
// todo: move all contents of this script to one called _loadouts_mp.nut, naming here is confusing af

// current contents of this script are just random placeholder funcs i wasn't sure about the proper location of

global function GetNPCDefaultWeaponForLevel
global function GetTitanLoadoutForCurrentMap

TitanLoadoutDef function GetTitanLoadoutForCurrentMap()
{
	TitanLoadoutDef loadout
	return loadout
}

NPCDefaultWeapon ornull function GetNPCDefaultWeaponForLevel( entity npc )
{
	return null
}

