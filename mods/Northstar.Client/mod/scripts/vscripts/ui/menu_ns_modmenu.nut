global function AddNorthstarModMenu
global function AddNorthstarModMenu_MainMenuFooter

void function AddNorthstarModMenu()
{
	AddMenu( "ModListMenu", $"resource/ui/menus/modlist.menu", InitModMenu )
}

void function AddNorthstarModMenu_MainMenuFooter()
{
	AddMenuFooterOption( GetMenu( "MainMenu" ), BUTTON_Y, "#Y_MENU_TITLE_MODS", "#MENU_TITLE_MODS", AdvanceToModListMenu )
}

void function AdvanceToModListMenu( var button )
{
	AdvanceMenu( GetMenu( "ModListMenu" ) )
}

void function InitModMenu()
{
	var menu = GetMenu( "ModListMenu" )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnModMenuOpened )
	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
	AddMenuFooterOption( menu, BUTTON_Y, "#Y_RELOAD_MODS", "#RELOAD_MODS", ReloadMods )
	
	foreach ( var button in GetElementsByClassname( GetMenu( "ModListMenu" ), "ModButton" ) )
		AddButtonEventHandler( button, UIE_GET_FOCUS, OnModMenuButtonFocused )
}

void function OnModMenuOpened()
{
	Hud_SetText( Hud_GetChild( GetMenu( "ModListMenu" ), "Title" ), "#MENU_TITLE_MODS" )

	array<var> buttons = GetElementsByClassname( GetMenu( "ModListMenu" ), "ModButton" )
	
	// disable all buttons, we'll enable the ones we need later
	foreach ( var button in buttons )
	{
		Hud_SetEnabled( button, false )
		Hud_SetVisible( button, false )
	}
	
	array<string> modNames = NSGetModNames()
	for ( int i = 0; i < modNames.len() && i < buttons.len(); i++ )
	{
		Hud_SetEnabled( buttons[ i ], true )
		Hud_SetVisible( buttons[ i ], true )
		
		SetButtonRuiText( buttons[ i ], modNames[ i ] + " v" + NSGetModVersionByModName( modNames[ i ] ) )
	}
}

void function OnModMenuButtonFocused( var button )
{
	string modName = NSGetModNames()[ int ( Hud_GetScriptID( button ) ) ]

	var rui = Hud_GetRui( Hud_GetChild( GetMenu( "ModListMenu" ), "LabelDetails" ) )
	
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

void function ReloadMods( var button )
{
	NSReloadMods()
	OnModMenuOpened() // temp, until we start doing uiscript_reset here
}