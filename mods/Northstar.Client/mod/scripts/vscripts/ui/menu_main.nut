global function InitMainMenu
global function EULA_Dialog
global function UpdateDataCenterFooter
global function LaunchGamePurchase
global function SP_Trial_LaunchGamePurchase
global function LaunchSPNew
global function LaunchSPContinue
global function LaunchSPMissionSelect
global function LaunchMP
global function LaunchGame
global function LaunchSPTrialMission
global function GetUserSignInState
global function NorthstarMasterServerAuthDialog

struct
{
	var menu
	var versionDisplay
	var trialLabel
} file

global const int NS_NOT_DECIDED_TO_SEND_TOKEN = 0
global const int NS_AGREED_TO_SEND_TOKEN = 1
global const int NS_DISAGREED_TO_SEND_TOKEN = 2

void function InitMainMenu()
{
	RegisterSignal( "EndOnMainMenu_Open" )

	var menu = GetMenu( "MainMenu" )
	file.menu = menu

	ClientCommand( "exec autoexec_ns_client" )
	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnMainMenu_Open )
	AddMenuEventHandler( menu, eUIEvent.MENU_NAVIGATE_BACK, OnMainMenu_NavigateBack )

	var titleRui = Hud_GetRui( Hud_GetChild( file.menu, "TitleRui" ) )
	RuiSetImage( titleRui, "basicImage", $"rui/menu/main_menu/title")

	file.versionDisplay = Hud_GetChild( menu, "versionDisplay" )
	file.trialLabel = Hud_GetChild( menu, "TrialLabel" )

	#if CONSOLE_PROG
		AddMenuFooterOption( menu, BUTTON_A, "#A_BUTTON_SELECT", "", null, IsConsoleSignedIn )
		#if DURANGO_PROG
			AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_SWITCH_PROFILE", "", null, IsConsoleSignedIn )
		#endif // DURANGO_PROG

		AddMenuVarChangeHandler( "CONSOLE_isSignedIn", UpdateFooterOptions )
	#endif // CONSOLE_PROG

	#if PC_PROG
		AddMenuFooterOption( menu, BUTTON_A, "#A_BUTTON_SELECT", "" )
	#endif // PC_PROG

	AddMenuFooterOption( menu, BUTTON_X, "#X_BUTTON_INBOX_ACCEPT", "#INBOX_ACCEPT", OpenDataCenterDialog, IsDataCenterFooterValid, UpdateDataCenterFooter )

#if DEV
	if ( DevStartPoints() )
		AddMenuFooterOption( menu, BUTTON_SHOULDER_LEFT, "#Y_BUTTON_DEV_MENU", "#DEV_MENU", OpenSinglePlayerDevMenu )
#endif // DEV
}

#if CONSOLE_PROG
	bool function IsConsoleSignedIn()
	{
		return ( GetMenuVarBool( "CONSOLE_isSignedIn" ) )
	}
#endif // CONSOLE_PROG

void function OnMainMenu_Open()
{
	Signal( uiGlobal.signalDummy, "EndOnMainMenu_Open" )
	EndSignal( uiGlobal.signalDummy, "EndOnMainMenu_Open" )

	SetConVarString( "communities_hostname", "" ) // disable communities due to crash exploits that are still possible through it

	UpdatePromoData() // On script restarts this gives us the last data until the new request is complete
	RequestMainMenuPromos() // This will be ignored if there was a recent request. "infoblock_requestInterval"

	TryUnlockCollectiblesAchievement()
	TryUnlockCompletedGameAchievements()

	Hud_SetText( file.versionDisplay, GetPublicGameVersion() )
	Hud_Show( file.versionDisplay )

	thread UpdateTrialLabel()

	// do +map stuff
	if ( Dev_CommandLineHasParm( "+map" ) )
	{
		SetConVarBool( "ns_auth_allow_insecure", true ) // good for testing
		ClientCommand( "map " + Dev_CommandLineParmValue( "+map" ) )
		Dev_CommandLineRemoveParm( "+map" )
	}

	// do agree to ns remote auth dialog
	if ( !GetConVarBool( "ns_has_agreed_to_send_token" ) )
		NorthstarMasterServerAuthDialog()

#if PC_PROG
	ActivatePanel( GetPanel( "MainMenuPanel" ) )
	return
#endif // PC_PROG

	int state
	int lastState = -1
	var panel
	var lastPanel

	while ( GetTopNonDialogMenu() == file.menu )
	{
		state = GetUserSignInState()

		if ( state != lastState )
		{
			if ( state == userSignInState.SIGNED_IN )
				panel = GetPanel( "MainMenuPanel" )
			else
				panel = GetPanel( "EstablishUserPanel" )

			if ( panel != lastPanel )
			{
				ActivatePanel( panel )
				lastPanel = panel
			}
		}

		lastState = state

		WaitFrame()
	}
}

void function NorthstarMasterServerAuthDialog()
{
	// todo: this should be in localisation
	DialogData dialogData
	dialogData.header = "#DIALOG_TITLE_INSTALLED_NORTHSTAR"
	dialogData.image = $"rui/menu/fd_menu/upgrade_northstar_chassis"
	dialogData.message = "#AUTHENTICATION_AGREEMENT_DIALOG_TEXT"
	AddDialogButton( dialogData, "#YES", NorthstarMasterServerAuthDialogAgree )
	AddDialogButton( dialogData, "#NO", NorthstarMasterServerAuthDialogDisagree )
	OpenDialog( dialogData )
}

void function NorthstarMasterServerAuthDialogAgree()
{
	int oldValue = GetConVarInt( "ns_has_agreed_to_send_token" )
	SetConVarInt( "ns_has_agreed_to_send_token", NS_AGREED_TO_SEND_TOKEN )

	if ( oldValue != 0 && oldValue != NS_AGREED_TO_SEND_TOKEN )
	{
		DialogData dialogData
		dialogData.header = "#DIALOG_TITLE_INSTALLED_NORTHSTAR"
		dialogData.image = $"rui/menu/fd_menu/upgrade_northstar_chassis"
		dialogData.message = "#AUTHENTICATION_AGREEMENT_RESTART"
		AddDialogButton( dialogData, "#OK" )
		OpenDialog( dialogData )
	}
}

void function NorthstarMasterServerAuthDialogDisagree()
{
	int oldValue = GetConVarInt( "ns_has_agreed_to_send_token" )
	SetConVarInt( "ns_has_agreed_to_send_token", NS_DISAGREED_TO_SEND_TOKEN )

	if ( oldValue != 0 && oldValue != NS_DISAGREED_TO_SEND_TOKEN )
	{
		DialogData dialogData
		dialogData.header = "#DIALOG_TITLE_INSTALLED_NORTHSTAR"
		dialogData.image = $"rui/menu/fd_menu/upgrade_northstar_chassis"
		dialogData.message = "#AUTHENTICATION_AGREEMENT_RESTART"
		AddDialogButton( dialogData, "#OK" )
		OpenDialog( dialogData )
	}
}

void function ActivatePanel( var panel )
{
	Assert( panel != null )

	array<var> elems = GetElementsByClassname( file.menu, "MainMenuPanelClass" )
	foreach ( elem in elems )
	{
		if ( elem != panel && Hud_IsVisible( elem ) )
			HidePanel( elem )
	}

	ShowPanel( panel )
}

void function OnMainMenu_NavigateBack()
{
#if DURANGO_PROG
	Durango_ShowAccountPicker()
#endif // DURANGO_PROG
}

int function GetUserSignInState()
{
#if DURANGO_PROG
	if ( Durango_InErrorScreen() )
	{
		return userSignInState.ERROR
	}
	else if ( Durango_IsSigningIn() )
	{
		return userSignInState.SIGNING_IN
	}
	else if ( !Console_IsSignedIn() && !Console_SkippedSignIn() )
	{
		//printt( "Console_IsSignedIn():", Console_IsSignedIn(), "Console_SkippedSignIn:", Console_SkippedSignIn() )
		return userSignInState.SIGNED_OUT
	}

	Assert( Console_IsSignedIn() || Console_SkippedSignIn() )
#endif
	return userSignInState.SIGNED_IN
}

void function UpdateDataCenterFooter( InputDef data )
{
	EndSignal( uiGlobal.signalDummy, "EndFooterUpdateFuncs" )

	int index = int( Hud_GetScriptID( data.vguiElem ) )
	int ping
	string name

	while ( data.conditionCheckFunc() )
	{
		ping = GetDatacenterPing()
		name = GetDatacenterName()

		if ( ping > 0 )
		{
			if ( IsControllerModeActive() )
				SetFooterText( file.menu, index, Localize( "#X_BUTTON_DATACENTER_INFO", name, ping ) )
			else
				SetFooterText( file.menu, index, Localize( "#DATACENTER_INFO", name, ping ) )
		}
		else
		{
			if ( IsControllerModeActive() )
				SetFooterText( file.menu, index, "#X_BUTTON_DATACENTER_CALCULATING" )
			else
				SetFooterText( file.menu, index, "#DATACENTER_CALCULATING" )
		}

		WaitFrame()
	}
}

bool function IsDataCenterFooterValid()
{
	#if PC_PROG
		return ( uiGlobal.activeMenu == file.menu )
	#else
		return ( uiGlobal.activeMenu == file.menu ) && Console_IsOnline() && Console_IsSignedIn()
	#endif
}

void function SP_Trial_LaunchGamePurchase()
{
	Disconnect()
	LaunchGamePurchase()
}

void function LaunchGamePurchase()
{
	ShowGamePurchaseStore()
}

void function LaunchSPNew()
{
	uiGlobal.launching = eLaunching.SINGLEPLAYER_NEW
	LaunchGame()
}

void function LaunchSPContinue()
{
	uiGlobal.launching = eLaunching.SINGLEPLAYER_CONTINUE
	LaunchGame()
}

void function LaunchSPMissionSelect()
{
	uiGlobal.launching = eLaunching.SINGLEPLAYER_MISSION_SELECT
	LaunchGame()
}

void function LaunchSPTrialMission()
{
	uiGlobal.launching = eLaunching.SINGLEPLAYER_MISSION_SELECT
	SPTrialMission_Start()
}

void function LaunchMP()
{
	uiGlobal.launching = eLaunching.MULTIPLAYER
	LaunchGame()
}

void function LaunchGame()
{
	Assert( uiGlobal.launching == eLaunching.SINGLEPLAYER_NEW ||
			uiGlobal.launching == eLaunching.SINGLEPLAYER_CONTINUE ||
			uiGlobal.launching == eLaunching.SINGLEPLAYER_MISSION_SELECT ||
			uiGlobal.launching == eLaunching.MULTIPLAYER ||
			uiGlobal.launching == eLaunching.MULTIPLAYER_INVITE )

	if ( uiGlobal.activeMenu == GetMenu( "PlayVideoMenu" ) )
	{
		SetVideoCompleteFunc( null )
		CloseActiveMenu()
	}

	if ( !IsGamePartiallyInstalled() )
	{
		DoGameNeedsToInstallDialog()
		return
	}

	// Because accepting an invite tries to launch the game we need this here
	if ( !IsGameFullyInstalled() )
	{
		printt( "Game is not fully installed." )

		if ( uiGlobal.launching == eLaunching.SINGLEPLAYER_CONTINUE )
		{
			string saveName = GetSaveName()
			string mapName = SaveGame_GetMapName( saveName )
			int startPointIndex = SaveGame_GetStartPoint( saveName )

			printt( mapName )
			printt( startPointIndex )

			bool isInTraining = (mapName == "sp_training" && startPointIndex < 5)  // "Titanfall" start point

			if ( !isInTraining )
			{
				DoGameNeedsToInstallDialog()
				return
			}

			printt( "Allowing 'continue' option to load into training." )
		}
		else if ( uiGlobal.launching != eLaunching.SINGLEPLAYER_NEW )
		{
			DoGameNeedsToInstallDialog()
			return
		}
	}

	#if CONSOLE_PROG
		if ( !Console_IsSignedIn() )
		{
			printt( "Not signed in." )
			return
		}

		if ( GetEULAVersionAccepted() < 1 ) // Treat as binary for now, as discussed with Preston.
		{
			if ( uiGlobal.activeMenu == GetMenu( "EULADialog" ) )
				return

			if ( IsDialog( uiGlobal.activeMenu ) )
				CloseActiveMenu( true )

			EULA_Dialog()
			return
		}

		if ( Nucleus_GetState() == NUCLEUS_STATE_INACTIVE )
			Nucleus_Login()

		if ( !uiGlobal.triedNucleusRegistration && uiGlobal.launching == eLaunching.MULTIPLAYER && !Nucleus_GetSkipRegistration() )
		{
			uiGlobal.triedNucleusRegistration = true
			thread Nucleus_HandleLoginResponse()
			return
		}

		if ( !GetConVarBool( "gamma_adjusted" ) )
		{
			if ( IsDialog( uiGlobal.activeMenu ) )
				CloseActiveMenu( true )

			AdvanceMenu( GetMenu( "GammaMenu" ) )
			return
		}
	#endif // CONSOLE_PROG

	if ( ( uiGlobal.launching == eLaunching.MULTIPLAYER || uiGlobal.launching == eLaunching.MULTIPLAYER_INVITE ) && !IsAdvocateGiftComplete() )
	{
		if ( IsDialog( uiGlobal.activeMenu ) )
			CloseActiveMenu( true )

		AdvanceMenu( GetMenu( "AdvocateGiftDialog" ) )
		return
	}

	SetMenuWasMultiplayerPlayedLast( true )
	if ( uiGlobal.launching == eLaunching.SINGLEPLAYER_NEW )
		NewGameSelected()
	else if ( uiGlobal.launching == eLaunching.SINGLEPLAYER_CONTINUE )
		LoadLastCheckpoint()
	else if ( uiGlobal.launching == eLaunching.SINGLEPLAYER_MISSION_SELECT )
		AdvanceMenu( GetMenu( "SinglePlayerMenu" ) )
	else
		thread StartSearchForPartyServer()

	uiGlobal.launching = eLaunching.FALSE
}

void function StartSearchForPartyServer()
{
	printt( "StartSearchForPartyServer" )

#if DURANGO_PROG
		// IMPORTANT: As a safety measure leave any party view we are in at this point.
		// Otherwise, if you are unlucky enough to get stuck in a party view, you will
		// trash its state by pointing it to your private lobby.
		Durango_LeaveParty()

		// IMPORTANT: It's possible that you have permission to play multiplayer
		// because your friend is signed in with his gold account on your machine,
		// but once that guy signs out, you shouldn't be able to play like you have
		// xboxlive gold anymore. To fix this, we need to check permissions periodically.
		// One of the places where we do this periodic check is when you press "PLAY"
		printt( "Durango - verifying MP permissions" )
		if ( !Console_HasPermissionToPlayMultiplayer() )
			Durango_VerifyMultiplayerPermissions()
#endif // DURANGO_PROG

	Signal( uiGlobal.signalDummy, "OnCancelConnect" )
	EndSignal( uiGlobal.signalDummy, "OnCancelConnect" )

	if ( IsDialog( uiGlobal.activeMenu ) )
		CloseActiveMenu( true )
	OpenConnectingDialog()

	Hud_SetText( uiGlobal.ConfirmMenuMessage, "" )
	Hud_SetText( uiGlobal.ConfirmMenuErrorCode, "" )

	Hud_Show( uiGlobal.ConfirmMenuMessage )
	Hud_Show( uiGlobal.ConfirmMenuErrorCode )

#if DURANGO_PROG
		if( !Console_IsOnline() )
		{
			printt( "Durango - finding empty party server failed - not online" )
			Hud_SetText( uiGlobal.ConfirmMenuMessage, "#DURANGO_NOT_ONLINE" )
			return
		}
#endif // DURANGO_PROG

#if PS4_PROG
		if(  !Console_IsOnline() )
		{
			printt( "PS4 - finding empty party server failed - not online" )
			Hud_SetText( uiGlobal.ConfirmMenuMessage, "#INTERNET_NOT_FOUND" )
			return
		}

		if ( PS4_isNetworkingDown() )
		{
			printt( "PS4 - finding empty party server failed - networking is down" )
			Hud_SetText( uiGlobal.ConfirmMenuMessage, "#PSN_CANNOT_CONNECT" )
			return
		}

		if(  !PS4_isUserNetworkingEnabled() )
		{
			Hud_SetText( uiGlobal.ConfirmMenuMessage, "#PSN_CHECKING_USABILITY" )
			PS4_ScheduleUserNetworkingEnabledTest()
			WaitFrame()

			if( !PS4_isUserNetworkingResolved() )
			{
				printt( "PS4 - finding empty party server stalled - networking isn't resolved yet" )
				// offer cancel ??
				while( !PS4_isUserNetworkingResolved())
					WaitFrame()
			}

			if( PS4_getUserNetworkingResolution() == PS4_NETWORK_STATUS_NOT_LOGGED_IN )
			{
  				Hud_SetText( uiGlobal.ConfirmMenuErrorCode, string(PS4_getUserNetworkingErrorStatus()) )
				Hud_SetText( uiGlobal.ConfirmMenuMessage, "#PSN_LOGIN" )

				Ps4_LoginDialog_Schedule()
				while( Ps4_LoginDialog_Running() )
					WaitFrame()

				PS4_ScheduleUserNetworkingEnabledTest()
				WaitFrame()
				if( !PS4_isUserNetworkingResolved() )
				{
					Hud_SetText( uiGlobal.ConfirmMenuErrorCode, "" )
					Hud_SetText( uiGlobal.ConfirmMenuMessage, "#PSN_CHECKING_USABILITY" )
					while( !PS4_isUserNetworkingResolved())
						WaitFrame()
				}
			}

			if( PS4_getUserNetworkingResolution() == PS4_NETWORK_STATUS_AGE_RESTRICTION )
			{
  		        Hud_SetText( uiGlobal.ConfirmMenuErrorCode, string(PS4_getUserNetworkingErrorStatus()) )
				Hud_SetText( uiGlobal.ConfirmMenuMessage, "#MULTIPLAYER_AGE_RESTRICTED" )
				return
			}

			if( PS4_getUserNetworkingResolution() == PS4_NETWORK_STATUS_IN_ERROR )
			{
  		        Hud_SetText( uiGlobal.ConfirmMenuErrorCode, string(PS4_getUserNetworkingErrorStatus()) )
				Hud_SetText( uiGlobal.ConfirmMenuMessage, "#PSN_HAD_ERROR" )
				return
			}

			if(  !PS4_isUserNetworkingEnabled() )
			{
				Hud_SetText( uiGlobal.ConfirmMenuErrorCode, string(PS4_getUserNetworkingErrorStatus()) )
				Hud_SetText( uiGlobal.ConfirmMenuMessage, "#PSN_NOT_ALLOWED" )
				return
   			}

			Hud_SetText( uiGlobal.ConfirmMenuErrorCode, "" )
			Hud_SetText( uiGlobal.ConfirmMenuMessage, "" )
		}

		if ( !Ps4_PSN_Is_Loggedin() )
		{
			Ps4_LoginDialog_Schedule()
			Hud_SetText( uiGlobal.ConfirmMenuMessage, "#PSN_LOGIN" )

			while( Ps4_LoginDialog_Running() )
				WaitFrame()

			if ( !Ps4_PSN_Is_Loggedin() )
				return
		}

		if( Ps4_CheckPlus_Schedule() )
		{
			while( Ps4_CheckPlus_Running() )
				WaitFrame()
			if( !Ps4_CheckPlus_Allowed() )
			{
				if( Ps4_CheckPlus_GetLastRequestResults() != 0 )
				{
  					Hud_SetText( uiGlobal.ConfirmMenuErrorCode, string( Ps4_CheckPlus_GetLastRequestResults()) )
					Hud_SetText( uiGlobal.ConfirmMenuMessage, "#PSN_HAD_ERROR" )
					return
				}

				if( Ps4_ScreenPlusDialog_Schedule() )
				{
					while( Ps4_ScreenPlusDialog_Running() )
						WaitFrame()
					if( !Ps4_ScreenPlusDialog_Allowed() )
					{
						Hud_SetText( uiGlobal.ConfirmMenuMessage, "#PSN_MUST_BE_PLUS_USER" )
						return
					}
				}
				else
				{
  					return
				}
			}
		}

        Hud_SetText( uiGlobal.ConfirmMenuErrorCode, "" )
		Hud_SetText( uiGlobal.ConfirmMenuMessage, "" )
#endif // #if PS4_PROG

	printt( "Checking if this user has permission to play MP\n" )
	if ( !Console_HasPermissionToPlayMultiplayer() )
	{
		Hud_SetText( uiGlobal.ConfirmMenuMessage, "#MULTIPLAYER_NOT_AVAILABLE" )
		return
	}

	Plat_ShowUGCRestrictionNotice()
	while ( Plat_IsSystemMessageDialogOpen() )
		WaitFrame()

	Plat_ShowChatRestrictionNotice()
	while ( Plat_IsSystemMessageDialogOpen() )
		WaitFrame()

#if PC_PROG
		if ( Origin_IsEnabled() )
		{
			Origin_RequestTicket()
			Hud_SetText( uiGlobal.ConfirmMenuMessage, "#WAITING_FOR_ORIGIN" )

			while ( !Origin_IsReady() )
				WaitFrame()
		}
#endif // PC_PROG

	printt( "SearchForPartyServer" )
	SetMenuWasMultiplayerPlayedLast( true )
	SearchForPartyServer()

	Hud_SetAutoText( uiGlobal.ConfirmMenuMessage, "", HATT_MATCHMAKING_EMPTY_SERVER_SEARCH_STATE, 0 )
	Hud_SetAutoText( uiGlobal.ConfirmMenuErrorCode, "", HATT_MATCHMAKING_EMPTY_SERVER_SEARCH_ERROR, 0 )
}

void function EULA_Dialog()
{
	if ( GetUserSignInState() != userSignInState.SIGNED_IN  )
		return

	if ( GetEULAVersionAccepted() >= 1 )
		return

	AdvanceMenu( GetMenu( "EULADialog" ) )
}

void function DoGameNeedsToInstallDialog()
{
	DialogData dialogData
	dialogData.header = "#MENU_WAIT_FOR_INTALL"

	int installProgress = int( GetGameFullyInstalledProgress()*100 )

	if ( uiGlobal.launching == eLaunching.MULTIPLAYER && IsGamePartiallyInstalled() && !Script_IsRunningTrialVersion() )
	{
		dialogData.message = Localize("#MENU_WAIT_FOR_INTALL_HINT", installProgress )
		AddDialogButton( dialogData, "#YES", LaunchSPNew )
		AddDialogButton( dialogData, "#NO" )
	}
	else
	{
		dialogData.message = Localize("#MENU_WAIT_FOR_INTALL_HINT_NOTRAINING", installProgress )
		AddDialogButton( dialogData, "#OK" )
	}

	AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )
	AddDialogFooter( dialogData, "#B_BUTTON_CANCEL" )

	OpenDialog( dialogData )
}

void function UpdateTrialLabel()
{
	//bool isTrialVersion
	//bool lastIsTrialVersion = Script_IsRunningTrialVersion()

	Hud_SetColor( file.trialLabel, 101, 109, 207, 255 )
	Hud_SetText( file.trialLabel, "+ NORTHSTAR" )
	Hud_SetVisible( file.trialLabel, true )

	//while ( GetTopNonDialogMenu() == file.menu )
	//{
	//	isTrialVersion = Script_IsRunningTrialVersion()
	//
	//	if ( isTrialVersion != lastIsTrialVersion )
	//		Hud_SetVisible( file.trialLabel, isTrialVersion )
	//
	//	lastIsTrialVersion = isTrialVersion
	//
	//	WaitFrame()
	//}
}

void function OpenSinglePlayerDevMenu( var button )
{
	AdvanceMenu( GetMenu( "SinglePlayerDevMenu" ) )
}