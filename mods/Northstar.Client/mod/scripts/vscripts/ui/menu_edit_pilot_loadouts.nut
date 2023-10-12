untyped

global function InitEditPilotLoadoutsMenu

struct
{
	var menu
	var loadoutPanel
	var[NUM_PERSISTENT_PILOT_LOADOUTS] loadoutHeaders
	var[NUM_PERSISTENT_PILOT_LOADOUTS] activateButtons
	bool enteringEdit = false
	var unlockReq
} file

void function InitEditPilotLoadoutsMenu()
{
	file.menu = GetMenu( "EditPilotLoadoutsMenu" )
	var menu = file.menu

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnPilotLoadoutsMenu_Open )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, OnPilotLoadoutsMenu_Close )
	AddMenuEventHandler( menu, eUIEvent.MENU_INPUT_MODE_CHANGED, OnPilotLoadoutsMenu_InputModeChanged )

	for ( int i = 0; i < NUM_PERSISTENT_PILOT_LOADOUTS; i++ )
	{
		var activateButton = Hud_GetChild( menu, "Button" + i )
		activateButton.s.rowIndex <- i
		Hud_SetVisible( activateButton, true )
		Hud_AddEventHandler( activateButton, UIE_CLICK, OnLoadoutButton_Activate )
		Hud_AddEventHandler( activateButton, UIE_GET_FOCUS, OnLoadoutButton_Focused )
		Hud_AddEventHandler( activateButton, UIE_LOSE_FOCUS, OnLoadoutButton_LostFocus )
		file.activateButtons[i] = activateButton
	}

	Hud_SetFocused( file.activateButtons[0] )

	file.loadoutPanel = Hud_GetChild( menu, "PilotLoadoutDisplay" )
	file.unlockReq = Hud_GetChild( menu, "UnlockReq" )

	AddMenuFooterOption( menu, BUTTON_A, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
}

void function OnPilotLoadoutsMenu_Open()
{
	entity player = GetUIPlayer()
	if ( player == null )
		return

	RunMenuClientFunction( "ClearEditingPilotLoadoutIndex" )

	int loadoutIndex = uiGlobal.pilotSpawnLoadoutIndex
	UpdatePilotLoadoutButtons( loadoutIndex, file.activateButtons )
	UpdatePilotLoadoutPanel( file.loadoutPanel, GetCachedPilotLoadout( loadoutIndex ) )
	UI_SetPresentationType( ePresentationType.PILOT )

	RefreshCreditsAvailable()
}

void function OnPilotLoadoutsMenu_Close()
{
	entity player = GetUIPlayer()
	if ( player == null )
		return

	foreach ( i, button in file.activateButtons )
	{
		string pilotLoadoutRef = "pilot_loadout_" + ( i + 1 )
		if ( !IsItemNew( player, pilotLoadoutRef ) )
			continue

		ClearNewStatus( button, pilotLoadoutRef )
	}
}

void function OnPilotLoadoutsMenu_InputModeChanged()
{
	UpdatePilotLoadoutPanelBinds( file.loadoutPanel )
}

void function OnLoadoutButton_Focused( var button )
{
	int index = expect int( button.s.rowIndex )

	// update the editingLoadoutIndex on focus so that it always matches
	// with the pilot loadout panel
	uiGlobal.editingLoadoutIndex = index
	uiGlobal.editingLoadoutType = "pilot"

	UpdatePilotLoadout( index )

	string pilotLoadoutRef = "pilot_loadout_" + ( index + 1 )
	string unlockReq = GetItemUnlockReqText( pilotLoadoutRef )
	RHud_SetText( file.unlockReq, unlockReq )
}

void function UpdatePilotLoadout( int loadoutIndex )
{
	PilotLoadoutDef loadout = GetCachedPilotLoadout( loadoutIndex )

	UpdatePilotLoadoutPanel( file.loadoutPanel, loadout )
	RunMenuClientFunction( "UpdatePilotModel", loadoutIndex )
}

void function OnLoadoutButton_Activate( var button )
{
	if ( !IsFullyConnected() )
		return

	if ( Hud_IsLocked( button ) )
	{
		int index = expect int ( button.s.rowIndex )
		string pilotLoadoutRef = "pilot_loadout_" + ( index + 1 )

		array<var> buttons
		foreach ( button in file.activateButtons )
		{
			buttons.append( button )
		}

		OpenBuyItemDialog( buttons, button, GetItemName( pilotLoadoutRef ), pilotLoadoutRef )
		return
	}

	int loadoutIndex = expect int ( button.s.rowIndex )
	SetEditLoadout( "pilot", loadoutIndex )

	if ( EDIT_LOADOUT_SELECTS )
	{
		bool indexChanged = loadoutIndex != uiGlobal.pilotSpawnLoadoutIndex

		if ( indexChanged )
		{
			EmitUISound( "Menu_LoadOut_Pilot_Select" )

			if ( !IsLobby() )
				uiGlobal.updatePilotSpawnLoadout = true
		}

		uiGlobal.pilotSpawnLoadoutIndex = loadoutIndex
		ClientCommand( "RequestPilotLoadout " + loadoutIndex )
	}

	if ( PRE_RELEASE_DEMO && loadoutIndex < 3 )
	{
		UpdatePilotLoadoutButtons( loadoutIndex, file.activateButtons )
		return
	}

	RunMenuClientFunction( "SetEditingPilotLoadoutIndex", loadoutIndex )
	AdvanceMenu( GetMenu( "EditPilotLoadoutMenu" ) )
}

void function OnLoadoutButton_LostFocus( var button )
{
	entity player = GetUIPlayer()
	if ( !IsValid( player ) )
		return

	int loadoutIndex = expect int ( button.s.rowIndex )
	string pilotLoadoutRef = "pilot_loadout_" + ( loadoutIndex + 1 )
	ClearNewStatus( button, pilotLoadoutRef )

	if ( IsItemLocked( player, pilotLoadoutRef ) )
		return

	PilotLoadoutDef loadout = GetCachedPilotLoadout( loadoutIndex )
	if ( (RefHasAnyNewSubitem( player, loadout.primary ) || RefHasAnyNewSubitem( player, loadout.secondary ) || RefHasAnyNewSubitem( player, loadout.weapon3 )) )
		Hud_SetNew( button, true )
}
