untyped
global function InitModesMenu
global function NSSetModeCategory

global enum eModeMenuModeCategory
{
	UNKNOWN = 0,
	PVPVE   = 1,
	PVE     = 2,
	PVP     = 3,
	FFA     = 4,
	TITAN   = 5,
	OTHER   = 6,
	CUSTOM  = 7

	SIZE
}

// List of blocked modes due to them being unfinished
const array<string> blockedModes =
[
	"fd_easy",
	"fd_normal",
	"fd_hard",
	"fd_master",
	"fd_insane"
]

struct ListEntry_t {
	string mode
	int category
}

// Slider mouse delta buffer
struct {
	int deltaX = 0
	int deltaY = 0
} mouseDeltaBuffer

struct {
	int scrollOffset
	var menu

	string searchString
	int searchEnum

	// Table of category overrides
	table<string,int> categoryOverrides

	// List of all modes we know
	array<ListEntry_t> modes

	// Sorted list of modes we want to show with categories included
	array<string> sortedModes
} file

const int MODES_PER_PAGE = 15

void function InitModesMenu()
{
	file.menu = GetMenu( "ModesMenu" )

	AddMouseMovementCaptureHandler( Hud_GetChild( file.menu, "MouseMovementCapture"), UpdateMouseDeltaBuffer )

	AddMenuEventHandler( file.menu, eUIEvent.MENU_CLOSE, OnCloseModesMenu )
	AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, OnOpenModesMenu )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnModeListUpArrow"), UIE_CLICK, OnUpArrowSelected )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnModeListDownArrow"), UIE_CLICK, OnDownArrowSelected )

	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnModeLabel"), UIE_CHANGE, FilterAndUpdateList )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnModeSearch"), UIE_CHANGE, FilterAndUpdateList )
	AddButtonEventHandler( Hud_GetChild( file.menu, "SwtModeLabel"), UIE_CHANGE, FilterAndUpdateList )

	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnModeFiltersClear"), UIE_CLICK, OnBtnFiltersClear_Activate )

	array<var> buttons = GetElementsByClassname( file.menu, "ModeSelectorPanel" )
	foreach ( var panel in buttons )
	{
		AddEventHandlerToButton( panel, "BtnMode", UIE_GET_FOCUS, ModeButton_GetFocus )
		AddEventHandlerToButton( panel, "BtnMode", UIE_CLICK, ModeButton_Click )
	}

	Hud_SetText( Hud_GetChild( file.menu, "SwtModeLabel" ), "#MODE_MENU_SWITCH" )
	SetButtonRuiText( Hud_GetChild( file.menu, "SwtModeLabel" ), "" )
	Hud_DialogList_AddListItem( Hud_GetChild( file.menu, "SwtModeLabel" ) , "#MODE_MENU_ALL", "-1" )
	for( int i = 0; i < eModeMenuModeCategory.SIZE; i++ )
	{
		Hud_DialogList_AddListItem( Hud_GetChild( file.menu, "SwtModeLabel" ) , GetCategoryStringFromEnum(i), string(i) )
	}

	AddMenuFooterOption( file.menu, BUTTON_A, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( file.menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
}

void function NSSetModeCategory( string mode, int category )
{
	if( mode in file.categoryOverrides )
	{
		file.categoryOverrides[mode] = category
		printt( "Overwriting category for mode:", mode )
		return
	}

	file.categoryOverrides[mode] <- category
}

void function OnBtnFiltersClear_Activate( var b )
{
	file.searchString = ""
	file.searchEnum = -1

	SetConVarInt( "modemenu_mode_filter", -1 )
	Hud_SetText( Hud_GetChild( file.menu, "BtnModeSearch"), "" )

	file.scrollOffset = 0

	BuildSortedModesArray()
	UpdateListSliderHeight(float(file.sortedModes.len()))
	UpdateListSliderPosition(file.sortedModes.len())
	UpdateVisibleModes()
}

void function FilterAndUpdateList( var n )
{
	file.searchString = Hud_GetUTF8Text( Hud_GetChild( file.menu, "BtnModeSearch" ) )
	file.searchEnum = GetConVarInt( "modemenu_mode_filter" )

	file.scrollOffset = 0

	BuildSortedModesArray()
	UpdateListSliderHeight(float(file.sortedModes.len()))
	UpdateListSliderPosition(file.sortedModes.len())
	UpdateVisibleModes()
}

void function OnOpenModesMenu()
{
	RegisterButtonPressedCallback( MOUSE_WHEEL_UP , OnScrollUp )
	RegisterButtonPressedCallback( MOUSE_WHEEL_DOWN , OnScrollDown )

	// Reset filters
	file.searchString = ""
	file.searchEnum = -1

	// We rebuild the modes array on open menu to make sure
	// all modes get listed
	BuildModesArray()
	BuildSortedModesArray()

	UpdateListSliderHeight(float(file.sortedModes.len()))
	UpdateListSliderPosition(file.sortedModes.len())
	UpdateVisibleModes()

	// Set to the first mode if there's no mode focused
	if ( level.ui.privatematch_mode == 0 )
	{
		array<var> panels = GetElementsByClassname( file.menu, "ModeSelectorPanel" )
		foreach( var panel in panels )
		{
			if( Hud_IsEnabled( Hud_GetChild( panel, "BtnMode") ) )
			{
				Hud_SetFocused( Hud_GetChild( panel, "BtnMode") )
				break
			}
		}
	}
}

void function OnCloseModesMenu()
{
	try
	{
		DeregisterButtonPressedCallback( MOUSE_WHEEL_UP , OnScrollUp )
		DeregisterButtonPressedCallback( MOUSE_WHEEL_DOWN , OnScrollDown )
	}
	catch ( ex ) {}
}

string function GetCategoryStringFromEnum( int category )
{
	switch( category )
	{
		case eModeMenuModeCategory.PVPVE: return "#MODE_MENU_PVPVE"
		case eModeMenuModeCategory.PVE: return "#MODE_MENU_PVE"
		case eModeMenuModeCategory.PVP: return "#MODE_MENU_PVP"
		case eModeMenuModeCategory.FFA: return "#MODE_MENU_FFA"
		case eModeMenuModeCategory.TITAN: return "#MODE_MENU_TITAN_ONLY"
		case eModeMenuModeCategory.OTHER: return "#MODE_MENU_OTHER"
		case eModeMenuModeCategory.CUSTOM: return "#MODE_MENU_CUSTOM"
	}

	return "#MODE_MENU_UNKNOWN"
}

void function BuildModesArray()
{
	file.modes.clear()

	foreach( string mode in GetPrivateMatchModes() )
	{
		ListEntry_t entry
		entry.mode = mode
		entry.category = eModeMenuModeCategory.UNKNOWN

		switch( mode )
		{
			case "aitdm":
			case "at":
				entry.category = eModeMenuModeCategory.PVPVE
				break
			case "fd_easy":
			case "fd_normal":
			case "fd_hard":
			case "fd_master":
			case "fd_insane":
				entry.category = eModeMenuModeCategory.PVE
				break
			case "tdm":
			case "ctf":
			case "mfd":
			case "ps":
			case "cp":
			case "speedball":
			case "rocket_lf":
			case "holopilot_lf":
				entry.category = eModeMenuModeCategory.PVP
				break
			case "ffa":
			case "fra":
				entry.category = eModeMenuModeCategory.FFA
				break
			case "lts":
			case "ttdm":
			case "attdm":
			case "turbo_ttdm":
			case "alts":
			case "turbo_lts":
				entry.category = eModeMenuModeCategory.TITAN
				break
			case "coliseum":
			case "sp_coop":
				entry.category = eModeMenuModeCategory.OTHER
				break
			case "chamber":
			case "hidden":
			case "sns":
			case "fw":
			case "gg":
			case "tt":
			case "inf":
			case "kr":
			case "fastball":
			case "hs":
			case "ctf_comp":
			case "tffa":
				entry.category = eModeMenuModeCategory.CUSTOM
				break
		}

		file.modes.append(entry)
	}
}

int function SortModesAlphabetize( string a, string b )
{
	a = Localize( GetGameModeDisplayName( a ) )
	b = Localize( GetGameModeDisplayName( b ) )

	if ( a > b )
		return 1

	if ( a < b )
		return -1

	return 0
}

void function BuildSortedModesArray()
{
	file.sortedModes.clear()

	// Build sorted list of categories
	array<string> categories
	for( int i = 0; i < eModeMenuModeCategory.SIZE; i++ )
	{
		if( file.searchEnum != -1 && file.searchEnum != i )
			continue

		categories.append( GetCategoryStringFromEnum( i ) )
	}

	categories.sort( SortStringAlphabetize )

	// Build final list of mixed modes and categories
	foreach( string category in categories )
	{
		// Build sorted list of modes in category
		array<string> modes
		foreach( ListEntry_t entry in file.modes )
		{
			int iCategory = entry.category
			if( entry.mode in file.categoryOverrides )
				iCategory = file.categoryOverrides[entry.mode]
			
			if( GetCategoryStringFromEnum( iCategory ) != category )
				continue

			string mode = entry.mode

			if( file.searchString != "" && Localize(GetGameModeDisplayName(mode)).tolower().find(file.searchString.tolower()) == null )
				continue

			if( !modes.contains(mode) )
				modes.append( mode )
		}

		modes.sort( SortModesAlphabetize )

		if( modes.len() == 0 )
			continue

		// Add to final list we then display
		file.sortedModes.append( category )
		foreach( string mode in modes )
			file.sortedModes.append( mode )
	}
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
	if( file.sortedModes.len() < MODES_PER_PAGE )
		return

	var sliderButton = Hud_GetChild( file.menu , "BtnModeListSlider" )
	var sliderPanel = Hud_GetChild( file.menu , "BtnModeListSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu , "MouseMovementCapture" )

	Hud_SetFocused( sliderButton )

	int[2] screenSize = GetScreenSize()
	float minYPos = -40.0 * ( screenSize[1] / 1080.0 )
	float maxHeight = 596.0  * ( screenSize[1] / 1080.0 )
	float maxYPos = minYPos - ( maxHeight - Hud_GetHeight( sliderPanel ) )
	float useableSpace = maxHeight - Hud_GetHeight( sliderPanel )

	float jump = minYPos - ( useableSpace / ( float( file.sortedModes.len() ) ) )

	// got local from official respaw scripts, without untyped throws an error
	local pos =	Hud_GetPos( sliderButton )[1]
	local newPos = pos - mouseDeltaBuffer.deltaY
	FlushMouseDeltaBuffer()

	if ( newPos < maxYPos ) newPos = maxYPos
	if ( newPos > minYPos ) newPos = minYPos

	Hud_SetPos( sliderButton , 2, newPos )
	Hud_SetPos( sliderPanel , 2, newPos )
	Hud_SetPos( movementCapture , 2, newPos )

	file.scrollOffset = -int( ( ( newPos - minYPos ) / useableSpace ) * ( file.sortedModes.len() - MODES_PER_PAGE ) )
	UpdateVisibleModes()
}

void function UpdateListSliderHeight( float modes )
{
	var sliderButton = Hud_GetChild( file.menu , "BtnModeListSlider" )
	var sliderPanel = Hud_GetChild( file.menu , "BtnModeListSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu , "MouseMovementCapture" )

	int[2] screenSize = GetScreenSize()
	float maxHeight = 596.0 * ( screenSize[1] / 1080.0 )
	float minHeight = 80.0 * ( screenSize[1] / 1080.0 )

	float height = maxHeight * ( MODES_PER_PAGE / modes )

	if ( height > maxHeight ) height = maxHeight
	if ( height < minHeight ) height = minHeight

	Hud_SetHeight( sliderButton, height )
	Hud_SetHeight( sliderPanel, height )
	Hud_SetHeight( movementCapture, height )
}


void function UpdateListSliderPosition( int modes )
{
	if( modes < MODES_PER_PAGE )
		return

	var sliderButton = Hud_GetChild( file.menu, "BtnModeListSlider" )
	var sliderPanel = Hud_GetChild( file.menu, "BtnModeListSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu, "MouseMovementCapture" )

	float minYPos = -40.0 * ( GetScreenSize()[1] / 1080.0 )
	float useableSpace = (596.0 * ( GetScreenSize()[1] / 1080.0 ) - Hud_GetHeight( sliderPanel ) )

	float jump = minYPos - ( useableSpace / ( float( modes ) - MODES_PER_PAGE ) * file.scrollOffset )

	if ( jump > minYPos ) jump = minYPos

	Hud_SetPos( sliderButton, 2, jump )
	Hud_SetPos( sliderPanel, 2, jump )
	Hud_SetPos( movementCapture, 2, jump )
}

void function OnScrollDown( var button )
{
	if (file.sortedModes.len() <= MODES_PER_PAGE) return
	file.scrollOffset += 5
	if (file.scrollOffset + MODES_PER_PAGE > file.sortedModes.len()) {
		file.scrollOffset = file.sortedModes.len() - MODES_PER_PAGE
	}
	UpdateVisibleModes()
	UpdateListSliderPosition( file.sortedModes.len() )
}

void function OnScrollUp( var button )
{
	file.scrollOffset -= 5
	if ( file.scrollOffset < 0 ) {
		file.scrollOffset = 0
	}
	UpdateVisibleModes()
	UpdateListSliderPosition( file.sortedModes.len() )
}

void function OnDownArrowSelected( var button )
{
	if ( file.sortedModes.len() <= MODES_PER_PAGE ) return
	file.scrollOffset += 1
	if ( file.scrollOffset + MODES_PER_PAGE > file.sortedModes.len() )
	{
		file.scrollOffset = file.sortedModes.len() - MODES_PER_PAGE
	}

	UpdateVisibleModes()
	UpdateListSliderPosition( file.sortedModes.len() )
}


void function OnUpArrowSelected( var button )
{
	file.scrollOffset -= 1
	if ( file.scrollOffset < 0 )
	{
		file.scrollOffset = 0
	}

	UpdateVisibleModes()
	UpdateListSliderPosition( file.sortedModes.len() )
}

bool function IsStringCategory( string str )
{
	return GetGameModeDisplayName( str ) == ""
}

/////////////////////////////
// LIST
/////////////////////////////

void function UpdateVisibleModes()
{
	// ensures that we only ever show enough buttons for the number of modes we have
	array<var> buttons = GetElementsByClassname( GetMenu( "ModesMenu" ), "ModeSelectorPanel" )
	foreach ( var panel in buttons )
	{
		Hud_SetEnabled( panel, false )
		Hud_SetVisible( panel, false )
		Hud_SetText( Hud_GetChild( panel, "Header" ), "" )
		Hud_SetText( Hud_GetChild( panel, "BtnMode" ), "" )
		SetButtonRuiText( Hud_GetChild( panel, "BtnMode" ), "" )
	}

	for ( int i = 0; i < MODES_PER_PAGE; i++ )
	{
		if ( i + file.scrollOffset >= file.sortedModes.len() )
			break

		// Setup locals
		var panel = buttons[i]
		var button = Hud_GetChild( panel, "BtnMode" )
		var header = Hud_GetChild( panel, "Header" )

		int modeIndex = i + file.scrollOffset
		string mode = file.sortedModes[ modeIndex ]

		bool bIsCategory = IsStringCategory( mode )
		mode = bIsCategory ? mode : GetGameModeDisplayName( mode )

		// Show the panel
		Hud_SetEnabled( panel, true )
		Hud_SetVisible( panel, true )
		Hud_SetLocked( button, false )

		if( bIsCategory )
		{
			Hud_SetText( header, mode )
			Hud_SetEnabled( button, false )
		}
		else
		{
			Hud_SetEnabled( button, true )
			SetButtonRuiText( button, mode )

			if( blockedModes.contains( file.sortedModes[ modeIndex ] ) )
				Hud_SetLocked( button, true )

			if ( PrivateMatch_IsValidMapModeCombo( PrivateMatch_GetSelectedMap(), mode ) )
			{
				Hud_SetLocked( button, true )
				SetButtonRuiText( button, mode )
			}
		}
	}
}

void function ModeButton_GetFocus( var button )
{
	int modeId = int( Hud_GetScriptID( Hud_GetParent( button ) ) ) + file.scrollOffset - 1

	var nextModeImage = Hud_GetChild( file.menu, "NextModeImage" )
	var nextModeIcon = Hud_GetChild( file.menu, "ModeIconImage" )
	var nextModeName = Hud_GetChild( file.menu, "NextModeName" )
	var nextModeDesc = Hud_GetChild( file.menu, "NextModeDesc" )

	if ( modeId > file.sortedModes.len() )
		return

	string modeName = file.sortedModes[modeId]

	asset playlistImage = GetPlaylistImage( modeName )
	RuiSetImage( Hud_GetRui( nextModeImage ), "basicImage", playlistImage )
	RuiSetImage( Hud_GetRui( nextModeIcon ), "basicImage", GetPlaylistThumbnailImage( modeName ) )
	Hud_SetText( nextModeName, GetGameModeDisplayName( modeName ) )

	string mapName = PrivateMatch_GetSelectedMap()
	bool mapSupportsMode = PrivateMatch_IsValidMapModeCombo( mapName, modeName )
	if ( IsFDMode( modeName ) ) // HACK!
		Hud_SetText( nextModeDesc, Localize( "#FD_PLAYERS_DESC", Localize( GetGameModeDisplayHint( modeName ) ) ) )
	else
		Hud_SetText( nextModeDesc, GetGameModeDisplayHint( modeName ) )
}

void function ModeButton_Click( var button )
{
	// this never activates on custom servers, but keeping it for parity with official
	if ( !AmIPartyLeader() && GetPartySize() > 1 )
		return

	if ( Hud_IsLocked( button ) )
		return

	int modeID = int( Hud_GetScriptID( Hud_GetParent( button ) ) ) + file.scrollOffset - 1

	string modeName = file.sortedModes[ modeID ]

	// on modded servers set us to the first map for that mode automatically
	// need this for coliseum mainly which is literally impossible to select without this
 	if ( !PrivateMatch_IsValidMapModeCombo( PrivateMatch_GetSelectedMap(), modeName ) )
	{
		ClientCommand( "SetCustomMap " + GetPrivateMatchMapsForMode( modeName )[ 0 ] )
	}
	// set it
	ClientCommand( "PrivateMatchSetMode " + modeName )
	CloseActiveMenu()
}
