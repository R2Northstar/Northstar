untyped

global function TitanTransfer_Init

global function PilotBecomesTitan
global function TitanBecomesPilot
global function CreateAutoTitanForPlayer_ForTitanBecomesPilot
global function CreateAutoTitanForPlayer_FromTitanLoadout
global function CopyWeapons
global function StorePilotWeapons
global function RetrievePilotWeapons
global function SetTitanSettings

global function StoreWeapons
global function GiveWeaponsFromStoredArray

global function TitanCoreEffectTransfer_threaded
global function ForceTitanSustainedDischargeEnd

function TitanTransfer_Init()
{
	// these vars transfer from player titan to npc titan and vice versa

	RegisterSignal( "PlayerEmbarkedTitan" )
	RegisterSignal( "PlayerDisembarkedTitan" )

	AddSoulTransferFunc( TitanCoreEffectTransfer )
	AddCallback_OnTitanBecomesPilot( OnClassChangeBecomePilot )
	AddCallback_OnPilotBecomesTitan( OnClassChangeBecomeTitan )
}

void function TitanCoreEffectTransfer( entity soul, entity titan, entity oldTitan )
{
	thread TitanCoreEffectTransfer_threaded( soul, titan, oldTitan )
}
function TitanCoreEffectTransfer_threaded( entity soul, entity titan, entity oldTitan )
{
	WaitEndFrame() // because the titan aint a titan yet

	if ( !IsValid( soul ) || !IsValid( titan ) )
		return

	if ( !( "coreEffect" in soul.s ) )
		return

	soul.s.coreEffect.ent.Kill_Deprecated_UseDestroyInstead()
	soul.s.coreEffect.ent = soul.s.coreEffect.func( titan, soul.s.coreEffect.parameter )
}

void function OnClassChangeBecomePilot( entity player, entity titan ) //Stuff here used to be in old CPlayer:OnChangedPlayerClass, for turning into Pilot class
{
	player.ClearDoomed()
	player.UnsetUsable()
	player.lastTitanTime = Time()

	player.Minimap_SetHeightTracking( true )
	ResetTitanBuildTime( player )
	RandomizeHead( player )
}

void function OnClassChangeBecomeTitan( entity player, entity titan ) //Stuff here used to be in old CPlayer:OnChangedPlayerClass, for turning into Titan class
{
	CodeCallback_PlayerInTitanCockpit( player, player )
	player.Minimap_SetHeightTracking( false )
	ResetTitanBuildTime( player )
}

function CopyWeapons( entity fromEnt, entity toEnt )
{
	entity activeWeapon = fromEnt.GetActiveWeapon()
	if ( IsValid( activeWeapon ) )
	{
		if ( activeWeapon.IsWeaponOffhand() )
			fromEnt.ClearOffhand()
	}

	array<entity> weapons = fromEnt.GetMainWeapons()
	foreach ( weapon in weapons )
	{
		entity giveWeapon = fromEnt.TakeWeapon_NoDelete( weapon.GetWeaponClassName() )
		toEnt.GiveExistingWeapon( giveWeapon )
	}

	for ( int i = 0; i < OFFHAND_COUNT; i++ )
	{
		entity offhandWeapon
		offhandWeapon = fromEnt.TakeOffhandWeapon_NoDelete( i )

		// maintain offhand index
		if ( offhandWeapon )
			toEnt.GiveExistingOffhandWeapon( offhandWeapon, i )
	}

	if ( activeWeapon )
	{
		string name = activeWeapon.GetWeaponClassName()
		toEnt.SetActiveWeaponByName( name )
	}
}

array<StoredWeapon> function StoreWeapons( entity player )
{
	array<StoredWeapon> storedWeapons

	entity activeWeapon = player.GetActiveWeapon()

	array<entity> mainWeapons = player.GetMainWeapons()

	foreach ( i, weapon in mainWeapons )
	{
		StoredWeapon sw

		if ( weapon.GetScriptFlags0() & WEAPONFLAG_AMPED )
		{
			weapon.Signal( "StopAmpedWeapons" )
		}

		sw.name = weapon.GetWeaponClassName()
		sw.weaponType = eStoredWeaponType.main
		sw.activeWeapon = ( weapon == activeWeapon )
		sw.inventoryIndex = i
		sw.mods = weapon.GetMods()
		sw.modBitfield = weapon.GetModBitField()
		sw.ammoCount = weapon.GetWeaponPrimaryAmmoCount()
		sw.clipCount = weapon.GetWeaponPrimaryClipCount()
		sw.nextAttackTime = weapon.GetNextAttackAllowedTime()
		sw.skinIndex = weapon.GetSkin()
		sw.camoIndex = weapon.GetCamo()
		sw.isProScreenOwner = weapon.GetProScreenOwner() == player

		storedWeapons.append( sw )
	}

	array<entity> offhandWeapons = player.GetOffhandWeapons()

	foreach ( weapon in offhandWeapons )
	{
		StoredWeapon sw

		sw.name = weapon.GetWeaponClassName()
		sw.weaponType = eStoredWeaponType.offhand
		sw.activeWeapon = ( weapon == activeWeapon )
		sw.inventoryIndex = weapon.GetInventoryIndex()
		sw.mods = weapon.GetMods()
		sw.ammoCount = weapon.GetWeaponPrimaryAmmoCount()
		sw.clipCount = weapon.GetWeaponPrimaryClipCount()
		sw.nextAttackTime = weapon.GetNextAttackAllowedTime()
		#if MP
		sw.burnReward = weapon.e.burnReward
		#endif

		if ( sw.activeWeapon )
			storedWeapons.insert( 0, sw )
		else
			storedWeapons.append( sw )
	}

	return storedWeapons
}

void function GiveWeaponsFromStoredArray( entity player, array<StoredWeapon> storedWeapons )
{
	int activeWeaponSlot = 0
	foreach ( i, storedWeapon in storedWeapons )
	{
		entity weapon

		switch ( storedWeapon.weaponType )
		{
			case eStoredWeaponType.main:
				weapon = player.GiveWeapon( storedWeapon.name, storedWeapon.mods )
				weapon.SetWeaponSkin( storedWeapon.skinIndex )
				weapon.SetWeaponCamo( storedWeapon.camoIndex )
				#if MP
				if ( storedWeapon.isProScreenOwner )
				{
					weapon.SetProScreenOwner( player )
					UpdateProScreen( player, weapon )
				}

				string weaponCategory = GetWeaponInfoFileKeyField_GlobalString( weapon.GetWeaponClassName(), "menu_category" )
				if ( weaponCategory == "at" || weaponCategory == "special" ) // refill AT/grenadier ammo stockpile
				{
					int defaultTotal = weapon.GetWeaponSettingInt( eWeaponVar.ammo_default_total )
					int clipSize = weapon.GetWeaponSettingInt( eWeaponVar.ammo_clip_size )

					weapon.SetWeaponPrimaryAmmoCount( defaultTotal - clipSize )

					if ( weapon.GetWeaponPrimaryClipCountMax() > 0 )
						weapon.SetWeaponPrimaryClipCount( storedWeapon.clipCount )
				}
				else
				{
					weapon.SetWeaponPrimaryAmmoCount( storedWeapon.ammoCount )
					if ( weapon.GetWeaponPrimaryClipCountMax() > 0 )
						weapon.SetWeaponPrimaryClipCount( storedWeapon.clipCount )
				}
				#else
				weapon.SetWeaponPrimaryAmmoCount( storedWeapon.ammoCount )
				if ( weapon.GetWeaponPrimaryClipCountMax() > 0 )
					weapon.SetWeaponPrimaryClipCount( storedWeapon.clipCount )
				#endif


				if ( storedWeapon.activeWeapon )
					activeWeaponSlot = i

				break

			case eStoredWeaponType.offhand:
				player.GiveOffhandWeapon( storedWeapon.name, storedWeapon.inventoryIndex, storedWeapon.mods )

				weapon = player.GetOffhandWeapon( storedWeapon.inventoryIndex )
				weapon.SetNextAttackAllowedTime( storedWeapon.nextAttackTime )
				weapon.SetWeaponPrimaryAmmoCount( storedWeapon.ammoCount )
				if ( weapon.GetWeaponPrimaryClipCountMax() > 0 )
					weapon.SetWeaponPrimaryClipCount( storedWeapon.clipCount )
				#if MP
				weapon.e.burnReward = storedWeapon.burnReward
				#endif

				break

			default:
				unreachable
		}
	}

	#if MP
		PlayerInventory_RefreshEquippedState( player )
	#endif

	player.SetActiveWeaponBySlot( activeWeaponSlot )
}

void function RetrievePilotWeapons( entity player )
{
	TakeAllWeapons( player )
	GiveWeaponsFromStoredArray( player, player.p.storedWeapons )
	SetPlayerCooldowns( player )
	player.p.storedWeapons.clear()
}

function StorePilotWeapons( entity player )
{
	player.p.storedWeapons = StoreWeapons( player )
	StoreOffhandData( player, false )
	TakeAllWeapons( player )
}

function TransferHealth( srcEnt, destEnt )
{
	destEnt.SetMaxHealth( srcEnt.GetMaxHealth() )
	destEnt.SetHealth( srcEnt.GetHealth() )
	//destEnt.SetHealthPerSegment( srcEnt.GetHealthPerSegment() )
}

entity function CreateAutoTitanForPlayer_FromTitanLoadout( entity player, TitanLoadoutDef loadout, vector origin, vector angles )
{
	int team = player.GetTeam()

	player.titansBuilt++
	ResetTitanBuildTime( player )

	entity npcTitan = CreateNPCTitan( loadout.setFile, team, origin, angles, loadout.setFileMods )
	SetTitanSpawnOptionsFromLoadout( npcTitan, loadout )
	SetSpawnOption_OwnerPlayer( npcTitan, player )

	if ( IsSingleplayer() )
	{
		npcTitan.EnableNPCFlag( NPC_IGNORE_FRIENDLY_SOUND )
	}
	#if MP
		string titanRef = GetTitanCharacterNameFromSetFile( loadout.setFile )
		npcTitan.SetTargetInfoIcon( GetTitanCoreIcon( titanRef ) )
	#endif

	return npcTitan
}

entity function CreateAutoTitanForPlayer_ForTitanBecomesPilot( entity player, bool hidden = false )
{
	vector origin = player.GetOrigin()
	vector angles = player.GetAngles()
	TitanLoadoutDef loadout = GetTitanLoadoutFromPlayerInventory( player )

	int team = player.GetTeam()
	entity npcTitan = CreateNPCTitan( loadout.setFile, team, origin, angles, loadout.setFileMods )
	npcTitan.s.spawnWithoutSoul <- true
	SetTitanSpawnOptionsFromLoadout( npcTitan, loadout )
	SetSpawnOption_OwnerPlayer( npcTitan, player )
	npcTitan.SetSkin( player.GetSkin() )
	npcTitan.SetCamo( player.GetCamo() )
	npcTitan.SetDecal( player.GetDecal() )

	if ( IsSingleplayer() )
		npcTitan.EnableNPCFlag( NPC_IGNORE_FRIENDLY_SOUND )

	return npcTitan
}

void function SetTitanSpawnOptionsFromLoadout( entity titan, TitanLoadoutDef loadout )
{
	titan.ai.titanSpawnLoadout = loadout
}

TitanLoadoutDef function GetTitanLoadoutFromPlayerInventory( entity player ) //TODO: Examine necessity for this? Was needed in R1 where TItans could pick up weapons off the ground, but may not be needed in R2 anymore. Might just be fine to call GetTitanLoadoutForPlayer()
{
	TitanLoadoutDef loadout = GetTitanLoadoutForPlayer( player )
	loadout.setFile = player.GetPlayerSettings()
	loadout.setFileMods = UntypedArrayToStringArray( player.GetPlayerSettingsMods() )

	array mainWeapons = player.GetMainWeapons()
	if ( mainWeapons.len() )
	{
		entity wep = player.GetMainWeapons()[0]
		loadout.primary = wep.GetWeaponClassName()
		loadout.primaryMods = wep.GetMods()
	}

	entity ord = player.GetOffhandWeapon(OFFHAND_ORDNANCE)
	if ( ord )
	{
		loadout.ordnance = ord.GetWeaponClassName()
		loadout.ordnanceMods = ord.GetMods()
	}

	entity tac = player.GetOffhandWeapon(OFFHAND_SPECIAL)
	if ( tac )
	{
		loadout.special = tac.GetWeaponClassName()
		loadout.specialMods = tac.GetMods()
	}

	entity antirodeo = player.GetOffhandWeapon(OFFHAND_ANTIRODEO)
	if ( antirodeo )
	{
		loadout.antirodeo = antirodeo.GetWeaponClassName()
		loadout.antirodeoMods = antirodeo.GetMods()
	}

	entity melee = player.GetMeleeWeapon()
	if ( melee )
		loadout.melee = melee.GetWeaponClassName()

	return loadout
}

void function ForceTitanSustainedDischargeEnd( entity player )
{
    // To disable core's while disembarking
	local weapons = player.GetOffhandWeapons()
   	foreach ( weapon in weapons )
   	{
   		if ( weapon.IsChargeWeapon() )
   			weapon.ForceChargeEndNoAttack()

   		if ( weapon.IsSustainedDischargeWeapon() && weapon.IsDischarging() )
   			weapon.ForceSustainedDischargeEnd();
   	}
}

function TitanBecomesPilot( entity player, entity titan )
{
	Assert( IsAlive( player ), player + ": Player is not alive" )
	Assert( player.IsTitan(), player + " is not a titan" )

	Assert( IsAlive( titan ), titan + " is not alive." )
	Assert( titan.IsTitan(), titan + " is not alive." )

	asset model = player.GetModelName()
	int skin = player.GetSkin()
	int camo = player.GetCamo()
	int decal = player.GetDecal()
	titan.SetModel( model )
	titan.SetSkin( skin )
	titan.SetCamo( camo )
	titan.SetDecal( decal )
	titan.SetPoseParametersSameAs( player )
	titan.SequenceTransitionFromEntity( player )

	ForceTitanSustainedDischargeEnd( player )

	TransferHealth( player, titan )
	//Transfer children before player becomes pilot model
	player.TransferChildrenTo( titan )
	player.TransferTethersToEntity( titan )
	entity soul = player.GetTitanSoul()
	SetSoulOwner( soul, titan )
	Assert( player.GetTitanSoul() == null )

	// this must happen before changing the players settings
	TransferDamageStates( player, titan )

	// cant have a titan passive when you're not a titan
	TakeAllTitanPassives( player )

	player.SetPlayerSettingsWithMods( player.s.storedPlayerSettings, player.s.storedPlayerSettingsMods )
	player.SetPlayerSettingPosMods( PLAYERPOSE_STANDING, player.s.storedPlayerStandMods )
	player.SetPlayerSettingPosMods( PLAYERPOSE_CROUCHING, player.s.storedPlayerCrouchMods )
	player.SetSkin( player.s.storedPlayerSkinIndex )
	player.SetCamo( player.s.storedPlayerCamoIndex )

	delete player.s.storedPlayerSettings
	delete player.s.storedPlayerSettingsMods
	delete player.s.storedPlayerStandMods
	delete player.s.storedPlayerCrouchMods
	delete player.s.storedPlayerSkinIndex
	delete player.s.storedPlayerCamoIndex

	TakeAllWeapons( titan )
	CopyWeapons( player, titan )

	player.SetTitle( "" )

	RetrievePilotWeapons( player )

	if ( Riff_AmmoLimit() != eAmmoLimit.Default )
	{
		switch ( Riff_AmmoLimit() )
		{
			case eAmmoLimit.Limited:
				local weapons = player.GetMainWeapons()
				foreach ( weapon in weapons )
				{
					local clipAmmo = player.GetWeaponAmmoMaxLoaded( weapon )

					if ( clipAmmo > 0 )
						weapon.SetWeaponPrimaryAmmoCount( clipAmmo * 2 )
				}

				local offhand = player.GetOffhandWeapon( 0 )
				if ( offhand )
				{
					local ammoLoaded = player.GetWeaponAmmoMaxLoaded( offhand )
					offhand.SetWeaponPrimaryClipCount( max( 1, ammoLoaded - 2 ) )
				}
				break
		}
	}

	// Added via AddCallback_OnTitanBecomesPilot
	foreach ( callbackFunc in svGlobal.onTitanBecomesPilotCallbacks )
	{
		callbackFunc( player, titan )
	}

	// Ensure rodeo doesn't happen straight away, if a nearby Titan runs by
	Rodeo_SetCooldown( player )

	if ( player.cloakedForever )
	{
		// infinite cloak active
		EnableCloakForever( player )
	}
	if ( player.stimmedForever )
	{
		StimPlayer( player, USE_TIME_INFINITE )
	}

	soul.Signal( "PlayerDisembarkedTitan", { player = player } )

	// no longer owned
	if ( soul.capturable )
	{
		soul.ClearBossPlayer()
		titan.ClearBossPlayer()
		titan.SetUsableByGroup( "friendlies pilot" )
		titan.DisableBehavior( "Follow" )
		player.SetPetTitan( null )
		if ( !player.s.savedTitanBuildTimer )
			ResetTitanBuildTime( player )
		else
			player.SetNextTitanRespawnAvailable( player.s.savedTitanBuildTimer )
		return
	}
	return titan
}

function PilotBecomesTitan( entity player, entity titan, bool fullCopy = true )
{
	player.SetPetTitan( null )

	// puts the weapons into a table
	StorePilotWeapons( player )

	#if HAS_TITAN_WEAPON_SWAPPING
	{
		foreach ( weapon in titan.GetMainWeapons() )
		{
			// the pilot's weapons will recent entirely in sp if this doesn't match
			player.p.lastPrimaryWeaponEnt = weapon
			break
		}
	}
	#endif

	if ( fullCopy )
	{
		CopyWeapons( titan, player )
	}

	//Should only be the first time a player embarks into a Titan that Titan's life.
	//Check with differ if there is a better way than .e.var on the soul.
	//TitanLoadoutDef loadout = GetTitanLoadoutForPlayer( player )
	//PROTO_DisplayTitanLoadouts( player, titan, loadout )

	entity soul = titan.GetTitanSoul()
	soul.soul.lastOwner = player

	player.s.storedPlayerSettings <- player.GetPlayerSettings()
	player.s.storedPlayerSettingsMods <- player.GetPlayerSettingsMods()
	player.s.storedPlayerStandMods <- player.GetPlayerModsForPos( PLAYERPOSE_STANDING )
	player.s.storedPlayerCrouchMods <- player.GetPlayerModsForPos( PLAYERPOSE_CROUCHING )
	player.s.storedPlayerSkinIndex <- player.GetSkin()
	player.s.storedPlayerCamoIndex <- player.GetCamo()
	printt( player.GetSkin(), player.GetCamo() )

	string settings = GetSoulPlayerSettings( soul )
	var titanTint = Dev_GetPlayerSettingByKeyField_Global( settings, "titan_tint" )

	if ( titanTint != null )
	{
		expect string( titanTint )
		Highlight_SetEnemyHighlight( player, titanTint )
	}
	else
	{
		Highlight_ClearEnemyHighlight( player )
	}

	if ( !player.GetParent() )
	{
		player.SetOrigin( titan.GetOrigin() )
		player.SetAngles( titan.GetAngles() )
		player.SetVelocity( Vector( 0,0,0 ) )
	}

	if ( soul.capturable )
	{
		printt( player.GetPetTitan(), player.GetNextTitanRespawnAvailable() )
		if ( IsValid( player.GetPetTitan() ) || player.s.replacementDropInProgress )
			player.s.savedTitanBuildTimer <- null
		else
			player.s.savedTitanBuildTimer <- player.GetNextTitanRespawnAvailable()

		if ( GameRules_GetGameMode() == "ctt" )
		{
			titan.Minimap_AlwaysShow( 0, null )
			player.Minimap_AlwaysShow( TEAM_IMC, null )
			player.Minimap_AlwaysShow( TEAM_MILITIA, null )
			player.SetHudInfoVisibilityTestAlwaysPasses( true )
		}
	}

	SetSoulOwner( soul, player )

	if ( soul.GetBossPlayer() != player )
		SoulBecomesOwnedByPlayer( soul, player )

	foreach ( int passive, _ in level.titanPassives )
	{
		if ( SoulHasPassive( soul, passive ) )
		{
			GiveTitanPassiveLifeLong( player, passive )
		}
	}

	asset model = titan.GetModelName()
	int skin = titan.GetSkin()
	int camo = titan.GetCamo()
	int decal = titan.GetDecal()
	TitanSettings titanSettings = titan.ai.titanSettings
	array<string> mods = titanSettings.titanSetFileMods

	player.SetPlayerSettingsFromDataTable( { playerSetFile = titanSettings.titanSetFile, playerSetFileMods = mods } )
	var title = GetPlayerSettingsFieldForClassName( settings, "printname" )

	if ( title != null )
	{
		player.SetTitle( expect string( title ) )
	}

	if ( IsAlive( player ) )
		TransferHealth( titan, player )

	player.SetModel( model )
	player.SetSkin( skin )
	player.SetCamo( camo )
	player.SetDecal( decal )
	player.SetPoseParametersSameAs( titan )
	player.SequenceTransitionFromEntity( titan )

	// no cloak titan
	player.SetCloakDuration( 0, 0, 0 )

	// this must happen after changing the players settings
	TransferDamageStates( titan, player )

	titan.TransferTethersToEntity( player )

	//We parent the player to the titan in the process of embarking
	//Must clear parent when transfering children to avoid parenting the player to himself
	if ( player.GetParent() == titan )
		player.ClearParent()
	//Transfer children after player has become titan model.
	titan.TransferChildrenTo( player )

	player.SetOrigin( titan.GetOrigin() )
	player.SetAngles( titan.GetAngles() )
	player.SetVelocity( Vector( 0,0,0 ) )

	soul.e.embarkCount++
	soul.Signal( "PlayerEmbarkedTitan", { player = player } )
	player.Signal( "PlayerEmbarkedTitan", { titan = titan } )
	titan.Signal( "TitanStopsThinking" )

	// Added via AddCallback_OnPilotBecomesTitan
	foreach ( callbackFunc in svGlobal.onPilotBecomesTitanCallbacks )
	{
		callbackFunc( player, titan )
	}

	#if DEV
		thread Dev_CheckTitanIsDeletedAtEndOfPilotBecomesTitan( titan )
	#endif
}

void function SetTitanSettings( TitanSettings titanSettings, string titanSetFile, array<string> mods = [] )
{
	Assert( titanSettings.titanSetFile == "", "Tried to set titan settings to " + titanSetFile + ", but its already set to " + titanSettings.titanSetFile )
	titanSettings.titanSetFile = titanSetFile
	titanSettings.titanSetFileMods = mods
}

void function Dev_CheckTitanIsDeletedAtEndOfPilotBecomesTitan( entity titan )
{
	WaitEndFrame()

	Assert( !IsValid( titan ), "Titan should be deleted at end of PilotBecomesTitan" )
}