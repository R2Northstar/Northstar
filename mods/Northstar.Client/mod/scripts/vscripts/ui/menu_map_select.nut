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
	
	array< var > gridInfos
	array< var > gridButtons
	
	array< string > mapsArrayFiltered
	
	int scrollOffset = 0
	
	int lastSelectedID
	
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
	
	file.gridInfos = GetElementsByClassname( file.menu, "MapGridInfo" )
	
	file.gridButtons = GetElementsByClassname( file.menu, "MapGridButtons" )
	
	AddButtonEventHandler( Hud_GetChild( Hud_GetChild( file.menu , "MapsGridPanel" ), "DummyTop" ), UIE_GET_FOCUS, OnHitDummyTop )
	AddButtonEventHandler( Hud_GetChild( Hud_GetChild( file.menu , "MapsGridPanel" ), "DummyBottom" ), UIE_GET_FOCUS, OnHitDummyBottom )
	
	// uhh
	foreach ( var button in file.gridButtons )
	{
		AddButtonEventHandler( button, UIE_CLICK, MapButton_Activate )
		AddButtonEventHandler( button, UIE_GET_FOCUS, MapButton_Focus )
	}
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
	
	Hud_SetFocused( file.gridButtons[0] )
	
	RegisterButtonPressedCallback(MOUSE_WHEEL_UP , OnScrollUp)
	RegisterButtonPressedCallback(MOUSE_WHEEL_DOWN , OnScrollDown)
	//RegisterButtonPressedCallback(KEY_TAB , OnKeyTabPressed)
}

void function OnHitDummyTop( var button )
{
	if( file.scrollOffset == 0 )
	{
		Hud_SetFocused( file.gridButtons[ file.lastSelectedID ] )
		return
	}
	
	file.scrollOffset--
	
	UpdateMapsGrid()
	UpdateListSliderPosition()
	UpdateNextMapInfo()
	
	Hud_SetFocused( file.gridButtons[ file.lastSelectedID ] )
}

void function OnHitDummyBottom( var button )
{
	if ( file.mapsArrayFiltered.len() <= BUTTONS_PER_PAGE || file.mapsArrayFiltered.len() <= 12 )
		return
		
	file.scrollOffset += 1
	
	int compensate = 0
	if ( file.mapsArrayFiltered.len() % 3 != 0 )
		compensate = 1
	
	if ((file.scrollOffset + BUTTONS_PER_PAGE) * 3 > file.mapsArrayFiltered.len())
		file.scrollOffset = (file.mapsArrayFiltered.len() - BUTTONS_PER_PAGE * 3) / 3 + compensate
	
	UpdateMapsGrid()
	UpdateListSliderPosition()
	UpdateNextMapInfo()
	
	int scriptID = file.lastSelectedID
	
	if( scriptID > file.mapsArrayFiltered.len() - 1 - file.scrollOffset * 3 )
		scriptID = file.mapsArrayFiltered.len() - file.scrollOffset * 3 - 1
	
	
	var lastButton = file.gridButtons[ scriptID ]
	
	Hud_SetFocused( lastButton )
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

	int mapID = int( Hud_GetScriptID(  button  ) )
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
	int mapID = int( Hud_GetScriptID(  button  ) )
	string mapName = file.mapsArrayFiltered[ mapID + file.scrollOffset * 3 ]
	
	file.lastSelectedID = mapID
	
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
	
	foreach ( int _index,  var element in file.gridInfos )
	{
		if ( ( _index + trueOffset ) >= mapsArray.len() ) return
		
		var mapImage = Hud_GetChild( element, "MapImage" )
		var mapName = Hud_GetChild( element, "MapName" )
		
		string name = mapsArray[ _index + trueOffset ]
		
		RuiSetImage( Hud_GetRui( mapImage ), "basicImage", GetMapImageForMapName( name ) )
		Hud_SetText( mapName, GetMapDisplayName( name ) )
		
		if ( IsLocked( name ) )
			LockMapButton( element )
		
		Hud_SetVisible( file.gridButtons[ _index ], true )
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
	foreach ( _index, var element in file.gridInfos )
	{
		Hud_SetVisible( element, false )
		
		var mapButton = file.gridButtons[ _index ]
		var mapFG = Hud_GetChild( element, "MapNameLockedForeground" )
		
		Hud_SetLocked( mapButton, false )
		Hud_SetVisible( mapButton, false )
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
	var mapFG = Hud_GetChild( element, "MapNameLockedForeground" )
	
	Hud_SetVisible( mapFG, true )
}

bool function IsLocked( string map )
{
	
	bool sp = map.find( "sp_" ) == 0 && PrivateMatch_GetSelectedMode() != "sp_coop"
	if ( sp )
		return true

	if ( IsItemInEntitlementUnlock( map ) && IsValid( GetUIPlayer() ) )
	{
		if ( IsItemLocked( GetUIPlayer(), map ) && GetCurrentPlaylistVarInt( map + "_available" , 0 ) == 0 )
		{
			return true
		}
	}
	
	if ( !PrivateMatch_IsValidMapModeCombo( map, PrivateMatch_GetSelectedMode() ) )
		return true
	
	
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

	int compensate = 0
	if ( file.mapsArrayFiltered.len() % 3 != 0 )
		compensate = 1

	file.scrollOffset = -int( ( (newPos - minYPos) / useableSpace ) * ( file.mapsArrayFiltered.len() / 3 + compensate - BUTTONS_PER_PAGE) )
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
	
	int compensate = 0
	if ( file.mapsArrayFiltered.len() % 3 != 0 )
		compensate = 1
	
	float maps = float ( file.mapsArrayFiltered.len() / 3 + compensate )

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
	if ( file.scrollOffset + 5 > file.mapsArrayFiltered.len() / 3 && file.mapsArrayFiltered.len() % 3 == 0 ) return
	
	file.scrollOffset += 1

	if ((file.scrollOffset + BUTTONS_PER_PAGE) * 3 > file.mapsArrayFiltered.len()) {
		file.scrollOffset = (file.mapsArrayFiltered.len() - BUTTONS_PER_PAGE * 3) / 3 + 1
	}
	UpdateMapsGrid()
	UpdateListSliderPosition()
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