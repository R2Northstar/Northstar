untyped
// Only way to get Hud_GetPos(sliderButton) working was to use untyped

global function AddNorthstarServerBrowserMenu
global function ThreadedAuthAndConnectToServer

global function AddConnectToServerCallback
global function RemoveConnectToServerCallback
global function TriggerConnectToServerCallbacks

// Stop peeking

const int BUTTONS_PER_PAGE = 15 // Number of servers we show
const float DOUBLE_CLICK_TIME_MS = 0.4 // Max time between clicks for double click registering 

// Stores mouse delta used for scroll bar
struct {
	int deltaX = 0
	int deltaY = 0
} mouseDeltaBuffer

// Filters
struct {
	bool hideFull = false
	bool hideEmpty = false
	bool hideProtected = false
	bool useSearch = false
	string searchTerm
	array<string> filterMaps
	string filterMap
	array<string> filterGamemodes
	string filterGamemode
} filterArguments


enum sortingBy
{
	NONE,
	DEFAULT,
	NAME,
	PLAYERS,
	MAP,
	GAMEMODE,
	REGION
}

// Column sort direction, only one of these can be aplied at once
struct {
	// true = alphabeticaly false = reverse
	bool serverName = true
	bool serverPlayers = true
	bool serverMap = true
	bool serverGamemode = true
	bool serverRegion = true
	// 0 = none; 1 = default; 2 = name; 3 = players; 4 = map; 5 = gamemode; 6 = region
	int sortingBy = 1
} filterDirection

struct serverStruct {
	int serverIndex
	bool serverProtected
	string serverName
	int serverPlayers
	int serverPlayersMax
	string serverMap
	string serverGamemode
	string serverRegion
}

struct {
	// UI state vars
	var menu
	int focusedServerIndex = 0
	int scrollOffset = 0
	bool serverListRequestFailed = false
	float serverSelectedTime = 0
	float serverSelectedTimeLast = 0
	int serverButtonFocusedID = 0
	bool shouldFocus = true
	bool cancelConnection = false
	
	// filtered array of servers
	array<serverStruct> serversArrayFiltered

	array<ServerInfo> filteredServers
	ServerInfo& focusedServer
	ServerInfo& lastSelectedServer
	
	// UI references
	array<var> serverButtons
	array<var> serversName
	array<var> playerCountLabels
	array<var> serversProtected
	array<var> serversMap
	array<var> serversGamemode
	array<var> serversRegion

	array< void functionref( ServerInfo ) > connectCallbacks
} file



bool function FloatsEqual( float arg1, float arg2, float epsilon )
{
	if ( fabs( arg1 - arg2 ) < epsilon ) return true
	
	return false
}


////////////////////////////
// Init
////////////////////////////
void function AddNorthstarServerBrowserMenu()
{
	AddMenu( "ServerBrowserMenu", $"resource/ui/menus/server_browser.menu", InitServerBrowserMenu, "#MENU_SERVER_BROWSER" )
}

void function UpdatePrivateMatchModesAndMaps()
{
	array<string> realMaps = [ "mp_lobby" ]
	realMaps.extend( GetPrivateMatchMaps() )

	foreach ( int enum_, string map in realMaps )
	{
		if ( filterArguments.filterMaps.find( map ) != -1 )
			continue

		filterArguments.filterMaps.append( map )

		string localized = GetMapDisplayName( map )
		Hud_DialogList_AddListItem( Hud_GetChild( file.menu, "SwtBtnSelectMap" ) , localized, string( enum_ + 1 ) )
	}

	array<string> realModes = [ "private_match" ]
	realModes.extend( GetPrivateMatchModes() )

	foreach( int enum_, string mode in realModes )
	{
		string localized = GetGameModeDisplayName( mode )
		if ( filterArguments.filterGamemodes.find( localized ) != -1 )
			continue

		filterArguments.filterGamemodes.append( localized )
		Hud_DialogList_AddListItem( Hud_GetChild( file.menu, "SwtBtnSelectGamemode" ) , localized, string( enum_ + 1 ) )
	}
}

void function InitServerBrowserMenu()
{
	file.menu = GetMenu( "ServerBrowserMenu" )

	AddMouseMovementCaptureHandler( Hud_GetChild(file.menu, "MouseMovementCapture"), UpdateMouseDeltaBuffer )

	// Get menu stuff
	file.serverButtons = GetElementsByClassname( file.menu, "ServerButton" )
	file.serversName = GetElementsByClassname( file.menu, "ServerName" )
	file.playerCountLabels = GetElementsByClassname( file.menu, "PlayerCount" )
	file.serversProtected = GetElementsByClassname( file.menu, "ServerLock" )
	file.serversMap = GetElementsByClassname( file.menu, "ServerMap" )
	file.serversGamemode = GetElementsByClassname( file.menu, "ServerGamemode" )
	file.serversRegion = GetElementsByClassname( file.menu, "Serverregion" )

	filterArguments.filterMaps = [ "SWITCH_ANY" ]
	Hud_DialogList_AddListItem( Hud_GetChild( file.menu, "SwtBtnSelectMap" ), "SWITCH_ANY", "0" )

	filterArguments.filterGamemodes = [ "SWITCH_ANY" ]
	Hud_DialogList_AddListItem( Hud_GetChild( file.menu, "SwtBtnSelectGamemode" ), "SWITCH_ANY", "0" )

	// Event handlers
	AddMenuEventHandler( file.menu, eUIEvent.MENU_CLOSE, OnCloseServerBrowserMenu )
	AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, OnServerBrowserMenuOpened )
	AddMenuFooterOption( file.menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
	AddMenuFooterOption( file.menu, BUTTON_Y, PrependControllerPrompts( BUTTON_Y, "#REFRESH_SERVERS" ), "#REFRESH_SERVERS", RefreshServers )

	// Setup server buttons
	var width = 1120.0  * ( GetScreenSize()[1] / 1080.0 )
	foreach ( var button in GetElementsByClassname( file.menu, "ServerButton" ) )
	{
		AddButtonEventHandler( button, UIE_CLICK, OnServerButtonClicked )
		AddButtonEventHandler( button, UIE_GET_FOCUS, OnServerButtonFocused )
		Hud_SetWidth( button , width )
	}

	AddButtonEventHandler( Hud_GetChild( file.menu , "BtnServerDummmyTop" ), UIE_GET_FOCUS, OnHitDummyTop )
	AddButtonEventHandler( Hud_GetChild( file.menu , "BtnServerDummmyBottom" ), UIE_GET_FOCUS, OnHitDummyBottom )



	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnServerJoin"), UIE_CLICK, OnServerSelected )

	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnServerListUpArrow"), UIE_CLICK, OnUpArrowSelected )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnServerListDownArrow"), UIE_CLICK, OnDownArrowSelected )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnDummyAfterFilterClear"), UIE_GET_FOCUS, OnHitDummyAfterFilterClear )



	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnFiltersClear"), UIE_CLICK, OnBtnFiltersClear_Activate )


	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnServerNameTab"), UIE_CLICK, SortServerListByName_Activate )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnServerPlayersTab"), UIE_CLICK, SortServerListByPlayers_Activate )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnServerMapTab"), UIE_CLICK, SortServerListByMap_Activate )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnServerGamemodeTab"), UIE_CLICK, SortServerListByGamemode_Activate )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnServerRegionTab"), UIE_CLICK, SortServerListByRegion_Activate )


	AddButtonEventHandler( Hud_GetChild( file.menu, "SwtBtnSelectMap"), UIE_CHANGE, FilterAndUpdateList )
	AddButtonEventHandler( Hud_GetChild( file.menu, "SwtBtnSelectGamemode"), UIE_CHANGE, FilterAndUpdateList )
	AddButtonEventHandler( Hud_GetChild( file.menu, "SwtBtnHideFull"), UIE_CHANGE, FilterAndUpdateList )
	AddButtonEventHandler( Hud_GetChild( file.menu, "SwtBtnHideEmpty"), UIE_CHANGE, FilterAndUpdateList )
	AddButtonEventHandler( Hud_GetChild( file.menu, "SwtBtnHideProtected"), UIE_CHANGE, FilterAndUpdateList )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnSearchLabel"), UIE_CHANGE, FilterAndUpdateList )

	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnServerSearch"), UIE_CHANGE, FilterAndUpdateList )

	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnServerDescription"), UIE_CLICK, ShowServerDescription )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnServerMods"), UIE_CLICK, ShowServerMods )

	AddButtonEventHandler( Hud_GetChild( file.menu, "ConnectingButton"), UIE_CLICK, ConnectingButton_Activate )


	// Hidden cause no need, if server descriptions become too long use this
	Hud_SetEnabled( Hud_GetChild( file.menu, "BtnServerDescription"), false )
	Hud_SetEnabled( Hud_GetChild( file.menu, "BtnServerMods"), false )
	Hud_SetText( Hud_GetChild( file.menu, "BtnServerDescription"), "" )
	Hud_SetText( Hud_GetChild( file.menu, "BtnServerMods"), "" )


	// Rui is a pain
	RuiSetString( Hud_GetRui( Hud_GetChild( file.menu, "SwtBtnHideFull") ), "buttonText", "" )
	RuiSetString( Hud_GetRui( Hud_GetChild( file.menu, "SwtBtnHideEmpty") ), "buttonText", "" )
	RuiSetString( Hud_GetRui( Hud_GetChild( file.menu, "SwtBtnHideProtected") ), "buttonText", "" )
	RuiSetString( Hud_GetRui( Hud_GetChild( file.menu, "SwtBtnSelectMap") ), "buttonText", "" )
	RuiSetString( Hud_GetRui( Hud_GetChild( file.menu, "SwtBtnSelectGamemode") ), "buttonText", "" )


	ToggleConnectingHUD(false)

	// UI was cut off on some aspect ratios; not perfect
	UpdateServerInfoBasedOnRes()
}

////////////////////////////
// Slider
////////////////////////////
void function UpdateMouseDeltaBuffer( int x, int y )
{
	mouseDeltaBuffer.deltaX += x
	mouseDeltaBuffer.deltaY += y

	SliderBarUpdate()
}

void function FlushMouseDeltaBuffer()
{
	mouseDeltaBuffer.deltaX = 0
	mouseDeltaBuffer.deltaY = 0
}


void function SliderBarUpdate()
{
	if ( file.filteredServers.len() <= BUTTONS_PER_PAGE )
	{
		FlushMouseDeltaBuffer()
		return
	}

	var sliderButton = Hud_GetChild( file.menu , "BtnServerListSlider" )
	var sliderPanel = Hud_GetChild( file.menu , "BtnServerListSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu , "MouseMovementCapture" )

	Hud_SetFocused( sliderButton )

	float minYPos = -40.0 * ( GetScreenSize()[1] / 1080.0 )
	float maxHeight = 562.0  * ( GetScreenSize()[1] / 1080.0 )
	float maxYPos = minYPos - ( maxHeight - Hud_GetHeight( sliderPanel ) )
	float useableSpace = ( maxHeight - Hud_GetHeight( sliderPanel ) )

	float jump = minYPos - ( useableSpace / ( float( file.filteredServers.len() ) ) )

	// got local from official respaw scripts, without untyped throws an error
	local pos =	Hud_GetPos( sliderButton )[1]
	local newPos = pos - mouseDeltaBuffer.deltaY
	FlushMouseDeltaBuffer()

	if ( newPos < maxYPos ) newPos = maxYPos
	if ( newPos > minYPos ) newPos = minYPos

	Hud_SetPos( sliderButton , 2, newPos )
	Hud_SetPos( sliderPanel , 2, newPos )
	Hud_SetPos( movementCapture , 2, newPos )

	file.scrollOffset = -int( ( ( newPos - minYPos ) / useableSpace ) * ( file.filteredServers.len() - BUTTONS_PER_PAGE ) )
	UpdateShownPage()
}

void function UpdateListSliderHeight( float servers )
{
	var sliderButton = Hud_GetChild( file.menu , "BtnServerListSlider" )
	var sliderPanel = Hud_GetChild( file.menu , "BtnServerListSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu , "MouseMovementCapture" )

	float maxHeight = 562.0 * ( GetScreenSize()[1] / 1080.0 )
	float minHeight = 80.0 * ( GetScreenSize()[1] / 1080.0 )

	float height = maxHeight * ( BUTTONS_PER_PAGE / servers )

	if ( height > maxHeight ) height = maxHeight
	if ( height < minHeight ) height = minHeight

	Hud_SetHeight( sliderButton , height )
	Hud_SetHeight( sliderPanel , height )
	Hud_SetHeight( movementCapture , height )
}


void function UpdateListSliderPosition( int servers )
{
	var sliderButton = Hud_GetChild( file.menu , "BtnServerListSlider" )
	var sliderPanel = Hud_GetChild( file.menu , "BtnServerListSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu , "MouseMovementCapture" )

	float minYPos = -40.0 * ( GetScreenSize()[1] / 1080.0 )
	float useableSpace = (562.0 * ( GetScreenSize()[1] / 1080.0 ) - Hud_GetHeight( sliderPanel ) )

	float jump = minYPos - ( useableSpace / ( float( servers ) - BUTTONS_PER_PAGE ) * file.scrollOffset )

	if ( jump > minYPos ) jump = minYPos

	Hud_SetPos( sliderButton , 2, jump )
	Hud_SetPos( sliderPanel , 2, jump )
	Hud_SetPos( movementCapture , 2, jump )
}

void function OnScrollDown( var button )
{
	if (file.filteredServers.len() <= BUTTONS_PER_PAGE) return
	file.scrollOffset += 5
	if (file.scrollOffset + BUTTONS_PER_PAGE > file.filteredServers.len()) {
		file.scrollOffset = file.filteredServers.len() - BUTTONS_PER_PAGE
	}
	UpdateShownPage()
	UpdateListSliderPosition( file.filteredServers.len() )
}

void function OnScrollUp( var button )
{
	file.scrollOffset -= 5
	if ( file.scrollOffset < 0 ) {
		file.scrollOffset = 0
	}
	UpdateShownPage()
	UpdateListSliderPosition( file.filteredServers.len() )
}

////////////////////////////
// Connecting pop-up
////////////////////////////
void function ToggleConnectingHUD( bool vis )
{
	foreach (e in GetElementsByClassname( file.menu, "connectingHUD" ) ) {
		Hud_SetEnabled( e, vis )
		Hud_SetVisible( e, vis )
	}

	if ( vis ) Hud_SetFocused( Hud_GetChild( file.menu, "ConnectingButton" ) )
}

void function ConnectingButton_Activate( var button )
{
	file.cancelConnection = true
}

////////////////////////////
// Aspect ratio compensation
////////////////////////////
// No way to get aspect ratio sadly
// This doesn't werk on some obscure resolutions, mostly really small 4:3
void function UpdateServerInfoBasedOnRes()
{
	if ( FloatsEqual( float(GetScreenSize()[0] ) / float( GetScreenSize()[1] ) , 1.6, 0.07 ) ) // 16/10
	{
		Hud_SetWidth( Hud_GetChild(file.menu, "ServerName"), 392)
		Hud_SetWidth( Hud_GetChild(file.menu, "NextMapImage"), 400)
		Hud_SetWidth( Hud_GetChild(file.menu, "NextMapBack"), 400)
		Hud_SetWidth( Hud_GetChild(file.menu, "LabelMods"), 360)
		Hud_SetWidth( Hud_GetChild(file.menu, "LabelDescription"), 360)
		Hud_SetWidth( Hud_GetChild(file.menu, "ServerDetailsPanel"), 400)
	}
	if( FloatsEqual( float( GetScreenSize()[0] ) / float( GetScreenSize()[1] ) , 1.3, 0.055 ) ) // 4/3
	{
		Hud_SetWidth( Hud_GetChild(file.menu, "ServerName"), 292)
		Hud_SetWidth( Hud_GetChild(file.menu, "NextMapImage"), 300)
		Hud_SetWidth( Hud_GetChild(file.menu, "NextMapBack"), 300)
		Hud_SetWidth( Hud_GetChild(file.menu, "LabelMods"), 260)
		Hud_SetWidth( Hud_GetChild(file.menu, "LabelDescription"), 260)
		Hud_SetWidth( Hud_GetChild(file.menu, "ServerDetailsPanel"), 300)
	}
}

////////////////////////////
// Open/close callbacks
////////////////////////////
void function OnCloseServerBrowserMenu()
{
	try
	{
		DeregisterButtonPressedCallback( MOUSE_WHEEL_UP , OnScrollUp )
		DeregisterButtonPressedCallback( MOUSE_WHEEL_DOWN , OnScrollDown )
		DeregisterButtonPressedCallback( KEY_TAB , OnKeyTabPressed )
		DeregisterButtonPressedCallback( KEY_ENTER, OnEnterPressed )
		DeregisterButtonPressedCallback( KEY_R, OnKeyRPressed )
	}
	catch ( ex ) {}
}

void function OnServerBrowserMenuOpened()
{
	Hud_SetText( Hud_GetChild( file.menu, "InGamePlayerLabel" ), Localize( "#INGAME_PLAYERS", "0" ) )
	Hud_SetText( Hud_GetChild( file.menu, "TotalServerLabel" ),  Localize( "#TOTAL_SERVERS", "0" ) )
	UpdatePrivateMatchModesAndMaps()
	Hud_SetText( Hud_GetChild( file.menu, "Title" ), "#MENU_TITLE_SERVER_BROWSER" )
	UI_SetPresentationType( ePresentationType.KNOWLEDGEBASE_MAIN )

	file.scrollOffset = 0
	// dont rerequest if we came from the connect menu
	if ( !NSIsRequestingServerList() && uiGlobal.lastMenuNavDirection != MENU_NAV_BACK )
	{
		NSClearRecievedServerList()
		NSRequestServerList()
	}

	filterDirection.sortingBy = sortingBy.DEFAULT

	thread WaitForServerListRequest()


	RegisterButtonPressedCallback( MOUSE_WHEEL_UP , OnScrollUp )
	RegisterButtonPressedCallback( MOUSE_WHEEL_DOWN , OnScrollDown )
	RegisterButtonPressedCallback( KEY_TAB , OnKeyTabPressed )
	RegisterButtonPressedCallback( KEY_ENTER, OnEnterPressed )
	RegisterButtonPressedCallback( KEY_R, OnKeyRPressed )
}

////////////////////////////
// Arrow navigation fuckery
////////////////////////////
bool function IsFilterPanelElementFocused()
{
	// get name of focused element
	var focusedElement = GetFocus()

	foreach ( element in GetElementsByClassname( file.menu, "FilterPanelChild" ) )
	{
		if ( element == focusedElement ) return true
	}


	return false;
}

void function OnKeyTabPressed( var button )
{
	try
	{
		// toggle focus between server list and filter panel
		if ( IsFilterPanelElementFocused() )
		{
			Hud_SetFocused( Hud_GetChild( file.menu, "BtnServer1" ) )
		}
		else
		{
			Hud_SetFocused( Hud_GetChild( file.menu, "BtnServerSearch" ) )
			HideServerInfo()
		}
	}
	catch ( ex ) {}
}

void function OnHitDummyTop( var button )
{
	file.scrollOffset -= 1
	if ( file.scrollOffset < 0 )
	{
		// was at top already
		file.scrollOffset = 0
		Hud_SetFocused(Hud_GetChild(file.menu, "BtnServerNameTab"))
	}
	else 
	{
		// only update if list position changed
		UpdateShownPage()
		UpdateListSliderPosition( file.filteredServers.len() )
		DisplayFocusedServerInfo( file.serverButtonFocusedID )
		Hud_SetFocused( Hud_GetChild( file.menu, "BtnServer1" ) )
	}
}

void function OnHitDummyBottom( var button )
{
	file.scrollOffset += 1
	if ( file.scrollOffset + BUTTONS_PER_PAGE > file.filteredServers.len() )
	{
		// was at bottom already
		file.scrollOffset = file.filteredServers.len() - BUTTONS_PER_PAGE
		Hud_SetFocused( Hud_GetChild( file.menu, "BtnServerSearch" ) )
		HideServerInfo()
	}
	else
	{
		// only update if list position changed
		UpdateShownPage()
		UpdateListSliderPosition( file.filteredServers.len() )
		DisplayFocusedServerInfo( file.serverButtonFocusedID )
		Hud_SetFocused( Hud_GetChild( file.menu, "BtnServer15" ) )
	}
}

void function OnHitDummyAfterFilterClear( var button )
{
	Hud_SetFocused( Hud_GetChild( file.menu, "BtnServerNameTab" ) )
}


void function OnDownArrowSelected( var button )
{
	if ( file.filteredServers.len() <= BUTTONS_PER_PAGE ) return
	file.scrollOffset += 1
	if ( file.scrollOffset + BUTTONS_PER_PAGE > file.filteredServers.len() )
	{
		file.scrollOffset = file.filteredServers.len() - BUTTONS_PER_PAGE
	}
	
	UpdateShownPage()
	UpdateListSliderPosition( file.filteredServers.len() )
}


void function OnUpArrowSelected( var button )
{
	file.scrollOffset -= 1
	if ( file.scrollOffset < 0 )
	{
		file.scrollOffset = 0
	}
	
	UpdateShownPage()
	UpdateListSliderPosition( file.filteredServers.len() )
}

////////////////////////
// Key Callbacks
////////////////////////
void function OnEnterPressed( arg ) 
{
	// only trigger if a server is focused
	if ( IsServerButtonFocused() ) 
	{
		OnServerSelected(0)
	}
}

void function OnKeyRPressed( arg ) 
{
	if ( !IsSearchBarFocused() ) 
	{
		RefreshServers(0);
	}
}

bool function IsServerButtonFocused() 
{
	var focusedElement = GetFocus()
	if ( focusedElement == null )
		return false
	
	var name = Hud_GetHudName( focusedElement )

	foreach ( element in GetElementsByClassname( file.menu, "ServerButton" ) ) 
	{
		if ( element == focusedElement ) 
			return true
	}

	return false
}

bool function IsSearchBarFocused() 
{
	return Hud_GetChild( file.menu, "BtnServerSearch" ) == GetFocus()
}


////////////////////////////
// Unused
////////////////////////////
void function ShowServerDescription( var button )
{
	Hud_SetVisible( Hud_GetChild( file.menu, "LabelDescription" ), true )
	Hud_SetVisible( Hud_GetChild( file.menu, "LabelMods" ), false )
}

void function ShowServerMods( var button )
{
	Hud_SetVisible( Hud_GetChild( file.menu, "LabelDescription" ), false )
	Hud_SetVisible( Hud_GetChild( file.menu, "LabelMods" ), true )
}

////////////////////////////
// Server list; filter,update,...
////////////////////////////
void function HideServerInfo()
{
	Hud_SetVisible( Hud_GetChild( file.menu, "BtnServerDescription" ), false )
	Hud_SetVisible( Hud_GetChild( file.menu, "BtnServerMods" ), false )
	Hud_SetVisible( Hud_GetChild( file.menu, "BtnServerJoin" ), false )
	Hud_SetVisible( Hud_GetChild( file.menu, "LabelDescription" ), false )
	Hud_SetVisible( Hud_GetChild( file.menu, "LabelMods" ), false )
	Hud_SetVisible( Hud_GetChild( file.menu, "NextMapImage" ), false )
	Hud_SetVisible( Hud_GetChild( file.menu, "NextMapBack" ), false )
	Hud_SetVisible( Hud_GetChild( file.menu, "NextMapName" ), false )
	Hud_SetVisible( Hud_GetChild( file.menu, "ServerName" ), false )
	Hud_SetVisible( Hud_GetChild( file.menu, "NextModeIcon" ), false )
	Hud_SetVisible( Hud_GetChild( file.menu, "NextGameModeName" ), false )
}

void function OnBtnFiltersClear_Activate( var button )
{
	Hud_SetText( Hud_GetChild( file.menu, "BtnServerSearch" ), "" )

	SetConVarBool( "filter_hide_empty", false )
	SetConVarBool( "filter_hide_full", false )
	SetConVarBool( "filter_hide_protected", false )
	SetConVarInt( "filter_map", 0 )
	SetConVarInt( "filter_gamemode", 0 )

	FilterAndUpdateList(0)
}

void function FilterAndUpdateList( var n )
{
	filterArguments.searchTerm = Hud_GetUTF8Text( Hud_GetChild( file.menu, "BtnServerSearch" ) )
	if ( filterArguments.searchTerm == "" ) filterArguments.useSearch = false else filterArguments.useSearch = true
	filterArguments.filterMap = filterArguments.filterMaps[ GetConVarInt( "filter_map" ) ]
	filterArguments.filterGamemode = filterArguments.filterGamemodes[ GetConVarInt( "filter_gamemode" ) ]
	filterArguments.hideEmpty = GetConVarBool( "filter_hide_empty" )
	filterArguments.hideFull = GetConVarBool( "filter_hide_full" )
	filterArguments.hideProtected = GetConVarBool( "filter_hide_protected" )

	file.scrollOffset = 0
	UpdateListSliderPosition( file.filteredServers.len() )

	HideServerInfo()
	FilterServerList()


	switch ( filterDirection.sortingBy )
	{
		case sortingBy.NONE:
			UpdateShownPage()
			break
		case sortingBy.DEFAULT:
			filterDirection.serverName = !filterDirection.serverName
			SortServerListByDefault_Activate(0)
			break
		case sortingBy.NAME:
			filterDirection.serverName = !filterDirection.serverName
			SortServerListByName_Activate(0)
			break
		case sortingBy.PLAYERS:
			filterDirection.serverPlayers = !filterDirection.serverPlayers
			SortServerListByPlayers_Activate(0)
			break
		case sortingBy.MAP:
			filterDirection.serverMap = !filterDirection.serverMap
			SortServerListByMap_Activate(0)
			break
		case sortingBy.GAMEMODE:
			filterDirection.serverGamemode = !filterDirection.serverGamemode
			SortServerListByGamemode_Activate(0)
			break
		case sortingBy.REGION:
			filterDirection.serverRegion = !filterDirection.serverRegion
			SortServerListByRegion_Activate(0)
			break
		default:
			printt( "How the f did you get here" )
	}

	if ( file.shouldFocus )
	{
		file.shouldFocus = false
		Hud_SetFocused( Hud_GetChild( file.menu, "BtnServer1" ) )
	}
}


void function RefreshServers( var button )
{
	if ( NSIsRequestingServerList() )
		return

	file.serverListRequestFailed = false
	file.scrollOffset = 0
	NSClearRecievedServerList()
	NSRequestServerList()

	thread WaitForServerListRequest()
}


void function WaitForServerListRequest()
{
	for ( int i = 0; i < BUTTONS_PER_PAGE; i++)
	{
		Hud_SetVisible( file.serversProtected[ i ], false )
		Hud_SetVisible( file.serverButtons[ i ], false )
		Hud_SetText( file.serversName[ i ], "" )
		Hud_SetText( file.playerCountLabels[ i ], "" )
		Hud_SetText( file.serversMap[ i ], "" )
		Hud_SetText( file.serversGamemode[ i ], "" )
		Hud_SetText( file.serversRegion[ i ], "" )
	}

	HideServerInfo()

	Hud_SetVisible( file.serversName[ 0 ], true )
	Hud_SetText( file.serversName[ 0 ], "#NS_SERVERBROWSER_WAITINGFORSERVERS" )

	// wait for request to complete
	while ( NSIsRequestingServerList() )
		WaitFrame()

	file.serverListRequestFailed = !NSMasterServerConnectionSuccessful()
	if ( file.serverListRequestFailed )
	{
		Hud_SetText( file.serversName[ 0 ], "#NS_SERVERBROWSER_CONNECTIONFAILED" )
	}
	else
	{
		FilterAndUpdateList(0)
		Hud_SetFocused( Hud_GetChild(file.menu, "BtnServer1" ) )
	}
}



void function FilterServerList()
{
	file.filteredServers.clear()
	int totalPlayers = 0

	array<ServerInfo> servers = NSGetGameServers()

	foreach ( ServerInfo server in servers )
	{
		totalPlayers += server.playerCount

		// Filters
		if ( filterArguments.hideEmpty && server.playerCount == 0 )
			continue;
		
		if ( filterArguments.hideFull && server.playerCount == server.maxPlayerCount )
			continue;
		
		if ( filterArguments.hideProtected && server.requiresPassword )
			continue;
		
		if ( filterArguments.filterMap != "SWITCH_ANY" && filterArguments.filterMap != server.map )
			continue;
		
		if ( filterArguments.filterGamemode != "SWITCH_ANY" && filterArguments.filterGamemode != GetGameModeDisplayName(server.playlist) )
			continue;
	
		// Search
		if ( filterArguments.useSearch )
		{	
			array<string> sName
			sName.append( server.name.tolower() )
			sName.append( Localize( GetMapDisplayName( server.map ) ).tolower() )
			sName.append( server.map.tolower() )
			sName.append( server.playlist.tolower() )
			sName.append( Localize( server.playlist ).tolower() )
			sName.append( server.description.tolower() )
			sName.append( server.region.tolower() )

			string sTerm = filterArguments.searchTerm.tolower()
			
			bool found = false
			for( int j = 0; j < sName.len(); j++ )
			{
				if ( sName[j].find( sTerm ) != null )
					found = true
			}
			
			if ( !found )
				continue;
		}

		file.filteredServers.append( server )
	}
	
	// Update player and server count
	Hud_SetText( Hud_GetChild( file.menu, "InGamePlayerLabel" ), Localize("#INGAME_PLAYERS", string( totalPlayers ) ) )
	Hud_SetText( Hud_GetChild( file.menu, "TotalServerLabel" ),  Localize("#TOTAL_SERVERS", string( NSGetServerCount() ) ) )
}


void function UpdateShownPage()
{

	for ( int i = 0; i < BUTTONS_PER_PAGE; i++ )
	{
		Hud_SetVisible( file.serversProtected[ i ], false )
		Hud_SetVisible( file.serverButtons[ i ], false )
		Hud_SetText( file.serversName[ i ], "" )
		Hud_SetText( file.playerCountLabels[ i ], "" )
		Hud_SetText( file.serversMap[ i ], "" )
		Hud_SetText( file.serversGamemode[ i ], "" )
		Hud_SetText( file.serversRegion[ i ], "" )
	}

	int j = file.filteredServers.len() > BUTTONS_PER_PAGE ? BUTTONS_PER_PAGE : file.filteredServers.len()

	for ( int i = 0; i < j; i++ )
	{
		int buttonIndex = file.scrollOffset + i
		ServerInfo server = file.filteredServers[ buttonIndex ]

		Hud_SetEnabled( file.serverButtons[ i ], true )
		Hud_SetVisible( file.serverButtons[ i ], true )

		Hud_SetVisible( file.serversProtected[ i ], server.requiresPassword )
		Hud_SetText( file.serversName[ i ], server.name )
		Hud_SetText( file.playerCountLabels[ i ], format( "%i/%i", server.playerCount, server.maxPlayerCount ) )
		Hud_SetText( file.serversMap[ i ], GetMapDisplayName( server.map ) )
		Hud_SetText( file.serversGamemode[ i ], GetGameModeDisplayName( server.playlist ) )
		Hud_SetText( file.serversRegion[ i ], server.region )
	}


	if ( NSGetServerCount() == 0 )
	{
		Hud_SetEnabled( file.serverButtons[ 0 ], true )
		Hud_SetVisible( file.serverButtons[ 0 ], true )
		Hud_SetText( file.serversName[ 0 ], "#NS_SERVERBROWSER_NOSERVERS" )
	}
	UpdateListSliderHeight( float( file.filteredServers.len() ) )
}

void function OnServerButtonFocused( var button )
{
	if ( file.scrollOffset < 0 )
		file.scrollOffset = 0
	
	int scriptID = int ( Hud_GetScriptID( button ) )
	file.serverButtonFocusedID = scriptID
	if ( file.filteredServers.len() > 0 )
		// file.focusedServerIndex = file.filteredServers[ file.scrollOffset + scriptID ].serverIndex
		file.focusedServer = file.filteredServers[ file.scrollOffset + scriptID ]
	DisplayFocusedServerInfo( scriptID )

}

void function OnServerButtonClicked(var button)
{
	int scriptID = int ( Hud_GetScriptID( button ) )

	DisplayFocusedServerInfo( scriptID )
	CheckDoubleClick( scriptID, true )
}

void function CheckDoubleClick( int scriptID, bool wasClickNav )
{
	if ( NSGetServerCount() == 0 ) return


	int serverIndex = file.scrollOffset + scriptID

	bool sameServer = false
	if ( file.lastSelectedServer == file.filteredServers[ serverIndex ] ) sameServer = true

	file.serverSelectedTimeLast = file.serverSelectedTime
	file.serverSelectedTime = Time()

	file.lastSelectedServer = file.filteredServers[ serverIndex ]

	if ( wasClickNav && ( file.serverSelectedTime - file.serverSelectedTimeLast < DOUBLE_CLICK_TIME_MS ) && sameServer )
	{
		OnServerSelected(0)
	}
}

void function DisplayFocusedServerInfo( int scriptID )
{
	if ( scriptID == 999 || scriptID == -1 || scriptID == 16 ) return

	if ( NSIsRequestingServerList() || NSGetServerCount() == 0 || file.serverListRequestFailed || file.filteredServers.len() == 0 )
		return

	var menu = GetMenu( "ServerBrowserMenu" )

	int serverIndex = file.scrollOffset + scriptID
	if ( serverIndex < 0 ) serverIndex = 0

	ServerInfo server = file.filteredServers[ serverIndex ]

	Hud_SetVisible( Hud_GetChild( menu, "BtnServerDescription" ), true )
	Hud_SetVisible( Hud_GetChild( menu, "BtnServerMods" ), true )
	Hud_SetVisible( Hud_GetChild( menu, "BtnServerJoin" ), true )
	// text panels
	Hud_SetVisible( Hud_GetChild( menu, "LabelDescription" ), true )
	Hud_SetVisible( Hud_GetChild( menu, "LabelMods" ), false )
	Hud_SetText( Hud_GetChild( menu, "LabelDescription" ), server.description + "\n\nRequired Mods:\n" + FillInServerModsLabel( server.requiredMods ) )

	// map name/image/server name
	string map = server.map
	Hud_SetVisible( Hud_GetChild( menu, "NextMapImage" ), true )
	Hud_SetVisible( Hud_GetChild( menu, "NextMapBack" ), true )
	RuiSetImage( Hud_GetRui( Hud_GetChild( menu, "NextMapImage" ) ), "basicImage", GetMapImageForMapName( map ) )
	Hud_SetVisible( Hud_GetChild( menu, "NextMapName" ), true )
	Hud_SetText( Hud_GetChild( menu, "NextMapName" ), GetMapDisplayName( map ) )
	Hud_SetVisible( Hud_GetChild( menu, "ServerName" ), true )
	Hud_SetText( Hud_GetChild( menu, "ServerName" ), server.name )

	// mode name/image
	string mode = server.playlist
	Hud_SetVisible( Hud_GetChild( menu, "NextModeIcon" ), true )
	RuiSetImage( Hud_GetRui( Hud_GetChild( menu, "NextModeIcon" ) ), "basicImage", GetPlaylistThumbnailImage( mode ) )
	Hud_SetVisible( Hud_GetChild( menu, "NextGameModeName" ), true )

	if ( mode.len() != 0 )
		Hud_SetText( Hud_GetChild( menu, "NextGameModeName" ), GetGameModeDisplayName( mode ) )
	else
		Hud_SetText( Hud_GetChild( menu, "NextGameModeName" ), "#NS_SERVERBROWSER_UNKNOWNMODE" )
}

string function FillInServerModsLabel( array<RequiredModInfo> mods )
{
	string ret

	foreach ( RequiredModInfo mod in mods )
	{
		ret += format( "  %s v%s\n", mod.name, mod.version )
	}

	return ret
}


void function OnServerSelected( var button )
{
	if ( NSIsRequestingServerList() || NSGetServerCount() == 0 || file.serverListRequestFailed )
		return

	ServerInfo server = file.focusedServer

	file.lastSelectedServer = server

	foreach ( RequiredModInfo mod in server.requiredMods )
	{
		if ( !NSGetModNames().contains( mod.name ) )
		{
			DialogData dialogData
			dialogData.header = "#ERROR"
			dialogData.message = format( "Missing mod \"%s\" v%s", mod.name, mod.version )
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
			// this uses semver https://semver.org
			array<string> serverModVersion = split( mod.name, "." )
			array<string> clientModVersion = split( NSGetModVersionByModName( mod.name ), "." )

			bool semverFail = false
			// if server has invalid semver don't bother checking
			if ( serverModVersion.len() == 3 )
			{
				// bad client semver
				if ( clientModVersion.len() != serverModVersion.len() )
					semverFail = true
				// major version, don't think we should need to check other versions
				else if ( clientModVersion[ 0 ] != serverModVersion[ 0 ] )
					semverFail = true
			}

			if ( semverFail )
			{
				DialogData dialogData
				dialogData.header = "#ERROR"
				dialogData.message = format( "Server has mod \"%s\" v%s while we have v%s", mod.name, mod.version, NSGetModVersionByModName( mod.name ) )
				dialogData.image = $"ui/menu/common/dialog_error"

				#if PC_PROG
					AddDialogButton( dialogData, "#DISMISS" )

					AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )
				#endif // PC_PROG
				AddDialogFooter( dialogData, "#B_BUTTON_DISMISS_RUI" )

				OpenDialog( dialogData )

				return
			}
		}
	}

	if ( server.requiresPassword )
	{
		OnCloseServerBrowserMenu()
		AdvanceMenu( GetMenu( "ConnectWithPasswordMenu" ) )
	}
	else
	{
		TriggerConnectToServerCallbacks()
		thread ThreadedAuthAndConnectToServer()
	}
}


void function ThreadedAuthAndConnectToServer( string password = "" )
{
	if ( NSIsAuthenticatingWithServer() )
		return

	NSTryAuthWithServer( file.lastSelectedServer.index, password )

	ToggleConnectingHUD( true )

	while ( NSIsAuthenticatingWithServer() && !file.cancelConnection )
	{
		WaitFrame()
	}

	ToggleConnectingHUD( false )

	if ( file.cancelConnection )
	{
		file.cancelConnection = false
		// re-focus server list
		Hud_SetFocused( Hud_GetChild( file.menu, "BtnServer" + ( file.serverButtonFocusedID + 1 ) ) )
		return
	}

	file.cancelConnection = false

	if ( NSWasAuthSuccessful() )
	{
		bool modsChanged

		// unload mods we don't need, load necessary ones and reload mods before connecting
		foreach ( RequiredModInfo mod in file.lastSelectedServer.requiredMods )
		{
			if ( NSIsModRequiredOnClient( mod.name ) )
			{
				modsChanged = modsChanged || NSIsModEnabled( mod.name ) != file.lastSelectedServer.requiredMods.contains( mod )
				NSSetModEnabled( mod.name, file.lastSelectedServer.requiredMods.contains( mod ) )
			}
		}

		// only actually reload if we need to since the uiscript reset on reload lags hard
		if ( modsChanged )
			ReloadMods()

		NSConnectToAuthedServer()
	}
	else
	{
		string reason = NSGetAuthFailReason()

		DialogData dialogData
		dialogData.header = "#ERROR"
		dialogData.message = reason
		dialogData.image = $"ui/menu/common/dialog_error"

		#if PC_PROG
			AddDialogButton( dialogData, "#DISMISS" )

			AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )
		#endif // PC_PROG
		AddDialogFooter( dialogData, "#B_BUTTON_DISMISS_RUI" )

		OpenDialog( dialogData )
	}
}

//////////////////////////////////////
// Shadow realm
//////////////////////////////////////
int function ServerSortLogic ( ServerInfo a, ServerInfo b )
{
	var aTemp
	var bTemp

	bool direction

	// We can hard code this cause adding entire columns isn't as easy
	switch ( filterDirection.sortingBy )
	{
		case sortingBy.DEFAULT:
			aTemp = a.playerCount
			bTemp = b.playerCount

			// `1000` is assumed to always be higher than `serverPlayersMax`
			if (aTemp + 1 < a.maxPlayerCount)
				aTemp = aTemp+2000
			if (bTemp + 1 < b.maxPlayerCount)
				bTemp = bTemp+2000
			if (aTemp + 1 == a.maxPlayerCount)
				aTemp = aTemp+1000
			if (bTemp + 1 == b.maxPlayerCount)
				bTemp = bTemp+1000

			direction = filterDirection.serverName
			break;
		case sortingBy.NAME:
			aTemp = a.name.tolower()
			bTemp = b.name.tolower()
			direction = filterDirection.serverName
			break;
		case sortingBy.PLAYERS:
			aTemp = a.playerCount
			bTemp = b.playerCount
			direction = filterDirection.serverPlayers
			break;
		case sortingBy.MAP:
			aTemp = Localize( a.map ).tolower()
			bTemp = Localize( b.map ).tolower()
			direction = filterDirection.serverMap
			break;
		case sortingBy.GAMEMODE:
			aTemp = Localize( a.playlist ).tolower()
			bTemp = Localize( b.playlist ).tolower()
			direction = filterDirection.serverGamemode
			break;
		case sortingBy.REGION:
			aTemp = a.region
			bTemp = b.region
			direction = filterDirection.serverRegion
			break;
		default:
			return 0
	}

	int invert = direction == true ? 1 : -1

	if ( aTemp > bTemp )
		return 1 * invert

	if ( aTemp < bTemp )
		return -1 * invert

	return 0
}

void function SortServerListByDefault_Activate ( var button )
{
	filterDirection.sortingBy = sortingBy.DEFAULT

	file.filteredServers.sort( ServerSortLogic )

	filterDirection.serverName = !filterDirection.serverName

	UpdateShownPage()
}


void function SortServerListByName_Activate ( var button )
{
	filterDirection.sortingBy = sortingBy.NAME

	file.filteredServers.sort( ServerSortLogic )

	filterDirection.serverName = !filterDirection.serverName

	UpdateShownPage()
}


void function SortServerListByPlayers_Activate( var button )
{
	filterDirection.sortingBy = sortingBy.PLAYERS

	file.filteredServers.sort( ServerSortLogic )

	filterDirection.serverPlayers = !filterDirection.serverPlayers

	UpdateShownPage()
}

void function SortServerListByMap_Activate( var button )
{
	filterDirection.sortingBy = sortingBy.MAP

	file.filteredServers.sort( ServerSortLogic )

	filterDirection.serverMap = !filterDirection.serverMap

	UpdateShownPage()
}

void function SortServerListByGamemode_Activate( var button )
{
	filterDirection.sortingBy = sortingBy.GAMEMODE

	file.filteredServers.sort( ServerSortLogic )

	filterDirection.serverGamemode = !filterDirection.serverGamemode

	UpdateShownPage()
}

void function SortServerListByRegion_Activate( var button )
{
	filterDirection.sortingBy = sortingBy.REGION

	file.filteredServers.sort( ServerSortLogic )

	filterDirection.serverRegion = !filterDirection.serverRegion

	UpdateShownPage()
}

//////////////////////////////////////
// Callbacks
//////////////////////////////////////

void function AddConnectToServerCallback( void functionref( ServerInfo ) callback )
{
	if ( file.connectCallbacks.find( callback ) >= 0 )
		throw "ConnectToServerCallback has been registered twice. Duplicate callbacks are not allowed."
	file.connectCallbacks.append( callback )
}

void function RemoveConnectToServerCallback( void functionref( ServerInfo ) callback )
{
	file.connectCallbacks.fastremovebyvalue( callback )
}

void function TriggerConnectToServerCallbacks()
{
	foreach( callback in file.connectCallbacks )
	{
		callback( file.lastSelectedServer )
	}
}
