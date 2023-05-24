untyped
global function AddModSettingsMenu
global function ModSettings_AddSetting
global function ModSettings_AddEnumSetting
global function ModSettings_AddSliderSetting
global function ModSettings_AddButton
global function ModSettings_AddModTitle
global function ModSettings_AddModCategory
global function PureModulo

// Legacy functions for backwards compatability. These will be removed eventually
global function AddConVarSetting
global function AddConVarSettingEnum
global function AddConVarSettingSlider
global function AddModSettingsButton
global function AddModTitle
global function AddModCategory

const int BUTTONS_PER_PAGE = 15
const string SETTING_ITEM_TEXT = "                        " // this is long enough to be the same size as the textentry field

enum eEmptySpaceType
{
	None,
	TopBar,
	BottomBar
}

struct ConVarData {
	string displayName
	bool isEnumSetting = false
	string conVar
	string type

	string modName
	string catName
	bool isCategoryName = false
	bool isModName = false

	bool isEmptySpace = false
	int spaceType = 0

	// SLIDER BULLSHIT
	bool sliderEnabled = false
	float min = 0.0
	float max = 1.0
	float stepSize = 0.05
	bool forceClamp = false

	bool isCustomButton = false
	void functionref() onPress

	array<string> values
	var customMenu
	bool hasCustomMenu = false
}

struct {
	var menu
	int scrollOffset = 0
	bool updatingList = false
	bool isOpen

	array<ConVarData> conVarList
	// if people use searches - i hate them but it'll do : )
	array<ConVarData> filteredList
	string filterText = ""
	table<int, int> enumRealValues
	table<string, bool> setFuncs
	array<var> modPanels
	array<var> resetModButtons
	array<MS_Slider> sliders
	string currentMod = ""
	string currentCat = ""
} file

struct {
	int deltaX = 0
	int deltaY = 0
} mouseDeltaBuffer

void function AddModSettingsMenu()
{
	AddMenu( "ModSettings", $"resource/ui/menus/mod_settings.menu", InitModMenu )
}

void function InitModMenu()
{
	file.menu = GetMenu( "ModSettings" )
	// DumpStack(2)
	AddMenuFooterOption( file.menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )

	/////////////////////////////
	// BASE NORTHSTAR SETTINGS //
	/////////////////////////////

	/*
	ModSettings_AddModTitle( "^FF000000EXAMPLE" )
	ModSettings_AddModCategory( "I wasted way too much time on this..." )
	ModSettings_AddButton( "This is a custom button you can click on!", void function() : ()
	{
		print( "HELLOOOOOO" )
	} )
	ModSettings_AddEnumSetting( "filter_mods", "Very Huge Enum Example", split( "Never gonna give you up Never gonna let you down Never gonna run around and desert you Never gonna make you cry Never gonna say goodbye Never gonna tell a lie and hurt you", " " ) )
	*/
	// Nuke weird rui on filter switch :D
	// RuiSetString( Hud_GetRui( Hud_GetChild( file.menu, "SwtBtnShowFilter" ) ), "buttonText", "" )

	file.modPanels = GetElementsByClassname( file.menu, "ModButton" )

	AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, OnModMenuOpened )
	AddMenuEventHandler( file.menu, eUIEvent.MENU_CLOSE, OnModMenuClosed )

	int len = file.modPanels.len()
	for ( int i = 0; i < len; i++ )
	{

		// AddButtonEventHandler( button, UIE_CHANGE, OnSettingButtonPressed  )
		// get panel
		var panel = file.modPanels[i]

		// reset to default nav
		var child = Hud_GetChild( panel, "BtnMod" )


		child.SetNavUp( Hud_GetChild( file.modPanels[ int( PureModulo( i - 1, len ) ) ], "BtnMod" ) )
		child.SetNavDown( Hud_GetChild( file.modPanels[ int( PureModulo( i + 1, len ) ) ], "BtnMod" ) )

		// Enum button nav
		child = Hud_GetChild( panel, "EnumSelectButton" )
		Hud_DialogList_AddListItem( child, SETTING_ITEM_TEXT, "main" )
		Hud_DialogList_AddListItem( child, SETTING_ITEM_TEXT, "next" )
		Hud_DialogList_AddListItem( child, SETTING_ITEM_TEXT, "prev" )

		child.SetNavUp( Hud_GetChild( file.modPanels[ int( PureModulo( i - 1, len ) ) ], "EnumSelectButton" ) )
		child.SetNavDown( Hud_GetChild( file.modPanels[ int( PureModulo( i + 1, len ) ) ], "EnumSelectButton" ) )
		Hud_AddEventHandler( child, UIE_CLICK, UpdateEnumSetting )

		// reset button nav

		child = Hud_GetChild( panel, "ResetModToDefault" )
		Hud_AddEventHandler( child, UIE_GET_FOCUS, void function( var child ) : (panel)
		{
			Hud_SetColor( Hud_GetChild( panel, "ResetModImage" ), 0, 0, 0, 255 )
		})
		Hud_AddEventHandler( child, UIE_LOSE_FOCUS, void function( var child ) : (panel)
		{
			Hud_SetColor( Hud_GetChild( panel, "ResetModImage" ), 180, 180, 180, 180 )
		})

		child.SetNavUp( Hud_GetChild( file.modPanels[ int( PureModulo( i - 1, len ) ) ], "ResetModToDefault" ) )
		child.SetNavDown( Hud_GetChild( file.modPanels[ int( PureModulo( i + 1, len ) ) ], "ResetModToDefault" ) )

		Hud_AddEventHandler( child, UIE_CLICK, ResetConVar )
		file.resetModButtons.append(child)

		// text field nav
		child = Hud_GetChild( panel, "TextEntrySetting" )

		Hud_AddEventHandler( child, UIE_LOSE_FOCUS, SendTextPanelChanges )

		child.SetNavUp( Hud_GetChild( file.modPanels[ int( PureModulo( i - 1, len ) ) ], "TextEntrySetting" ) )
		child.SetNavDown( Hud_GetChild( file.modPanels[ int( PureModulo( i + 1, len ) ) ], "TextEntrySetting" ) )

		child = Hud_GetChild( panel, "Slider" )

		child.SetNavUp( Hud_GetChild( file.modPanels[ int( PureModulo( i - 1, len ) ) ], "Slider" ) )
		child.SetNavDown( Hud_GetChild( file.modPanels[ int( PureModulo( i + 1, len ) ) ], "Slider" ) )

		file.sliders.append( MS_Slider_Setup( child ) )

		Hud_AddEventHandler( child, UIE_CHANGE, OnSliderChange )

		child = Hud_GetChild( panel, "OpenCustomMenu" )

		Hud_AddEventHandler( child, UIE_CLICK, CustomButtonPressed )
	}

	// Hud_AddEventHandler( Hud_GetChild( file.menu, "BtnModsSearch" ), UIE_LOSE_FOCUS, OnFilterTextPanelChanged )
	Hud_AddEventHandler( Hud_GetChild( file.menu, "BtnFiltersClear" ), UIE_CLICK, OnClearButtonPressed )
	// mouse delta
	AddMouseMovementCaptureHandler( file.menu, UpdateMouseDeltaBuffer )

	Hud_AddEventHandler( Hud_GetChild( file.menu, "BtnModsSearch" ), UIE_CHANGE, void function ( var inputField ) : ()
	{
		file.filterText = Hud_GetUTF8Text( inputField )
		OnFiltersChange()
	} )
}

// "PureModulo"
// Used instead of modulo in some places.
// Why? beacuse PureModulo loops back onto positive numbers instead of going into the negatives.
// DO NOT TOUCH.
// a / b != floor( float( a ) / b )
// int( float( a ) / b ) != floor( float( a ) / b )
// Examples:
// -1 % 5 = -1
// PureModulo( -1, 5 ) = 4
float function PureModulo( int a, int b )
{
	return b * ( ( float( a ) / b ) - floor( float( a ) / b ) )
}

void function ResetConVar( var button )
{
	ConVarData conVar = file.filteredList[ int ( Hud_GetScriptID( Hud_GetParent( button ) ) ) + file.scrollOffset ]

	if ( conVar.isCategoryName )
		ShowAreYouSureDialog( "#ARE_YOU_SURE", ResetAllConVarsForModEventHandler( conVar.catName ), "#WILL_RESET_ALL_SETTINGS"  )
	else
		ShowAreYouSureDialog( "#ARE_YOU_SURE", ResetConVarEventHandler( int ( Hud_GetScriptID( Hud_GetParent( button ) ) ) + file.scrollOffset ), Localize( "#WILL_RESET_SETTING", Localize( conVar.displayName ) ) )
}

void function ShowAreYouSureDialog( string header, void functionref() func, string details )
{
	DialogData dialogData
	dialogData.header = header
	dialogData.message = details

	AddDialogButton( dialogData, "#NO" )
	AddDialogButton( dialogData, "#YES", func )

	AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )
	AddDialogFooter( dialogData, "#B_BUTTON_BACK" )

	OpenDialog( dialogData )
}

void functionref() function ResetAllConVarsForModEventHandler( string catName )
{
	return void function() : ( catName )
	{
		for ( int i = 0; i < file.conVarList.len(); i++ )
		{
			ConVarData c = file.conVarList[ i ]
			if ( c.catName != catName || c.isCategoryName || c.isEmptySpace || c.isCustomButton )
				continue
			SetConVarToDefault( c.conVar )

			int index = file.filteredList.find( c )
			if ( file.filteredList.find( c ) < 0 )
				continue

			if ( min( BUTTONS_PER_PAGE - 1, max( 0, index - file.scrollOffset ) ) == index - file.scrollOffset )
			{
				Hud_SetText( Hud_GetChild( file.modPanels[ index - file.scrollOffset ], "TextEntrySetting" ), c.isEnumSetting ? c.values[ GetConVarInt( c.conVar ) ] : GetConVarString( c.conVar ) )
				if( c.sliderEnabled )
					MS_Slider_SetValue( file.sliders[ index - file.scrollOffset ], GetConVarFloat( c.conVar ) )
			}
		}
	}
}

void functionref() function ResetConVarEventHandler( int modIndex )
{
	return void function() : ( modIndex )
	{
		ConVarData c = file.filteredList[ modIndex ]
		SetConVarToDefault( c.conVar )
		if ( min( BUTTONS_PER_PAGE - 1, max( 0, modIndex - file.scrollOffset ) ) == modIndex - file.scrollOffset )
		{
			Hud_SetText( Hud_GetChild( file.modPanels[ modIndex - file.scrollOffset ], "TextEntrySetting" ), c.isEnumSetting ? c.values[ GetConVarInt( c.conVar ) ] : GetConVarString( c.conVar ) )
			if( c.sliderEnabled )
				MS_Slider_SetValue( file.sliders[ modIndex - file.scrollOffset ], GetConVarFloat( c.conVar ) )
		}
	}
}

////////////
// slider //
////////////
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
	if ( file.filteredList.len() <= 15 )
	{
		FlushMouseDeltaBuffer()
		return
	}

	var sliderButton = Hud_GetChild( file.menu, "BtnModListSlider" )
	var sliderPanel = Hud_GetChild( file.menu, "BtnModListSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu, "MouseMovementCapture" )

	Hud_SetFocused( sliderButton )

	float minYPos = -40.0 * ( GetScreenSize()[1] / 1080.0 ) // why the hardcoded positions?!?!?!?!?!
	float maxHeight = 615.0  * ( GetScreenSize()[1] / 1080.0 )
	float maxYPos = minYPos - ( maxHeight - Hud_GetHeight( sliderPanel ) )
	float useableSpace = ( maxHeight - Hud_GetHeight( sliderPanel ) )

	float jump = minYPos - ( useableSpace / ( float( file.filteredList.len() ) ) )

	int pos = expect int( expect array( Hud_GetPos( sliderButton ) )[1] )
	float newPos = float( pos - mouseDeltaBuffer.deltaY )
	FlushMouseDeltaBuffer()

	if ( newPos < maxYPos ) newPos = maxYPos
	if ( newPos > minYPos ) newPos = minYPos

	Hud_SetPos( sliderButton, 2, newPos )
	Hud_SetPos( sliderPanel, 2, newPos )
	Hud_SetPos( movementCapture, 2, newPos )

	file.scrollOffset = -int( ( ( newPos - minYPos ) / useableSpace ) * ( file.filteredList.len() - BUTTONS_PER_PAGE ) )
	UpdateList()
}

void function UpdateListSliderHeight()
{
	var sliderButton = Hud_GetChild( file.menu, "BtnModListSlider" )
	var sliderPanel = Hud_GetChild( file.menu, "BtnModListSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu, "MouseMovementCapture" )

	float mods = float ( file.filteredList.len() )

	float maxHeight = 615.0 * ( GetScreenSize()[1] / 1080.0 ) // why the hardcoded 320/80???
	float minHeight = 80.0 * ( GetScreenSize()[1] / 1080.0 )

	float height = maxHeight * ( float( BUTTONS_PER_PAGE ) / mods )

	if ( height > maxHeight ) height = maxHeight
	if ( height < minHeight ) height = minHeight

	Hud_SetHeight( sliderButton, height )
	Hud_SetHeight( sliderPanel, height )
	Hud_SetHeight( movementCapture, height )
}

void function UpdateList()
{
	Hud_SetFocused( Hud_GetChild( file.menu, "BtnModsSearch" ) )
	file.updatingList = true

	array<ConVarData> filteredList = []

	array<string> filters = split( file.filterText, "," )
	array<ConVarData> list = file.conVarList
	if ( filters.len() <= 0 )
		filters.append( "" )
	foreach( string f in filters )
	{
		string filter = strip( f )
		string lastCatNameInFilter = ""
		string lastModNameInFilter = ""
		int curCatIndex = 0
		int curModTitleIndex = -1
		for ( int i = 0; i < list.len(); i++ )
		{
			ConVarData prev = list[ maxint( 0, i - 1 ) ]
			ConVarData c = list[i]
			ConVarData next = list[ minint( list.len() - 1, i + 1 ) ]
			if ( c.isEmptySpace )
				continue

			string displayName = c.displayName
			if ( c.isModName )
			{
				displayName = c.modName
				curModTitleIndex = i
			}
			if ( c.isCategoryName )
			{
				displayName = c.catName
				curCatIndex = i
			}
			if ( filter == "" || SanitizeDisplayName( Localize( displayName ) ).tolower().find( filter.tolower() ) != null )
			{
				if ( c.isModName )
				{
					lastModNameInFilter = c.modName
					array<ConVarData> modVars = GetAllVarsInMod( list, c.modName )
					if ( filteredList.len() <= 0 && modVars[0].spaceType == eEmptySpaceType.None )
						filteredList.extend( modVars.slice( 1, modVars.len() ) )
					else filteredList.extend( modVars )

					i += modVars.len() - 1
				}
				else if ( c.isCategoryName )
				{
					if ( lastModNameInFilter != c.modName )
					{
						array<ConVarData> modVars = GetModConVarDatas( list, curModTitleIndex )
						if ( filteredList.len() <= 0 && modVars[0].spaceType == eEmptySpaceType.None )
							filteredList.extend( modVars.slice( 1, modVars.len() ) )
						else filteredList.extend( modVars )

						lastModNameInFilter = c.modName
					}
					filteredList.extend( GetAllVarsInCategory( list, c.catName ) )
					i += GetAllVarsInCategory( list, c.catName ).len() - 1
					lastCatNameInFilter = c.catName
				}
				else
				{
					if ( lastModNameInFilter != c.modName )
					{
						array<ConVarData> modVars = GetModConVarDatas( list, curModTitleIndex )
						if ( filteredList.len() <= 0 && modVars[0].spaceType == eEmptySpaceType.None )
							filteredList.extend( modVars.slice( 1, modVars.len() ) )
						else filteredList.extend( modVars )

						lastModNameInFilter = c.modName
					}
					if ( lastCatNameInFilter != c.catName )
					{
						filteredList.extend( GetCatConVarDatas( curCatIndex ) )
						lastCatNameInFilter = c.catName
					}
					filteredList.append( c )
				}
			}
		}
		list = filteredList
		filteredList = []
	}
	filteredList = list


	file.filteredList = filteredList

	int j = int( min( file.filteredList.len() + file.scrollOffset, BUTTONS_PER_PAGE ) )

	for ( int i = 0; i < BUTTONS_PER_PAGE; i++ )
	{
		Hud_SetEnabled( file.modPanels[i], i < j )
		Hud_SetVisible( file.modPanels[i], i < j )

		if ( i < j )
			SetModMenuNameText( file.modPanels[i] )
	}
	file.updatingList = false

	if ( file.conVarList.len() <= 0 )
	{
		Hud_SetVisible( Hud_GetChild( file.menu, "NoResultLabel" ), true )
		Hud_SetText( Hud_GetChild( file.menu, "NoResultLabel" ), "#NO_MODS" )
	}
	else if ( file.filteredList.len() <= 0 )
	{
		Hud_SetVisible( Hud_GetChild( file.menu, "NoResultLabel" ), true )
		Hud_SetText( Hud_GetChild( file.menu, "NoResultLabel" ), "#NO_RESULTS" )
	}
	else
	{
		Hud_Hide( Hud_GetChild( file.menu, "NoResultLabel" ) )
	}
}

array<ConVarData> function GetModConVarDatas( array<ConVarData> arr, int index )
{
	if ( index <= 1 )
		return [ arr[ index - 1 ], arr[ index ], arr[ index + 1 ] ]
	return [ arr[ index - 2 ], arr[ index - 1 ], arr[ index ], arr[ index + 1 ] ]
}

array<ConVarData> function GetCatConVarDatas( int index )
{
	if ( file.conVarList[ index - 1 ].spaceType != eEmptySpaceType.None )
		return [ file.conVarList[ index ] ]
	return [ file.conVarList[ index - 1 ], file.conVarList[ index ] ]
}

array<ConVarData> function GetAllVarsInCategory( array<ConVarData> arr, string catName )
{
	array<ConVarData> vars = []
	for ( int i = 0; i < arr.len(); i++ )
	{
		ConVarData c = arr[i]
		if ( c.catName == catName )
		{
			vars.append( arr[i] )
		}
	}
	return vars
}

array<ConVarData> function GetAllVarsInMod( array<ConVarData> arr, string modName )
{
	array<ConVarData> vars = []
	for ( int i = 0; i < arr.len(); i++ )
	{
		ConVarData c = arr[i]
		if ( c.modName == modName )
		{
			vars.append( arr[i] )
		}
	}
	return vars
}

void function SetModMenuNameText( var button )
{
	int index = int ( Hud_GetScriptID( button ) ) + file.scrollOffset
	ConVarData conVar = file.filteredList[ int ( Hud_GetScriptID( button ) ) + file.scrollOffset ]

	var panel = file.modPanels[ int ( Hud_GetScriptID( button ) ) ]

	var label = Hud_GetChild( panel, "BtnMod" )
	var textField = Hud_GetChild( panel, "TextEntrySetting" )
	var enumButton = Hud_GetChild( panel, "EnumSelectButton" )
	var resetButton = Hud_GetChild( panel, "ResetModToDefault" )
	var resetVGUI = Hud_GetChild( panel, "ResetModImage" )
	var bottomLine = Hud_GetChild( panel, "BottomLine" )
	var topLine = Hud_GetChild( panel, "TopLine" )
	var modTitle = Hud_GetChild( panel, "ModTitle" )
	var customMenuButton = Hud_GetChild( panel, "OpenCustomMenu")
	var slider = Hud_GetChild( panel, "Slider" )
	Hud_SetVisible( slider, false )
	Hud_SetEnabled( slider, true )


	if ( conVar.isEmptySpace )
	{
		string s = ""
		Hud_SetPos( label, 0, 0 )
		Hud_SetVisible( label, false )
		Hud_SetVisible( textField, false )
		Hud_SetVisible( enumButton, false )
		Hud_SetVisible( resetButton, false )
		Hud_SetVisible( resetVGUI, false )
		Hud_SetVisible( modTitle, false )
		Hud_SetVisible( customMenuButton, false )
		Hud_SetVisible( bottomLine, false )
		Hud_SetVisible( topLine, false )
		switch ( conVar.spaceType )
		{
			case eEmptySpaceType.TopBar:
				Hud_SetVisible( topLine, true )
				return

			case eEmptySpaceType.BottomBar:
				Hud_SetVisible( bottomLine, true )
				return

			case eEmptySpaceType.None:
				return
		}
	}

	Hud_SetVisible( textField, !conVar.isCategoryName )
	Hud_SetVisible( bottomLine, conVar.isCategoryName || conVar.spaceType == eEmptySpaceType.BottomBar )
	Hud_SetVisible( topLine, false )
	Hud_SetVisible( enumButton, !conVar.isCategoryName && conVar.isEnumSetting )
	Hud_SetVisible( modTitle, conVar.isModName )
	Hud_SetVisible( customMenuButton, false )
	float scaleX = GetScreenSize()[1] / 1080.0
	float scaleY = GetScreenSize()[1] / 1080.0
	if ( conVar.sliderEnabled )
	{
		Hud_SetSize( slider, int( 320 * scaleX ), int( 45 * scaleY ) )
		MS_Slider s = file.sliders[ int ( Hud_GetScriptID( button ) ) ]
		MS_Slider_SetMin( s, conVar.min )
		MS_Slider_SetMax( s, conVar.max )
		MS_Slider_SetStepSize( s, conVar.stepSize )
		MS_Slider_SetValue( s, GetConVarFloat( conVar.conVar ) )
	}
	else Hud_SetSize( slider, 0, int( 45 * scaleY ) )
	if ( conVar.isCustomButton )
	{
		Hud_SetVisible( label, false )
		Hud_SetVisible( textField, false )
		Hud_SetVisible( enumButton, false )
		Hud_SetVisible( resetButton, false )
		Hud_SetVisible( modTitle, false )
		Hud_SetVisible( resetVGUI, false )
		Hud_SetVisible( customMenuButton, true )
		Hud_SetText( customMenuButton, conVar.displayName )
	}
	else if ( conVar.isModName )
	{
		Hud_SetText( modTitle, conVar.modName )
		Hud_SetPos( label, 0, 0 )
		Hud_SetVisible( label, false )
		Hud_SetVisible( textField, false )
		Hud_SetVisible( enumButton, false )
		Hud_SetVisible( resetButton, false )
		Hud_SetVisible( resetVGUI, false )
		Hud_SetVisible( bottomLine, false )
		Hud_SetVisible( topLine, false )
	}
	else if ( conVar.isCategoryName )
	{
		Hud_SetText( label, conVar.catName )
		Hud_SetPos( label, 0, 0 )
		Hud_SetSize( label, int( scaleX * ( 1180 - 420 - 85 ) ), int( scaleY * 40 ) )
		Hud_SetVisible( label, true )
		Hud_SetVisible( textField, false )
		Hud_SetVisible( enumButton, false )
		Hud_SetVisible( resetButton, true )
		Hud_SetVisible( resetVGUI, true )

		Hud_SetSize( resetButton, int( scaleX * 90 ), int( scaleY * 40 ) )
	}
	else {
		Hud_SetVisible( slider, conVar.sliderEnabled )

		Hud_SetText( label, conVar.displayName )
		if (conVar.type == "float")
			Hud_SetText( textField, string( GetConVarFloat(conVar.conVar) ) )
		else Hud_SetText( textField, conVar.isEnumSetting ? conVar.values[ GetConVarInt( conVar.conVar ) ] : GetConVarString( conVar.conVar ) )
		Hud_SetPos( label, int(scaleX * 25), 0 )
		Hud_SetText( resetButton, "" )
		if (conVar.sliderEnabled)
			Hud_SetSize( label, int(scaleX * (375 + 85)), int(scaleY * 40) )
		else Hud_SetSize( label, int(scaleX * (375 + 405)), int(scaleY * 40) )
		if ( conVar.type == "float" )
			Hud_SetText( textField, string( GetConVarFloat( conVar.conVar ) ) )
		else Hud_SetText( textField, conVar.isEnumSetting ? conVar.values[ GetConVarInt( conVar.conVar ) ] : GetConVarString( conVar.conVar ) )
		Hud_SetPos( label, int( scaleX * 25 ), 0 )
		Hud_SetText( resetButton, "" )
		Hud_SetSize( resetButton, int( scaleX * 90 ), int( scaleY * 40 ) )
		if ( conVar.sliderEnabled )
			Hud_SetSize( label, int( scaleX * ( 375 + 85 ) ), int( scaleY * 40 ) )
		else Hud_SetSize( label, int( scaleX * ( 375 + 405 ) ), int( scaleY * 40 ) )
		Hud_SetVisible( label, true )
		Hud_SetVisible( textField, true )
		Hud_SetVisible( resetButton, true )
		Hud_SetVisible( resetVGUI, true )
	}
}

void function CustomButtonPressed( var button )
{
	var panel = Hud_GetParent( button )
	ConVarData c = file.filteredList[ int( Hud_GetScriptID( panel ) ) + file.scrollOffset ]
	c.onPress()
}

void function OnScrollDown( var button )
{
	if ( file.filteredList.len() <= BUTTONS_PER_PAGE ) return
	file.scrollOffset += 5
	if ( file.scrollOffset + BUTTONS_PER_PAGE > file.filteredList.len() )
	{
		file.scrollOffset = file.filteredList.len() - BUTTONS_PER_PAGE
	}
	UpdateList()
	UpdateListSliderPosition()
}

void function OnScrollUp( var button )
{
	file.scrollOffset -= 5
	if ( file.scrollOffset < 0 )
	{
		file.scrollOffset = 0
	}
	UpdateList()
	UpdateListSliderPosition()
}

void function UpdateListSliderPosition()
{
	var sliderButton = Hud_GetChild( file.menu , "BtnModListSlider" )
	var sliderPanel = Hud_GetChild( file.menu , "BtnModListSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu , "MouseMovementCapture" )

	float mods = float ( file.filteredList.len() )

	float minYPos = -40.0 * ( GetScreenSize()[1] / 1080.0 )
	float useableSpace = ( 615.0 * ( GetScreenSize()[1] / 1080.0 ) - Hud_GetHeight( sliderPanel ) )

	float jump = minYPos - ( useableSpace / ( mods - float( BUTTONS_PER_PAGE ) ) * file.scrollOffset )


	if ( jump > minYPos ) jump = minYPos

	Hud_SetPos( sliderButton , 2, jump )
	Hud_SetPos( sliderPanel , 2, jump )
	Hud_SetPos( movementCapture , 2, jump )
}

void function OnModMenuOpened()
{
	if( !file.isOpen )
	{
		file.scrollOffset = 0
		file.filterText = ""

		RegisterButtonPressedCallback( MOUSE_WHEEL_UP , OnScrollUp )
		RegisterButtonPressedCallback( MOUSE_WHEEL_DOWN , OnScrollDown )
		RegisterButtonPressedCallback( MOUSE_LEFT , OnClick )

		OnFiltersChange()
		file.isOpen = true
	}
}

void function OnClick( var button )
{
	if (file.resetModButtons.contains(GetFocus()))
		thread CheckFocus(GetFocus())
	if (GetFocus() == Hud_GetChild(file.menu, "NoResultLabel"))
		thread CheckFocus(GetFocus())
}

void function CheckFocus( var button )
{
	wait 0.05
	if (file.resetModButtons.contains(GetFocus()))
	{
		thread ResetConVar(GetFocus())
	}
	if (GetFocus() == Hud_GetChild(file.menu, "NoResultLabel"))
		LaunchExternalWebBrowser( "https://northstar.thunderstore.io/", WEBBROWSER_FLAG_FORCEEXTERNAL )
}

void function OnFiltersChange()
{
	file.scrollOffset = 0

	UpdateList()

	UpdateListSliderHeight()
}

void function OnModMenuClosed()
{
	DeregisterButtonPressedCallback( MOUSE_WHEEL_UP , OnScrollUp )
	DeregisterButtonPressedCallback( MOUSE_WHEEL_DOWN , OnScrollDown )
	DeregisterButtonPressedCallback( MOUSE_LEFT , OnClick )

	file.scrollOffset = 0
	UpdateListSliderPosition()
	file.isOpen = false
}

void function ModSettings_AddModTitle( string modName, int stackPos = 2 )
{
	file.currentMod = modName
	if ( file.conVarList.len() > 0 )
	{
		ConVarData catData

		catData.isEmptySpace = true
		catData.modName = file.currentMod

		file.conVarList.append( catData )
	}
	ConVarData topBar
	topBar.isEmptySpace = true
	topBar.modName = modName
	topBar.spaceType = eEmptySpaceType.TopBar


	ConVarData modData

	modData.modName = modName
	modData.displayName = modName
	modData.isModName = true


	ConVarData botBar
	botBar.isEmptySpace = true
	botBar.modName = modName
	botBar.spaceType = eEmptySpaceType.BottomBar
	file.conVarList.extend( [ topBar, modData, botBar ] )
	file.setFuncs[ expect string( getstackinfos( stackPos )[ "func" ] ) ] <- false
}

void function AddModTitle( string modName, int stackPos = 2 )
{
	ModSettings_AddModTitle( modName, stackPos + 1 )
}

void function ModSettings_AddModCategory( string catName, int stackPos = 2 )
{
	if ( !( getstackinfos( stackPos )[ "func" ] in file.setFuncs ) )
		throw getstackinfos( stackPos )[ "src" ] + " #" + getstackinfos( stackPos )[ "line" ] + "\nCannot add a category before a mod title!"
	
	ConVarData space
	space.isEmptySpace = true
	space.modName = file.currentMod
	space.catName = catName
	file.conVarList.append( space )

	ConVarData catData

	catData.catName = catName
	catData.displayName = catName
	catData.modName = file.currentMod
	catData.isCategoryName = true

	file.conVarList.append( catData )

	file.currentCat = catName
	file.setFuncs[ expect string( getstackinfos( stackPos )[ "func" ] ) ] = true
}

void function AddModCategory( string catName, int stackPos = 2 )
{
	ModSettings_AddModCategory( catName, stackPos + 1 )
}

void function ModSettings_AddButton( string buttonLabel, void functionref() onPress, int stackPos = 2 )
{
	if ( !( getstackinfos( stackPos )[ "func" ] in file.setFuncs ) || !file.setFuncs[ expect string( getstackinfos( stackPos )[ "func" ] ) ] )
		throw getstackinfos( stackPos )[ "src" ] + " #" + getstackinfos( stackPos )[ "line" ] + "\nCannot add a button before a category and mod title!"

	ConVarData data

	data.isCustomButton = true
	data.displayName = buttonLabel
	data.modName = file.currentMod
	data.catName = file.currentCat
	data.onPress = onPress

	file.conVarList.append( data )
}

void function AddModSettingsButton( string buttonLabel, void functionref() onPress, int stackPos = 2 )
{
	ModSettings_AddButton( buttonLabel, onPress, stackPos + 1 )
}

void function ModSettings_AddSetting( string conVar, string displayName, string type = "", int stackPos = 2 )
{
	if ( !( getstackinfos( stackPos )[ "func" ] in file.setFuncs ) || !file.setFuncs[ expect string( getstackinfos( stackPos )[ "func" ] ) ] )
		throw getstackinfos( stackPos )[ "src" ] + " #" + getstackinfos( stackPos )[ "line" ] + "\nCannot add a setting before a category and mod title!"
	ConVarData data

	data.catName = file.currentCat
	data.conVar = conVar
	data.modName = file.currentMod
	data.displayName = displayName
	data.type = type

	file.conVarList.append( data )
}

void function AddConVarSetting( string conVar, string displayName, string type = "", int stackPos = 2 )
{
	ModSettings_AddSetting( conVar, displayName, type, stackPos + 1 )
}

void function ModSettings_AddSliderSetting( string conVar, string displayName, float min = 0.0, float max = 1.0, float stepSize = 0.1, bool forceClamp = false, int stackPos = 2 )
{
	if ( !( getstackinfos( stackPos )[ "func" ] in file.setFuncs ) || !file.setFuncs[ expect string( getstackinfos( stackPos )[ "func" ] ) ] )
		throw getstackinfos( stackPos )[ "src" ] + " #" + getstackinfos( stackPos )[ "line" ] + "\nCannot add a setting before a category and mod title!"
	ConVarData data

	data.catName = file.currentCat
	data.conVar = conVar
	data.modName = file.currentMod
	data.displayName = displayName
	data.type = "float"
	data.sliderEnabled = true
	data.forceClamp = false
	data.min = min
	data.max = max
	data.stepSize = stepSize

	file.conVarList.append( data )
}

void function AddConVarSettingSlider( string conVar, string displayName, float min = 0.0, float max = 1.0, float stepSize = 0.1, bool forceClamp = false, int stackPos = 2 )
{
	ModSettings_AddSliderSetting( conVar, displayName, min, max, stepSize, forceClamp, stackPos + 1 )
}

void function ModSettings_AddEnumSetting( string conVar, string displayName, array<string> values, int stackPos = 2 )
{
	if ( !( getstackinfos( stackPos )[ "func" ] in file.setFuncs ) || !file.setFuncs[ expect string( getstackinfos( stackPos )[ "func" ] ) ] )
		throw getstackinfos( stackPos )[ "src" ] + " #" + getstackinfos( stackPos )[ "line" ] + "\nCannot add a setting before a category and mod title!"
	ConVarData data

	data.catName = file.currentCat
	data.modName = file.currentMod
	data.conVar = conVar
	data.displayName = displayName
	data.values = values
	data.isEnumSetting = true
	data.min = 0
	data.max = values.len() - 1.0
	data.sliderEnabled = values.len() > 2
	data.forceClamp = true
	data.stepSize = 1

	file.conVarList.append( data )
}

void function AddConVarSettingEnum( string conVar, string displayName, array<string> values, int stackPos = 2 )
{
	ModSettings_AddEnumSetting( conVar, displayName, values, stackPos + 1 )
}

void function OnSliderChange( var button )
{
	if ( file.updatingList )
		return
	var panel = Hud_GetParent( button )
	ConVarData c = file.filteredList[ int( Hud_GetScriptID( panel ) ) + file.scrollOffset ]
	var textPanel = Hud_GetChild( panel, "TextEntrySetting" )

	if ( c.isEnumSetting )
	{
		int val = int( RoundToNearestInt( Hud_SliderControl_GetCurrentValue( button ) ) )
		SetConVarInt( c.conVar, val )
		Hud_SetText( textPanel, ( c.values[ GetConVarInt( c.conVar ) ] ) )
		MS_Slider_SetValue( file.sliders[ int( Hud_GetScriptID( Hud_GetParent( textPanel ) ) ) ], float( val ) )

		return
	}
	float val = Hud_SliderControl_GetCurrentValue( button )
	if ( c.forceClamp )
	{
		int mod = int( RoundToNearestInt( val % c.stepSize / c.stepSize ) )
		val = ( int( val / c.stepSize ) + mod ) * c.stepSize
	}
	SetConVarFloat( c.conVar, val )
	MS_Slider_SetValue( file.sliders[ int( Hud_GetScriptID( Hud_GetParent( textPanel ) ) ) ], val )

	Hud_SetText( textPanel, string( GetConVarFloat( c.conVar ) ) )
}

void function SendTextPanelChanges( var textPanel )
{
	ConVarData c = file.filteredList[ int( Hud_GetScriptID( Hud_GetParent( textPanel ) ) ) + file.scrollOffset ]
	if ( c.conVar == "" ) return
	// enums don't need to do this
	if ( !c.isEnumSetting )
	{
		string newSetting = Hud_GetUTF8Text( textPanel )

		switch ( c.type )
		{
			case "int":
				try
				{
					SetConVarInt( c.conVar, newSetting.tointeger() )
				}
				catch ( ex )
				{
					ThrowInvalidValue( "This setting is an integer, and only accepts whole numbers." )
					Hud_SetText( textPanel, GetConVarString( c.conVar ) )
				}
			case "bool":
				if ( newSetting != "0" && newSetting != "1" )
				{
					ThrowInvalidValue( "This setting is a boolean, and only accepts values of 0 or 1." )

					// set back to previous value : )
					Hud_SetText( textPanel, string( GetConVarBool( c.conVar ) ) )

					break
				}
				SetConVarBool( c.conVar, newSetting == "1" )
				break
			case "float":
				try
				{
					SetConVarFloat( c.conVar, newSetting.tofloat() )
				}
				catch ( ex )
				{
					printt( ex )
					ThrowInvalidValue( "This setting is a float, and only accepts a number - we could not parse this!\n\n( Use \".\" for the floating point, not \",\". )" )
				}
				if ( c.sliderEnabled )
				{
					var panel = Hud_GetParent( textPanel )
					MS_Slider s = file.sliders[ int ( Hud_GetScriptID( panel ) ) ]

					MS_Slider_SetValue( s, GetConVarFloat( c.conVar ) )
				}
				break
			case "float2":
				try
				{
					array<string> split = split( newSetting, " " )
					if ( split.len() != 2 )
					{
						ThrowInvalidValue( "This setting is a float2, and only accepts a pair of numbers - you put in " + split.len() + "!" )
						Hud_SetText( textPanel, GetConVarString( c.conVar ) )
						break
					}
					vector settingTest = < split[0].tofloat(), split[1].tofloat(), 0 >

					SetConVarString( c.conVar, newSetting )
				}
				catch ( ex )
				{
					ThrowInvalidValue( "This setting is a float2, and only accepts a pair of numbers - you put something we could not parse!\n\n( Use \".\" for the floating point, not \",\". )" )
					Hud_SetText( textPanel, GetConVarString( c.conVar ) )
				}
				break
			// idk sometimes it's called Float3 most of the time it's called vector, I am not complaining.
			case "vector":
			case "float3":
				try
				{
					array<string> split = split( newSetting, " " )
					if ( split.len() != 3 )
					{
						ThrowInvalidValue( "This setting is a float3, and only accepts a trio of numbers - you put in " + split.len() + "!" )
						Hud_SetText( textPanel, GetConVarString( c.conVar ) )
						break
					}
					vector settingTest = < split[0].tofloat(), split[1].tofloat(), 0 >

					SetConVarString( c.conVar, newSetting )
				}
				catch ( ex )
				{
					ThrowInvalidValue( "This setting is a float3, and only accepts a trio of numbers - you put something we could not parse!\n\n( Use \".\" for the floating point, not \",\". )" )
					Hud_SetText( textPanel, GetConVarString( c.conVar ) )
				}
				break
			default:
				SetConVarString( c.conVar, newSetting )
				break;
		}
	}
	else Hud_SetText( textPanel, Localize( c.values[ GetConVarInt( c.conVar ) ] ) )
}

void function ThrowInvalidValue( string desc )
{
	DialogData dialogData
	dialogData.header = "Invalid Value"
	dialogData.image = $"ui/menu/common/dialog_error"
	dialogData.message = desc
	AddDialogButton( dialogData, "#OK" )
	OpenDialog( dialogData )
}

void function UpdateEnumSetting( var button )
{
	int scriptId = int( Hud_GetScriptID( Hud_GetParent( button ) ) )
	ConVarData c = file.filteredList[ scriptId + file.scrollOffset ]

	var panel = file.modPanels[ scriptId ]

	var textPanel = Hud_GetChild( panel, "TextEntrySetting" )

	string selectionVal = Hud_GetDialogListSelectionValue( button )

	if ( selectionVal == "main" )
		return

	int enumVal = GetConVarInt( c.conVar )
	if ( selectionVal == "next" ) // enum val += 1
		enumVal = ( enumVal + 1 ) % c.values.len()
	else // enum val -= 1
	{
		enumVal--
		if ( enumVal == -1 )
			enumVal = c.values.len() - 1
	}

	SetConVarInt( c.conVar, enumVal )
	Hud_SetText( textPanel, c.values[ enumVal ] )

	Hud_SetDialogListSelectionValue( button, "main" )
}

void function OnClearButtonPressed( var button )
{
	file.filterText = ""
	Hud_SetText( Hud_GetChild( file.menu, "BtnModsSearch" ), "" )

	OnFiltersChange()
}

string function SanitizeDisplayName( string displayName )
{
	array<string> parts = split( displayName, "^" )
	string result = ""
	if ( parts.len() == 1 )
		return parts[0]
	foreach ( string p in parts )
	{
		if ( p == "" )
		{
			result += "^"
			continue
		}
		int i = 0
		for ( i = 0; i < 8 && i < p.len(); i++ )
		{
			var c = p[i]
			if ( ( c < 'a' || c > 'f' ) && ( c < 'A' || c > 'F' ) && ( c < '0' || c > '9' ) )
				break
		}
		if ( i == 0 )
			result += p
		else result += p.slice( i, p.len() )
	}
	return result
}
