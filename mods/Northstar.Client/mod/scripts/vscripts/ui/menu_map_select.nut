untyped


global function MenuMapSelect_Init

global function InitMapsMenu


const int BUTTONS_PER_PAGE = 4


struct {
	int deltaX = 0
	int deltaY = 0
} mouseDeltaBuffer

struct {
	int mapsPerPage = 21
	int currentMapPage
	
	array< var > gridButtons
	array< string > mapsArrayFiltered
	
	int scrollOffset = 0
	
	var menu
} file





void function MenuMapSelect_Init()
{
	RegisterSignal( "OnCloseMapsMenu" )
}

void function InitMapsMenu()
{
	file.menu = GetMenu( "MapsMenu" )
	
	AddMouseMovementCaptureHandler( file.menu, UpdateMouseDeltaBuffer )
	

	AddMenuEventHandler( file.menu, eUIEvent.MENU_CLOSE, OnCloseMapsMenu )
	AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, OnOpenMapsMenu )

	

	AddMenuFooterOption( file.menu, BUTTON_A, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( file.menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
	
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnMapGridUpArrow"), UIE_CLICK, OnUpArrowSelected )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnMapGridDownArrow"), UIE_CLICK, OnDownArrowSelected )
	
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnFiltersClear"), UIE_CLICK, OnBtnFiltersClear_Activate )
	
	AddButtonEventHandler( Hud_GetChild( file.menu, "SwtBtnHideLocked"), UIE_CHANGE, OnFiltersChanged )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnMapsSearch"), UIE_CHANGE, OnFiltersChanged )
	
	RuiSetString( Hud_GetRui( Hud_GetChild( file.menu, "SwtBtnhideLocked")), "buttonText", "")
	
	file.gridButtons = GetElementsByClassname( file.menu, "MapGridButtons" )
	
	// uhh
	foreach ( var mapButton in file.gridButtons )
	{
		var button = Hud_GetChild( mapButton, "MapButton" )
		AddButtonEventHandler( button, UIE_CLICK, MapButton_Activate )
		AddButtonEventHandler( button, UIE_GET_FOCUS, MapButton_Focus )
	}
	
	
	FilterMapsArray()
}


// https://youtu.be/VHi2wKBKBc4

void function OnCloseMapsMenu()
{
	Signal( uiGlobal.signalDummy, "OnCloseMapsMenu" )
	
	try
	{
		DeregisterButtonPressedCallback(MOUSE_WHEEL_UP , OnScrollUp)
		DeregisterButtonPressedCallback(MOUSE_WHEEL_DOWN , OnScrollDown)
		//DeregisterButtonPressedCallback(KEY_TAB , OnKeyTabPressed)
	}
	catch ( ex ) {}
}

void function OnOpenMapsMenu()
{
	RefreshList()
	
	RegisterButtonPressedCallback(MOUSE_WHEEL_UP , OnScrollUp)
	RegisterButtonPressedCallback(MOUSE_WHEEL_DOWN , OnScrollDown)
	//RegisterButtonPressedCallback(KEY_TAB , OnKeyTabPressed)
}

void function RefreshList()
{
	file.scrollOffset = 0
	FilterMapsArray()
	UpdateMapsGrid()
	if ( file.mapsArrayFiltered.len() != 0 )
		UpdateMapsInfo( file.mapsArrayFiltered[0] )
	UpdateListSliderHeight()
	UpdateListSliderPosition()
	UpdateNextMapInfo()
}

void function OnFiltersChanged( var button )
{
	FilterMapsArray()
	RefreshList()
}

void function MapButton_Activate( var button )
{
	if ( !AmIPartyLeader() && GetPartySize() > 1 )
		return

	int mapID = int( Hud_GetScriptID( Hud_GetParent( button ) ) )
	string mapName = file.mapsArrayFiltered[ mapID + file.scrollOffset * 3 ]
	
	if ( IsLocked( mapName ) )
		return
	
	printt( mapName, mapID )

	UpdateMapsInfo( mapName )
	ClientCommand( "SetCustomMap " + mapName )
	CloseActiveMenu()
}

void function MapButton_Focus( var button )
{
	int mapID = int( Hud_GetScriptID( Hud_GetParent( button ) ) )
	string mapName = file.mapsArrayFiltered[ mapID + file.scrollOffset * 3 ]

	UpdateMapsInfo( mapName )
}

void function OnBtnFiltersClear_Activate( var button )
{
	Hud_SetText( Hud_GetChild( file.menu, "BtnMapsSearch" ), "" )

	SetConVarInt( "filter_map_hide_locked", 0 )
	
	RefreshList()
}

void function UpdateMapsInfo( string map )
{
	RuiSetImage( Hud_GetRui( Hud_GetChild( file.menu, "NextMapImage" ) ), "basicImage", GetMapImageForMapName( map ) )
	Hud_SetText( Hud_GetChild( file.menu, "NextMapDescription" ), GetMapDisplayDesc( map ) )
	Hud_SetText( Hud_GetChild( file.menu, "NextMapName" ), GetMapDisplayName( map ) )
}

void function UpdateNextMapInfo()
{
	array< string > mapsArray = file.mapsArrayFiltered
	
	if( !mapsArray.len() )
		return
	
	var nextMapName = Hud_GetChild( file.menu, "NextMapName" )
	Hud_SetText( nextMapName, GetMapDisplayName( mapsArray[ 0 ] ) )
}

void function UpdateMapsGrid()
{	
	HideAllMapButtons()
	
	array< string > mapsArray = file.mapsArrayFiltered
	
	
	int trueOffset = file.scrollOffset * 3
	
	foreach ( int _index,  var element in file.gridButtons )
	{
		if ( ( _index + trueOffset ) >= mapsArray.len() ) return
		
		var mapImage = Hud_GetChild( element, "MapImage" )
		var mapName = Hud_GetChild( element, "MapName" )
		
		string name = mapsArray[ _index + trueOffset ]
		
		RuiSetImage( Hud_GetRui( mapImage ), "basicImage", GetMapImageForMapName( name ) )
		Hud_SetText( mapName, GetMapDisplayName( name ) )
		
		if ( IsLocked( name ) )
			LockMapButton( element )
		
		MakeMapButtonVisible( element )
	}
}

void function FilterMapsArray()
{
	file.mapsArrayFiltered.clear()
	
	string searchTerm = Hud_GetUTF8Text( Hud_GetChild( file.menu, "BtnMapsSearch" ) )
	
	bool useSearch =  searchTerm != ""
	
	bool hideLocked = bool( GetConVarInt( "filter_map_hide_locked" ) )
	
	foreach ( string map in GetPrivateMatchMaps() )
	{
		bool containsTerm = Localize( GetMapDisplayName( map ) ).tolower().find( searchTerm.tolower() ) == null ? false : true
		
		if ( hideLocked && !IsLocked( map ) && ( useSearch == true ? containsTerm : true ) )
		{
			file.mapsArrayFiltered.append( map )
		}
		else if ( !hideLocked && ( useSearch == true ? containsTerm : true ) )
		{
			file.mapsArrayFiltered.append( map )
		}
	}
}

void function HideAllMapButtons()
{
	foreach ( var element in file.gridButtons )
	{
		Hud_SetVisible( element, false )
		
		var mapButton = Hud_GetChild( element, "MapButton" )
		var mapFG = Hud_GetChild( element, "MapNameLockedForeground" )
		
		Hud_SetLocked( mapButton, false )
		Hud_SetVisible( mapFG, false )
	}
}

// :trol:
void function MakeMapButtonVisible( var element )
{
	Hud_SetVisible( element, true )
}

void function LockMapButton( var element )
{
	var mapButton = Hud_GetChild( element, "MapButton" )
	var mapFG = Hud_GetChild( element, "MapNameLockedForeground" )
	
	Hud_SetVisible( mapButton, true )
	Hud_SetVisible( mapFG, true )
}

bool function IsLocked( string map )
{
	
	bool sp = map.find( "sp_" ) == 0
	if ( sp )
		return true

	if ( IsItemInEntitlementUnlock( map ) && IsValid( GetUIPlayer() ) )
	{
		if ( IsItemLocked( GetUIPlayer(), map ) && GetCurrentPlaylistVarInt( map + "_available" , 0 ) == 0 )
		{
			return true
		}
	}
	
	return false
}

//////////////////////////////
// Slider
//////////////////////////////
void function UpdateMouseDeltaBuffer(int x, int y)
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
	if ( file.mapsArrayFiltered.len() <= BUTTONS_PER_PAGE || file.mapsArrayFiltered.len() <= 12 )
	{
		FlushMouseDeltaBuffer()
		return
	}

	var sliderButton = Hud_GetChild( file.menu , "BtnMapGridSlider" )
	var sliderPanel = Hud_GetChild( file.menu , "BtnMapGridSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu , "MouseMovementCapture" )

	Hud_SetFocused(sliderButton)

	float minYPos = -42.0 * (GetScreenSize()[1] / 1080.0)
	float maxHeight = 582.0  * (GetScreenSize()[1] / 1080.0)
	float maxYPos = minYPos - (maxHeight - Hud_GetHeight( sliderPanel ))
	float useableSpace = ( maxHeight - Hud_GetHeight( sliderPanel ))

	float jump = minYPos - ( useableSpace / (  file.mapsArrayFiltered.len() / 3 + 1 ))

	// got local from official respaw scripts, without untyped throws an error
	local pos =	Hud_GetPos(sliderButton)[1]
	local newPos = pos - mouseDeltaBuffer.deltaY
	FlushMouseDeltaBuffer()

	if ( newPos < maxYPos ) newPos = maxYPos
	if ( newPos > minYPos ) newPos = minYPos

	Hud_SetPos( sliderButton , 2, newPos )
	Hud_SetPos( sliderPanel , 2, newPos )
	Hud_SetPos( movementCapture , 2, newPos )

	file.scrollOffset = -int( ( (newPos - minYPos) / useableSpace ) * ( file.mapsArrayFiltered.len() / 3 + 1 - BUTTONS_PER_PAGE) )
	UpdateMapsGrid()
}

void function UpdateListSliderHeight()
{
	var sliderButton = Hud_GetChild( file.menu , "BtnMapGridSlider" )
	var sliderPanel = Hud_GetChild( file.menu , "BtnMapGridSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu , "MouseMovementCapture" )
	
	float maps = float ( file.mapsArrayFiltered.len() / 3 )

	float maxHeight = 582.0 * (GetScreenSize()[1] / 1080.0)
	float minHeight = 80.0 * (GetScreenSize()[1] / 1080.0)

	float height = maxHeight * ( float( BUTTONS_PER_PAGE ) / maps )

	if ( height > maxHeight ) height = maxHeight
	if ( height < minHeight ) height = minHeight

	Hud_SetHeight( sliderButton , height )
	Hud_SetHeight( sliderPanel , height )
	Hud_SetHeight( movementCapture , height )
}


void function UpdateListSliderPosition()
{
	if ( file.mapsArrayFiltered.len() == 12 )
		return
	
	var sliderButton = Hud_GetChild( file.menu , "BtnMapGridSlider" )
	var sliderPanel = Hud_GetChild( file.menu , "BtnMapGridSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu , "MouseMovementCapture" )
	
	float maps = float ( file.mapsArrayFiltered.len() / 3 + 1 )

	float minYPos = -42.0 * (GetScreenSize()[1] / 1080.0)
	float useableSpace = (582.0 * (GetScreenSize()[1] / 1080.0) - Hud_GetHeight( sliderPanel ))

	float jump = minYPos - ( useableSpace / ( maps - float( BUTTONS_PER_PAGE ) ) * file.scrollOffset )

	//jump = jump * (GetScreenSize()[1] / 1080.0)

	if ( jump > minYPos ) jump = minYPos

	Hud_SetPos( sliderButton , 2, jump )
	Hud_SetPos( sliderPanel , 2, jump )
	Hud_SetPos( movementCapture , 2, jump )
}

void function OnDownArrowSelected( var button )
{
	if ( file.mapsArrayFiltered.len() <= BUTTONS_PER_PAGE || file.mapsArrayFiltered.len() <= 12 ) return
	file.scrollOffset += 1
	if ((file.scrollOffset + BUTTONS_PER_PAGE) * 3 > file.mapsArrayFiltered.len()) {
		file.scrollOffset = (file.mapsArrayFiltered.len() - BUTTONS_PER_PAGE * 3) / 3 + 1
	}
	UpdateMapsGrid()
	UpdateListSliderPosition()
	printt(file.scrollOffset)
}


void function OnUpArrowSelected( var button )
{
	file.scrollOffset -= 1
	if (file.scrollOffset < 0) {
		file.scrollOffset = 0
	}
	UpdateMapsGrid()
	UpdateListSliderPosition()
}

void function OnScrollDown( var button )
{
	if ( file.mapsArrayFiltered.len() <= BUTTONS_PER_PAGE || file.mapsArrayFiltered.len() <= 12 ) return
	file.scrollOffset += 2
	if ((file.scrollOffset + BUTTONS_PER_PAGE) * 3 > file.mapsArrayFiltered.len()) {
		file.scrollOffset = (file.mapsArrayFiltered.len() - BUTTONS_PER_PAGE * 3) / 3 + 1
	}
	UpdateMapsGrid()
	UpdateListSliderPosition()
}

void function OnScrollUp( var button )
{
	file.scrollOffset -= 2
	if (file.scrollOffset < 0) {
		file.scrollOffset = 0
	}
	UpdateMapsGrid()
	UpdateListSliderPosition()
}