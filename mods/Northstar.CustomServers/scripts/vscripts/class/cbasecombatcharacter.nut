untyped

global function CodeCallback_RegisterClass_CBaseCombatCharacter

function CodeCallback_RegisterClass_CBaseCombatCharacter()
{
	CBaseCombatCharacter.ClassName <- "CBaseCombatCharacter"

	RegisterSignal( "ContextAction_SetBusy" ) // signalled from ContextAction_SetBusy() in code


	/*
	CBaseCombatCharacter.__SetActiveWeaponByName <- CBaseCombatCharacter.SetActiveWeaponByName
	function CBaseCombatCharacter::SetActiveWeaponByName( weapon )
	{
		printt( "set active weapon " + weapon + " for " + this )
		return this.__SetActiveWeaponByName( weapon )
	}

	CBaseCombatCharacter.__TakeWeapon <- CBaseCombatCharacter.TakeWeapon
	function CBaseCombatCharacter::TakeWeapon( weapon )
	{
	//	printt( "Take weapon " + weapon + " from " + this )
		return this.__TakeWeapon( weapon )
	}

	*/
}
