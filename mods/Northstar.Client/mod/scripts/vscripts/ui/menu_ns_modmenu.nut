global function AddNorthstarModMenu
global function AddNorthstarModMenu_MainMenuFooter
global function ReloadMods

struct {
	bool shouldReloadModsOnEnd
} file

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
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, OnModMenuClosed )
	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
	AddMenuFooterOption( menu, BUTTON_Y, "#Y_RELOAD_MODS", "#RELOAD_MODS", OnReloadModsButtonPressed )
	AddMenuFooterOption( menu, BUTTON_BACK, "#BACK_AUTHENTICATION_AGREEMENT", "#AUTHENTICATION_AGREEMENT", OnAuthenticationAgreementButtonPressed )
	
	foreach ( var button in GetElementsByClassname( GetMenu( "ModListMenu" ), "ModButton" ) )
	{
		AddButtonEventHandler( button, UIE_GET_FOCUS, OnModMenuButtonFocused )
		AddButtonEventHandler( button, UIE_CLICK, OnModMenuButtonPressed )
	}
}

void function OnModMenuOpened()
{
	file.shouldReloadModsOnEnd = false

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
		
		SetModMenuNameText( buttons[ i ] )
	}
}

void function OnModMenuClosed()
{
	if ( file.shouldReloadModsOnEnd )
		ReloadMods()
}

void function SetModMenuNameText( var button )
{
	string modName = NSGetModNames()[ int ( Hud_GetScriptID( button ) ) ]

	// should be localisation at some point
	if ( NSIsModEnabled( modName ) )
		SetButtonRuiText( button, modName + " v" + NSGetModVersionByModName( modName ) )
	else
		SetButtonRuiText( button, modName + " (DISABLED)" ) 
}

void function OnModMenuButtonPressed( var button )
{
	string modName = NSGetModNames()[ int ( Hud_GetScriptID( button ) ) ]
	NSSetModEnabled( modName, !NSIsModEnabled( modName ) )
	SetModMenuNameText( button )
	
	file.shouldReloadModsOnEnd = true
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