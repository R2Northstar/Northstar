global function ToolgunToolCreateExplosion_Init

void function ToolgunToolCreateExplosion_Init()
{
	AddCallback_OnToolgunToolsInit( CreateToolgunToolCreateExplosion )
}

void function CreateToolgunToolCreateExplosion()
{
	ToolgunTool createExplosionTool
	createExplosionTool.toolName = "Create explosion"
	createExplosionTool.toolDescription = "Creates an explosion"
	
	createExplosionTool.onFired = ToolgunToolCreateExplosion_Fire
	
	RegisterTool( createExplosionTool )
}

void function ToolgunToolCreateExplosion_Fire( entity player, entity weapon, WeaponPrimaryAttackParams attackParams )
{
	#if SERVER
	int dist = 55555 // should hit edge of map at all times ideally
	vector forward = AnglesToForward( player.EyeAngles() )

	// raycast to explosion position
	TraceResults trace = TraceLine( player.EyePosition(), player.EyePosition() + ( dist * forward ), null, TRACE_MASK_NPCSOLID )
	// make explosion
	Explosion( trace.endPos, player, player, 90, 90, 100, 100, 0, trace.endPos, 5000, damageTypes.explosive, eDamageSourceId.burn, "exp_small" )
	#endif
}