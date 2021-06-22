global function InitTeamTitanSelectMenu
global function TeamTitanSelectMenuIsOpen
global function ServerCallback_OpenTeamTitanMenu
global function ServerCallback_CloseTeamTitanMenu
global function ServerCallback_UpdateTeamTitanMenuTime
global function ServerCallback_RegisterTeamTitanMenuButtons
global function TTSUpdateDoubleXP
global function TTSUpdateDoubleXPStatus
global function TTSMenuModeFD
global function TTSMenuModeDefault
global function TTSMenu_UpdateGameMode
global function EnableDoubleXP

const float SELECT_DELAY = 0.2

enum eTTSMenuMode
{
	DEFAULT,
	FD
}

struct
{
	var menu
	bool allowManualClose = false
	bool isReady = false
	bool menuOpened = false
	bool allowSelection = false

	array<var> titanButtons
	array<var> titanUpgradeButtons
	var editButton
	var readyPanel
	var cover
	var doubleXPButton
	var chatBox

	bool buttonsRegistered = false

	int menuMode

	float nextAllowSoundTime = 0.0
} file

void function InitTeamTitanSelectMenu()
{
	file.menu = GetMenu( "TeamTitanSelectMenu" )

	AddMenuEventHandler( file.menu, eUIEvent.MENU_NAVIGATE_BACK, OnTeamTitanSelectMenu_NavigateBack )
	AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, OnTeamTitanSelectMenu_Open )
	AddMenuEventHandler( file.menu, eUIEvent.MENU_SHOW, OnTeamTitanSelectMenu_Open )
	AddMenuEventHandler( file.menu, eUIEvent.MENU_HIDE, OnTeamTitanSelectMenu_Hide )
	AddMenuEventHandler( file.menu, eUIEvent.MENU_CLOSE, OnTeamTitanSelectMenu_Close )

	RegisterSignal( "TTSMenuClosed" )
	RegisterSignal( "Delayed_RequestTitanLoadout" )

	float margin = 10.0
	float totalWidth = 0.0
	for ( int i=0; i<NUM_PERSISTENT_TITAN_LOADOUTS; i++ )
	{
		var button = Hud_GetChild( file.menu, "TitanButton" + i )
		file.titanButtons.append( button )
		float xPos = totalWidth * -1
		totalWidth += Hud_GetWidth( button ) + margin
		Hud_SetPos( button, xPos, Hud_GetY( button ) )
	}

	var bg = Hud_GetChild( file.menu, "BG" )
	totalWidth -= margin
	float bgWidth = float( Hud_GetWidth( bg ) )
	float startPos = (bgWidth*0.5 - totalWidth*0.5) * -1
	for ( int i=0; i<NUM_PERSISTENT_TITAN_LOADOUTS; i++ )
	{
		var button = file.titanButtons[i]
		Hud_SetPos( button, startPos + Hud_GetX( button ), Hud_GetY( button ) )

		Hud_AddEventHandler( button, UIE_CLICK, TitanButton_OnClick )
		Hud_AddEventHandler( button, UIE_GET_FOCUS, TitanButton_OnFocused )
	}

	for ( int i=0; i<7; i++ )
	{
		var button = Hud_GetChild( file.menu, "BtnSub" + i )

		Hud_AddEventHandler( button, UIE_LOSE_FOCUS, TitanUpgradeButton_OnLoseFocus )
		Hud_AddEventHandler( button, UIE_GET_FOCUS, TitanUpgradeButton_OnFocused )
	}

	SetNavLeftRight( file.titanButtons, true )

	//file.editButton = Hud_GetChild( file.menu, "EditTitanButton" )
	//Hud_AddEventHandler( file.editButton, UIE_CLICK, EditTitanButton_OnClick )
	file.readyPanel = Hud_GetChild( file.menu, "ReadyRui" )
	file.cover = Hud_GetChild( file.menu, "Cover" )

	#if PC_PROG
	file.chatBox = Hud_GetChild( file.menu, "LobbyChatBox" )
	#endif // PC_PROG

	file.doubleXPButton = Hud_GetChild( file.menu, "DoubleXP" )

	AddMenuFooterOption( file.menu, BUTTON_A, "#A_BUTTON_SELECT", "", null, TeamTitanSelect_IsNotReady )
	AddMenuFooterOption( file.menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
	AddMenuFooterOption( file.menu, BUTTON_X, "#MENU_X_BUTTON_EDIT_TITAN", "#MENU_EDIT_TITAN", EditTitanButton_OnClick, TeamTitanSelect_IsReady )
	AddMenuFooterOption( file.menu, BUTTON_Y, "#MENU_Y_BUTTON_EDIT_PILOT", "#MENU_EDIT_PILOT", EditPilotButton_OnClick, CoverIsOff )
}

void function TTSUpdateDoubleXP( int count, bool avialable, float status )
{
	var rui = Hud_GetRui( file.doubleXPButton )
	RuiSetInt( rui, "doubleXPCount", count )
	RuiSetBool( rui, "doubleXPAvailable", avialable )
	RuiSetFloat( rui, "doubleXPStatus", status )
}

void function TTSUpdateDoubleXPStatus( int status )
{
	var rui = Hud_GetRui( file.doubleXPButton )
	RuiSetFloat( rui, "doubleXPStatus", float( status ) )
}

void function ServerCallback_UpdateTeamTitanMenuTime( float endTime )
{
	Signal( uiGlobal.signalDummy, "TTSMenuClosed" )

	file.allowSelection = true

	if ( file.nextAllowSoundTime < Time() )
	{
		EmitUISound( "ui_ctf_1p_playerscore" )
		file.nextAllowSoundTime = Time() + 5.0
	}

	Hud_SetEnabled( file.cover, false )
	Hud_Hide( file.cover )
	Hud_SetAlpha( file.cover, 0 )

	if ( endTime > 5 )
		file.allowSelection = true

	thread UpdateSubText( Time() + endTime )
}

void function ServerCallback_OpenTeamTitanMenu( float endTime )
{
	if ( TeamTitanSelectMenuIsOpen() )
		return

	if ( uiGlobal.activeMenu != null )
		CloseAllMenus()

	RunClientScript( "PlayTTSMusic" )

	file.allowManualClose = false
	file.allowSelection = true
	file.isReady = true // set to true so selection mode kicks in
	thread MenuFadeIn()
	BeginSelectionMode()
	AdvanceMenu( file.menu )
	thread UpdateSubText( Time() + endTime )
}

void function MenuFadeIn()
{
	Hud_SetEnabled( file.cover, true )
	Hud_SetAlpha( file.cover, 255 )
	Hud_Show( file.cover )
	wait 1.0
	Hud_FadeOverTime( file.cover, 0, 1.0 )
	wait 1.0
	Hud_Hide( file.cover )
	Hud_SetEnabled( file.cover, false )
}

void function UpdateSubText( float endTime )
{
	EndSignal( uiGlobal.signalDummy, "TTSMenuClosed" )

	var subText = Hud_GetChild( file.menu, "MenuSubTitle" )
	var rui = Hud_GetRui( file.readyPanel )
	RuiSetBool( rui, "isReady", true )

	thread Countdown( endTime )
	while ( Time() < endTime )
	{
		int countdownTime = int( ceil( endTime - Time() ) )
		Hud_SetText( subText, Localize( "#MENU_STARTS_IN", countdownTime ) )
		RuiSetInt( rui, "timer", countdownTime )
		WaitFrame()
	}

	Hud_SetText( subText, Localize( "#MENU_STARTS_IN", 0 ) )
	RuiSetInt( rui, "timer", 0 )
}

void function Countdown( float endTime )
{
	EndSignal( uiGlobal.signalDummy, "TTSMenuClosed" )

	float countdownTime = 5.0
	float startCountdownTime = endTime - countdownTime

	if ( Time() > startCountdownTime )
		return

	wait startCountdownTime - Time()

	while ( Time() < endTime )
	{
		EmitUISound( "UI_InGame_MarkedForDeath_CountdownToMarked" )
		wait 1.0
	}

	file.allowSelection = false
	BeginEditMode(null)

	Hud_SetAlpha( file.cover, 0 )
	Hud_SetEnabled( file.cover, true )
	Hud_Show( file.cover )
	Hud_FadeOverTime( file.cover, 255, 1.0 )

	float soundTime = DoPrematchWarpSound() ? PICK_LOADOUT_SOUND_TIME : 1.5
	wait soundTime

	thread ServerCallback_CloseTeamTitanMenu()
}

void function ServerCallback_CloseTeamTitanMenu()
{
	if ( TeamTitanSelectMenuIsOpen() )
	{
		file.allowManualClose = true
		UI_SetPresentationType( ePresentationType.INACTIVE )
		CloseAllMenus()
		OnTeamTitanSelectMenu_Close()
	}
}

void function OnTeamTitanSelectMenu_NavigateBack()
{
	if ( file.allowManualClose )
	{
		CloseActiveMenu()
		return
	}

	if ( file.isReady && file.allowSelection )
	{
		BeginSelectionMode()
		return
	}

	LeaveDialog()
	return
}

void function TTSMenu_UpdateGameMode( string modeName )
{
	var title = Hud_GetChild( file.menu, "MenuTitle" )
	Hud_SetText( title, Localize( modeName ) )
}

void function ServerCallback_RegisterTeamTitanMenuButtons()
{
	RegisterButtonCallbacks()
}

void function RegisterButtonCallbacks()
{
	if ( file.buttonsRegistered )
		return

	file.buttonsRegistered = true
	RegisterButtonPressedCallback( BUTTON_BACK, EnableDoubleXP )
	RegisterButtonPressedCallback( KEY_RSHIFT, EnableDoubleXP )
}

void function OnTeamTitanSelectMenu_Open()
{
	file.menuOpened = true

	var dataTable = GetDataTable( $"datatable/titan_properties.rpak" )
	int loadoutIconCol = GetDataTableColumnByName( dataTable, "loadoutIconFD" )
	int titanCol = GetDataTableColumnByName( dataTable, "titanRef" )

	entity player = GetUIPlayer()

	var nextMapImage = Hud_GetChild( file.menu, "NextMapImage" )
	string mapName = GetActiveLevel()
	asset mapImage = GetMapImageForMapName( mapName )

	RefreshCreditsAvailable()

	RuiSetImage( Hud_GetRui( nextMapImage ), "basicImage", mapImage )
	Hud_Show( nextMapImage )
	Hud_SetText( Hud_GetChild( file.menu, "NextMapName" ), GetMapDisplayName( mapName ) )
	Hud_Show( Hud_GetChild( file.menu, "NextMapName" ) )

	var buttonToFocus

	for ( int i=0; i<NUM_PERSISTENT_TITAN_LOADOUTS; i++ )
	{
		var button = file.titanButtons[i]
		TitanLoadoutDef loadout = GetCachedTitanLoadout( i )
		int row = GetDataTableRowMatchingStringValue( dataTable, titanCol,  loadout.titanClass )

		asset icon = GetDataTableAsset( dataTable, row, loadoutIconCol )
		var rui = Hud_GetRui( button )

		RuiSetImage( rui, "buttonImage", icon )

		if ( !IsTitanLoadoutAvailable( player, loadout.titanClass ) )
		{
			Hud_SetLocked( button, true )
			if ( !IsItemLocked( player, loadout.titanClass ) )
				RefreshButtonCost( button, loadout.titanClass, "", 0, 0 )
		}
		else
		{
			Hud_SetLocked( button, IsItemLocked( player, loadout.titanClass ) )
			RefreshButtonCost( button, loadout.titanClass )

			if ( uiGlobal.titanSpawnLoadoutIndex == i )
			{
				buttonToFocus = button
			}
		}
	}

	if ( buttonToFocus == null )
		buttonToFocus = FindValidTitanButton()
	thread HACK_DelayedSetFocus_BecauseWhy( buttonToFocus )

	TitanLoadoutDef loadout = GetCachedTitanLoadout( uiGlobal.titanSpawnLoadoutIndex )

	for ( int i=0; i<7; i++ )
	{
		var button = Hud_GetChild( file.menu, "BtnSub"+i )
		file.titanUpgradeButtons.append( button )

		if ( file.menuMode == eTTSMenuMode.FD )
		{
			Hud_Show( button )
		}
		else
		{
			Hud_Hide( button )
		}
	}
	SetNavLeftRight( file.titanUpgradeButtons, true )

	SetBlurEnabled( false )
	var title = Hud_GetChild( file.menu, "MenuTitle" )
	string name = expect string( GetCurrentPlaylistVar( "name" ) )
	Hud_SetText( title, Localize( name ) )
	RunMenuClientFunction( "ShowTTSPanel" )

	if ( file.isReady )
		UI_SetPresentationType( ePresentationType.TITAN_CENTER_SELECTED )
	else
		UI_SetPresentationType( ePresentationType.TITAN_CENTER )


	RunClientScript( "TTS_UpdateLocalPlayerTitan", loadout.setFile, loadout.primary, loadout.passive1, loadout.passive2 )
}

void function EnableDoubleXP( var button )
{
	#if PC_PROG
	if ( Hud_IsFocused( file.chatBox ) )
		return
	#endif // PC_PROG

	if ( CanRunClientScript() )
	{
		EmitUISound( "Menu_Email_Sent" )
		RunClientScript( "UseDoubleXP" )
	}
}

void function OnTeamTitanSelectMenu_Hide()
{
	RunMenuClientFunction( "HideTTSPanel" )

	DeregisterButtonCallbacks()
}

void function DeregisterButtonCallbacks()
{
	if ( !file.buttonsRegistered )
		return

	file.buttonsRegistered = false

	DeregisterButtonPressedCallback( BUTTON_BACK, EnableDoubleXP )
	DeregisterButtonPressedCallback( KEY_RSHIFT, EnableDoubleXP )
}

void function OnTeamTitanSelectMenu_Close()
{
	RunMenuClientFunction( "ClearAllPilotPreview" )
	Signal( uiGlobal.signalDummy, "TTSMenuClosed" )
	file.menuOpened = false
	UI_SetPresentationType( ePresentationType.INACTIVE )

	DeregisterButtonCallbacks()
}

void function TitanButton_OnClick( var button )
{
	int scriptID = int( Hud_GetScriptID( button ) )
	if ( Hud_IsLocked( button ) )
	{
		TitanLoadoutDef loadout = GetCachedTitanLoadout( scriptID )
		if ( !IsTitanLoadoutAvailable( GetUIPlayer(), loadout.titanClass ) )
			return

		OpenBuyItemDialog( file.titanButtons, button, GetItemName( loadout.titanClass ), loadout.titanClass )
		return
	}

	if ( file.isReady )
	{
		BeginSelectionMode()
		return
	}

	uiGlobal.titanSpawnLoadoutIndex = scriptID
	Signal( uiGlobal.signalDummy, "Delayed_RequestTitanLoadout" )
	ClientCommand( "RequestTitanLoadout " + uiGlobal.titanSpawnLoadoutIndex )
	BeginEditMode( button )
}

void function TitanButton_OnFocused( var button )
{
	int scriptID = int( Hud_GetScriptID( button ) )

	var rui = Hud_GetRui( Hud_GetChild( file.menu, "TitanName" ) )

	TitanLoadoutDef loadout = GetCachedTitanLoadout( scriptID )

	RuiSetString( rui, "titanName", GetTitanLoadoutName( loadout ) )
	RuiSetString( rui, "titanLevelString", "" )
	RuiSetString( rui, "titanRole", "" )

	entity player = GetUIPlayer()

	var dataTable = GetDataTable( $"datatable/titan_properties.rpak" )
	int row = GetDataTableRowMatchingStringValue( dataTable, GetDataTableColumnByName( dataTable, "titanRef" ), loadout.titanClass )
	string role = GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, "fdRole" ) )
	int titanLevel = FD_TitanGetLevelForXP( loadout.titanClass, FD_TitanGetXP( GetUIPlayer(), loadout.titanClass ) )
	array<ItemDisplayData> titanUpgrades = FD_GetUpgradesForTitanClass( loadout.titanClass )

	if ( file.menuMode == eTTSMenuMode.FD )
	{
		RuiSetString( rui, "titanLevelString", Localize( "#FD_TITAN_LEVEL", titanLevel ) )
		RuiSetString( rui, "titanRole", Localize( "#FD_ROLE", Localize(role) ) )

		foreach ( index, item in titanUpgrades )
		{
			var button = file.titanUpgradeButtons[index]
			var upgradeRui = Hud_GetRui( button )

			bool locked = IsSubItemLocked( GetUIPlayer(), item.ref, item.parentRef )

			if ( locked )
				RuiSetImage( upgradeRui, "buttonImage", expect asset( item.i.lockedImage ) )
			else
				RuiSetImage( upgradeRui, "buttonImage", item.image )

			Hud_SetLocked( button, locked )
		}
	}

	if ( !Hud_IsLocked( button ) )
	{
		uiGlobal.titanSpawnLoadoutIndex = scriptID
		thread Delayed_RequestTitanLoadout( uiGlobal.titanSpawnLoadoutIndex )
		SetLabelRuiText( Hud_GetChild( file.menu, "TitanSelectTitle" ), "#MENU_TITAN_SELECT" )
	}
	else
	{
		RuiSetString( rui, "titanLevelString", GetItemUnlockReqText( loadout.titanClass ) )
	}

	SetLabelRuiText( Hud_GetChild( file.menu, "TitanSelectTitle" ), GetTitanAvailableText( player, loadout.titanClass) )

	RunMenuClientFunction( "UpdateTitanModel", scriptID )
	RunClientScript( "TTS_UpdateLocalPlayerTitan", loadout.setFile, loadout.primary, loadout.passive1, loadout.passive2 )
}

string function GetTitanAvailableText( entity player, string titanClass )
{
	int titanAvailableState = GetTitanLoadAvailableState( player, titanClass )

	if ( titanAvailableState == TITAN_CLASS_LOCK_STATE_AVAILABLE )
		return "#MENU_TITAN_SELECT_HINT"

	if ( titanAvailableState == TITAN_CLASS_LOCK_STATE_LEVELREQUIRED || titanAvailableState == TITAN_CLASS_LOCK_STATE_LEVELRECOMMENDED )
	{
		int difficultyLevel = GetCurrentPlaylistVarInt( "fd_difficulty", 0 )
		int requiredTitanLevel = 0
		switch ( difficultyLevel )
		{
			case eFDDifficultyLevel.EASY:
				if ( GetItemUnlockType( "fd_easy" ) == eUnlockType.STAT )
					requiredTitanLevel = int( GetStatUnlockStatVal( "fd_easy" ) )
				break
			case eFDDifficultyLevel.NORMAL:
				if ( GetItemUnlockType( "fd_normal" ) == eUnlockType.STAT )
					requiredTitanLevel = int( GetStatUnlockStatVal( "fd_normal" ) )
				break
			case eFDDifficultyLevel.HARD:
				if ( GetItemUnlockType( "fd_hard" ) == eUnlockType.STAT )
					requiredTitanLevel = int( GetStatUnlockStatVal( "fd_hard" ) )
				break
			case eFDDifficultyLevel.MASTER:
				if ( GetItemUnlockType( "fd_master" ) == eUnlockType.STAT )
					requiredTitanLevel = int( GetStatUnlockStatVal( "fd_master" ) )
				break
			case eFDDifficultyLevel.INSANE:
				if ( GetItemUnlockType( "fd_insane" ) == eUnlockType.STAT )
					requiredTitanLevel = int( GetStatUnlockStatVal( "fd_insane" ) )
				break
		}

		if ( titanAvailableState == TITAN_CLASS_LOCK_STATE_LEVELREQUIRED )
			return Localize( "#MENU_TITAN_SELECT_LEVELREQUIRED", requiredTitanLevel )
		else
			return Localize( "#MENU_TITAN_SELECT_LEVELRECOMMENDED", requiredTitanLevel )
	}

	if ( titanAvailableState == TITAN_CLASS_LOCK_STATE_INUSE )
		return "#MENU_TITAN_SELECT_INUSE"

	if ( titanAvailableState == TITAN_CLASS_LOCK_STATE_LOCKED )
		return "#MENU_TITAN_SELECT_LOCKED"

	return "#MENU_TITAN_SELECT_HINT"
}

void function Delayed_RequestTitanLoadout( int index )
{
	Signal( uiGlobal.signalDummy, "Delayed_RequestTitanLoadout" )
	EndSignal( uiGlobal.signalDummy, "Delayed_RequestTitanLoadout" )
	wait 0.5
	ClientCommand( "RequestTitanLoadout " + uiGlobal.titanSpawnLoadoutIndex )
}

void function TitanUpgradeButton_OnFocused( var button )
{
	if ( file.menuMode == eTTSMenuMode.DEFAULT )
		return

	int scriptID = int( Hud_GetScriptID( button ) )
	TitanLoadoutDef loadout = GetCachedTitanLoadout( uiGlobal.titanSpawnLoadoutIndex )
	array<ItemDisplayData> titanUpgrades = FD_GetUpgradesForTitanClass( loadout.titanClass )

	ItemDisplayData item = titanUpgrades[ scriptID ]
	var panel = Hud_GetChild( file.menu, "UpgradeName" )
	Hud_Show( panel )
	var rui = Hud_GetRui( panel )
	RuiSetString( rui, "upgradeName", item.name )
	RuiSetString( rui, "upgradeDesc", item.desc )
	RuiSetBool( rui, "isLocked", IsSubItemLocked( GetUIPlayer(), item.ref, item.parentRef ) )
}

void function TitanUpgradeButton_OnLoseFocus( var button )
{
	Hud_Hide( Hud_GetChild( file.menu, "UpgradeName" ) )
}

void function BeginEditMode( var button )
{
	if ( file.isReady )
		return

	file.isReady = true

	EmitUISound( "UI_InGame_FD_TitanSelected" )
	SetLabelRuiText( Hud_GetChild( file.menu, "TitanSelectTitle" ), "#MENU_TITAN_SELECTED" )
	Hud_Hide( Hud_GetChild( file.menu, "TitanSelectTitle" ) )
	Hud_Show( file.readyPanel )
	var rui = Hud_GetRui( file.readyPanel )
	RuiSetBool( rui, "isReady", true )

	foreach ( b in file.titanButtons )
	{
		Hud_Hide( b )
	}

	//Hud_Show( file.editButton )
	//Hud_SetFocused( file.editButton )
	Hud_SetFocused( file.titanUpgradeButtons[0] )

	TitanLoadoutDef loadout = GetCachedTitanLoadout( uiGlobal.titanSpawnLoadoutIndex )
	string primeTitanString = ""

	if ( loadout.isPrime == "titan_is_prime" )
		primeTitanString = "_prime"

	string modifiedAlias = "diag_gs_titan" + loadout.titanClass + primeTitanString + "_embark"
	EmitUISound( modifiedAlias )

	if ( uiGlobal.activeMenu == file.menu )
		UI_SetPresentationType( ePresentationType.TITAN_CENTER_SELECTED )

	Signal( uiGlobal.signalDummy, "Delayed_RequestTitanLoadout" )
	ClientCommand( "RequestTitanLoadout " + uiGlobal.titanSpawnLoadoutIndex )
	RunMenuClientFunction( "UpdateTitanModel", uiGlobal.titanSpawnLoadoutIndex )

	var subText = Hud_GetChild( file.menu, "MenuSubTitle" )
	// Hud_Hide( subText )
}

void function BeginSelectionMode()
{
	if ( !file.isReady )
		return

	file.isReady = false
	//Hud_Hide( file.editButton )

	SetLabelRuiText( Hud_GetChild( file.menu, "TitanSelectTitle" ), "#MENU_TITAN_SELECT_HINT" )
	Hud_Show( Hud_GetChild( file.menu, "TitanSelectTitle" ) )
	Hud_Hide( file.readyPanel )
	var rui = Hud_GetRui( file.readyPanel )
	RuiSetBool( rui, "isReady", false )

	Hud_SetFocused( FindValidTitanButton() )

	for ( int i=0; i<file.titanButtons.len(); i++ )
	{
		var b = file.titanButtons[i]
		Hud_Show( b )
		if ( i == uiGlobal.titanSpawnLoadoutIndex && !Hud_IsLocked( b ) )
		{
			Hud_SetFocused( b )
		}
	}

	Hud_Hide( Hud_GetChild( file.menu, "UpgradeName" ) )

	UI_SetPresentationType( ePresentationType.TITAN_CENTER )
	RunMenuClientFunction( "UpdateTitanModel", uiGlobal.titanSpawnLoadoutIndex )

	var subText = Hud_GetChild( file.menu, "MenuSubTitle" )
	// Hud_Show( subText )
}

void function EditPilotButton_OnClick( var button )
{
	// SetEditLoadout( "pilot", uiGlobal.pilotSpawnLoadoutIndex )
	// RunMenuClientFunction( "SetEditingPilotLoadoutIndex", uiGlobal.pilotSpawnLoadoutIndex )
	AdvanceMenu( GetMenu( "EditPilotLoadoutsMenu" ) )
	RunMenuClientFunction( "HideTTSPanel" )
}

void function EditTitanButton_OnClick( var button )
{
	SetEditLoadout( "titan", uiGlobal.titanSpawnLoadoutIndex )
	RunMenuClientFunction( "SetEditingTitanLoadoutIndex", uiGlobal.titanSpawnLoadoutIndex )
	AdvanceMenu( GetMenu( "EditTitanLoadoutMenu" ) )
	RunMenuClientFunction( "HideTTSPanel" )
}

bool function CoverIsOff()
{
	return !Hud_IsEnabled( file.cover )
}

bool function TeamTitanSelectMenuIsOpen()
{
	return file.menuOpened
}

bool function TeamTitanSelect_IsReady()
{
	return file.isReady
}

bool function TeamTitanSelect_IsNotReady()
{
	return !file.isReady
}

void function TTSMenuModeFD()
{
	file.menuMode = eTTSMenuMode.FD

	foreach ( button in file.titanUpgradeButtons )
	{
		Hud_Show( button )
	}
}

void function TTSMenuModeDefault()
{
	file.menuMode = eTTSMenuMode.DEFAULT

	foreach ( button in file.titanUpgradeButtons )
	{
		Hud_Hide( button )
	}

	var panel = Hud_GetChild( file.menu, "UpgradeName" )
	Hud_Hide( panel )
}

var function FindValidTitanButton()
{
	foreach ( button in file.titanButtons )
	{
		if ( Hud_IsLocked( button ) )
			continue

		return button
	}

	return file.titanButtons[0]
}