
global function UpdatePilotLoadoutPanel
global function UpdatePilotLoadoutPanelBinds
global function UpdatePilotLoadoutButtons
global function UpdatePilotItemButton

void function UpdatePilotLoadoutButtons( int selectedIndex, var[NUM_PERSISTENT_PILOT_LOADOUTS] buttons, bool focusSelected = true )
{
	entity player = GetUIPlayer()
	if ( player == null )
		return

	int numLoadouts = GetAllCachedPilotLoadouts().len()

	// HACK: num_pilot_loadouts is just used to disable certain loadouts for FNF
	int numLoadoutsForPlaylist = GetCurrentPlaylistVarInt( "num_pilot_loadouts", 0 )
	if ( numLoadoutsForPlaylist > 0 )
		numLoadouts = numLoadoutsForPlaylist

	foreach ( index, button in buttons )
	{
		PilotLoadoutDef loadout = GetCachedPilotLoadout( index )
		RHud_SetText( button, GetPilotLoadoutName( loadout ) )
		Hud_SetPanelAlpha( button, 0 )

		bool isSelected = ( index == selectedIndex ) ? true : false
		Hud_SetSelected( button, isSelected )

		string pilotLoadoutRef = "pilot_loadout_" + ( index + 1 )
		Hud_SetLocked( button, IsItemLocked( player, pilotLoadoutRef ) )

		bool shouldShowNew = ButtonShouldShowNew( eItemTypes.FEATURE, pilotLoadoutRef )
		if ( !shouldShowNew && (RefHasAnyNewSubitem( player, loadout.primary ) || RefHasAnyNewSubitem( player, loadout.secondary ) || RefHasAnyNewSubitem( player, loadout.weapon3 )) )
			shouldShowNew = true

		if ( IsItemLocked( player, pilotLoadoutRef ) )
			shouldShowNew = false

		Hud_SetNew( button, shouldShowNew )

		RefreshButtonCost( button, pilotLoadoutRef )
	}

	if ( focusSelected )
		Hud_SetFocused( buttons[ selectedIndex ] )
}

void function UpdatePilotLoadoutPanel( var loadoutPanel, PilotLoadoutDef loadout )
{
	SetLabelRuiText( Hud_GetChild( loadoutPanel, "TacticalName" ), Localize( GetItemName( loadout.special ) ) )
	SetLabelRuiText( Hud_GetChild( loadoutPanel, "PrimaryName" ), Localize( GetItemName( loadout.primary ) ) )
	SetLabelRuiText( Hud_GetChild( loadoutPanel, "SecondaryName" ), Localize( GetItemName( loadout.secondary ) ) )
	SetLabelRuiText( Hud_GetChild( loadoutPanel, "Weapon3Name" ), Localize( GetItemName( loadout.weapon3 ) ) )
	SetLabelRuiText( Hud_GetChild( loadoutPanel, "OrdnanceName" ), Localize( GetItemName( loadout.ordnance ) ) )
	SetLabelRuiText( Hud_GetChild( loadoutPanel, "Kit1Name" ), Localize( GetItemName( loadout.passive1 ) ) )
	SetLabelRuiText( Hud_GetChild( loadoutPanel, "Kit2Name" ), Localize( GetItemName( loadout.passive2 ) ) )
	SetLabelRuiText( Hud_GetChild( loadoutPanel, "ExecutionName" ), Localize( GetItemName( loadout.execution ) ) )

	UpdatePilotLoadoutPanelBinds( loadoutPanel )

	var menu = Hud_GetParent( loadoutPanel )
	array<var> buttons = GetElementsByClassname( menu, "PilotLoadoutPanelButtonClass" )

	/*if ( button )
	{
		// TEMP disabled since Hud_GetChild( menu, "ButtonTooltip" ) will fail
		//if ( HandleLockedMenuItem( menu, button ) )
		//	return
	}*/
	bool isEdit
	if ( Hud_GetHudName( loadoutPanel ) == "PilotLoadoutButtons" ) // Edit menu
		isEdit = true
	else // Select menu
		isEdit = false

	foreach ( button in buttons )
		UpdatePilotItemButton( button, loadout, isEdit )

	var renameEditBox = Hud_GetChild( loadoutPanel, "RenameEditBox" )

	asset pilotAppearanceImage = loadout.camoIndex > 0 ? CamoSkin_GetImage( CamoSkins_GetByIndex( loadout.camoIndex ) ) : $"rui/menu/common/appearance_button_swatch"

	asset primaryAppearanceImage
	if ( loadout.primarySkinIndex == 0 ) // default skin
		primaryAppearanceImage = $"rui/menu/common/appearance_button_swatch"
	else if ( loadout.primarySkinIndex == 1 ) // camo
		primaryAppearanceImage = CamoSkin_GetImage( CamoSkins_GetByIndex( loadout.primaryCamoIndex ) )
	else // warpaint skin
		primaryAppearanceImage = GetItemImageFromWeaponRefAndPersistenceValue( loadout.primary, loadout.primarySkinIndex, "primarySkinIndex" )

	asset secondaryAppearanceImage
	if ( loadout.secondarySkinIndex == 0 ) // default skin
		secondaryAppearanceImage = $"rui/menu/common/appearance_button_swatch"
	else if ( loadout.secondarySkinIndex == 1 ) // camo
		secondaryAppearanceImage = CamoSkin_GetImage( CamoSkins_GetByIndex( loadout.secondaryCamoIndex ) )
	else // warpaint skin
		secondaryAppearanceImage = GetItemImageFromWeaponRefAndPersistenceValue( loadout.secondary, loadout.secondarySkinIndex, "secondarySkinIndex" )

	asset weapon3AppearanceImage
	if ( loadout.weapon3SkinIndex == 0 ) // default skin
		weapon3AppearanceImage = $"rui/menu/common/appearance_button_swatch"
	else if ( loadout.weapon3SkinIndex == 1 ) // camo
		weapon3AppearanceImage = CamoSkin_GetImage( CamoSkins_GetByIndex( loadout.weapon3CamoIndex ) )
	else // warpaint skin
		weapon3AppearanceImage = GetItemImageFromWeaponRefAndPersistenceValue( loadout.weapon3, loadout.weapon3SkinIndex, "weapon3SkinIndex" )

	RuiSetImage( Hud_GetRui( Hud_GetChild( loadoutPanel, "ButtonPilotCamo" ) ), "camoImage", pilotAppearanceImage )
	RuiSetImage( Hud_GetRui( Hud_GetChild( loadoutPanel, "ButtonPrimarySkin" ) ), "camoImage", primaryAppearanceImage )
	RuiSetImage( Hud_GetRui( Hud_GetChild( loadoutPanel, "ButtonSecondarySkin" ) ), "camoImage", secondaryAppearanceImage )
	RuiSetImage( Hud_GetRui( Hud_GetChild( loadoutPanel, "ButtonWeapon3Skin" ) ), "camoImage", weapon3AppearanceImage )

	array<var> nonItemElements
	nonItemElements.append( Hud_GetChild( loadoutPanel, "ButtonPilotCamo" ) )
	nonItemElements.append( Hud_GetChild( loadoutPanel, "ButtonGender" ) )
	nonItemElements.append( Hud_GetChild( loadoutPanel, "ButtonPrimarySkin" ) )
	nonItemElements.append( Hud_GetChild( loadoutPanel, "ButtonSecondarySkin" ) )
	nonItemElements.append( Hud_GetChild( loadoutPanel, "ButtonWeapon3Skin" ) )
	nonItemElements.append( renameEditBox )

	foreach ( elem in nonItemElements )
	{
		if ( isEdit )
			Hud_Show( elem )
		else
			Hud_Hide( elem )
	}
	Hud_SetEnabled( renameEditBox, isEdit )
}

void function UpdatePilotItemButton( var button, PilotLoadoutDef loadout, bool isEdit )
{
	string propertyName = Hud_GetScriptID( button )
	string itemRef = GetPilotLoadoutValue( loadout, propertyName )
	int itemType = GetItemTypeFromPilotLoadoutProperty( propertyName )
	asset image

	ItemDisplayData parentItem

	if ( itemType == eItemTypes.PILOT_PRIMARY_ATTACHMENT || itemType == eItemTypes.PILOT_PRIMARY_MOD || itemType == eItemTypes.PILOT_SECONDARY_MOD || itemType == eItemTypes.PILOT_WEAPON_MOD3 )
	{
		string parentProperty = GetParentLoadoutProperty( "pilot", propertyName )
		Assert( parentProperty == "primary" || parentProperty == "secondary" || parentProperty == "weapon3" )

		if ( parentProperty == "primary" )
			parentItem = GetItemDisplayData( loadout.primary )
		else if ( parentProperty == "secondary" )
			parentItem = GetItemDisplayData( loadout.secondary )
		else
			parentItem = GetItemDisplayData( loadout.weapon3 )

		bool isHiddenAttachment = false

		if ( itemType == eItemTypes.PILOT_PRIMARY_ATTACHMENT )
		{
			// Disable attachment option for "special" primary weapons
			if ( "menuCategory" in parentItem.i && ( expect int( parentItem.i.menuCategory ) == ePrimaryWeaponCategory.SPECIAL || expect int( parentItem.i.menuCategory ) == ePrimaryWeaponCategory.HANDGUN ) )
			{
				isHiddenAttachment = true

				Hud_SetWidth( button, 0 )
				Hud_SetPos( button, 0, 0 ) // Clear sibling offset
			}
			else
			{
				int defaultButtonWidth = int( ContentScaledX( 72 ) )
				int defaultOffsetX = int( ContentScaledX( 6 ) )

				Hud_SetWidth( button, defaultButtonWidth )
				Hud_SetPos( button, defaultOffsetX, 0 )
			}
		}

		if ( !isHiddenAttachment )
			image = GetImage( itemType, parentItem.ref, itemRef )
	}
	else
	{
		image = GetImage( itemType, itemRef )
	}

	if ( itemType == eItemTypes.PILOT_PRIMARY || itemType == eItemTypes.PILOT_SECONDARY )
	{
		//if ( isEdit )
		//{
		//	RuiSetString( Hud_GetRui( button ), "subText", "" )
		//	RuiSetFloat( Hud_GetRui( button ), "numSegments", 0 )
		//	RuiSetFloat( Hud_GetRui( button ), "filledSegments", 0 )
		//}
		//else
		{
			int currentXP = WeaponGetXP( GetLocalClientPlayer(), itemRef )
			int numPips = WeaponGetNumPipsForXP( itemRef, currentXP )
			int filledPips = WeaponGetFilledPipsForXP( itemRef, currentXP )
			RuiSetString( Hud_GetRui( button ), "subText", WeaponGetDisplayGenAndLevelForXP( itemRef, currentXP ) )
			RuiSetFloat( Hud_GetRui( button ), "numSegments", float( numPips ) )
			RuiSetFloat( Hud_GetRui( button ), "filledSegments", float( filledPips ) )
		}
	}

	var rui = Hud_GetRui( button )

	if ( image == $"" )
	{
		RuiSetBool( rui, "isVisible", false )
		Hud_SetEnabled( button, false )
	}
	else
	{
		RuiSetBool( rui, "isVisible", true )
		RuiSetImage( rui, "buttonImage", image )

		Hud_SetEnabled( button, true )
	}

	bool isLocked = false
	bool shouldShowNew = false

	// For unlock and subitem checks below, treat weapon3 as secondary
	if ( propertyName == "weapon3Mod1" )
		propertyName = "secondaryMod1"
	else if ( propertyName == "weapon3Mod2" )
		propertyName = "secondaryMod2"
	else if ( propertyName == "weapon3Mod3" )
		propertyName = "secondaryMod3"

	string propertyRef = propertyName.tolower()

	if ( !IsSubItemType( itemType ) )
	{
		if ( IsUnlockValid( propertyRef ) && IsItemLocked( GetUIPlayer(), propertyRef ) )
		{
			RefreshButtonCost( button, propertyRef )
			isLocked = true
		}
		shouldShowNew = ButtonShouldShowNew( itemType, itemRef )
	}
	else
	{
		if ( IsUnlockValid( propertyRef, parentItem.ref ) && IsSubItemLocked( GetUIPlayer(), propertyRef, parentItem.ref ) )
		{
			RefreshButtonCost( button, propertyRef )
			isLocked = true
		}
		shouldShowNew = ButtonShouldShowNew( itemType, itemRef, parentItem.ref )
	}

	Hud_SetLocked( button, isLocked )

	if ( !shouldShowNew && IsUnlockValid( propertyRef, parentItem.ref ) )
		shouldShowNew = ButtonShouldShowNew( GetSubitemType( parentItem.ref, propertyRef ), propertyRef, parentItem.ref )
	Hud_SetNew( button, shouldShowNew )

#if HAS_THREAT_SCOPE_SLOT_LOCK
	if ( propertyName == "primaryMod2" )
	{
		string attatchmentRef = GetPilotLoadoutValue( loadout, "primaryAttachment" )
		if ( attatchmentRef == "threat_scope" )
		{
			Hud_SetLocked( button, true )
			RefreshButtonCost( button, propertyRef, "", 0, 0 )
			Hud_SetNew( button, false )
		}
	}
#endif
}

void function UpdatePilotLoadoutPanelBinds( var loadoutPanel )
{
	if ( IsControllerModeActive() )
	{
		//SetLabelRuiText( Hud_GetChild( loadoutPanel, "PrimaryBind" ), "%weaponCycle%" )
		//SetLabelRuiText( Hud_GetChild( loadoutPanel, "SecondaryBind" ), "%weaponCycle%" )
		SetLabelRuiText( Hud_GetChild( loadoutPanel, "Weapon3Bind" ), Localize( "#WEAPON3_HOLD_HINT" ) )
	}
	else
	{
		//SetLabelRuiText( Hud_GetChild( loadoutPanel, "PrimaryBind" ), "%weaponSelectPrimary0%" )
		//SetLabelRuiText( Hud_GetChild( loadoutPanel, "SecondaryBind" ), "%weaponSelectPrimary1%" )
		SetLabelRuiText( Hud_GetChild( loadoutPanel, "Weapon3Bind" ), Localize( "#WEAPON3_PRESS_HINT" ) )
	}

	//SetLabelRuiText( Hud_GetChild( loadoutPanel, "TacticalBind" ), Localize( "%offhand1%" ) )
	//SetLabelRuiText( Hud_GetChild( loadoutPanel, "OrdnanceBind" ), Localize( "%offhand0%" ) )
}

asset function GetItemImageFromWeaponRefAndPersistenceValue(string weaponRef, int persistenceValue, string loadoutProperty)
{
	string skinRef = GetSkinRefFromWeaponRefAndPersistenceValue( weaponRef, persistenceValue )
	if (!IsRefValid(skinRef))
	{
		if (uiGlobal.editingLoadoutIndex != -1)
		{
			printt( "Resetting invalid " + loadoutProperty + " for weapon " + weaponRef )
			SetCachedLoadoutValue(GetUIPlayer(), "pilot", uiGlobal.editingLoadoutIndex, loadoutProperty, "0")
		}
		return $"rui/menu/common/appearance_button_swatch"
	}

	return GetItemImage( skinRef )
}
