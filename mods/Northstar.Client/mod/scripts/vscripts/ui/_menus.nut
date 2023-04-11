untyped

global const bool EDIT_LOADOUT_SELECTS = true
global const string PURCHASE_SUCCESS_SOUND = "UI_Menu_Store_Purchase_Success"

global function UICodeCallback_CloseAllMenus
global function UICodeCallback_ActivateMenus
global function UICodeCallback_LevelInit
global function UICodeCallback_LevelLoadingStarted
global function UICodeCallback_LevelLoadingFinished
global function UICodeCallback_LevelShutdown
global function UICodeCallback_OnConnected
global function UICodeCallback_OnFocusChanged
global function UICodeCallback_NavigateBack
global function UICodeCallback_ToggleInGameMenu
global function UICodeCallback_TryCloseDialog
global function UICodeCallback_UpdateLoadingLevelName
global function UICodeCallback_ConsoleKeyboardClosed
global function UICodeCallback_ErrorDialog
global function UICodeCallback_AcceptInvite
global function UICodeCallback_OnDetenteDisplayed
global function UICodeCallback_OnSpLogDisplayed
global function UICodeCallback_EntitlementsChanged
global function UICodeCallback_StoreTransactionCompleted
global function UICodeCallback_GamePurchased
global function UICodeCallback_PartyUpdated
global function UICodeCallback_KeyBindOverwritten

global function AdvanceMenu
global function OpenSubmenu // REMOVE
global function CloseSubmenu // REMOVE
global function CloseActiveMenu
global function CloseActiveMenuNoParms
global function CloseAllMenus
global function CloseAllInGameMenus
global function CloseAllDialogs
global function CloseAllToTargetMenu
global function PrintMenuStack
global function CleanupInGameMenus
global function GetActiveMenu
global function GetMenu
global function GetPanel
global function GetAllMenuPanels
global function InitGamepadConfigs
global function InitMenus
global function AdvanceMenuEventHandler
global function PCSwitchTeamsButton_Activate
global function PCToggleSpectateButton_Activate
global function AddMenuElementsByClassname
global function FocusDefault
global function SetPanelDefaultFocus
global function PanelFocusDefault
global function OpenMenuWrapper
global function CloseMenuWrapper
global function IsLevelMultiplayer
global function AddMenuEventHandler
global function AddPanelEventHandler
global function AddButtonEventHandler
global function AddEventHandlerToButton
global function AddEventHandlerToButtonClass
global function DisableMusic
global function EnableMusic
global function PlayMusic
global function StopMusic
global function IsMenuInMenuStack
global function GetTopNonDialogMenu
global function IsDialog
global function IsDialogActive
global function IsDialogOnlyActiveMenu
global function SetNavUpDown
global function SetNavLeftRight
global function IsTrialPeriodActive
global function LaunchGamePurchaseOrDLCStore
global function SetMenuThinkFunc

global function PCBackButton_Activate

global function RegisterMenuVarInt
global function GetMenuVarInt
global function SetMenuVarInt
global function RegisterMenuVarBool
global function GetMenuVarBool
global function SetMenuVarBool
global function RegisterMenuVarVar
global function GetMenuVarVar
global function SetMenuVarVar
global function AddMenuVarChangeHandler

global function InviteFriends

global function HACK_DelayedSetFocus_BecauseWhy

#if DURANGO_PROG
	global function OpenXboxPartyApp
	global function OpenXboxHelp
#endif // DURANGO_PROG

global function OpenReviewTermsDialog
global function ClassicMusic_OnChange
global function IsClassicMusicAvailable


void function UICodeCallback_CloseAllMenus()
{
	printt( "UICodeCallback_CloseAllMenus" )
	CloseAllMenus()
	// This is usually followed by a call to UICodeCallback_ActivateMenus().
}

// Bringing up the console will cause this, and it probably shouldn't
void function UICodeCallback_ActivateMenus()
{
	if ( IsConnected() )
		return

	printt( "UICodeCallback_ActivateMenus:", uiGlobal.activeMenu && Hud_GetHudName( uiGlobal.activeMenu ) )

	if ( uiGlobal.menuStack.len() == 0 )
	{
		AdvanceMenu( GetMenu( "MainMenu" ) )
	}

	if ( uiGlobal.activeMenu == GetMenu( "MainMenu" ) )
		Signal( uiGlobal.signalDummy, "OpenErrorDialog" )

	PlayMusic()

	#if DURANGO_PROG
		Durango_LeaveParty()
	#endif // DURANGO_PROG
}

void function UICodeCallback_ToggleInGameMenu()
{
	if ( !IsFullyConnected() )
		return

	var activeMenu = uiGlobal.activeMenu
	bool isMP = IsLevelMultiplayer( GetActiveLevel() )
	bool isLobby = IsLobby()

	var ingameMenu
	if ( isMP )
	{
		ingameMenu = GetMenu( "InGameMPMenu" )
	}
	else
	{
		// Disable this callback for this special case menu so players can't skip it.
		var spTitanTutorialMenu = GetMenu( "SPTitanLoadoutTutorialMenu" )
		if ( activeMenu == spTitanTutorialMenu )
			return

		ingameMenu = GetMenu( "InGameSPMenu" )
	}

	if ( IsDialog( uiGlobal.activeMenu ) )
	{
		// Do nothing if a dialog is showing
	}
	else if ( TeamTitanSelectMenuIsOpen() )
	{
		if ( uiGlobal.activeMenu == GetMenu( "TeamTitanSelectMenu" ) )
		{
			// Do nothing here either
		}
		else
		{
			CloseActiveMenu()
		}
	}
	else if ( ( isMP && !isLobby ) || !isMP )
	{
		if ( !activeMenu )
			AdvanceMenu( ingameMenu )
		else
			CloseAllInGameMenus()
	}
}

// Return true to show load screen, false to not show load screen.
// levelname can be "" because the level to load isn't always known when the load screen starts
bool function UICodeCallback_LevelLoadingStarted( string levelname )
{
	printt( "UICodeCallback_LevelLoadingStarted: " + levelname )

	CloseAllDialogs()

	uiGlobal.loadingLevel = levelname
	uiGlobal.isLoading = true

	StopMusic()

	if ( uiGlobal.playingVideo )
		Signal( uiGlobal.signalDummy, "PlayVideoEnded" )

	if ( uiGlobal.playingCredits )
		Signal( uiGlobal.signalDummy, "PlayingCreditsDone" )

	// kill lingering postgame summary since persistent data may not be available at this point
	Signal( uiGlobal.signalDummy, "PGDisplay" )

#if CONSOLE_PROG
	if ( !Console_IsSignedIn() )
		return false
#endif

	return true
}

// Return true to show load screen, false to not show load screen.
bool function UICodeCallback_UpdateLoadingLevelName( string levelname )
{
	printt( "UICodeCallback_UpdateLoadingLevelName: " + levelname )

#if CONSOLE_PROG
	if ( !Console_IsSignedIn() )
		return false
#endif

	return true
}

void function UICodeCallback_LevelLoadingFinished( bool error )
{
	printt( "UICodeCallback_LevelLoadingFinished: " + uiGlobal.loadingLevel + " (" + error + ")" )

	if ( !IsLobby() )
	{
		HudChat_ClearTextFromAllChatPanels()
		ResetActiveChatroomLastModified()
	}
	else
	{
		uiGlobal.lobbyFromLoadingScreen = true
	}

	uiGlobal.loadingLevel = ""
	uiGlobal.isLoading = false
	Signal( uiGlobal.signalDummy, "LevelFinishedLoading" )
}

void function UICodeCallback_LevelInit( string levelname )
{
	Assert( IsConnected() )

	StopVideo()

	uiGlobal.loadedLevel = levelname

	printt( "UICodeCallback_LevelInit: " + uiGlobal.loadedLevel )

	if ( !uiGlobal.loadoutsInitialized )
	{
		string gameModeString = GetConVarString( "mp_gamemode" )
		if ( gameModeString != "solo" )
		{
			InitStatsTables()
		}
	}

	InitItems()

	if ( IsMultiplayer() )
	{
		ShWeaponXP_Init()
		ShTitanXP_Init()
		ShFactionXP_Init()
	}
	else
	{
		SPObjectiveStringsInit()
	}

	#if DEV
	UpdatePrecachedSPWeapons()
	#endif


	if ( !uiGlobal.loadoutsInitialized )
	{
		string gameModeString = GetConVarString( "mp_gamemode" )
		if ( gameModeString != "solo" )
		{
			DeathHints_Init()
			InitDefaultLoadouts()
			CreateChallenges()
			uiGlobal.loadoutsInitialized = true
		}
	}

	if ( IsLevelMultiplayer( levelname ) || IsLobbyMapName( levelname ) )
	{
		thread UpdateCachedLoadouts()
		thread UpdateCachedNewItems()
		thread InitUISpawnLoadoutIndexes()

		if ( !uiGlobal.eventHandlersAdded )
		{
			uiGlobal.eventHandlersAdded = true
		}

		UI_GetAllChallengesProgress()

		bool isLobby = IsLobbyMapName( levelname )

		string gameModeString = GetConVarString( "mp_gamemode" )
		if ( gameModeString == "" )
			gameModeString = "<null>"

		Assert( gameModeString == GetConVarString( "mp_gamemode" ) )
		Assert( gameModeString != "" )

	    int gameModeId = GameMode_GetGameModeId( gameModeString )

	    int mapId = eMaps.invalid
	    if ( levelname in getconsttable().eMaps )
	    {
	    	mapId = expect int( getconsttable().eMaps[ levelname ] )
	    }
	    else
	    {
	    	// Don't worry about this until we have to consider R2 Durango TCRs (10/2015)
	    	//if ( !IsTestMap() )
		    //	CodeWarning( "No map named '" + levelname + "' exists in eMaps, all shipping maps should be in this enum" )
	    }

	    int difficultyLevelId = 0
	    int roundId = 0

	    if ( isLobby )
	    	Durango_OnLobbySessionStart( gameModeId, difficultyLevelId )
	    else
	    	Durango_OnMultiplayerRoundStart( gameModeId, mapId, difficultyLevelId, roundId, 0 )
	}
	else
	{
		// SP loadout stuff
		UI_GetAllChallengesProgress() // TODO: Can this be moved so we don't call it twice? It's called above.

		SP_ResetObjectiveStringIndex() // Since this persists thru level load, we need to explicitely clear it.
	}

	if ( IsMultiplayer() )
	{
		foreach ( callbackFunc in uiGlobal.onLevelInitCallbacks )
		{
			thread callbackFunc()
		}

	}
	thread UpdateMenusOnConnect( levelname )

	uiGlobal.previousLevel = uiGlobal.loadedLevel
	uiGlobal.previousPlaylist = GetCurrentPlaylistName()
}

void function UICodeCallback_LevelShutdown()
{
	Signal( uiGlobal.signalDummy, "LevelShutdown" )

	printt( "UICodeCallback_LevelShutdown: " + uiGlobal.loadedLevel )

	StopVideo()

	if ( uiGlobal.loadedLevel != "" )
		CleanupInGameMenus()

	uiGlobal.loadedLevel = ""
	uiGlobal.mapSupportsMenuModelsUpdated = false
	uiGlobal.sp_showAlternateMissionLog = false
}

void function UICodeCallback_NavigateBack()
{
	if ( uiGlobal.activeMenu == null )
		return

	if ( IsDialog( uiGlobal.activeMenu ) )
	{
		if ( uiGlobal.menuData[ uiGlobal.activeMenu ].dialogData.noChoice ||
			 uiGlobal.menuData[ uiGlobal.activeMenu ].dialogData.forceChoice ||
			 Time() < uiGlobal.dialogInputEnableTime )
			return
	}

	Assert( uiGlobal.activeMenu in uiGlobal.menuData )
	if ( uiGlobal.menuData[ uiGlobal.activeMenu ].navBackFunc != null )
	{
		thread uiGlobal.menuData[ uiGlobal.activeMenu ].navBackFunc()
		return
	}

	if ( uiGlobal.activeMenu.GetType() == "submenu" ) // REMOVE
	{
		CloseSubmenu()
		return
	}

	CloseActiveMenu( true )
}

// Called when IsConnected() will start returning true.
void function UICodeCallback_OnConnected()
{

}

void function UICodeCallback_OnFocusChanged( var oldFocusedPanel, var newFocusedPanel )
{

}

// Accepting an origin invite closes dialogs, or aborts if they can't be closed
bool function UICodeCallback_TryCloseDialog()
{
	if ( !IsDialog( uiGlobal.activeMenu ) )
		return true

	if ( uiGlobal.menuData[ uiGlobal.activeMenu ].dialogData.forceChoice )
		return false

	CloseAllDialogs()
	Assert( !IsDialog( uiGlobal.activeMenu ) )
	return true
}

void function UICodeCallback_ConsoleKeyboardClosed()
{
	switch ( uiGlobal.activeMenu )
	{
		case GetMenu( "EditPilotLoadoutMenu" ):
			string oldName = GetPilotLoadoutName( GetCachedPilotLoadout( uiGlobal.editingLoadoutIndex ) )
			string newName = GetPilotLoadoutRenameText()

			// strip doesn't work on UTF-8 strings
			// newName = strip( newName ) // Remove leading/trailing whitespace
			if ( newName == "" ) // If all whitespace entered reset to previous name
				newName = oldName

			SetPilotLoadoutName( newName )
			SelectPilotLoadoutRenameText()
			if ( newName != oldName )
				EmitUISound( "Menu.Accept" ) // No callback when cancelled so for now assume name was changed
			break

		default:
			break
	}
}

void function UICodeCallback_OnDetenteDisplayed()
{
//	thread PlayDetentSound()
//}
//
//void function PlayDetentSound()
//{
//	WaitFrame() // otherwise gets killed off by code pause
//	WaitFrame() // otherwise gets killed off by code pause
//	EmitUISound( "Pilot_Killed_Indicator" )
}

void function UICodeCallback_OnSpLogDisplayed()
{
}

void function UICodeCallback_ErrorDialog( string errorDetails )
{
	printt( "UICodeCallback_ErrorDialog: " +  errorDetails )
	thread OpenErrorDialog( errorDetails )
}

void function UICodeCallback_AcceptInviteThread( string accesstoken )
{
	printt( "UICodeCallback_AcceptInviteThread '" + accesstoken + "'")

	#if PS4_PROG
		if ( !Ps4_PSN_Is_Loggedin() )
		{
			Ps4_LoginDialog_Schedule();
			while( Ps4_LoginDialog_Running() )
				WaitFrame()
			if ( !Ps4_PSN_Is_Loggedin() )
				return;
		}

		if( Ps4_CheckPlus_Schedule() )
		{
			while( Ps4_CheckPlus_Running() )
				WaitFrame()
			if( !Ps4_CheckPlus_Allowed() )
			{
				if( Ps4_CheckPlus_GetLastRequestResults() != 0 )
				{
					return
				}

				if( Ps4_ScreenPlusDialog_Schedule() )
				{
					while( Ps4_ScreenPlusDialog_Running() )
						WaitFrame()
					if( !Ps4_ScreenPlusDialog_Allowed() )
						return;
				}
				else
				{
  					return;
				}
			}
		}

	#endif // #if PS4_PROG

    SubscribeToChatroomPartyChannel( accesstoken );

}


void function UICodeCallback_AcceptInvite( string accesstoken )
{
	printt( "UICodeCallback_AcceptInvite '" + accesstoken + "'")
	thread 	UICodeCallback_AcceptInviteThread( accesstoken )
}

// TODO: replaceCurrent should not be an option. It should be a different function.
void function AdvanceMenu( var menu, bool replaceCurrent = false )
{
	//foreach ( index, menu in uiGlobal.menuStack )
	//{
	//	if ( menu != null )
	//		printt( "menu index " + index + " is named " + menu.GetDisplayName() )
	//}

	if ( uiGlobal.activeMenu )
	{
		// Don't open the same menu again if it's already open
		if ( uiGlobal.activeMenu == menu )
			return

		// Opening a normal menu while a dialog is open
		Assert( !IsDialog( uiGlobal.activeMenu ), "Tried opening menu: " + Hud_GetHudName( menu ) + " when uiGlobal.activeMenu was: " + Hud_GetHudName( uiGlobal.activeMenu ) )
	}

	if ( uiGlobal.activeMenu && !IsDialog( menu ) ) // Dialogs show on top so don't close existing menu when opening them
	{
		SetBlurEnabled( false )

		if ( replaceCurrent )
		{
			CloseMenuWrapper( uiGlobal.activeMenu )
			uiGlobal.menuStack.pop()
		}
		else
		{
			CloseMenu( uiGlobal.activeMenu )
			printt( Hud_GetHudName( uiGlobal.activeMenu ), "menu closed" )
		}
	}

	if ( IsDialog( menu ) && uiGlobal.activeMenu )
		SetFooterPanelVisibility( uiGlobal.activeMenu, false )

	uiGlobal.menuStack.push( menu )
	uiGlobal.activeMenu = menu

	uiGlobal.lastMenuNavDirection = MENU_NAV_FORWARD

	if ( uiGlobal.activeMenu )
	{
		if ( !IsLobby() && !uiGlobal.mapSupportsMenuModels )
			SetBlurEnabled( true )

		OpenMenuWrapper( uiGlobal.activeMenu, true )
	}

	Signal( uiGlobal.signalDummy, "ActiveMenuChanged" )
}

void function SetFooterPanelVisibility( var menu, bool visible )
{
	if ( !Hud_HasChild( menu, "FooterButtons" ) )
		return

	var panel = Hud_GetChild( menu, "FooterButtons" )
	Hud_SetVisible( panel, visible )
}

void function OpenSubmenu( var menu, bool updateMenuPos = true )
{
	Assert( menu )
	Assert( menu.GetType() == "submenu" )

	if ( uiGlobal.activeMenu )
	{
		// Don't open the same menu again if it's already open
		if ( uiGlobal.activeMenu == menu )
			return
	}

	local submenuPos = Hud_GetAbsPos( GetFocus() )

	uiGlobal.menuStack.push( menu )
	uiGlobal.activeMenu = menu

	OpenMenuWrapper( uiGlobal.activeMenu, true )

	if ( updateMenuPos )
	{
		var vguiButtonFrame = Hud_GetChild( uiGlobal.activeMenu, "ButtonFrame" )
		Hud_SetPos( vguiButtonFrame, submenuPos[0], submenuPos[1] )
	}

	uiGlobal.lastMenuNavDirection = MENU_NAV_FORWARD

	Signal( uiGlobal.signalDummy, "ActiveMenuChanged" )
}

void function CloseSubmenu( bool openStackMenu = true )
{
	if ( !uiGlobal.activeMenu )
		return

	if ( uiGlobal.activeMenu.GetType() != "submenu" )
		return

	CloseMenuWrapper( uiGlobal.activeMenu )
	uiGlobal.menuStack.pop()

	uiGlobal.lastMenuNavDirection = MENU_NAV_FORWARD

	if ( uiGlobal.menuStack.len() )
	{
		uiGlobal.activeMenu = uiGlobal.menuStack.top()

		// This runs any OnOpen function for the menu and sets focus, but doesn't actually open the menu because it is already open
		if ( openStackMenu )
			OpenMenuWrapper( uiGlobal.activeMenu, false )
	}
	else
	{
		uiGlobal.activeMenu = null
	}

	Signal( uiGlobal.signalDummy, "ActiveMenuChanged" )
}

void function CloseActiveMenuNoParms()
{
	CloseActiveMenu()
}

void function CloseActiveMenu( bool cancelled = false, bool openStackMenu = true )
{
	bool updateBlur = true
	bool wasDialog = false

	if ( uiGlobal.activeMenu )
	{
		if ( IsDialog( uiGlobal.activeMenu ) )
		{
			updateBlur = false
			wasDialog = true
			uiGlobal.dialogInputEnableTime = 0.0

			if ( uiGlobal.dialogCloseCallback )
			{
				uiGlobal.dialogCloseCallback( cancelled )
				uiGlobal.dialogCloseCallback = null
			}
		}

		if ( updateBlur )
			SetBlurEnabled( false )

		CloseMenuWrapper( uiGlobal.activeMenu )
	}

	uiGlobal.menuStack.pop()
	if ( uiGlobal.menuStack.len() )
		uiGlobal.activeMenu = uiGlobal.menuStack.top()
	else
		uiGlobal.activeMenu = null

	uiGlobal.lastMenuNavDirection = MENU_NAV_BACK

	if ( wasDialog )
	{
		if ( uiGlobal.activeMenu )
			SetFooterPanelVisibility( uiGlobal.activeMenu, true )

		if ( IsDialog( uiGlobal.activeMenu ) )
			openStackMenu = true
		else
			openStackMenu = false
	}

	if ( uiGlobal.activeMenu )
	{
		if ( uiGlobal.activeMenu.GetType() == "submenu" )
		{
			Hud_SetFocused( uiGlobal.menuData[ uiGlobal.activeMenu ].lastFocus )
		}
		else if ( openStackMenu )
		{
			OpenMenuWrapper( uiGlobal.activeMenu, false )

			if ( updateBlur && !IsLobby() && !uiGlobal.mapSupportsMenuModels )
				SetBlurEnabled( true )
		}
	}

	Signal( uiGlobal.signalDummy, "ActiveMenuChanged" )
}

void function CloseAllMenus()
{
	if ( IsDialog( uiGlobal.activeMenu ) )
		CloseActiveMenu( true )

	if ( uiGlobal.activeMenu && uiGlobal.activeMenu.GetType() == "submenu" )
		CloseSubmenu( false )

	if ( uiGlobal.activeMenu )
	{
		SetBlurEnabled( false )
		CloseMenuWrapper( uiGlobal.activeMenu )
	}

	uiGlobal.menuStack = []
	uiGlobal.activeMenu = null

	uiGlobal.lastMenuNavDirection = MENU_NAV_BACK

	Signal( uiGlobal.signalDummy, "ActiveMenuChanged" )
}

void function CloseAllInGameMenus()
{
	while ( uiGlobal.activeMenu )
	{
		if ( uiGlobal.activeMenu.GetType() == "submenu" )
			CloseSubmenu( false )

		CloseActiveMenu( true, false )
	}
}

void function CloseAllDialogs()
{
	while ( IsDialog( uiGlobal.activeMenu ) )
		CloseActiveMenu( true )
}

void function CloseAllToTargetMenu( var targetMenu )
{
	while ( uiGlobal.activeMenu != targetMenu )
		CloseActiveMenu( true, false )
}

void function PrintMenuStack()
{
	array<var> stack = clone uiGlobal.menuStack
	stack.reverse()

	printt( "MENU STACK:" )

	foreach ( menu in stack )
	{
		if ( menu )
			printt( "   ", Hud_GetHudName( menu ) )
		else
			printt( "    null" )
	}
}

// Happens on any level load
void function UpdateMenusOnConnect( string levelname )
{
	EndSignal( uiGlobal.signalDummy, "LevelShutdown" ) // HACK fix because UICodeCallback_LevelInit() incorrectly runs when disconnected by client error. Test with "script_error_client" while a level is loaded.

	CloseAllDialogs()

	var mainMenu = GetMenu( "MainMenu" )
	if ( IsMenuInMenuStack( mainMenu ) && !IsMenuInMenuStack( null ) )
		CloseAllToTargetMenu( mainMenu )

	Assert( uiGlobal.activeMenu != null || uiGlobal.menuStack.len() == 0 )

	AdvanceMenu( null )

	// TODO: The order things are called in should be predictable so this isn't needed
	while ( !uiGlobal.mapSupportsMenuModelsUpdated )
	{
		//printt( Time(), "beginning waitframe, uiGlobal.mapSupportsMenuModelsUpdated is:", uiGlobal.mapSupportsMenuModelsUpdated )
		WaitFrame()
		//printt( Time(), "ended waitframe, uiGlobal.mapSupportsMenuModelsUpdated is:", uiGlobal.mapSupportsMenuModelsUpdated )
	}

	if ( IsLevelMultiplayer( levelname ) )
	{
		bool isLobby = IsLobbyMapName( levelname )

		if ( isLobby )
		{
			if ( IsPrivateMatch() )
			{
				AdvanceMenu( GetMenu( "PrivateLobbyMenu" ) )
			}
			else
			{
				AdvanceMenu( GetMenu( "LobbyMenu" ) )
			}

			thread UpdateAnnouncementDialog()
		}
		else
		{
			UI_SetPresentationType( ePresentationType.INACTIVE )
		}
	}
}

bool function IsMenuInMenuStack( var searchMenu )
{
	foreach ( menu in uiGlobal.menuStack )
	{
		// loading a map pushes a null sentinel onto the menu stack
		if ( !menu )
			continue

		if ( menu == searchMenu )
			return true
	}

	return false
}

var function GetTopNonDialogMenu()
{
	array<var> menuArray = clone uiGlobal.menuStack
	menuArray.reverse()

	foreach ( menu in menuArray )
	{
		if ( menu == null || IsDialog( menu ) )
			continue

		return menu
	}

	return null
}

void function CleanupInGameMenus()
{
	Signal( uiGlobal.signalDummy, "CleanupInGameMenus" )

	CloseAllInGameMenus()
	Assert( uiGlobal.activeMenu == null )
	if ( uiGlobal.menuStack.len() )
	{
		if ( uiGlobal.loadingLevel == "" )
			CloseActiveMenu() // Disconnected. Remove stack null and open main menu.
		else
			CloseActiveMenu( true, false ) // Level to level transition. Remove stack null and DON'T open main menu.
	}
}

var function GetActiveMenu()
{
	return uiGlobal.activeMenu
}

var function GetMenu( string menuName )
{
	return uiGlobal.menus[ menuName ]
}

var function GetPanel( string panelName )
{
	return uiGlobal.panels[ panelName ]
}

array<var> function GetAllMenuPanels( var menu )
{
	array<var> menuPanels

	foreach ( panel in uiGlobal.allPanels )
	{
		if ( Hud_GetParent( panel ) == menu )
			menuPanels.append( panel )
	}

	return menuPanels
}

void function InitGamepadConfigs()
{
	uiGlobal.buttonConfigs = [ { orthodox = "gamepad_button_layout_default.cfg", southpaw = "gamepad_button_layout_default_southpaw.cfg" } ]
	uiGlobal.buttonConfigs.append( { orthodox = "gamepad_button_layout_bumper_jumper.cfg", southpaw = "gamepad_button_layout_bumper_jumper_southpaw.cfg" } )
	uiGlobal.buttonConfigs.append( { orthodox = "gamepad_button_layout_bumper_jumper_alt.cfg", southpaw = "gamepad_button_layout_bumper_jumper_alt_southpaw.cfg" } )
	uiGlobal.buttonConfigs.append( { orthodox = "gamepad_button_layout_pogo_stick.cfg", southpaw = "gamepad_button_layout_pogo_stick_southpaw.cfg" } )
	uiGlobal.buttonConfigs.append( { orthodox = "gamepad_button_layout_button_kicker.cfg", southpaw = "gamepad_button_layout_button_kicker_southpaw.cfg" } )
	uiGlobal.buttonConfigs.append( { orthodox = "gamepad_button_layout_circle.cfg", southpaw = "gamepad_button_layout_circle_southpaw.cfg" } )
	uiGlobal.buttonConfigs.append( { orthodox = "gamepad_button_layout_ninja.cfg", southpaw = "gamepad_button_layout_ninja_southpaw.cfg" } )
	uiGlobal.buttonConfigs.append( { orthodox = "gamepad_button_layout_custom.cfg", southpaw = "gamepad_button_layout_custom.cfg" } )

	uiGlobal.stickConfigs = []
	uiGlobal.stickConfigs.append( "gamepad_stick_layout_default.cfg" )
	uiGlobal.stickConfigs.append( "gamepad_stick_layout_southpaw.cfg" )
	uiGlobal.stickConfigs.append( "gamepad_stick_layout_legacy.cfg" )
	uiGlobal.stickConfigs.append( "gamepad_stick_layout_legacy_southpaw.cfg" )

	foreach ( key, val in uiGlobal.buttonConfigs )
	{
		VPKNotifyFile( "cfg/" + val.orthodox )
		VPKNotifyFile( "cfg/" + val.southpaw )
	}

	foreach ( key, val in uiGlobal.stickConfigs )
		VPKNotifyFile( "cfg/" + val )

	ExecCurrentGamepadButtonConfig()
	ExecCurrentGamepadStickConfig()

	SetStandardAbilityBindingsForPilot( GetLocalClientPlayer() )
}

void function InitMenus()
{
	InitGlobalMenuVars()
	SpShWeaponsInit()

	AddMenu( "MainMenu", $"resource/ui/menus/main.menu", InitMainMenu, "#MAIN" )
	AddPanel( GetMenu( "MainMenu" ), "EstablishUserPanel", InitEstablishUserPanel )
	AddPanel( GetMenu( "MainMenu" ), "MainMenuPanel", InitMainMenuPanel )

	AddMenu( "PlayVideoMenu", $"resource/ui/menus/play_video.menu", InitPlayVideoMenu )
	AddMenu( "LobbyMenu", $"resource/ui/menus/lobby.menu", InitLobbyMenu, "#LOBBY" )

	AddMenu( "FDMenu", $"resource/ui/menus/playlist_fd.menu", InitFDPlaylistMenu )
	AddMenu( "TeamTitanSelectMenu", $"resource/ui/menus/team_titan_select.menu", InitTeamTitanSelectMenu )
	AddMenu( "PlaylistMenu", $"resource/ui/menus/playlist.menu", InitPlaylistMenu )
	AddMenu( "PlaylistMixtapeMenu", $"resource/ui/menus/playlist_mixtape.menu", InitPlaylistMixtapeMenu )
	AddMenu( "PlaylistMixtapeChecklistMenu", $"resource/ui/menus/playlist_mixtape_checklist.menu", InitPlaylistMixtapeChecklistMenu )

	AddMenu( "SinglePlayerDevMenu", $"resource/ui/menus/singleplayer_dev.menu", InitSinglePlayerDevMenu, "SINGLE PLAYER DEV" )
	AddMenu( "SinglePlayerMenu", $"resource/ui/menus/singleplayer.menu", InitSinglePlayerMenu, "SINGLE PLAYER" )

	AddMenu( "SearchMenu", $"resource/ui/menus/search.menu", InitSearchMenu )

	AddMenu( "GammaMenu", $"resource/ui/menus/gamma.menu", InitGammaMenu, "#BRIGHTNESS" )

	AddMenu( "CommunitiesMenu", $"resource/ui/menus/community.menu", InitCommunitiesMenu )
	AddMenu( "Notifications", $"resource/ui/menus/notifications.menu", InitNotificationsMenu )
	AddMenu( "MyNetworks", $"resource/ui/menus/communities_mine.menu", InitMyNetworksMenu )
	AddMenu( "InboxFrontMenu", $"resource/ui/menus/inbox_front.menu", InitInboxFrontMenu )
	AddMenu( "Inbox", $"resource/ui/menus/inbox.menu", InitInboxMenu )
	AddMenu( "BrowseCommunities", $"resource/ui/menus/communities_browse.menu" )
	AddMenu( "CommunityEditMenu", $"resource/ui/menus/community_edit.menu" )
	AddMenu( "CommunityAdminSendMessage", $"resource/ui/menus/community_sendMessage.menu" )
	AddMenu( "CommunityAdminInviteRequestMenu", $"resource/ui/menus/community_inviteRequest.menu" )
#if NETWORK_INVITE
	AddMenu( "InviteFriendsToNetworkMenu", $"resource/ui/menus/invite_friends.menu", InitInviteFriendsToNetworkMenu )
#endif

	AddMenu( "InGameMPMenu", $"resource/ui/menus/ingame_mp.menu", InitInGameMPMenu )
	AddMenu( "InGameSPMenu", $"resource/ui/menus/ingame_sp.menu", InitInGameSPMenu )

	AddMenu( "Dialog", $"resource/ui/menus/dialog.menu", InitDialogMenu )
	AddMenu( "AnnouncementDialog", $"resource/ui/menus/dialog_announcement.menu", InitAnnouncementDialog )
	AddMenu( "ConnectingDialog", $"resource/ui/menus/dialog_connecting.menu", InitConnectingDialog )
	AddMenu( "DataCenterDialog", $"resource/ui/menus/dialog_datacenter.menu", InitDataCenterDialogMenu )
	AddMenu( "EULADialog", $"resource/ui/menus/dialog_eula.menu", InitEULADialog )
	AddMenu( "ReviewTermsDialog", $"resource/ui/menus/dialog_review_terms.menu", InitReviewTermsDialog )
	AddMenu( "RegistrationDialog", $"resource/ui/menus/dialog_registration.menu", InitRegistrationDialog )
	AddMenu( "AdvocateGiftDialog", $"resource/ui/menus/dialog_advocate_gift.menu", InitAdvocateGiftDialog )

	AddMenu( "ControlsMenu", $"resource/ui/menus/controls.menu", InitControlsMenu, "#CONTROLS" )
	AddMenu( "ControlsAdvancedLookMenu", $"resource/ui/menus/controls_advanced_look.menu", InitControlsAdvancedLookMenu, "#CONTROLS_ADVANCED_LOOK" )
	AddMenu( "GamepadLayoutMenu", $"resource/ui/menus/gamepadlayout.menu", InitGamepadLayoutMenu )
#if PC_PROG
	AddMenu_WithCreateFunc( "MouseKeyboardBindingsMenu", $"resource/ui/menus/mousekeyboardbindings.menu", InitMouseKeyboardMenu, CreateKeyBindingMenu )
	AddMenu( "AudioMenu", $"resource/ui/menus/audio.menu", InitAudioMenu, "#AUDIO" )
	AddMenu_WithCreateFunc( "VideoMenu", $"resource/ui/menus/video.menu", InitVideoMenu, CreateVideoOptionsMenu )
#elseif CONSOLE_PROG
	AddMenu( "AudioVideoMenu", $"resource/ui/menus/audio_video.menu", InitAudioVideoMenu, "#AUDIO_VIDEO" )
#endif

	AddMenu( "AdvancedHudMenu", $"resource/ui/menus/advanced_hud.menu", InitAdvancedHudMenu, "#ADVANCED_HUD" )

	AddMenu( "PilotLoadoutsMenu", $"resource/ui/menus/pilotloadouts.menu", InitPilotLoadoutsMenu )
	AddMenu( "TitanLoadoutsMenu", $"resource/ui/menus/titanloadouts.menu", InitTitanLoadoutsMenu )
	AddMenu( "EditPilotLoadoutsMenu", $"resource/ui/menus/pilotloadouts.menu", InitEditPilotLoadoutsMenu )
	AddMenu( "EditTitanLoadoutsMenu", $"resource/ui/menus/titanloadouts.menu", InitEditTitanLoadoutsMenu )
	AddMenu( "EditPilotLoadoutMenu", $"resource/ui/menus/editpilotloadout.menu", InitEditPilotLoadoutMenu )
	AddMenu( "EditTitanLoadoutMenu", $"resource/ui/menus/edittitanloadout.menu", InitEditTitanLoadoutMenu )

	AddMenu( "SPTitanLoadoutMenu", $"resource/ui/menus/sptitanloadout.menu", InitSPTitanLoadoutMenu )
	AddMenu( "SPTitanLoadoutTutorialMenu", $"resource/ui/menus/sptitanloadout_tutorial.menu", InitSPTitanLoadoutTutorialMenu )

	AddMenu( "SuitSelectMenu", $"resource/ui/menus/suitselect.menu", InitSuitSelectMenu )
	AddMenu( "WeaponSelectMenu", $"resource/ui/menus/weaponselect.menu", InitWeaponSelectMenu )
	AddMenu( "CategorySelectMenu", $"resource/ui/menus/categoryselect.menu", InitCategorySelectMenu )
	AddMenu( "AbilitySelectMenu", $"resource/ui/menus/abilityselect.menu", InitAbilitySelectMenu )
	AddMenu( "PassiveSelectMenu", $"resource/ui/menus/passiveselect.menu", InitPassiveSelectMenu )
	AddSubmenu( "ModSelectMenu", $"resource/ui/menus/modselect.menu", InitModSelectMenu )
	AddMenu( "CamoSelectMenu", $"resource/ui/menus/camoselect.menu", InitCamoSelectMenu )
	AddMenu( "NoseArtSelectMenu", $"resource/ui/menus/noseartselect.menu", InitNoseArtSelectMenu )
	AddMenu( "CallsignCardSelectMenu", $"resource/ui/menus/callsigncardselect.menu", InitCallsignCardSelectMenu )
	AddMenu( "CallsignIconSelectMenu", $"resource/ui/menus/callsigniconselect.menu", InitCallsignIconSelectMenu )
	AddMenu( "BoostStoreMenu", $"resource/ui/menus/booststore.menu", InitBoostStoreMenu )

	AddMenu( "PrivateLobbyMenu", $"resource/ui/menus/private_lobby.menu", InitPrivateMatchMenu, "#PRIVATE_MATCH" )
	AddMenu( "MapsMenu", $"resource/ui/menus/map_select.menu", InitMapsMenu )
	AddMenu( "ModesMenu", $"resource/ui/menus/mode_select.menu", InitModesMenu )
	AddMenu( "MatchSettingsMenu", $"resource/ui/menus/match_settings.menu", InitMatchSettingsMenu )

	AddMenu( "Advocate_Letter", $"resource/ui/menus/advocate_letter.menu", InitAdvocateLetterMenu )
	AddMenu( "Generation_Respawn", $"resource/ui/menus/generation_respawn.menu", InitGenerationRespawnMenu )
	AddMenu( "ChallengesMenu", $"resource/ui/menus/challenges.menu", InitChallengesMenu )

	AddMenu( "ViewStatsMenu", $"resource/ui/menus/viewstats.menu", InitViewStatsMenu, "#PERSONAL_STATS" )
	AddMenu( "ViewStats_Overview_Menu", $"resource/ui/menus/viewstats_overview.menu", InitViewStatsOverviewMenu )
	//AddMenu( "ViewStats_Kills_Menu", $"resource/ui/menus/viewstats_kills.menu", InitViewStatsKillsMenu )
	AddMenu( "ViewStats_Time_Menu", $"resource/ui/menus/viewstats_time.menu", InitViewStatsTimeMenu )
	//AddMenu( "ViewStats_Distance_Menu", $"resource/ui/menus/viewstats_distance.menu", InitViewStatsDistanceMenu )
	AddMenu( "ViewStats_Weapons_Menu", $"resource/ui/menus/viewstats_weapons.menu", InitViewStatsWeaponsMenu )
	AddMenu( "ViewStats_Titans_Menu", $"resource/ui/menus/viewstats_titans.menu", InitViewStatsTitansMenu )
	AddMenu( "ViewStats_Misc_Menu", $"resource/ui/menus/viewstats_misc.menu", InitViewStatsMiscMenu )
	AddMenu( "ViewStats_Maps_Menu", $"resource/ui/menus/viewstats_maps.menu", InitViewStatsMapsMenu )

	AddMenu( "PostGameMenu", $"resource/ui/menus/postgame.menu", InitPostGameMenu )
	AddMenu( "EOG_XP", $"resource/ui/menus/eog_xp.menu", InitEOG_XPMenu )
	AddMenu( "EOG_Coins", $"resource/ui/menus/eog_coins.menu", InitEOG_CoinsMenu )
	AddMenu( "EOG_Challenges", $"resource/ui/menus/eog_challenges.menu", InitEOG_ChallengesMenu )
	AddMenu( "EOG_Unlocks", $"resource/ui/menus/eog_unlocks.menu", InitEOG_UnlocksMenu )
	AddMenu( "EOG_Scoreboard", $"resource/ui/menus/eog_scoreboard.menu", InitEOG_ScoreboardMenu )

	AddMenu( "CreditsMenu", $"resource/ui/menus/credits.menu", InitCreditsMenu, "#CREDITS" )

	AddMenu( "BurnCardMenu", $"resource/ui/menus/burn_cards.menu", InitBurnCardMenu, "#MENU_BURNCARD_MENU" )
	AddMenu( "FactionChoiceMenu", $"resource/ui/menus/faction_choice.menu", InitFactionChoiceMenu, "#FACTION_CHOICE_MENU" )
	AddMenu( "ArmoryMenu", $"resource/ui/menus/armory.menu", InitArmoryMenu, "#ARMORY_MENU" )

	AddMenu( "StoreMenu", $"resource/ui/menus/store.menu", InitStoreMenu, "#STORE_MENU" )
	AddMenu( "StoreMenu_NewReleases", $"resource/ui/menus/store_new_releases.menu", InitStoreMenuNewReleases, "#STORE_NEW_RELEASES" )
	AddMenu( "StoreMenu_Limited", $"resource/ui/menus/store_limited.menu", InitStoreMenuLimited, "#STORE_LIMITED" )
	AddMenu( "StoreMenu_Sales", $"resource/ui/menus/store_bundles.menu", InitStoreMenuSales, "#STORE_BUNDLES" )
	AddMenu( "StoreMenu_Titans", $"resource/ui/menus/store_prime_titans.menu", InitStoreMenuTitans, "#STORE_TITANS" ) // reusing store_prime_titans.menu
	AddMenu( "StoreMenu_PrimeTitans", $"resource/ui/menus/store_prime_titans.menu", InitStoreMenuPrimeTitans, "#STORE_PRIME_TITANS" )
	//AddMenu( "StoreMenu_WeaponSelect", $"resource/ui/menus/store_weapon_select.menu", InitStoreMenuWeaponSelect )
	//AddMenu( "StoreMenu_WeaponSkinPreview", $"resource/ui/menus/store_weapon_skin_preview.menu", InitStoreMenuWeaponSkinPreview )
	AddMenu( "StoreMenu_WeaponSkinBundles", $"resource/ui/menus/store_weapon_skin_bundles.menu", InitStoreMenuWeaponSkinBundles )
	AddMenu( "StoreMenu_WeaponSkins", $"resource/ui/menus/store_weapons.menu", InitStoreMenuWeaponSkins )
	AddMenu( "StoreMenu_Customization", $"resource/ui/menus/store_customization.menu", InitStoreMenuCustomization, "#STORE_CUSTOMIZATION_PACKS" )
	AddMenu( "StoreMenu_CustomizationPreview", $"resource/ui/menus/store_customization_preview.menu", InitStoreMenuCustomizationPreview, "#STORE_CUSTOMIZATION_PACKS" )
	AddMenu( "StoreMenu_Camo", $"resource/ui/menus/store_camo.menu", InitStoreMenuCamo, "#STORE_CAMO_PACKS" )
	AddMenu( "StoreMenu_CamoPreview", $"resource/ui/menus/store_camo_preview.menu", InitStoreMenuCamoPreview, "#STORE_CAMO_PACKS" )
	AddMenu( "StoreMenu_Callsign", $"resource/ui/menus/store_callsign.menu", InitStoreMenuCallsign, "#STORE_CALLSIGN_PACKS" )
	AddMenu( "StoreMenu_CallsignPreview", $"resource/ui/menus/store_callsign_preview.menu", InitStoreMenuCallsignPreview, "#STORE_CALLSIGN_PACKS" )

	AddMenu( "KnowledgeBaseMenu", $"resource/ui/menus/knowledgebase.menu", InitKnowledgeBaseMenu )
	AddMenu( "KnowledgeBaseMenuSubMenu", $"resource/ui/menus/knowledgebase_submenu.menu", InitKnowledgeBaseMenuSubMenu )

	AddMenu( "DevMenu", $"resource/ui/menus/dev.menu", InitDevMenu, "Dev" )
	InitSharedStartPoints()

	foreach ( menu in uiGlobal.allMenus )
	{
		if ( uiGlobal.menuData[ menu ].initFunc != null )
			uiGlobal.menuData[ menu ].initFunc()

		array<var> elems = GetElementsByClassname( menu, "TabsCommonClass" )
		if ( elems.len() )
			uiGlobal.menuData[ menu ].hasTabs = true

		elems = GetElementsByClassname( menu, "EnableKeyBindingIcons" )
		foreach ( elem in elems )
			Hud_EnableKeyBindingIcons( elem )
	}

	InitTabs()

	var tabbedMenu = GetMenu( "PostGameMenu" )
	AddPanel( tabbedMenu, "PVEPanel", InitPVEPanel )
	AddPanel( tabbedMenu, "SummaryPanel", InitSummaryPanel )
	AddPanel( tabbedMenu, "FDAwardsPanel", InitFDAwardsPanel )

	AddPanel( tabbedMenu, "ScoreboardPanel", InitScoreboardPanel )

	foreach ( panel in uiGlobal.allPanels )
	{
		if ( uiGlobal.panelData[ panel ].initFunc != null )
			uiGlobal.panelData[ panel ].initFunc()
	}

	// A little weird, but GetElementsByClassname() uses menu scope rather than parent scope.
	foreach ( menu in uiGlobal.allMenus )
	{
		array<var> buttons = GetElementsByClassname( menu, "DefaultFocus" )
		foreach ( button in buttons )
		{
			var panel = Hud_GetParent( button )

			//Assert( elems.len() == 1, "More than 1 panel element set as DefaultFocus!" )
			Assert( panel != null, "no parent panel found for button " + Hud_GetHudName( button ) )
			Assert( panel in uiGlobal.panelData, "panel " + Hud_GetHudName( panel ) + " isn't in uiGlobal.panelData, but button " + Hud_GetHudName( button ) + " has defaultFocus set!" )
			uiGlobal.panelData[ panel ].defaultFocus = button
			//printt( "Found DefaultFocus, button was:", Hud_GetHudName( button ), "panel was:", Hud_GetHudName( panel ) )
		}
	}

	InitFooterOptions()

	#if DEV
	if ( Dev_CommandLineHasParm( "-autoprecache_all" ) )
	{
		// repreache all levels
		ExecuteLoadingClientCommands_SetStartPoint( "sp_training" )
		ClientCommand( "map sp_training" )
		CloseAllMenus()
	}
	#endif
}

void functionref( var ) function AdvanceMenuEventHandler( var menu )
{
	return void function( var item ) : ( menu )
	{
		if ( Hud_IsLocked( item ) )
			return

		AdvanceMenu( menu )
	}
}

void function PCBackButton_Activate( var button )
{
	UICodeCallback_NavigateBack()
}

void function PCSwitchTeamsButton_Activate( var button )
{
	ClientCommand( "PrivateMatchSwitchTeams" )
}

void function PCToggleSpectateButton_Activate( var button )
{
	ClientCommand( "PrivateMatchToggleSpectate" )
}

void function ToggleButtonStates( var button )
{
	for ( ;; )
	{
		Hud_SetEnabled( button, true )
		wait 1
		Hud_SetSelected( button, true )
		wait 1
		Hud_SetLocked( button, true )
		wait 1
		Hud_SetNew( button, true )
		wait 1
		Hud_SetNew( button, false )
		wait 1
		Hud_SetLocked( button, false )
		wait 1
		Hud_SetSelected( button, false )
		wait 1
		Hud_SetEnabled( button, false )
		wait 1
	}
}

void function AddMenuElementsByClassname( var menu, string classname )
{
	array<var> elements = GetElementsByClassname( menu, classname )

	if ( !(classname in menu.classElements) )
		menu.classElements[classname] <- []

	menu.classElements[classname].extend( elements )
}

void function FocusDefault( var menu )
{
	if (
				menu == GetMenu( "MainMenu" ) ||
				menu == GetMenu( "CategorySelectMenu" ) ||
			  menu == GetMenu( "AbilitySelectMenu" ) ||
			  menu == GetMenu( "PassiveSelectMenu" ) ||
			  menu == GetMenu( "WeaponSelectMenu" ) ||
			  menu == GetMenu( "SuitSelectMenu" ) ||
			  menu == GetMenu( "CamoSelectMenu" ) ||
			  menu == GetMenu( "NoseArtSelectMenu" ) ||
			  menu == GetMenu( "FactionChoiceMenu" ) ||
			  menu == GetMenu( "BurnCardMenu" ) ||
			  menu == GetMenu( "CallsignCardSelectMenu" ) ||
			  menu == GetMenu( "CallsignIconSelectMenu" ) )
	{
	}
	else
	{
		//printt( "FocusDefaultMenuItem() called" )
		FocusDefaultMenuItem( menu )
	}
}

void function SetPanelDefaultFocus( var panel, var button )
{
	uiGlobal.panelData[ panel ].defaultFocus = button
}

void function PanelFocusDefault( var panel )
{
	//printt( "PanelFocusDefault called" )
	if ( uiGlobal.panelData[ panel ].defaultFocus )
	{
		Hud_SetFocused( uiGlobal.panelData[ panel ].defaultFocus )
		//printt( "PanelFocusDefault if passed,", Hud_GetHudName( uiGlobal.panelData[ panel ].defaultFocus ), "focused" )
	}
}

void function SetMenuThinkFunc( var menu, void functionref() func )
{
	Assert( uiGlobal.menuData[ menu ].thinkFunc == null )
	uiGlobal.menuData[ menu ].thinkFunc = func
}

void function AddMenuEventHandler( var menu, int event, void functionref() func )
{
	if ( event == eUIEvent.MENU_OPEN )
	{
		Assert( uiGlobal.menuData[ menu ].openFunc == null )
		uiGlobal.menuData[ menu ].openFunc = func
	}
	else if ( event == eUIEvent.MENU_CLOSE )
	{
		Assert( uiGlobal.menuData[ menu ].closeFunc == null )
		uiGlobal.menuData[ menu ].closeFunc = func
	}
	else if ( event == eUIEvent.MENU_SHOW )
	{
		Assert( uiGlobal.menuData[ menu ].showFunc == null )
		uiGlobal.menuData[ menu ].showFunc = func
	}
	else if ( event == eUIEvent.MENU_HIDE )
	{
		Assert( uiGlobal.menuData[ menu ].hideFunc == null )
		uiGlobal.menuData[ menu ].hideFunc = func
	}
	else if ( event == eUIEvent.MENU_NAVIGATE_BACK )
	{
		Assert( uiGlobal.menuData[ menu ].navBackFunc == null )
		uiGlobal.menuData[ menu ].navBackFunc = func
	}
	else if ( event == eUIEvent.MENU_TAB_CHANGED )
	{
		Assert( uiGlobal.menuData[ menu ].tabChangedFunc == null )
		uiGlobal.menuData[ menu ].tabChangedFunc = func
	}
	else if ( event == eUIEvent.MENU_ENTITLEMENTS_CHANGED )
	{
		Assert( uiGlobal.menuData[ menu ].entitlementsChangedFunc == null )
		uiGlobal.menuData[ menu ].entitlementsChangedFunc = func
	}
	else if ( event == eUIEvent.MENU_INPUT_MODE_CHANGED )
	{
		Assert( uiGlobal.menuData[ menu ].inputModeChangedFunc == null )
		uiGlobal.menuData[ menu ].inputModeChangedFunc = func
	}
}

void function AddPanelEventHandler( var panel, int event, void functionref() func )
{
	if ( event == eUIEvent.PANEL_SHOW )
		uiGlobal.panelData[ panel ].showFunc = func
	else if ( event == eUIEvent.PANEL_HIDE )
		uiGlobal.panelData[ panel ].hideFunc = func
}

// TODO: Get a real on open event from code?
void function OpenMenuWrapper( var menu, bool focusDefault )
{
	OpenMenu( menu )
	printt( Hud_GetHudName( menu ), "menu opened" )

	Assert( menu in uiGlobal.menuData )
	if ( uiGlobal.menuData[ menu ].openFunc != null )
	{
		thread uiGlobal.menuData[ menu ].openFunc()
		//printt( "Called openFunc for:", menu.GetHudName() )
	}

	if ( focusDefault )
		FocusDefault( menu )

	//UpdateMenuTabs()
	UpdateFooterOptions()
}

void function CloseMenuWrapper( var menu )
{
	CloseMenu( menu )
	printt( Hud_GetHudName( menu ), "menu closed" )

	Assert( menu in uiGlobal.menuData )
	if ( uiGlobal.menuData[ menu ].closeFunc != null )
	{
		thread uiGlobal.menuData[ menu ].closeFunc()
		//printt( "Called closeFunc for:", Hud_GetHudName( menu ) )
	}
}

bool function IsLevelMultiplayer( string levelname )
{
	return levelname.find( "mp_" ) == 0
}

void function AddButtonEventHandler( var button, int event, void functionref( var ) func )
{
	Hud_AddEventHandler( button, event, func )
}

void function AddEventHandlerToButton( var menu, string buttonName, int event, void functionref( var ) func )
{
	var button = Hud_GetChild( menu, buttonName )
	Hud_AddEventHandler( button, event, func )
}

void function AddEventHandlerToButtonClass( var menu, string classname, int event, void functionref( var ) func )
{
	array<var> buttons = GetElementsByClassname( menu, classname )

	foreach ( button in buttons )
	{
		//printt( "button name:", Hud_GetHudName( button ) )
		Hud_AddEventHandler( button, event, func )
	}
}

// Added slight delay to main menu music to work around a hitch caused when the game first starts up
void function PlayMusicAfterDelay()
{
	wait MAINMENU_MUSIC_DELAY
	if ( uiGlobal.playingMusic )
		EmitUISound( "MainMenu_Music" )
}

void function DisableMusic()
{
	EmitUISound( "Movie_MuteAllGameSound" )
}

void function EnableMusic()
{
	StopUISoundByName( "Movie_MuteAllGameSound" )
}

void function PlayMusic()
{
	if ( !uiGlobal.playingMusic && !uiGlobal.playingVideo && !uiGlobal.playingCredits )
	{
		//printt( "PlayMusic() called. Playing: MainMenu_Music. uiGlobal.playingMusic:", uiGlobal.playingMusic, "uiGlobal.playingVideo:", uiGlobal.playingVideo, "uiGlobal.playingCredits:", uiGlobal.playingCredits )
		uiGlobal.playingMusic = true
		thread PlayMusicAfterDelay()
	}
	else
	{
		//printt( "PlayMusic() called, but doing nothing. uiGlobal.playingMusic:", uiGlobal.playingMusic, "uiGlobal.playingVideo:", uiGlobal.playingVideo, "uiGlobal.playingCredits:", uiGlobal.playingCredits )
	}
}

void function StopMusic()
{
	//printt( "StopMusic() called. Stopping: MainMenu_Music" )
	StopUISound( "MainMenu_Music" )
	uiGlobal.playingMusic = false
}

void function RegisterMenuVarInt( string varName, int value )
{
	table<string, int> intVars = uiGlobal.intVars

	Assert( !( varName in intVars ) )

	intVars[varName] <- value
}

void function RegisterMenuVarBool( string varName, bool value )
{
	table<string, bool> boolVars = uiGlobal.boolVars

	Assert( !( varName in boolVars ) )

	boolVars[varName] <- value
}

void function RegisterMenuVarVar( string varName, var value )
{
	table<string, var> varVars = uiGlobal.varVars

	Assert( !( varName in varVars ) )

	varVars[varName] <- value
}

int function GetMenuVarInt( string varName )
{
	table<string, int> intVars = uiGlobal.intVars

	Assert( varName in intVars )

	return intVars[varName]
}

bool function GetMenuVarBool( string varName )
{
	table<string, bool> boolVars = uiGlobal.boolVars

	Assert( varName in boolVars )

	return boolVars[varName]
}

var function GetMenuVarVar( string varName )
{
	table<string, var> varVars = uiGlobal.varVars

	Assert( varName in varVars )

	return varVars[varName]
}

void function SetMenuVarInt( string varName, int value )
{
	table<string, int> intVars = uiGlobal.intVars

	Assert( varName in intVars )

	if ( intVars[varName] == value )
		return

	intVars[varName] = value

	table<string, array<void functionref()> > varChangeFuncs = uiGlobal.varChangeFuncs

	if ( varName in varChangeFuncs )
	{
		foreach ( func in varChangeFuncs[varName] )
		{
			//printt( varName, "changed, calling changeFunc:", string( func ) )
			func()
		}
	}
}

void function SetMenuVarBool( string varName, bool value )
{
	table<string, bool> boolVars = uiGlobal.boolVars

	Assert( varName in boolVars )

	if ( boolVars[varName] == value )
		return

	boolVars[varName] = value

	table<string, array<void functionref()> > varChangeFuncs = uiGlobal.varChangeFuncs

	if ( varName in varChangeFuncs )
	{
		foreach ( func in varChangeFuncs[varName] )
		{
			//printt( varName, "changed, calling changeFunc:", string( func ) )
			func()
		}
	}
}

void function SetMenuVarVar( string varName, var value )
{
	table<string, var> varVars = uiGlobal.varVars

	Assert( varName in varVars )

	if ( varVars[varName] == value )
		return

	varVars[varName] = value

	table<string, array<void functionref()> > varChangeFuncs = uiGlobal.varChangeFuncs

	if ( varName in varChangeFuncs )
	{
		foreach ( func in varChangeFuncs[varName] )
		{
			//printt( varName, "changed, calling changeFunc:", string( func ) )
			func()
		}
	}
}

void function AddMenuVarChangeHandler( string varName, void functionref() func )
{
	table<string, array<void functionref()> > varChangeFuncs = uiGlobal.varChangeFuncs

	if ( !( varName in varChangeFuncs ) )
		varChangeFuncs[varName] <- []

	// TODO: Verify we're not duplicating an existing func
	varChangeFuncs[varName].append( func )
}

// These are common menu statuses that trigger menu logic any time they change
// They should become code callbacks, so script doesn't poll
void function InitGlobalMenuVars()
{
	RegisterMenuVarVar( "focus", null )
	RegisterMenuVarBool( "isConnected", false )
	RegisterMenuVarBool( "isFullyConnected", false )
	RegisterMenuVarBool( "isPartyLeader", false )
	RegisterMenuVarBool( "isPrivateMatch", false )
	RegisterMenuVarBool( "isGamepadActive", IsControllerModeActive() )

	#if CONSOLE_PROG
		RegisterMenuVarBool( "CONSOLE_isOnline", false )
		RegisterMenuVarBool( "CONSOLE_isSignedIn", false )
	#endif // CONSOLE_PROG

	#if DURANGO_PROG
		RegisterMenuVarBool( "DURANGO_isGameFullyInstalled", false )
		RegisterMenuVarBool( "DURANGO_canInviteFriends", false )
		RegisterMenuVarBool( "DURANGO_isJoinable", false )
    #elseif PS4_PROG
		RegisterMenuVarBool( "PS4_canInviteFriends", false)
	#elseif PC_PROG
		RegisterMenuVarBool( "ORIGIN_isEnabled", false )
		RegisterMenuVarBool( "ORIGIN_isJoinable", false )
	#endif

	thread UpdateFocus()
	thread UpdateIsConnected()
	thread UpdateIsFullyConnected()
	thread UpdateAmIPartyLeader()
	thread UpdateIsPrivateMatch()
	thread UpdateActiveMenuThink()

	#if CONSOLE_PROG
		thread UpdateConsole_IsOnline()
		thread UpdateConsole_IsSignedIn()
	#endif // CONSOLE_PROG

	#if DURANGO_PROG
		thread UpdateDurango_IsGameFullyInstalled()
		thread UpdateDurango_CanInviteFriends()
		thread UpdateDurango_IsJoinable()
    #elseif PS4_PROG
		thread UpdatePS4_CanInviteFriends()
	#elseif PC_PROG
		thread UpdateOrigin_IsEnabled()
		thread UpdateOrigin_IsJoinable()
		thread UpdateIsGamepadActive()
	#endif
}

void function UpdateFocus()
{
	while ( true )
	{
		SetMenuVarVar( "focus", GetFocus() )
		WaitFrame()
	}
}

void function UpdateActiveMenuThink()
{
	while ( true )
	{
		var menu = GetActiveMenu()
		if ( menu )
		{
			Assert( menu in uiGlobal.menuData )
			if ( uiGlobal.menuData[ menu ].thinkFunc != null )
				uiGlobal.menuData[ menu ].thinkFunc()
		}

		WaitFrame()
	}
}

void function UpdateIsConnected()
{
	while ( true )
	{
		SetMenuVarBool( "isConnected", IsConnected() )
		WaitFrame()
	}
}

void function UpdateIsFullyConnected()
{
	while ( true )
	{
		SetMenuVarBool( "isFullyConnected", IsFullyConnected() )
		WaitFrame()
	}
}

void function UpdateAmIPartyLeader()
{
	while ( true )
	{
		SetMenuVarBool( "isPartyLeader", AmIPartyLeader() )
		WaitFrame()
	}
}

void function UpdateIsPrivateMatch()
{
	while ( true )
	{
		SetMenuVarBool( "isPrivateMatch", IsPrivateMatch() )
		WaitFrame()
	}
}

#if CONSOLE_PROG
	void function UpdateConsole_IsOnline()
	{
		while ( true )
		{
			SetMenuVarBool( "CONSOLE_isOnline", Console_IsOnline() )
			WaitFrame()
		}
	}

	void function UpdateConsole_IsSignedIn()
	{
		while ( true )
		{
			SetMenuVarBool( "CONSOLE_isSignedIn", Console_IsSignedIn() )
			WaitFrame()
		}
	}
#endif // CONSOLE_PROG


#if PS4_PROG
	void function UpdatePS4_CanInviteFriends()
	{
		while ( true )
		{
			SetMenuVarBool( "PS4_canInviteFriends", PS4_canInviteFriends() )
			WaitFrame()
		}
	}
#endif // PS4_PROG



#if DURANGO_PROG
	void function UpdateDurango_IsGameFullyInstalled()
	{
		while ( true )
		{
			SetMenuVarBool( "DURANGO_isGameFullyInstalled", IsGameFullyInstalled() )
			wait 1 // Poll less frequent
		}
	}

	void function UpdateDurango_CanInviteFriends()
	{
		while ( true )
		{
			SetMenuVarBool( "DURANGO_canInviteFriends", Durango_CanInviteFriends() )
			WaitFrame()
		}
	}

	void function UpdateDurango_IsJoinable()
	{
		while ( true )
		{
			SetMenuVarBool( "DURANGO_isJoinable", Durango_IsJoinable() )
			WaitFrame()
		}
	}
#endif // DURANGO_PROG

#if PC_PROG
	void function UpdateOrigin_IsEnabled()
	{
		while ( true )
		{
			SetMenuVarBool( "ORIGIN_isEnabled", Origin_IsEnabled() )
			WaitFrame()
		}
	}

	void function UpdateOrigin_IsJoinable()
	{
		while ( true )
		{
			SetMenuVarBool( "ORIGIN_isJoinable", Origin_IsJoinable() )
			WaitFrame()
		}
	}

	void function UpdateIsGamepadActive()
	{
		while ( true )
		{
			SetMenuVarBool( "isGamepadActive", IsControllerModeActive() )
			WaitFrame()
		}
	}
#endif // PC_PROG

void function InviteFriends( var button )
{
	//AdvanceMenu( GetMenu( "InviteFriendsToPartyMenu" ) )

	#if DURANGO_PROG
		Durango_InviteFriends()
	#elseif PS4_PROG
	    ClientCommand("session_debug_invite");
	#elseif PC_PROG
		Assert( Origin_IsEnabled() )
		Assert( Origin_IsJoinable() )

		Origin_ShowInviteFriendsDialog()
	#endif
}

#if DURANGO_PROG
void function OpenXboxPartyApp( var button )
{
	Durango_OpenPartyApp()
}

void function OpenXboxHelp( var button )
{
	Durango_ShowHelpWindow()
}
#endif // DURANGO_PROG

void function OpenReviewTermsDialog( var button )
{
	AdvanceMenu( GetMenu( "ReviewTermsDialog" ) )
}

void function OpenErrorDialog( string errorDetails )
{
	DialogData dialogData
	dialogData.header = "#ERROR"
	dialogData.message = errorDetails
	dialogData.image = $"ui/menu/common/dialog_error"

#if PC_PROG
	AddDialogButton( dialogData, "#DISMISS" )

	AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )
#endif // PC_PROG
	AddDialogFooter( dialogData, "#B_BUTTON_DISMISS_RUI" )

	while ( uiGlobal.activeMenu != GetMenu( "MainMenu" ) )
	{
		WaitSignal( uiGlobal.signalDummy, "OpenErrorDialog", "ActiveMenuChanged" )
	}

	OpenDialog( dialogData )
}

bool function IsDialog( var menu )
{
	if ( menu == null )
		return false

	return uiGlobal.menuData[ menu ].isDialog
}

bool function IsDialogActive( DialogData dialogData )
{
	if ( !IsDialog( uiGlobal.activeMenu ) )
		return false

	return uiGlobal.menuData[ uiGlobal.activeMenu ].dialogData == dialogData
}

bool function IsDialogOnlyActiveMenu()
{
	if ( !IsDialog( uiGlobal.activeMenu ) )
		return false

	int stackLen = uiGlobal.menuStack.len()
	if ( stackLen < 1 )
		return false

	if ( uiGlobal.menuStack[stackLen - 1] != uiGlobal.activeMenu )
		return false

	if ( stackLen == 1 )
		return true

	if ( uiGlobal.menuStack[stackLen - 2] == null )
		return true

	return false
}

void function SetNavUpDown( array<var> buttons, var wrap = true )
{
	Assert( buttons.len() > 0 )

	var first = buttons[0]
	var last = buttons[buttons.len() - 1]
	var prev
	var next
	var button

	for ( int i = 0; i < buttons.len(); i++ )
	{
		button = buttons[i]

		if ( button == first )
			prev = last
		else
			prev = buttons[i - 1]

		if ( button == last )
			next = first
		else
			next = buttons[i + 1]

		button.SetNavUp( prev )
		button.SetNavDown( next )

		//printt( "SetNavUP for:", Hud_GetHudName( button ), "to:", Hud_GetHudName( prev ) )
		//printt( "SetNavDown for:", Hud_GetHudName( button ), "to:", Hud_GetHudName( next ) )
	}
}

void function SetNavLeftRight( array<var> buttons, var wrap = true )
{
	Assert( buttons.len() > 0 )

	var first = buttons[0]
	var last = buttons[buttons.len() - 1]
	var prev
	var next
	var button

	for ( int i = 0; i < buttons.len(); i++ )
	{
		button = buttons[i]

		if ( button == first )
			prev = last
		else
			prev = buttons[i - 1]

		if ( button == last )
			next = first
		else
			next = buttons[i + 1]

		button.SetNavLeft( prev )
		button.SetNavRight( next )

		//printt( "SetNavUP for:", Hud_GetHudName( button ), "to:", Hud_GetHudName( prev ) )
		//printt( "SetNavDown for:", Hud_GetHudName( button ), "to:", Hud_GetHudName( next ) )
	}
}

void function UICodeCallback_EntitlementsChanged()
{
	if ( uiGlobal.activeMenu == null )
		return

	if ( uiGlobal.menuData[ uiGlobal.activeMenu ].entitlementsChangedFunc != null )
		thread uiGlobal.menuData[ uiGlobal.activeMenu ].entitlementsChangedFunc()
}

#if PC_PROG
void function QuitGame()
{
	ClientCommand( "quit" )
}
#endif

void function UICodeCallback_StoreTransactionCompleted()
{
	// this callback is only supported and needed on PS4 currently
#if PS4_PROG
	if ( InStoreMenu() )
		OnOpenDLCStore()
#endif
}

void function UICodeCallback_GamePurchased()
{
	// this callback is only supported and needed on PC currently
#if PC_PROG
	DialogData dialogData
	dialogData.header = "#PURCHASE_GAME_COMPLETE"
	dialogData.message = "#PURCHASE_GAME_RESTART"
	AddDialogButton( dialogData, "#QUIT", QuitGame )

	OpenDialog( dialogData )
#endif
}

bool function IsTrialPeriodActive()
{
	return GetConVarBool( "trialPeriodIsActive" )
}

void function LaunchGamePurchaseOrDLCStore( array<string> menuNames = [ "StoreMenu" ] )
{
	if ( Script_IsRunningTrialVersion() )
	{
		LaunchGamePurchase()
	}
	else
	{
		void functionref() preOpenFunc = null

		foreach ( menuName in menuNames )
		{
			// Special case because this menu needs a few properties set before opening
			if ( menuName == "StoreMenu_WeaponSkins" )
			{
				preOpenFunc = DefaultToDLC11WeaponWarpaintBundle
				break
			}
		}

		OpenStoreMenu( menuNames, preOpenFunc )
	}
}

void function UICodeCallback_PartyUpdated()
{
	if ( AmIPartyLeader() )
	{
		string activeSearchingPlaylist = GetActiveSearchingPlaylist()
		if ( activeSearchingPlaylist != "" && !CanPlaylistFitMyParty( activeSearchingPlaylist ) )
		{
			CancelMatchSearch()

			DialogData dialogData
			dialogData.header = "#MATCHMAKING_CANCELED"
			dialogData.message = "#MATCHMAKING_CANCELED_REASON_PARTY_SIZE"
			AddDialogButton( dialogData, "#OK" )

			OpenDialog( dialogData )
		}
	}
}


void function HACK_DelayedSetFocus_BecauseWhy( var item )
{
	wait 0.1
	if ( IsValid( item ) )
		Hud_SetFocused( item )
}

void function ClassicMusic_OnChange( var button )
{
	bool isEnabled = GetConVarBool( "sound_classic_music" )

	if ( IsFullyConnected() && IsMultiplayer() && GetUIPlayer() )
	{
		if ( IsItemLocked( GetUIPlayer(), "classic_music" ) )
			SetConVarBool( "sound_classic_music", false )

		if ( IsLobby() )
			thread RunClientScript( "OnSoundClassicMusicChanged" )
	}
}

bool function IsClassicMusicAvailable()
{
	bool classicMusicAvailable = false
	if ( IsFullyConnected() && IsMultiplayer() && GetUIPlayer() )
		classicMusicAvailable = !IsItemLocked( GetUIPlayer(), "classic_music" )

	return classicMusicAvailable
}

void function UICodeCallback_KeyBindOverwritten( string key, string oldbinding, string newbinding )
{
	DialogData dialogData
	dialogData.header = Localize( "#MENU_KEYBIND_WAS_BEING_USED", key )
	dialogData.message = Localize( "#MENU_KEYBIND_WAS_BEING_USED_SUB", key, Localize( oldbinding ) )

	AddDialogButton( dialogData, "#OK" )

	OpenDialog( dialogData )
}
