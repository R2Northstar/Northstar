untyped

global function AddNorthstarModMenu
global function AddNorthstarModMenu_MainMenuFooter
global function ReloadMods


const int BUTTONS_PER_PAGE = 17


struct modStruct {
	int modIndex
	string modName
}

enum filterShow {
	ALL = 0,
	ONLY_ENABLED = 1,
	ONLY_DISABLED = 2
}

struct {
	int deltaX = 0
	int deltaY = 0
} mouseDeltaBuffer

struct {
	bool shouldReloadModsOnEnd
	string currentMod
	var currentButton
	int scrollOffset = 0
	
	array<modStruct> modsArrayFiltered
	
	var menu
} file

void function AddNorthstarModMenu()
{
	AddMenu( "ModListMenu", $"resource/ui/menus/modlist.menu", InitModMenu )
}

void function AddNorthstarModMenu_MainMenuFooter()
{
	string controllerStr = PrependControllerPrompts( BUTTON_Y, "#MENU_TITLE_MODS" )
	AddMenuFooterOption( GetMenu( "MainMenu" ), BUTTON_Y, controllerStr, "#MENU_TITLE_MODS", AdvanceToModListMenu )
}

void function AdvanceToModListMenu( var button )
{
	AdvanceMenu( GetMenu( "ModListMenu" ) )
}

void function InitModMenu()
{
	file.menu = GetMenu( "ModListMenu" )
	
	AddMouseMovementCaptureHandler( file.menu, UpdateMouseDeltaBuffer )

	AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, OnModMenuOpened )
	AddMenuEventHandler( file.menu, eUIEvent.MENU_CLOSE, OnModMenuClosed )
	AddMenuFooterOption( file.menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
	AddMenuFooterOption(
		file.menu,
		BUTTON_X,
		PrependControllerPrompts( BUTTON_X, "#RELOAD_MODS" ),
		"#RELOAD_MODS",
		OnReloadModsButtonPressed
	)
	AddMenuFooterOption(
		file.menu,
		BUTTON_BACK,
		PrependControllerPrompts( BUTTON_Y, "#AUTHENTICATION_AGREEMENT" ),
		"#AUTHENTICATION_AGREEMENT",
		OnAuthenticationAgreementButtonPressed
	)
	
	foreach ( var button in GetElementsByClassname( file.menu, "ModButton" ) )
	{
		AddButtonEventHandler( button, UIE_GET_FOCUS, OnModMenuButtonFocused )
		AddButtonEventHandler( button, UIE_CLICK, OnModMenuButtonPressed )
	}
	
	AddButtonEventHandler( Hud_GetChild( file.menu, "SwtBtnShowFilter"), UIE_CHANGE, OnFiltersChange )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnModsSearch"), UIE_CHANGE, OnFiltersChange )
	
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnModListUpArrow"), UIE_CLICK, OnUpArrowSelected )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnModListDownArrow"), UIE_CLICK, OnDownArrowSelected )
	
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnFiltersClear"), UIE_CLICK, OnBtnFiltersClear_Activate )
	
	// Nuke weird rui on filter switch
	RuiSetString( Hud_GetRui( Hud_GetChild( file.menu, "SwtBtnShowFilter")), "buttonText", "")
}

void function OnModMenuOpened()
{
	file.shouldReloadModsOnEnd = false
	file.scrollOffset = 0
	
	RegisterButtonPressedCallback(MOUSE_WHEEL_UP , OnScrollUp)
	RegisterButtonPressedCallback(MOUSE_WHEEL_DOWN , OnScrollDown)

	Hud_SetText( Hud_GetChild( file.menu, "Title" ), "#MENU_TITLE_MODS" )

	
	OnFiltersChange(0)
}

void function OnModMenuClosed()
{
	try
	{
		DeregisterButtonPressedCallback(MOUSE_WHEEL_UP , OnScrollUp)
		DeregisterButtonPressedCallback(MOUSE_WHEEL_DOWN , OnScrollDown)
	}
	catch ( ex ) {}
	
	if ( file.shouldReloadModsOnEnd )
		ReloadMods()
}

void function OnFiltersChange( var n )
{
	file.scrollOffset = 0
	
	HideAllButtons()
	
	RefreshModsArray()
	
	UpdateList()
	
	UpdateListSliderHeight()
}

void function RefreshModsArray()
{
	string searchTerm = Hud_GetUTF8Text( Hud_GetChild( file.menu, "BtnModsSearch" ) ).tolower()
	
	file.modsArrayFiltered.clear()
	
	
	bool useSearch = searchTerm != ""
	
	
	array<string> modNames = NSGetModNames()
	int modCount = modNames.len()
	
	foreach ( int index_, mod in modNames ) {
		modStruct tempMod
		tempMod.modIndex = index_
		tempMod.modName = mod
		
		int filter = GetConVarInt( "filter_mods" )
		bool enabled = NSIsModEnabled( tempMod.modName )
		
		bool containsTerm = tempMod.modName.tolower().find(searchTerm) != null
		
		if ( filter == filterShow.ALL && (useSearch == true ? containsTerm : true ) )
		{
			file.modsArrayFiltered.append( tempMod )
		}
		else if ( filter == filterShow.ONLY_ENABLED && enabled && (useSearch == true ? containsTerm : true ))
		{
			file.modsArrayFiltered.append( tempMod )
		}
		else if ( filter == filterShow.ONLY_DISABLED && !enabled && (useSearch == true ? containsTerm : true ))
		{
			file.modsArrayFiltered.append( tempMod )
		}
	}
}

void function HideAllButtons()
{
	array<var> buttons = GetElementsByClassname( file.menu, "ModButton" )
	
	// disable all buttons, we'll enable the ones we need later
	foreach ( var button in buttons )
	{
		Hud_SetEnabled( button, false )
		Hud_SetVisible( button, false )
	}
}

void function UpdateList()
{
	array<var> buttons = GetElementsByClassname( file.menu, "ModButton" )
	
	
	int j = file.modsArrayFiltered.len() > 17 ? 17 : file.modsArrayFiltered.len()
	
	for ( int i = 0; i < j; i++ )
	{
		Hud_SetEnabled( buttons[ i ], true )
		Hud_SetVisible( buttons[ i ], true )
		
		SetModMenuNameText( buttons[ i ] )
	}
}

void function SetModMenuNameText( var button )
{
	modStruct mod = file.modsArrayFiltered[ int ( Hud_GetScriptID( button ) ) + file.scrollOffset ]

	// should be localisation at some point
	if ( NSIsModEnabled( mod.modName ) )
		SetButtonRuiText( button, mod.modName + " v" + NSGetModVersionByModName( mod.modName ) )
	else
		SetButtonRuiText( button, mod.modName + " (DISABLED)" ) 
}

void function OnModMenuButtonPressed( var button )
{
	string modName = file.modsArrayFiltered[ int ( Hud_GetScriptID( button ) ) + file.scrollOffset ].modName
	if ( ( modName == "Northstar.Client" ||  modName == "Northstar.Coop" || modName == "Northstar.CustomServers") && NSIsModEnabled( modName ) )
	{
		file.currentMod = modName
		file.currentButton = button
		CoreModToggleDialog( modName )
	}
	else
	{
		NSSetModEnabled( modName, !NSIsModEnabled( modName ) )

		SetModMenuNameText( button )

		file.shouldReloadModsOnEnd = true
	}
}

void function CoreModToggleDialog( string mod )
{
	DialogData dialogData
	dialogData.header = "#WARNING"
	dialogData.message = "#CORE_MOD_DISABLE_WARNING"

	AddDialogButton( dialogData, "#CANCEL" )
	// This can't have any arguments so we use the file struct
	AddDialogButton( dialogData, "#DISABLE", DisableMod )

	AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )
	AddDialogFooter( dialogData, "#B_BUTTON_CANCEL" )

	OpenDialog( dialogData )
}

void function DisableMod()
{
	NSSetModEnabled( file.currentMod, false )

	SetModMenuNameText( file.currentButton )

	file.shouldReloadModsOnEnd = true
}

void function OnModMenuButtonFocused( var button )
{
	string modName = file.modsArrayFiltered[ int ( Hud_GetScriptID( button ) ) + file.scrollOffset ].modName

	var rui = Hud_GetRui( Hud_GetChild( file.menu, "LabelDetails" ) )
	
	RuiSetGameTime( rui, "startTime", -99999.99 ) // make sure it skips the whole animation for showing this
	RuiSetString( rui, "headerText", modName )
	RuiSetString( rui, "messageText", FormatModDescription( modName ) )
}

string function FormatModDescription( string modName )
{
	string ret
	// version
	ret += format( "Version %s\n", NSGetModVersionByModName( modName ) ) 
	
	// download link
	string modLink = NSGetModDownloadLinkByModName( modName )
	if ( modLink.len() != 0 )
		ret += format( "Download link: \"%s\"\n", modLink )
	
	// load priority
	ret += format( "Load Priority: %i\n", NSGetModLoadPriority( modName ) )
	
	// todo: add ClientRequired here
	
	// convars
	array<string> modCvars = NSGetModConvarsByModName( modName )
	if ( modCvars.len() != 0 )
	{
		ret += "ConVars: "
	
		for ( int i = 0; i < modCvars.len(); i++ )
		{
			if ( i != modCvars.len() - 1 )
				ret += format( "\"%s\", ", modCvars[ i ] )
			else
				ret += format( "\"%s\"", modCvars[ i ] )
		}
		
		ret += "\n"
	}
	
	// description
	ret += format( "\n%s\n", NSGetModDescriptionByModName( modName ) )
	
	return ret
}

void function OnReloadModsButtonPressed( var button )
{
	ReloadMods()
}

void function ReloadMods()
{
	NSReloadMods()
	ClientCommand( "reload_localization" )
	ClientCommand( "loadPlaylists" )
	
	bool svCheatsOriginal = GetConVarBool( "sv_cheats" )	
	SetConVarBool( "sv_cheats", true )
	ClientCommand( "weapon_reparse" ) // weapon_reparse only works if a server is running and sv_cheats is 1, gotta figure this out eventually
	SetConVarBool( "sv_cheats", svCheatsOriginal )
	
	// note: the logic for this seems really odd, unsure why it doesn't seem to update, since the same code seems to get run irregardless of whether we've read weapon data before
	ClientCommand( "uiscript_reset" )
}

void function OnAuthenticationAgreementButtonPressed( var button )
{
	NorthstarMasterServerAuthDialog()
}


void function OnBtnFiltersClear_Activate( var button )
{
	Hud_SetText( Hud_GetChild( file.menu, "BtnModsSearch" ), "" )

	SetConVarInt( "filter_mods", 0 )

	OnFiltersChange(0)
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
	if ( file.modsArrayFiltered.len() <= 17 )
	{
		FlushMouseDeltaBuffer()
		return
	}

	var sliderButton = Hud_GetChild( file.menu , "BtnModListSlider" )
	var sliderPanel = Hud_GetChild( file.menu , "BtnModListSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu , "MouseMovementCapture" )

	Hud_SetFocused(sliderButton)

	float minYPos = -40.0 * (GetScreenSize()[1] / 1080.0)
	float maxHeight = 604.0  * (GetScreenSize()[1] / 1080.0)
	float maxYPos = minYPos - (maxHeight - Hud_GetHeight( sliderPanel ))
	float useableSpace = (maxHeight - Hud_GetHeight( sliderPanel ))

	float jump = minYPos - (useableSpace / ( float( file.modsArrayFiltered.len())))

	// got local from official respaw scripts, without untyped throws an error
	local pos =	Hud_GetPos(sliderButton)[1]
	local newPos = pos - mouseDeltaBuffer.deltaY
	FlushMouseDeltaBuffer()

	if ( newPos < maxYPos ) newPos = maxYPos
	if ( newPos > minYPos ) newPos = minYPos

	Hud_SetPos( sliderButton , 2, newPos )
	Hud_SetPos( sliderPanel , 2, newPos )
	Hud_SetPos( movementCapture , 2, newPos )

	file.scrollOffset = -int( ( (newPos - minYPos) / useableSpace ) * ( file.modsArrayFiltered.len() - BUTTONS_PER_PAGE) )
	UpdateList()
}

void function UpdateListSliderHeight()
{
	var sliderButton = Hud_GetChild( file.menu , "BtnModListSlider" )
	var sliderPanel = Hud_GetChild( file.menu , "BtnModListSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu , "MouseMovementCapture" )
	
	float mods = float ( file.modsArrayFiltered.len() )

	float maxHeight = 604.0 * (GetScreenSize()[1] / 1080.0)
	float minHeight = 80.0 * (GetScreenSize()[1] / 1080.0)

	float height = maxHeight * ( float( BUTTONS_PER_PAGE ) / mods )

	if ( height > maxHeight ) height = maxHeight
	if ( height < minHeight ) height = minHeight

	Hud_SetHeight( sliderButton , height )
	Hud_SetHeight( sliderPanel , height )
	Hud_SetHeight( movementCapture , height )
}


void function UpdateListSliderPosition()
{
	var sliderButton = Hud_GetChild( file.menu , "BtnModListSlider" )
	var sliderPanel = Hud_GetChild( file.menu , "BtnModListSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu , "MouseMovementCapture" )
	
	float mods = float ( file.modsArrayFiltered.len() )

	float minYPos = -40.0 * (GetScreenSize()[1] / 1080.0)
	float useableSpace = (604.0 * (GetScreenSize()[1] / 1080.0) - Hud_GetHeight( sliderPanel ))

	float jump = minYPos - (useableSpace / ( mods - float( BUTTONS_PER_PAGE ) ) * file.scrollOffset)

	//jump = jump * (GetScreenSize()[1] / 1080.0)

	if ( jump > minYPos ) jump = minYPos

	Hud_SetPos( sliderButton , 2, jump )
	Hud_SetPos( sliderPanel , 2, jump )
	Hud_SetPos( movementCapture , 2, jump )
}

void function OnDownArrowSelected( var button )
{
	if ( file.modsArrayFiltered.len() <= BUTTONS_PER_PAGE ) return
	file.scrollOffset += 1
	if (file.scrollOffset + BUTTONS_PER_PAGE > file.modsArrayFiltered.len()) {
		file.scrollOffset = file.modsArrayFiltered.len() - BUTTONS_PER_PAGE
	}
	UpdateList()
	UpdateListSliderPosition()
}


void function OnUpArrowSelected( var button )
{
	file.scrollOffset -= 1
	if (file.scrollOffset < 0) {
		file.scrollOffset = 0
	}
	UpdateList()
	UpdateListSliderPosition()
}

void function OnScrollDown( var button )
{
	if ( file.modsArrayFiltered.len() <= BUTTONS_PER_PAGE ) return
	file.scrollOffset += 5
	if (file.scrollOffset + BUTTONS_PER_PAGE > file.modsArrayFiltered.len()) {
		file.scrollOffset = file.modsArrayFiltered.len() - BUTTONS_PER_PAGE
	}
	UpdateList()
	UpdateListSliderPosition()
}

void function OnScrollUp( var button )
{
	file.scrollOffset -= 5
	if (file.scrollOffset < 0) {
		file.scrollOffset = 0
	}
	UpdateList()
	UpdateListSliderPosition()
}