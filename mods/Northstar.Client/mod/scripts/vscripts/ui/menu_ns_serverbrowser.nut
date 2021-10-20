global function AddNorthstarServerBrowserMenu
global function ThreadedAuthAndConnectToServer

const int BUTTONS_PER_PAGE = 15

struct {
	int page = 0
	int lastSelectedServer = 0
} file

void function AddNorthstarServerBrowserMenu()
{
	AddMenu( "ServerBrowserMenu", $"resource/ui/menus/server_browser.menu", InitServerBrowserMenu, "#MENU_SERVER_BROWSER" )
}

void function InitServerBrowserMenu()
{
	AddMenuEventHandler( GetMenu( "ServerBrowserMenu" ), eUIEvent.MENU_OPEN, OnServerBrowserMenuOpened )
	AddMenuFooterOption( GetMenu( "ServerBrowserMenu" ), BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
	AddMenuFooterOption( GetMenu( "ServerBrowserMenu" ), BUTTON_Y, "#Y_REFRESH_SERVERS", "#REFRESH_SERVERS", RefreshServers )
	
	foreach ( var button in GetElementsByClassname( GetMenu( "ServerBrowserMenu" ), "ServerButton" ) )
	{
		AddButtonEventHandler( button, UIE_GET_FOCUS, OnServerFocused )
		AddButtonEventHandler( button, UIE_CLICK, OnServerSelected )
	}
}

void function OnServerBrowserMenuOpened()
{
	Hud_SetText( Hud_GetChild( GetMenu( "ServerBrowserMenu" ), "Title" ), "#MENU_TITLE_SERVER_BROWSER" )
	UI_SetPresentationType( ePresentationType.KNOWLEDGEBASE_MAIN )
	
	file.page = 0
	// dont rerequest if we came from the connect menu
	if ( !NSIsRequestingServerList() && uiGlobal.lastMenuNavDirection != MENU_NAV_BACK )
	{
		NSClearRecievedServerList()
		NSRequestServerList()
	}
	
	thread WaitForServerListRequest()
}

void function RefreshServers( var button )
{
	if ( NSIsRequestingServerList() )
		return
	
	NSClearRecievedServerList()
	NSRequestServerList()
	
	thread WaitForServerListRequest()
}

void function WaitForServerListRequest()
{
	var menu = GetMenu( "ServerBrowserMenu" )
	array<var> serverButtons = GetElementsByClassname( menu, "ServerButton" )
	foreach ( var button in serverButtons )
	{
		Hud_SetEnabled( button, false )
		Hud_SetVisible( button, false )
	}
		
	Hud_SetVisible( Hud_GetChild( menu, "LabelDetails" ), false )
	Hud_SetVisible( Hud_GetChild( menu, "NextMapImage" ), false )
	Hud_SetVisible( Hud_GetChild( menu, "NextMapName" ), false )
	Hud_SetVisible( Hud_GetChild( menu, "NextModeIcon" ), false )
	Hud_SetVisible( Hud_GetChild( menu, "NextGameModeName" ), false )
		
	Hud_SetEnabled( serverButtons[ 0 ], true )
	Hud_SetVisible( serverButtons[ 0 ], true )
	
	SetButtonRuiText( serverButtons[ 0 ], "#NS_SERVERBROWSER_WAITINGFORSERVERS" )
	
	// wait for request to complete
	while ( NSIsRequestingServerList() )
		WaitFrame()
	
	if ( !NSMasterServerConnectionSuccessful() )
		SetButtonRuiText( serverButtons[ 0 ], "#NS_SERVERBROWSER_CONNECTIONFAILED" )
	else
		UpdateShownPage()
}

void function UpdateShownPage()
{
	var menu = GetMenu( "ServerBrowserMenu" )

	// hide old ui elements
	array<var> serverButtons = GetElementsByClassname( menu, "ServerButton" )
	foreach ( var button in serverButtons )
	{
		Hud_SetEnabled( button, false )
		Hud_SetVisible( button, false )
	}
	
	Hud_SetFocused( serverButtons[ serverButtons.len() - 1 ] )
	
	Hud_SetVisible( Hud_GetChild( menu, "LabelDetails" ), false )
	Hud_SetVisible( Hud_GetChild( menu, "NextMapImage" ), false )
	Hud_SetVisible( Hud_GetChild( menu, "NextMapName" ), false )
	Hud_SetVisible( Hud_GetChild( menu, "NextModeIcon" ), false )
	Hud_SetVisible( Hud_GetChild( menu, "NextGameModeName" ), false )
	
	for ( int i = 0; i < NSGetServerCount() && i < serverButtons.len(); i++ )
	{
		int serverIndex = file.page * BUTTONS_PER_PAGE + i
		
		Hud_SetEnabled( serverButtons[ i ], true )
		Hud_SetVisible( serverButtons[ i ], true )
		SetButtonRuiText( serverButtons[ i ], NSGetServerName( serverIndex ) )
	}
	
	if ( NSGetServerCount() == 0 )
	{
		Hud_SetEnabled( serverButtons[ 0 ], true )
		Hud_SetVisible( serverButtons[ 0 ], true )
		SetButtonRuiText( serverButtons[ 0 ], "#NS_SERVERBROWSER_NOSERVERS" )
	}
}

void function OnServerFocused( var button )
{
	if ( NSIsRequestingServerList() || !NSMasterServerConnectionSuccessful() || NSGetServerCount() == 0 )
		return

	var menu = GetMenu( "ServerBrowserMenu" )
	int serverIndex = file.page * BUTTONS_PER_PAGE + int ( Hud_GetScriptID( button ) )

	// text panel
	Hud_SetVisible( Hud_GetChild( menu, "LabelDetails" ), true )
	var textRui = Hud_GetRui( Hud_GetChild( menu, "LabelDetails" ) )
	RuiSetGameTime( textRui, "startTime", -99999.99 ) // make sure it skips the whole animation for showing this
	RuiSetString( textRui, "messageText", FormatServerDescription( serverIndex ) )

	// map name/image
	string map = NSGetServerMap( serverIndex )
	Hud_SetVisible( Hud_GetChild( menu, "NextMapImage" ), true )
	RuiSetImage( Hud_GetRui( Hud_GetChild( menu, "NextMapImage" ) ), "basicImage", GetMapImageForMapName( map ) )
	Hud_SetVisible( Hud_GetChild( menu, "NextMapName" ), true )
	Hud_SetText( Hud_GetChild( menu, "NextMapName" ), GetMapDisplayName( map ) )

	// mode name/image
	string mode = NSGetServerPlaylist( serverIndex )
	Hud_SetVisible( Hud_GetChild( menu, "NextModeIcon" ), true )
	RuiSetImage( Hud_GetRui( Hud_GetChild( menu, "NextModeIcon" ) ), "basicImage", GetPlaylistThumbnailImage( mode ) )
	Hud_SetVisible( Hud_GetChild( menu, "NextGameModeName" ), true )
	
	string displayName = GetGameModeDisplayName( mode )
	if ( displayName.len() != 0 )
		Hud_SetText( Hud_GetChild( menu, "NextGameModeName" ), displayName )
	else
		Hud_SetText( Hud_GetChild( menu, "NextGameModeName" ), "#NS_SERVERBROWSER_UNKNOWNMODE" )
}

string function FormatServerDescription( int server )
{
	string ret = "\n\n\n\n"
	
	ret += NSGetServerName( server ) + "\n"
	ret += format( "%i/%i players\n", NSGetServerPlayerCount( server ), NSGetServerMaxPlayerCount( server ) )
	ret += NSGetServerDescription( server ) + "\n\n"
	
	ret += "Required Mods: \n"
	for ( int i = 0; i < NSGetServerRequiredModsCount( server ); i++ )
		ret += "    " + NSGetServerRequiredModName( server, i ) + " v" + NSGetServerRequiredModVersion( server, i ) + "\n"
	
	return ret
}

void function OnServerSelected( var button )
{
	if ( NSIsRequestingServerList() || !NSMasterServerConnectionSuccessful() )
		return

	int server = int( Hud_GetScriptID( button ) )

	// check mods
	for ( int i = 0; i < NSGetServerRequiredModsCount( server ); i++ ) 
	{	
		if ( !NSGetModNames().contains( NSGetServerRequiredModName( server, i ) ) )
		{		
			DialogData dialogData
			dialogData.header = "#ERROR"
			dialogData.message = "Missing mod \"" + NSGetServerRequiredModName( server, i ) + "\" v" + NSGetServerRequiredModVersion( server, i )
			dialogData.image = $"ui/menu/common/dialog_error"
		
			#if PC_PROG
				AddDialogButton( dialogData, "#DISMISS" )
			
				AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )
			#endif // PC_PROG
			AddDialogFooter( dialogData, "#B_BUTTON_DISMISS_RUI" )
	
			OpenDialog( dialogData )
			
			return
		}
		else
		{
			string modVersion = NSGetServerRequiredModVersion( server, i )
			// check this is sorta valid semver, d
		}
	}
		
	var menu = GetMenu( "ServerBrowserMenu" )
	int serverIndex = file.page * BUTTONS_PER_PAGE + int ( Hud_GetScriptID( button ) )
	
	file.lastSelectedServer = serverIndex
	
	if ( NSServerRequiresPassword( serverIndex ) )
		AdvanceMenu( GetMenu( "ConnectWithPasswordMenu" ) )
	else
		thread ThreadedAuthAndConnectToServer()
}

void function ThreadedAuthAndConnectToServer( string password = "" )
{
	if ( NSIsAuthenticatingWithServer() )
		return

	print( "trying to authenticate with server " + NSGetServerName( file.lastSelectedServer ) + " with password " + password )
	NSTryAuthWithServer( file.lastSelectedServer, password )
	
	while ( NSIsAuthenticatingWithServer() )
		WaitFrame()
	
	if ( NSWasAuthSuccessful() )
	{
		array<string> requiredMods
		for ( int i = 0; i < NSGetServerRequiredModsCount( file.lastSelectedServer ); i++ )
			requiredMods.append( NSGetServerRequiredModName( file.lastSelectedServer, i ) )
	
		// unload mods we don't need, load necessary ones and reload mods before connecting
		foreach ( string mod in NSGetModNames() )
			if ( NSIsModRequiredOnClient( mod ) )
				NSSetModEnabled( mod, requiredMods.contains( mod ) )
			
		ReloadMods()
		
		NSConnectToAuthedServer()
	}
	else
	{	
		DialogData dialogData
		dialogData.header = "#ERROR"
		dialogData.message = "Authentication Failed"
		dialogData.image = $"ui/menu/common/dialog_error"
	
		#if PC_PROG
			AddDialogButton( dialogData, "#DISMISS" )
		
			AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )
		#endif // PC_PROG
		AddDialogFooter( dialogData, "#B_BUTTON_DISMISS_RUI" )

		OpenDialog( dialogData )
	}
}	