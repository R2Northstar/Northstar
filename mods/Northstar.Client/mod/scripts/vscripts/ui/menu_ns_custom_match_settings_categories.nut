global function AddNorthstarCustomMatchSettingsCategoryMenu

void function AddNorthstarCustomMatchSettingsCategoryMenu()
{
	AddMenu( "CustomMatchSettingsCategoryMenu", $"resource/ui/menus/custom_match_settings_categories.menu", InitNorthstarCustomMatchSettingsCategoryMenu, "#MENU_MATCH_SETTINGS" )
}

void function InitNorthstarCustomMatchSettingsCategoryMenu()
{
	AddMenuEventHandler( GetMenu( "CustomMatchSettingsCategoryMenu" ), eUIEvent.MENU_OPEN, OnNorthstarCustomMatchSettingsCategoryMenuOpened )
	AddMenuFooterOption( GetMenu( "CustomMatchSettingsCategoryMenu" ), BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
	AddMenuFooterOption( GetMenu( "CustomMatchSettingsCategoryMenu" ), BUTTON_Y, "#Y_BUTTON_RESTORE_DEFAULTS", "#RESTORE_DEFAULTS", ResetMatchSettingsToDefault )

	foreach ( var button in GetElementsByClassname( GetMenu( "CustomMatchSettingsCategoryMenu" ), "MatchSettingCategoryButton" ) )
	{
		AddButtonEventHandler( button, UIE_CLICK, SelectPrivateMatchSettingsCategory )
	
		Hud_SetEnabled( button, false )
		Hud_SetVisible( button, false )
	}
}

void function OnNorthstarCustomMatchSettingsCategoryMenuOpened()
{
	array<string> categories = GetPrivateMatchSettingCategories()
	array<var> buttons = GetElementsByClassname( GetMenu( "CustomMatchSettingsCategoryMenu" ), "MatchSettingCategoryButton" )
	
	foreach ( var button in buttons )
	{
		Hud_SetEnabled( button, false )
		Hud_SetVisible( button, false )
	}
	
	for ( int i = 0, j = 0; j < categories.len() && i < buttons.len(); i++, j++ )
	{
		Hud_SetText( buttons[ i ], Localize( categories[ j ] ) + " ->" )
		Hud_SetEnabled( buttons[ i ], true )
		Hud_SetVisible( buttons[ i ], true )
	}
}

void function SelectPrivateMatchSettingsCategory( var button )
{
	SetNextMatchSettingsCategory( GetPrivateMatchSettingCategories()[ int( Hud_GetScriptID( button ) ) ] )
	AdvanceMenu( GetMenu( "CustomMatchSettingsMenu" ) )
}

void function ResetMatchSettingsToDefault( var button )
{
	ClientCommand( "ResetMatchSettingsToDefault" )
}