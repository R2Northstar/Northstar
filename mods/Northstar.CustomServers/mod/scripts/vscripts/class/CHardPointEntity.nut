untyped

// note: had to rename all instances of C_HardPointEntity to CHardPointEntity here, unsure why this was even a thing?
global function CodeCallback_RegisterClass_CHardPointEntity

function CodeCallback_RegisterClass_CHardPointEntity()
{
	CHardPointEntity.ClassName <- "CHardPointEntity"


	function CHardPointEntity::Enabled()
	{
		return this.GetHardpointID() >= 0
	}
	#document( "CHardPointEntity::Enabled", "Returns true if this hardpoint is enabled" )
}
