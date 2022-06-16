untyped
// Only way to get Hud_GetPos(sliderButton) working was to use untyped

global function AddNorthstarServerBrowserMenu
global function ThreadedAuthAndConnectToServer


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
	LATENCY
}

// Column sort direction, only one of these can be aplied at once
struct {
	// true = alphabeticaly false = reverse
	bool serverName = true
	bool serverPlayers = true
	bool serverMap = true
	bool serverGamemode = true
	bool serverLatency = true
	// 0 = none; 1 = default; 2 = name; 3 = players; 4 = map; 5 = gamemode; 6 = latency
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
	int serverLatency
}

struct {
	// UI state vars
	var menu
	int lastSelectedServer = 999
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
	
	// UI references
	array<var> serverButtons
	array<var> serversName
	array<var> playerCountLabels
	array<var> serversProtected
	array<var> serversMap
	array<var> serversGamemode
	array<var> serversLatency
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

	AddMouseMovementCaptureHandler( file.menu, UpdateMouseDeltaBuffer )

	// Get menu stuff
	file.serverButtons = GetElementsByClassname( file.menu, "ServerButton" )
	file.serversName = GetElementsByClassname( file.menu, "ServerName" )
	file.playerCountLabels = GetElementsByClassname( file.menu, "PlayerCount" )
	file.serversProtected = GetElementsByClassname( file.menu, "ServerLock" )
	file.serversMap = GetElementsByClassname( file.menu, "ServerMap" )
	file.serversGamemode = GetElementsByClassname( file.menu, "ServerGamemode" )
	file.serversLatency = GetElementsByClassname( file.menu, "ServerLatency" )

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
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnServerLatencyTab"), UIE_CLICK, SortServerListByLatency_Activate )


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

	// Unfinished features
	Hud_SetLocked( Hud_GetChild( file.menu, "BtnServerLatencyTab" ), true )

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
	if ( file.serversArrayFiltered.len() <= BUTTONS_PER_PAGE )
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

	float jump = minYPos - ( useableSpace / ( float( file.serversArrayFiltered.len() ) ) )

	// got local from official respaw scripts, without untyped throws an error
	local pos =	Hud_GetPos( sliderButton )[1]
	local newPos = pos - mouseDeltaBuffer.deltaY
	FlushMouseDeltaBuffer()

	if ( newPos < maxYPos ) newPos = maxYPos
	if ( newPos > minYPos ) newPos = minYPos

	Hud_SetPos( sliderButton , 2, newPos )
	Hud_SetPos( sliderPanel , 2, newPos )
	Hud_SetPos( movementCapture , 2, newPos )

	file.scrollOffset = -int( ( ( newPos - minYPos ) / useableSpace ) * ( file.serversArrayFiltered.len() - BUTTONS_PER_PAGE ) )
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
	if (file.serversArrayFiltered.len() <= BUTTONS_PER_PAGE) return
	file.scrollOffset += 5
	if (file.scrollOffset + BUTTONS_PER_PAGE > file.serversArrayFiltered.len()) {
		file.scrollOffset = file.serversArrayFiltered.len() - BUTTONS_PER_PAGE
	}
	UpdateShownPage()
	UpdateListSliderPosition( file.serversArrayFiltered.len() )
}

void function OnScrollUp( var button )
{
	file.scrollOffset -= 5
	if ( file.scrollOffset < 0 ) {
		file.scrollOffset = 0
	}
	UpdateShownPage()
	UpdateListSliderPosition( file.serversArrayFiltered.len() )
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
		UpdateListSliderPosition( file.serversArrayFiltered.len() )
		DisplayFocusedServerInfo( file.serverButtonFocusedID )
		Hud_SetFocused( Hud_GetChild( file.menu, "BtnServer1" ) )
	}
}

void function OnHitDummyBottom( var button )
{
	file.scrollOffset += 1
	if ( file.scrollOffset + BUTTONS_PER_PAGE > file.serversArrayFiltered.len() )
	{
		// was at bottom already
		file.scrollOffset = file.serversArrayFiltered.len() - BUTTONS_PER_PAGE
		Hud_SetFocused( Hud_GetChild( file.menu, "BtnServerSearch" ) )
		HideServerInfo()
	}
	else
	{
		// only update if list position changed
		UpdateShownPage()
		UpdateListSliderPosition( file.serversArrayFiltered.len() )
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
	if ( file.serversArrayFiltered.len() <= BUTTONS_PER_PAGE ) return
	file.scrollOffset += 1
	if ( file.scrollOffset + BUTTONS_PER_PAGE > file.serversArrayFiltered.len() )
	{
		file.scrollOffset = file.serversArrayFiltered.len() - BUTTONS_PER_PAGE
	}
	
	UpdateShownPage()
	UpdateListSliderPosition( file.serversArrayFiltered.len() )
}


void function OnUpArrowSelected( var button )
{
	file.scrollOffset -= 1
	if ( file.scrollOffset < 0 )
	{
		file.scrollOffset = 0
	}
	
	UpdateShownPage()
	UpdateListSliderPosition( file.serversArrayFiltered.len() )
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
	UpdateListSliderPosition( file.serversArrayFiltered.len() )

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
		case sortingBy.LATENCY:
			filterDirection.serverLatency = !filterDirection.serverLatency
			SortServerListByLatency_Activate(0)
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
		Hud_SetText( file.serversLatency[ i ], "" )
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
	file.serversArrayFiltered.clear()
	int totalPlayers = 0

	for ( int i = 0; i < NSGetServerCount(); i++ )
	{
		serverStruct tempServer
		tempServer.serverIndex = i
		tempServer.serverProtected = NSServerRequiresPassword( i )
		tempServer.serverName = NSGetServerName( i )
		tempServer.serverPlayers = NSGetServerPlayerCount( i )
		tempServer.serverPlayersMax = NSGetServerMaxPlayerCount( i )
		tempServer.serverMap = NSGetServerMap( i )
		tempServer.serverGamemode = GetGameModeDisplayName( NSGetServerPlaylist ( i ) )

		totalPlayers += tempServer.serverPlayers


		// Filters
		if ( filterArguments.hideEmpty && tempServer.serverPlayers == 0 )
			continue;
		
		if ( filterArguments.hideFull && tempServer.serverPlayers == tempServer.serverPlayersMax )
			continue;
		
		if ( filterArguments.hideProtected && tempServer.serverProtected )
			continue;
		
		if ( filterArguments.filterMap != "SWITCH_ANY" && filterArguments.filterMap != tempServer.serverMap )
			continue;
		
		if ( filterArguments.filterGamemode != "SWITCH_ANY" && filterArguments.filterGamemode != tempServer.serverGamemode )
			continue;
		
		// Search
		if ( filterArguments.useSearch )
		{	
			array<string> sName
			sName.append( tempServer.serverName.tolower() )
			sName.append( Localize( GetMapDisplayName( tempServer.serverMap ) ).tolower() )
			sName.append( tempServer.serverMap.tolower() )
			sName.append( tempServer.serverGamemode.tolower() )
			sName.append( Localize( tempServer.serverGamemode ).tolower() )
			sName.append( NSGetServerDescription( i ).tolower() )

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
		
		// Server fits our requirements, add it to the list
		file.serversArrayFiltered.append( tempServer )
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
		Hud_SetText( file.serversLatency[ i ], "" )
	}

	int j = file.serversArrayFiltered.len() > BUTTONS_PER_PAGE ? BUTTONS_PER_PAGE : file.serversArrayFiltered.len()

	for ( int i = 0; i < j; i++ )
	{

		int buttonIndex = file.scrollOffset + i
		int serverIndex = file.serversArrayFiltered[ buttonIndex ].serverIndex

		Hud_SetEnabled( file.serverButtons[ i ], true )
		Hud_SetVisible( file.serverButtons[ i ], true )

		Hud_SetVisible( file.serversProtected[ i ], file.serversArrayFiltered[ buttonIndex ].serverProtected )
		Hud_SetText( file.serversName[ i ], file.serversArrayFiltered[ buttonIndex ].serverName )
		Hud_SetText( file.playerCountLabels[ i ], format( "%i/%i", file.serversArrayFiltered[ buttonIndex ].serverPlayers, file.serversArrayFiltered[ buttonIndex ].serverPlayersMax ) )
		Hud_SetText( file.serversMap[ i ], GetMapDisplayName( file.serversArrayFiltered[ buttonIndex ].serverMap ) )
		Hud_SetText( file.serversGamemode[ i ], file.serversArrayFiltered[ buttonIndex ].serverGamemode )
	}


	if ( NSGetServerCount() == 0 )
	{
		Hud_SetEnabled( file.serverButtons[ 0 ], true )
		Hud_SetVisible( file.serverButtons[ 0 ], true )
		Hud_SetText( file.serversName[ 0 ], "#NS_SERVERBROWSER_NOSERVERS" )
	}
	UpdateListSliderHeight( float( file.serversArrayFiltered.len() ) )
}

void function OnServerButtonFocused( var button )
{
	if ( file.scrollOffset < 0 )
		file.scrollOffset = 0
	
	int scriptID = int ( Hud_GetScriptID( button ) )
	file.serverButtonFocusedID = scriptID
	if ( file.serversArrayFiltered.len() > 0 )
		file.focusedServerIndex = file.serversArrayFiltered[ file.scrollOffset + scriptID ].serverIndex
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
	if ( file.lastSelectedServer == serverIndex ) sameServer = true


	file.serverSelectedTimeLast = file.serverSelectedTime
	file.serverSelectedTime = Time()

	file.lastSelectedServer = serverIndex

	if ( wasClickNav && ( file.serverSelectedTime - file.serverSelectedTimeLast < DOUBLE_CLICK_TIME_MS ) && sameServer )
	{
		OnServerSelected(0)
	}
}

void function DisplayFocusedServerInfo( int scriptID )
{
	if ( scriptID == 999 || scriptID == -1 || scriptID == 16 ) return

	if ( NSIsRequestingServerList() || NSGetServerCount() == 0 || file.serverListRequestFailed || file.serversArrayFiltered.len() == 0 )
		return

	var menu = GetMenu( "ServerBrowserMenu" )

	int serverIndex = file.scrollOffset + scriptID
	if ( serverIndex < 0 ) serverIndex = 0


	Hud_SetVisible( Hud_GetChild( menu, "BtnServerDescription" ), true )
	Hud_SetVisible( Hud_GetChild( menu, "BtnServerMods" ), true )
	Hud_SetVisible( Hud_GetChild( menu, "BtnServerJoin" ), true )
	// text panels
	Hud_SetVisible( Hud_GetChild( menu, "LabelDescription" ), true )
	Hud_SetVisible( Hud_GetChild( menu, "LabelMods" ), false )
	Hud_SetText( Hud_GetChild( menu, "LabelDescription" ), NSGetServerDescription( file.serversArrayFiltered[ serverIndex ].serverIndex ) + "\n\nRequired Mods:\n" + FillInServerModsLabel( file.serversArrayFiltered[ serverIndex ].serverIndex ) )

	// map name/image/server name
	string map = file.serversArrayFiltered[ serverIndex ].serverMap
	Hud_SetVisible( Hud_GetChild( menu, "NextMapImage" ), true )
	Hud_SetVisible( Hud_GetChild( menu, "NextMapBack" ), true )
	RuiSetImage( Hud_GetRui( Hud_GetChild( menu, "NextMapImage" ) ), "basicImage", GetMapImageForMapName( map ) )
	Hud_SetVisible( Hud_GetChild( menu, "NextMapName" ), true )
	Hud_SetText( Hud_GetChild( menu, "NextMapName" ), GetMapDisplayName( map ) )
	Hud_SetVisible( Hud_GetChild( menu, "ServerName" ), true )
	Hud_SetText( Hud_GetChild( menu, "ServerName" ), NSGetServerName( file.serversArrayFiltered[ serverIndex ].serverIndex ) )

	// mode name/image
	string mode = file.serversArrayFiltered[ serverIndex ].serverGamemode
	Hud_SetVisible( Hud_GetChild( menu, "NextModeIcon" ), true )
	RuiSetImage( Hud_GetRui( Hud_GetChild( menu, "NextModeIcon" ) ), "basicImage", GetPlaylistThumbnailImage( mode ) )
	Hud_SetVisible( Hud_GetChild( menu, "NextGameModeName" ), true )

	if ( mode.len() != 0 )
		Hud_SetText( Hud_GetChild( menu, "NextGameModeName" ), mode )
	else
		Hud_SetText( Hud_GetChild( menu, "NextGameModeName" ), "#NS_SERVERBROWSER_UNKNOWNMODE" )
}

string function FillInServerModsLabel( int server )
{
	string ret

	for ( int i = 0; i < NSGetServerRequiredModsCount( server ); i++ )
	{
		ret += "  "
		ret += NSGetServerRequiredModName( server, i ) + " v" + NSGetServerRequiredModVersion( server, i ) + "\n"
	}
	return ret
}


void function OnServerSelected( var button )
{
	if ( NSIsRequestingServerList() || NSGetServerCount() == 0 || file.serverListRequestFailed )
		return

	int serverIndex = file.focusedServerIndex

	file.lastSelectedServer = serverIndex

	// check mods
	for ( int i = 0; i < NSGetServerRequiredModsCount( serverIndex ); i++ )
	{
		if ( !NSGetModNames().contains( NSGetServerRequiredModName( serverIndex, i ) ) )
		{
			DialogData dialogData
			dialogData.header = "#ERROR"
			dialogData.message = "Missing mod \"" + NSGetServerRequiredModName( serverIndex, i ) + "\" v" + NSGetServerRequiredModVersion( serverIndex, i )
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
			array<string> serverModVersion = split( NSGetServerRequiredModVersion( serverIndex, i ), "." )
			array<string> clientModVersion = split( NSGetModVersionByModName( NSGetServerRequiredModName( serverIndex, i ) ), "." )

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
				dialogData.message = "Server has mod \"" + NSGetServerRequiredModName( serverIndex, i ) + "\" v" + NSGetServerRequiredModVersion( serverIndex, i ) + " while we have v" + NSGetModVersionByModName( NSGetServerRequiredModName( serverIndex, i ) )
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

	if ( NSServerRequiresPassword( serverIndex ) )
	{
		OnCloseServerBrowserMenu()
		AdvanceMenu( GetMenu( "ConnectWithPasswordMenu" ) )
	}
	else
		thread ThreadedAuthAndConnectToServer()
}


void function ThreadedAuthAndConnectToServer( string password = "" )
{
	if ( NSIsAuthenticatingWithServer() )
		return

	print( "trying to authenticate with server " + NSGetServerName( file.lastSelectedServer ) + " with password " + password )

	NSTryAuthWithServer( file.lastSelectedServer, password )

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
	NSSetLoading( true )
	NSUpdateServerInfo(
		NSGetServerID( file.lastSelectedServer ),
		NSGetServerName( file.lastSelectedServer ),
		password,
		NSGetServerPlayerCount( file.lastSelectedServer ),
		NSGetServerMaxPlayerCount( file.lastSelectedServer ),
		NSGetServerMap( file.lastSelectedServer ),
		Localize( GetMapDisplayName( NSGetServerMap( file.lastSelectedServer ) ) ),
		NSGetServerPlaylist( file.lastSelectedServer ),
		Localize( GetPlaylistDisplayName( NSGetServerPlaylist( file.lastSelectedServer ) ) )
	)

	if ( NSWasAuthSuccessful() )
	{
		bool modsChanged

		array<string> requiredMods
		for ( int i = 0; i < NSGetServerRequiredModsCount( file.lastSelectedServer ); i++ )
			requiredMods.append( NSGetServerRequiredModName( file.lastSelectedServer, i ) )

		// unload mods we don't need, load necessary ones and reload mods before connecting
		foreach ( string mod in NSGetModNames() )
		{
			if ( NSIsModRequiredOnClient( mod ) )
			{
				modsChanged = modsChanged || NSIsModEnabled( mod ) != requiredMods.contains( mod )
				NSSetModEnabled( mod, requiredMods.contains( mod ) )
			}
		}

		// only actually reload if we need to since the uiscript reset on reload lags hard
		if ( modsChanged )
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

//////////////////////////////////////
// Shadow realm
//////////////////////////////////////
int function ServerSortLogic ( serverStruct a, serverStruct b )
{
	var aTemp
	var bTemp

	bool direction

	// We can hard code this cause adding entire columns isn't as easy
	switch ( filterDirection.sortingBy )
	{
		case sortingBy.DEFAULT:
			aTemp = a.serverPlayers
			bTemp = b.serverPlayers

			// `1000` is assumed to always be higher than `serverPlayersMax`
			if (aTemp + 1 < a.serverPlayersMax)
				aTemp = aTemp+2000
			if (bTemp + 1 < b.serverPlayersMax)
				bTemp = bTemp+2000
			if (aTemp + 1 == a.serverPlayersMax)
				aTemp = aTemp+1000
			if (bTemp + 1 == b.serverPlayersMax)
				bTemp = bTemp+1000

			direction = filterDirection.serverName
			break;
		case sortingBy.NAME:
			aTemp = a.serverName.tolower()
			bTemp = b.serverName.tolower()
			direction = filterDirection.serverName
			break;
		case sortingBy.PLAYERS:
			aTemp = a.serverPlayers
			bTemp = b.serverPlayers
			direction = filterDirection.serverPlayers
			break;
		case sortingBy.MAP:
			aTemp = Localize( a.serverMap ).tolower()
			bTemp = Localize( b.serverMap ).tolower()
			direction = filterDirection.serverMap
			break;
		case sortingBy.GAMEMODE:
			aTemp = Localize( a.serverGamemode ).tolower()
			bTemp = Localize( b.serverGamemode ).tolower()
			direction = filterDirection.serverGamemode
			break;
		case sortingBy.LATENCY:
			aTemp = a.serverLatency
			bTemp = b.serverLatency
			direction = filterDirection.serverLatency
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

	file.serversArrayFiltered.sort( ServerSortLogic )

	filterDirection.serverName = !filterDirection.serverName

	UpdateShownPage()
}


void function SortServerListByName_Activate ( var button )
{
	filterDirection.sortingBy = sortingBy.NAME

	file.serversArrayFiltered.sort( ServerSortLogic )

	filterDirection.serverName = !filterDirection.serverName

	UpdateShownPage()
}


void function SortServerListByPlayers_Activate( var button )
{
	filterDirection.sortingBy = sortingBy.PLAYERS

	file.serversArrayFiltered.sort( ServerSortLogic )

	filterDirection.serverPlayers = !filterDirection.serverPlayers

	UpdateShownPage()
}

void function SortServerListByMap_Activate( var button )
{
	filterDirection.sortingBy = sortingBy.MAP

	file.serversArrayFiltered.sort( ServerSortLogic )

	filterDirection.serverMap = !filterDirection.serverMap

	UpdateShownPage()
}

void function SortServerListByGamemode_Activate( var button )
{
	filterDirection.sortingBy = sortingBy.GAMEMODE

	file.serversArrayFiltered.sort( ServerSortLogic )

	filterDirection.serverGamemode = !filterDirection.serverGamemode

	UpdateShownPage()
}

void function SortServerListByLatency_Activate( var button )
{
	filterDirection.sortingBy = sortingBy.LATENCY

	file.serversArrayFiltered.sort( ServerSortLogic )

	filterDirection.serverLatency = !filterDirection.serverLatency

	UpdateShownPage()
}
