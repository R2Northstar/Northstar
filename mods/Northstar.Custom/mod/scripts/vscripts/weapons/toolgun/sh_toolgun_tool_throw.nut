global function ToolgunToolThrowEntity_Init

void function ToolgunToolThrowEntity_Init()
{
	AddCallback_OnToolgunToolsInit( CreateToolgunToolThrow )
}

void function CreateToolgunToolThrow()
{
	ToolgunTool throwTool
	throwTool.toolName = "Throw entity"
	throwTool.toolDescription = "Spawns and throws the currently selected entity type"
	
	throwTool.onFired = ToolgunToolThrow_OnFired
	
	RegisterTool( throwTool )
}

void function ToolgunToolThrow_OnFired( entity player, entity weapon, WeaponPrimaryAttackParams attackParams )
{
	#if SERVER
	ClientCommand( player, "ent_throw npc_frag_drone" )
	#endif
}