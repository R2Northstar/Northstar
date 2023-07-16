ArcCannon_PrecacheFX( self )

function OnWeaponActivate( activateParams )
{
	local weaponOwner = self.GetWeaponOwner()
	thread DelayedArcCannonStart( self, weaponOwner )
	if( !("weaponOwner" in self.s) )
		self.s.weaponOwner <- weaponOwner
}

function DelayedArcCannonStart( weapon, weaponOwner )
{
	weapon.EndSignal( "WeaponDeactivateEvent" )

	wait 0

	if ( IsValid( weapon ) && IsValid( weaponOwner ) && weapon == weaponOwner.GetActiveWeapon() )
	{
		if( weaponOwner.IsPlayer() )
		{
			local modelEnt = weaponOwner.GetViewModelEntity()
	 		if( IsValid( modelEnt ) && EntHasModelSet( modelEnt ) )
				ArcCannon_Start( weapon )
		}
		else
		{
			ArcCannon_Start( weapon )
		}
	}
}

function OnWeaponDeactivate( deactivateParams )
{
	ArcCannon_ChargeEnd( self, self.s.weaponOwner )
	ArcCannon_Stop( self )
}

function OnWeaponReload( reloadParams )
{
	local reloadTime = self.GetWeaponInfoFileKeyField( "reload_time" )
	thread ArcCannon_HideIdleEffect( self, reloadTime ) //constant seems to help it sync up better
}

function OnWeaponOwnerChanged( changeParams )
{
	if ( IsClient() )
	{
		local viewPlayer = GetLocalViewPlayer()
		if ( changeParams.oldOwner != null && changeParams.oldOwner == viewPlayer )
		{
			ArcCannon_ChargeEnd( self, changeParams.oldOwner )
			ArcCannon_Stop( self, changeParams.oldOwner )
		}
		if ( changeParams.newOwner != null && changeParams.newOwner == viewPlayer )
			thread ArcCannon_HideIdleEffect( self, 0.25 )	
	}
	else
	{
		if ( changeParams.oldOwner != null )
		{
			ArcCannon_ChargeEnd( self, changeParams.oldOwner )
			ArcCannon_Stop( self, changeParams.oldOwner )
		}
		if ( changeParams.newOwner != null )
			thread ArcCannon_HideIdleEffect( self, 0.25 )			
	}
}

function OnWeaponChargeBegin( chargeParams )
{
	ArcCannon_ChargeBegin( self )
}

function OnWeaponChargeEnd( chargeParams )
{
	ArcCannon_ChargeEnd( self )
}

function OnWeaponPrimaryAttack( attackParams )
{
	if ( self.HasMod( "capacitor" ) && self.GetWeaponChargeFraction() < GetArcCannonChargeFraction( self ) )
		return 0

	if ( !attackParams.firstTimePredicted )
		return

	local fireRate = self.GetWeaponInfoFileKeyField( "fire_rate" )
	thread ArcCannon_HideIdleEffect( self, (1 / fireRate) )
	return FireArcCannon( self, attackParams )
}

function OnWeaponNpcPrimaryAttack( attackParams )
{
	local fireRate = self.GetWeaponInfoFileKeyField( "fire_rate" )
	thread ArcCannon_HideIdleEffect( self, fireRate )
	return FireArcCannon( self, attackParams )
}

function OnWeaponStartZoomIn()
{
	HandleWeaponSoundZoomIn( self, "Weapon_Titan_ArcCannon.ADS_In" )
}

function OnWeaponStartZoomOut()
{
	HandleWeaponSoundZoomOut( self, "Weapon_Titan_ArcCannon.ADS_Out" )
}

/*
function OnWeaponPrimaryAttackVMActivityToUse()
{
	local baseCharge = self.GetWeaponChargeFraction()
	local charge = clamp ( baseCharge * ( 1 / 0.7 ), 0.0, 1.0 )

	if ( charge > 0.25 )
		return 1
	else
		return 0
}*/
