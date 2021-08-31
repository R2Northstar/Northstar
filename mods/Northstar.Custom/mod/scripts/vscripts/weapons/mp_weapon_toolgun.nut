untyped
global function OnWeaponActivate_weapon_toolgun
global function OnWeaponDeactivate_weapon_toolgun
global function OnWeaponPrimaryAttack_weapon_toolgun
global function OnWeaponStartZoomIn_weapon_toolgun
global function OnWeaponStartZoomOut_weapon_toolgun
#if SERVER
global function OnWeaponNpcPrimaryAttack_weapon_toolgun
#endif

void function OnWeaponActivate_weapon_toolgun( entity weapon )
{
	CallToolOnEquipped( weapon.GetOwner(), weapon )
}

void function OnWeaponDeactivate_weapon_toolgun( entity weapon )
{
	CallToolOnUnequipped( weapon.GetOwner(), weapon )
}

var function OnWeaponPrimaryAttack_weapon_toolgun( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	CallToolOnFired( weapon.GetOwner(), weapon, attackParams )
}

void function OnWeaponStartZoomIn_weapon_toolgun( entity weapon )
{
	CallToolOnAds( weapon.GetOwner(), weapon )
}

void function OnWeaponStartZoomOut_weapon_toolgun( entity weapon )
{
	CallToolOnUnAds( weapon.GetOwner(), weapon )
}

var function OnWeaponNpcPrimaryAttack_weapon_toolgun( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	// do nothing for now, maybe make it launch nukes or something later that could be funny
} 