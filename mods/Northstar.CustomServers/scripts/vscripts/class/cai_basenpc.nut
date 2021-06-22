untyped

global function IsCrawling
global function CodeCallback_RegisterClass_CAI_BaseNPC
global function SetSpawnOption_AISettings
global function SetSpawnOption_Alert
global function SetSpawnOption_NotAlert
global function SetSpawnOption_Ordnance
global function SetSpawnOption_OwnerPlayer
global function SetSpawnOption_Sidearm
global function SetSpawnOption_SquadName
global function SetSpawnOption_Special
global function SetSpawnOption_Melee
global function SetSpawnOption_CoreAbility
global function SetSpawnOption_Antirodeo
global function SetSpawnOption_Titanfall
global function SetSpawnOption_TitanSoulPassive1
global function SetSpawnOption_TitanSoulPassive2
global function SetSpawnOption_TitanSoulPassive3
global function SetSpawnOption_TitanSoulPassive4
global function SetSpawnOption_TitanSoulPassive5
global function SetSpawnOption_TitanSoulPassive6
global function SetSpawnOption_Warpfall
global function SetSpawnOption_Weapon
global function SetSpawnOption_NPCTitan
global function SetSpawnOption_TitanLoadout

function CodeCallback_RegisterClass_CAI_BaseNPC()
{
	#document( "SetSpawnOption_AISettings", "Specify AI Setting" )
	#document( "SetSpawnOption_Alert", "Enable spawn alerted" )
	#document( "SetSpawnOption_NotAlert", "Enable spawn alerted" )
	#document( "SetSpawnOption_Ordnance", "Specify spawn ordnance" )
	#document( "SetSpawnOption_OwnerPlayer", "This titan will be the auto titan of this player" )
	#document( "SetSpawnOption_SquadName", "Specify spawn squadname" )
	#document( "SetSpawnOption_Special", "Specify spawn tactical ability" )
	#document( "SetSpawnOption_Titanfall", "npc titan will spawn via titanfall" )
	#document( "SetSpawnOption_TitanSoulPassive1", "Set this passive on the titan soul" )
	#document( "SetSpawnOption_TitanSoulPassive2", "Set this passive on the titan soul" )
	#document( "SetSpawnOption_TitanSoulPassive3", "Set this passive on the titan soul" )
	#document( "SetSpawnOption_TitanSoulPassive4", "Set this passive on the titan soul" )
	#document( "SetSpawnOption_TitanSoulPassive5", "Set this passive on the titan soul" )
	#document( "SetSpawnOption_TitanSoulPassive6", "Set this passive on the titan soul" )
	#document( "SetSpawnOption_Warpfall", "Titan or super spectre will spawn via warpsfall" )
	#document( "SetSpawnOption_Weapon", "Specify spawn weapon and mods" )
	#document( "SetSpawnOption_NPCTitan", "Spawn titan of type" )


	//printl( "Class Script: CAI_BaseNPC" )

	CAI_BaseNPC.ClassName <- "CAI_BaseNPC"
	CAI_BaseNPC.supportsXRay <- null

	CAI_BaseNPC.mySpawnOptions_aiSettings <- null
	CAI_BaseNPC.mySpawnOptions_alert <- null
	CAI_BaseNPC.mySpawnOptions_sidearm <- null
	CAI_BaseNPC.mySpawnOptions_titanfallSpawn <- null
	CAI_BaseNPC.mySpawnOptions_warpfallSpawn <- null
	CAI_BaseNPC.mySpawnOptions_routeTD <- null
	CAI_BaseNPC.mySpawnOptions_ownerPlayer <- null
	CAI_BaseNPC.executedSpawnOptions <- null

	function CAI_BaseNPC::HasXRaySupport()
	{
		return ( this.supportsXRay != null )
	}

	function CAI_BaseNPC::ForceCombat()
	{
		this.FireNow( "UpdateEnemyMemory", "!player" )
	}
	#document( CAI_BaseNPC, "ForceCombat", "Force into combat state by updating NPC's memory of the player." )

	function CAI_BaseNPC::InCombat()
	{
		entity enemy = expect entity( this ).GetEnemy()
		if ( !IsValid( enemy ) )
			return false

		return this.CanSee( enemy )
	}
	#document( CAI_BaseNPC, "InCombat", "Returns true if NPC is in combat" )
}



function SetSpawnOption_AISettings( entity npc, setting )
{
	Assert( IsValid( npc ) && npc.IsNPC(), npc + " is not an npc!" )
	Assert( !npc.executedSpawnOptions, npc + " tried to set spawn options after npc was dispatchspawned." )
	npc.mySpawnOptions_aiSettings = setting
}

function SetSpawnOption_Alert( entity npc )
{
	Assert( IsValid( npc ) && npc.IsNPC(), npc + " is not an npc!" )
	Assert( !npc.executedSpawnOptions, npc + " tried to set spawn options after npc was dispatchspawned." )
	npc.mySpawnOptions_alert = true
}

function SetSpawnOption_NotAlert( entity npc )
{
	Assert( IsValid( npc ) && npc.IsNPC(), npc + " is not an npc!" )
	Assert( !npc.executedSpawnOptions, npc + " tried to set spawn options after npc was dispatchspawned." )
	npc.mySpawnOptions_alert = false
}

void function SetSpawnOption_Weapon( entity npc, string weapon, array<string> mods = [] )
{
	Assert( weapon != "", "Tried to assign no weapon as a spawn weapon" )
	Assert( IsValid( npc ) && npc.IsNPC(), npc + " is not an npc!" )
	Assert( !npc.executedSpawnOptions, npc + " tried to set spawn options after npc was dispatchspawned." )

	if ( npc.IsTitan() )
	{
		npc.ai.titanSpawnLoadout.primary = weapon
		npc.ai.titanSpawnLoadout.primaryMods = mods
	}
	else
	{
		NPCDefaultWeapon spawnoptionsweapon
		spawnoptionsweapon.wep = weapon
		spawnoptionsweapon.mods = mods

		npc.ai.mySpawnOptions_weapon = spawnoptionsweapon
	}
}

void function SetSpawnOption_Sidearm( entity npc, string weapon, array<string> mods = [])
{
	Assert( weapon != "", "Tried to assign no weapon as a spawn weapon" )
	Assert( IsValid( npc ) && npc.IsNPC(), npc + " is not an npc!" )
	Assert( !npc.executedSpawnOptions, npc + " tried to set spawn options after npc was dispatchspawned." )

	if ( !npc.IsTitan() )
		npc.mySpawnOptions_sidearm = { wep = weapon, mods = mods }
}

void function SetSpawnOption_Ordnance( entity npc, string ordnance, array<string> mods = [] )
{
	Assert( IsValid( npc ) && npc.IsNPC(), npc + " is not an npc!" )
	Assert( !npc.executedSpawnOptions, npc + " tried to set spawn options after npc was dispatchspawned." )
	npc.ai.titanSpawnLoadout.ordnance = ordnance
	npc.ai.titanSpawnLoadout.ordnanceMods = mods
}

void function SetSpawnOption_Special( entity npc, string special, array<string> mods = [] )
{
	Assert( IsValid( npc ) && npc.IsNPC(), npc + " is not an npc!" )
	Assert( !npc.executedSpawnOptions, npc + " tried to set spawn options after npc was dispatchspawned." )
	npc.ai.titanSpawnLoadout.special = special
	npc.ai.titanSpawnLoadout.specialMods = mods
}

void function SetSpawnOption_Antirodeo( entity npc, string antirodeo, array<string> mods = [] )
{
	Assert( IsValid( npc ) && npc.IsNPC(), npc + " is not an npc!" )
	Assert( !npc.executedSpawnOptions, npc + " tried to set spawn options after npc was dispatchspawned." )
	npc.ai.titanSpawnLoadout.antirodeo = antirodeo
	npc.ai.titanSpawnLoadout.antirodeoMods = mods
}

void function SetSpawnOption_Melee( entity npc, string melee )
{
	Assert( IsValid( npc ) && npc.IsNPC(), npc + " is not an npc!" )
	Assert( !npc.executedSpawnOptions, npc + " tried to set spawn options after npc was dispatchspawned." )
	npc.ai.titanSpawnLoadout.melee = melee
}

void function SetSpawnOption_CoreAbility( entity npc, string core )
{
	Assert( IsValid( npc ) && npc.IsNPC(), npc + " is not an npc!" )
	Assert( !npc.executedSpawnOptions, npc + " tried to set spawn options after npc was dispatchspawned." )
	npc.ai.titanSpawnLoadout.coreAbility = core
}

function SetSpawnOption_SquadName( entity npc, squadName )
{
	Assert( IsValid( npc ) && npc.IsNPC(), npc + " is not an npc!" )
	Assert( !npc.executedSpawnOptions, npc + " tried to set spawn options after npc was dispatchspawned." )
	npc.kv.squadname = squadName
}

function SetSpawnOption_Titanfall( entity npc )
{
	Assert( IsValid( npc ) && npc.IsNPC(), npc + " is not an npc!" )
	Assert( !npc.executedSpawnOptions, npc + " tried to set spawn options after npc was dispatchspawned." )
	Assert( npc.IsTitan(), "npc is for titans only" )
	npc.mySpawnOptions_titanfallSpawn = true
}

function SetSpawnOption_Warpfall( entity npc )
{
	Assert( IsValid( npc ) && npc.IsNPC(), npc + " is not an npc!" )
	Assert( !npc.executedSpawnOptions, npc + " tried to set spawn options after npc was dispatchspawned." )
	Assert( npc.IsTitan() || npc.GetClassName() == "npc_super_spectre", "npc is for titans and superspectres only" )
	npc.mySpawnOptions_warpfallSpawn = true
}

function SetSpawnOption_OwnerPlayer( entity npc, entity player )
{
	Assert( IsValid( player ) )
	Assert( player.IsPlayer() )
	Assert( IsValid( npc ) && npc.IsNPC(), npc + " is not an npc!" )
	Assert( !npc.executedSpawnOptions, npc + " tried to set spawn options after npc was dispatchspawned." )
	npc.mySpawnOptions_ownerPlayer = player
}

function SetSpawnOption_TitanSoulPassive1( entity npc, string passive )
{
	Assert( IsValid( npc ) && npc.IsNPC(), npc + " is not an npc!" )
	Assert( !npc.executedSpawnOptions, npc + " tried to set spawn options after npc was dispatchspawned." )
	npc.ai.titanSpawnLoadout.passive1 = passive
}

function SetSpawnOption_TitanSoulPassive2( entity npc, string passive )
{
	Assert( IsValid( npc ) && npc.IsNPC(), npc + " is not an npc!" )
	Assert( !npc.executedSpawnOptions, npc + " tried to set spawn options after npc was dispatchspawned." )
	npc.ai.titanSpawnLoadout.passive2 = passive
}

function SetSpawnOption_TitanSoulPassive3( entity npc, string passive )
{
	Assert( IsValid( npc ) && npc.IsNPC(), npc + " is not an npc!" )
	Assert( !npc.executedSpawnOptions, npc + " tried to set spawn options after npc was dispatchspawned." )
	npc.ai.titanSpawnLoadout.passive3 = passive
}

function SetSpawnOption_TitanSoulPassive4( entity npc, string passive )
{
	Assert( IsValid( npc ) && npc.IsNPC(), npc + " is not an npc!" )
	Assert( !npc.executedSpawnOptions, npc + " tried to set spawn options after npc was dispatchspawned." )
	npc.ai.titanSpawnLoadout.passive4 = passive
}

function SetSpawnOption_TitanSoulPassive5( entity npc, string passive )
{
	Assert( IsValid( npc ) && npc.IsNPC(), npc + " is not an npc!" )
	Assert( !npc.executedSpawnOptions, npc + " tried to set spawn options after npc was dispatchspawned." )
	npc.ai.titanSpawnLoadout.passive5 = passive
}

function SetSpawnOption_TitanSoulPassive6( entity npc, string passive )
{
	Assert( IsValid( npc ) && npc.IsNPC(), npc + " is not an npc!" )
	Assert( !npc.executedSpawnOptions, npc + " tried to set spawn options after npc was dispatchspawned." )
	npc.ai.titanSpawnLoadout.passive6 = passive
}

function SetSpawnOption_NPCTitan( entity npc, int type )
{
	Assert( IsValid( npc ) && npc.IsNPC(), npc + " is not an npc!" )
	Assert( npc.IsTitan(), npc + " is not a Titan!" )
	Assert( !npc.executedSpawnOptions, npc + " tried to set spawn options after npc was dispatchspawned." )
	npc.ai.bossTitanType = type
}


function SetSpawnOption_TitanLoadout( entity npc, TitanLoadoutDef loadout )
{
	Assert( IsValid( npc ) && npc.IsNPC(), npc + " is not an npc!" )
	Assert( npc.IsTitan(), npc + " is not a Titan!" )
	Assert( !npc.executedSpawnOptions, npc + " tried to set spawn options after npc was dispatchspawned." )
	npc.ai.titanSpawnLoadout = loadout
}

bool function IsCrawling( entity npc )
{
	return npc.ai.crawling
}

