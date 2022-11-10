untyped

global function AddNorthstarModMenu
global function AddNorthstarModMenu_MainMenuFooter
global function ReloadMods


struct modData {
	string name = ""
	string version = ""
	string link = ""
	int loadPriority = 0
	bool enabled = false
	array<string> conVars = []
}

struct panelContent {
	modData& mod
	bool isHeader = false
}

enum filterShow {
	ALL = 0,
	ONLY_ENABLED = 1,
	ONLY_DISABLED = 2
	ONLY_NOT_REQUIRED = 3,
	ONLY_REQUIRED = 4
}

struct {
	int deltaX = 0
	int deltaY = 0
} mouseDeltaBuffer

struct {
	array<panelContent> mods
	var menu
	array<var> panels
	int scrollOffset = 0
	array<string> enabledMods
	var currentButton
	string searchTerm
	modData& lastMod
} file

const int PANELS_LEN = 15
const string[3] CORE_MODS = ["Northstar.Client", "Northstar.Coop", "Northstar.CustomServers"] // Shows a warning if you try to disable these

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
	file.panels = GetElementsByClassname( file.menu, "ModSelectorPanel" )

	var rui = Hud_GetRui( Hud_GetChild( file.menu, "WarningLegendImage" ) )
	RuiSetImage( rui, "basicImage", $"ui/menu/common/dialog_error" )

	RuiSetFloat( Hud_GetRui( Hud_GetChild( file.menu, "ModEnabledBar" ) ), "basicImageAlpha", 0.8 )

	// Mod buttons
	foreach ( var panel in file.panels )
	{
		var button = Hud_GetChild( panel, "BtnMod" )
		AddButtonEventHandler( button, UIE_GET_FOCUS, OnModButtonFocused )
		AddButtonEventHandler( button, UIE_CLICK, OnModButtonPressed )

		var rui = Hud_GetRui( Hud_GetChild( panel, "WarningImage" ) )
		RuiSetImage( rui, "basicImage", $"ui/menu/common/dialog_error" )
	}

	AddMouseMovementCaptureHandler( Hud_GetChild(file.menu, "MouseMovementCapture"), UpdateMouseDeltaBuffer )

	// UI Events
	AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, OnModMenuOpened )
	AddMenuEventHandler( file.menu, eUIEvent.MENU_CLOSE, OnModMenuClosed )

	// up / down buttons
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnModListUpArrow" ), UIE_CLICK, OnUpArrowSelected )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnModListDownArrow" ), UIE_CLICK, OnDownArrowSelected )

	// Mod info buttons
	AddButtonEventHandler( Hud_GetChild( file.menu, "ModPageButton" ), UIE_CLICK, OnModLinkButtonPressed )

	// Filter buttons
	AddButtonEventHandler( Hud_GetChild( file.menu, "SwtBtnShowFilter"), UIE_CHANGE, OnFiltersChange )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnModsSearch"), UIE_CHANGE, OnFiltersChange )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnListReverse"), UIE_CHANGE, OnFiltersChange )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnFiltersClear"), UIE_CLICK, OnBtnFiltersClear_Activate )

	AddButtonEventHandler( Hud_GetChild( file.menu, "HideCVButton"), UIE_CHANGE, OnHideConVarsChange )

	// Footers
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

	// Nuke weird rui on filter switch
	RuiSetString( Hud_GetRui( Hud_GetChild( file.menu, "SwtBtnShowFilter")), "buttonText", "")
	RuiSetString( Hud_GetRui( Hud_GetChild( file.menu, "HideCVButton")), "buttonText", "")
	RuiSetString( Hud_GetRui( Hud_GetChild( file.menu, "BtnListReverse")), "buttonText", "")
}

// EVENTS

void function OnModMenuOpened()
{
	file.enabledMods = GetEnabledModsArray() // used to check if mods should be reloaded

	UpdateList()
	UpdateListSliderHeight()
	UpdateListSliderPosition()

	RegisterButtonPressedCallback(MOUSE_WHEEL_UP , OnScrollUp)
	RegisterButtonPressedCallback(MOUSE_WHEEL_DOWN , OnScrollDown)
}

void function OnModMenuClosed()
{
	try
	{
		DeregisterButtonPressedCallback(MOUSE_WHEEL_UP , OnScrollUp)
		DeregisterButtonPressedCallback(MOUSE_WHEEL_DOWN , OnScrollDown)
	}
	catch ( ex ) {}

	array<string> current = GetEnabledModsArray()
	bool reload
	foreach ( string mod in current )
	{
		if ( file.enabledMods.find(mod) == -1 )
		{
			reload = true
			break
		}
	}
	if ( current.len() != file.enabledMods.len() || reload ) // Only reload if we have to
		ReloadMods()
}

void function OnModButtonFocused( var button )
{
	if( int ( Hud_GetScriptID( Hud_GetParent( button ) ) ) > file.mods.len() )
		return

	file.currentButton = button
	file.lastMod = file.mods[ int ( Hud_GetScriptID( Hud_GetParent( button ) ) ) + file.scrollOffset - 1 ].mod
	string modName = file.lastMod.name
	var rui = Hud_GetRui( Hud_GetChild( file.menu, "LabelDetails" ) )

	RuiSetGameTime( rui, "startTime", -99999.99 ) // make sure it skips the whole animation for showing this
	RuiSetString( rui, "headerText", modName )
	RuiSetString( rui, "messageText", FormatModDescription( modName ) )

	// Add a button to open the link with if required
	string link = NSGetModDownloadLinkByModName( modName )
	var linkButton = Hud_GetChild( file.menu, "ModPageButton" )
	if ( link.len() )
	{
		Hud_SetEnabled( linkButton, true )
		Hud_SetVisible( linkButton, true )
		Hud_SetText( linkButton, link )
	}
	else
	{
		Hud_SetEnabled( linkButton, false )
		Hud_SetVisible( linkButton, false )
	}

	SetControlBarColor( modName )

	bool required = NSIsModRequiredOnClient( modName )
	Hud_SetVisible( Hud_GetChild( file.menu, "WarningLegendLabel"  ), required )
	Hud_SetVisible( Hud_GetChild( file.menu, "WarningLegendImage"  ), required )
}

void function OnModButtonPressed( var button )
{
	string modName = file.mods[ int ( Hud_GetScriptID( Hud_GetParent( button ) ) ) + file.scrollOffset - 1 ].mod.name
	if ( StaticFind( modName ) && NSIsModEnabled( modName ) )
		CoreModToggleDialog( modName )
	else
	{
		NSSetModEnabled( modName, !NSIsModEnabled( modName ) )
		var panel = file.panels[ int ( Hud_GetScriptID( Hud_GetParent( button ) ) ) - 1 ]
		SetControlBoxColor( Hud_GetChild( panel, "ControlBox" ), modName )
		SetControlBarColor( modName )
		SetModEnabledHelperImageAsset( Hud_GetChild( panel, "EnabledImage" ), modName )
		// RefreshMods()
		UpdateListSliderPosition()
		UpdateListSliderHeight()
	}
}

void function OnReloadModsButtonPressed( var button )
{
	ReloadMods()
}

void function OnAuthenticationAgreementButtonPressed( var button )
{
	NorthstarMasterServerAuthDialog()
}

void function OnModLinkButtonPressed( var button )
{
	string modName = file.mods[ int ( Hud_GetScriptID( Hud_GetParent( file.currentButton ) ) ) + file.scrollOffset - 1 ].mod.name
	string link = NSGetModDownloadLinkByModName( modName )
	if ( link.find("http://") != 0 && link.find("https://") != 0 )
		link = "http://" + link // links without the http or https protocol get opened in the internal browser
	LaunchExternalWebBrowser( link, WEBBROWSER_FLAG_FORCEEXTERNAL )
}

void function OnFiltersChange( var n )
{
	file.scrollOffset = 0

	UpdateList()
	UpdateListSliderHeight()
	UpdateListSliderPosition()
}

void function OnBtnFiltersClear_Activate( var button )
{
	Hud_SetText( Hud_GetChild( file.menu, "BtnModsSearch" ), "" )

	SetConVarInt( "filter_mods", 0 )

	OnFiltersChange( null )
}

void function OnHideConVarsChange( var n )
{
	string modName = file.lastMod.name
	if ( modName == "" )
		return
	var rui = Hud_GetRui( Hud_GetChild( file.menu, "LabelDetails" ) )
	RuiSetString( rui, "messageText", FormatModDescription( modName ) )
}

// LIST LOGIC

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
	string modName = file.mods[ int ( Hud_GetScriptID( Hud_GetParent( file.currentButton ) ) ) + file.scrollOffset - 1 ].mod.name
	NSSetModEnabled( modName, false )

	var panel = file.panels[ int ( Hud_GetScriptID( Hud_GetParent( file.currentButton ) ) ) - 1]
	SetControlBoxColor( Hud_GetChild( panel, "ControlBox" ), modName )
	SetControlBarColor( modName )
	SetModEnabledHelperImageAsset( Hud_GetChild( panel, "EnabledImage" ), modName )

	RefreshMods()
}

array<string> function GetEnabledModsArray()
{
	array<string> enabledMods
	foreach ( string mod in NSGetModNames() )
	{
		if ( NSIsModEnabled( mod ) )
			enabledMods.append( mod )
	}
	return enabledMods
}

void function HideAllPanels()
{
	foreach ( var panel in file.panels )
	{
		Hud_SetEnabled( panel, false )
		Hud_SetVisible( panel, false )
	}
}

void function UpdateList()
{
	HideAllPanels()
	RefreshMods()
	DisplayModPanels()
}

void function RefreshMods()
{
	array<string> modNames = NSGetModNames()
	file.mods.clear()

	bool reverse = GetConVarBool( "modlist_reverse" )

	int lastLoadPriority = reverse ? NSGetModLoadPriority( modNames[ modNames.len() - 1 ] ) + 1 : -1 
	string searchTerm = Hud_GetUTF8Text( Hud_GetChild( file.menu, "BtnModsSearch" ) ).tolower()

	for ( int i = reverse ? modNames.len() - 1 : 0;
		reverse ? ( i >= 0 ) : ( i < modNames.len() );
		i += ( reverse ? -1 : 1) )
	{
		string mod = modNames[i]

		if ( searchTerm.len() && mod.tolower().find( searchTerm ) == null )
			continue

		bool enabled = NSIsModEnabled( mod )
		bool required = NSIsModRequiredOnClient( mod )
		switch ( GetConVarInt( "filter_mods" ) )
		{
			case filterShow.ONLY_ENABLED:
				if ( !enabled )
					continue
				break
			case filterShow.ONLY_DISABLED:
				if ( enabled )
					continue
				break
			case filterShow.ONLY_REQUIRED:
				if ( !required )
					continue
				break
			case filterShow.ONLY_NOT_REQUIRED:
				if( required )
					continue
				break
		}

		int pr = NSGetModLoadPriority( mod )

		if ( reverse ? pr < lastLoadPriority : pr > lastLoadPriority )
		{
			modData m
			m.name = pr.tostring()

			panelContent c
			c.mod = m
			c.isHeader = true
			file.mods.append( c )
			lastLoadPriority = pr
		}

		modData m
		m.name = mod
		m.version = NSGetModVersionByModName( mod )
		m.link = NSGetModDownloadLinkByModName( mod )
		m.loadPriority = NSGetModLoadPriority( mod )
		m.enabled = enabled
		m.conVars = NSGetModConvarsByModName( mod )

		panelContent c
		c.mod = m

		file.mods.append( c )
	}
}

void function DisplayModPanels()
{
	foreach ( int i, var panel in file.panels)
	{
		if ( i >= file.mods.len() || file.scrollOffset + i >= file.mods.len() ) // don't try to show more panels than needed
			break

		panelContent c = file.mods[ file.scrollOffset + i ]
		modData mod = c.mod
		var btn = Hud_GetChild( panel, "BtnMod" )
		var headerLabel = Hud_GetChild( panel, "Header" )
		var box = Hud_GetChild( panel, "ControlBox" )
		var line = Hud_GetChild( panel, "BottomLine" )
		var warning = Hud_GetChild( panel, "WarningImage" )
		var enabledImage = Hud_GetChild( panel, "EnabledImage" )
		
		if ( c.isHeader )
		{
			Hud_SetEnabled( btn, false )
			Hud_SetVisible( btn, false )

			Hud_SetText( headerLabel, "Load Priority: " + mod.name )
			Hud_SetVisible( headerLabel, true )

			Hud_SetVisible( box, false )
			Hud_SetVisible( line, true )

			Hud_SetVisible( warning, false )
			Hud_SetVisible( enabledImage, false )
		}
		else
		{
			Hud_SetEnabled( btn, true )
			Hud_SetVisible( btn, true )
			Hud_SetText( btn, mod.name )

			Hud_SetVisible( headerLabel, false )

			SetControlBoxColor( box, mod.name )
			Hud_SetVisible( box, true )
			Hud_SetVisible( line, false )

			Hud_SetVisible( warning, NSIsModRequiredOnClient( c.mod.name ) )

			SetModEnabledHelperImageAsset( enabledImage, c.mod.name )
		}
		Hud_SetVisible( panel, true )
	}
}

void function SetModEnabledHelperImageAsset( var panel, string modName )
{
	if( NSIsModEnabled( modName ) )
		RuiSetImage( Hud_GetRui( panel ), "basicImage", $"rui/menu/common/merit_state_success" )
	else
		RuiSetImage( Hud_GetRui( panel ), "basicImage", $"rui/menu/common/merit_state_failure" )
	RuiSetFloat3(Hud_GetRui( panel ), "basicImageColor", GetControlColorForMod( modName ) )
	Hud_SetVisible( panel, true )
}

void function SetControlBoxColor( var box, string modName )
{
	var rui = Hud_GetRui( box )
	// if ( NSIsModEnabled( modName ) )
	// 	RuiSetFloat3(rui, "basicImageColor", <0,1,0>)
	// else
	// 	RuiSetFloat3(rui, "basicImageColor", <1,0,0>)
	RuiSetFloat3(rui, "basicImageColor", GetControlColorForMod( modName ) )
}

void function SetControlBarColor( string modName )
{
	var bar_element = Hud_GetChild( file.menu, "ModEnabledBar" )
	var bar = Hud_GetRui( bar_element )
	// if ( NSIsModEnabled( modName ) )
	// 	RuiSetFloat3(bar, "basicImageColor", <0,1,0>)
	// else
	// 	RuiSetFloat3(bar, "basicImageColor", <1,0,0>)
	RuiSetFloat3(bar, "basicImageColor", GetControlColorForMod( modName ) )
	Hud_SetVisible( bar_element, true )
}

vector function GetControlColorForMod( string modName )
{
	if ( NSIsModEnabled( modName ) )
		switch ( GetConVarInt( "colorblind_mode" ) )
		{
			case 1:
			case 2:
			case 3:
			default:
				return <0,1,0>
		}
	else
		switch ( GetConVarInt( "colorblind_mode" ) )
		{
			case 1:
			case 2:
				return <0.29,0,0.57>
			case 3:
			default:
				return <1,0,0>
		}
	unreachable
}

string function FormatModDescription( string modName )
{
	string ret
	// version
	ret += format( "Version %s\n", NSGetModVersionByModName( modName ) )

	// load priority
	ret += format( "Load Priority: %i\n", NSGetModLoadPriority( modName ) )

	// convars
	array<string> modCvars = NSGetModConvarsByModName( modName )
	if ( modCvars.len() != 0 && GetConVarBool( "modlist_show_convars" ) )
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

////////////
// SLIDER
////////////

void function UpdateMouseDeltaBuffer(int x, int y)
{
	mouseDeltaBuffer.deltaX = x
	mouseDeltaBuffer.deltaY = y

	UpdateListSliderHeight()
	SliderBarUpdate()
}


void function SliderBarUpdate()
{
	if ( file.mods.len() <= 15 )
		return

	var sliderButton = Hud_GetChild( file.menu , "BtnModListSlider" )
	var sliderPanel = Hud_GetChild( file.menu , "BtnModListSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu , "MouseMovementCapture" )

	Hud_SetFocused(sliderButton)

	float minYPos = -40.0 * (GetScreenSize()[1] / 1080.0)
	float maxHeight = 604.0  * (GetScreenSize()[1] / 1080.0)
	float maxYPos = minYPos - (maxHeight - Hud_GetHeight( sliderPanel ))
	float useableSpace = (maxHeight - Hud_GetHeight( sliderPanel ))

	float jump = minYPos - (useableSpace / ( float( file.mods.len())))

	// got local from official respaw scripts, without untyped throws an error
	local pos =	Hud_GetPos(sliderButton)[1]
	local newPos = pos - mouseDeltaBuffer.deltaY

	if ( newPos < maxYPos ) newPos = maxYPos
	if ( newPos > minYPos ) newPos = minYPos

	Hud_SetPos( sliderButton , 2, newPos )
	Hud_SetPos( sliderPanel , 2, newPos )
	Hud_SetPos( movementCapture , 2, newPos )

	file.scrollOffset = -int( ( (newPos - minYPos) / useableSpace ) * ( file.mods.len() - PANELS_LEN) )
	UpdateList()
}

void function UpdateListSliderPosition()
{
	var sliderButton = Hud_GetChild( file.menu , "BtnModListSlider" )
	var sliderPanel = Hud_GetChild( file.menu , "BtnModListSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu , "MouseMovementCapture" )

	float mods = float ( file.mods.len() )

	float minYPos = -40.0 * (GetScreenSize()[1] / 1080.0)
	float useableSpace = (604.0 * (GetScreenSize()[1] / 1080.0) - Hud_GetHeight( sliderPanel ))

	float jump = minYPos - (useableSpace / ( mods - float( PANELS_LEN ) ) * file.scrollOffset)

	if ( jump > minYPos ) jump = minYPos

	Hud_SetPos( sliderButton , 2, jump )
	Hud_SetPos( sliderPanel , 2, jump )
	Hud_SetPos( movementCapture , 2, jump )
}

void function UpdateListSliderHeight()
{
	var sliderButton = Hud_GetChild( file.menu , "BtnModListSlider" )
	var sliderPanel = Hud_GetChild( file.menu , "BtnModListSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu , "MouseMovementCapture" )

	float mods = float ( file.mods.len() )

	float maxHeight = 604.0 * (GetScreenSize()[1] / 1080.0)
	float minHeight = 80.0 * (GetScreenSize()[1] / 1080.0)

	float height = maxHeight * ( float( PANELS_LEN ) / mods )

	if ( height > maxHeight ) height = maxHeight
	if ( height < minHeight ) height = minHeight

	Hud_SetHeight( sliderButton , height )
	Hud_SetHeight( sliderPanel , height )
	Hud_SetHeight( movementCapture , height )
}

void function OnScrollDown( var button )
{
	if ( file.mods.len() <= PANELS_LEN ) return
	file.scrollOffset += 5
	if (file.scrollOffset + PANELS_LEN > file.mods.len())
		file.scrollOffset = file.mods.len() - PANELS_LEN
	Hud_SetFocused( Hud_GetChild( file.menu, "BtnModListSlider" ) )
	ValidateScrollOffset()
}

void function OnScrollUp( var button )
{
	file.scrollOffset -= 5
	if (file.scrollOffset < 0)
		file.scrollOffset = 0
	Hud_SetFocused( Hud_GetChild( file.menu, "BtnModListSlider" ) )
	ValidateScrollOffset()
}

void function OnDownArrowSelected( var button )
{
	if ( file.mods.len() <= PANELS_LEN ) return
	file.scrollOffset += 1
	if (file.scrollOffset + PANELS_LEN > file.mods.len())
		file.scrollOffset = file.mods.len() - PANELS_LEN
	ValidateScrollOffset()
}

void function OnUpArrowSelected( var button )
{
	file.scrollOffset -= 1
	if (file.scrollOffset < 0)
		file.scrollOffset = 0
	ValidateScrollOffset()
}

void function ValidateScrollOffset()
{
	RefreshMods()
	if( file.scrollOffset + 15  > file.mods.len() )
		file.scrollOffset = file.mods.len() - 15
	if( file.scrollOffset < 0 )
		file.scrollOffset = 0
	HideAllPanels()
	DisplayModPanels()
	UpdateListSliderHeight()
	UpdateListSliderPosition()
}

// Static arrays don't have the .find method for some reason
bool function StaticFind( string mod )
{
	foreach( string smod in CORE_MODS )
		if ( mod == smod )
			return true
	return false
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