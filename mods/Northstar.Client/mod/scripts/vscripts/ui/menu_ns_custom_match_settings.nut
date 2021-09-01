global function AddNorthstarCustomMatchSettingsMenu
global function SetNextMatchSettingsCategory

const string SETTING_ITEM_TEXT = "                           " // this is long enough to be the same size as the textentry field

struct {
	string currentCategory
	
	table< int, int > enumRealValues
} file

void function AddNorthstarCustomMatchSettingsMenu()
{
	AddMenu( "CustomMatchSettingsMenu", $"resource/ui/menus/custom_match_settings.menu", InitNorthstarCustomMatchSettingsMenu, "#MENU_MATCH_SETTINGS" )
}

void function SetNextMatchSettingsCategory( string category )
{
	file.currentCategory = category
	Hud_SetText( Hud_GetChild( GetMenu( "CustomMatchSettingsMenu" ), "Title" ), Localize( "#MENU_MATCH_SETTINGS_SUBMENU", Localize( category ) ) )
	print( "Category: " + category )
	
	file.enumRealValues.clear()
}

void function InitNorthstarCustomMatchSettingsMenu()
{
	AddMenuEventHandler( GetMenu( "CustomMatchSettingsMenu" ), eUIEvent.MENU_OPEN, OnNorthstarCustomMatchSettingsMenuOpened )
	AddMenuFooterOption( GetMenu( "CustomMatchSettingsMenu" ), BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
	
	foreach ( var button in GetElementsByClassname( GetMenu( "CustomMatchSettingsMenu" ), "MatchSettingButton" ) )
	{	
		// it's not possible to clear dialoglists, so we have to hack together stuff that effectively recreates their functionality
		Hud_DialogList_AddListItem( button, SETTING_ITEM_TEXT, "prev" )
		Hud_DialogList_AddListItem( button, SETTING_ITEM_TEXT, "main" )
		Hud_DialogList_AddListItem( button, SETTING_ITEM_TEXT, "next" )
		
		AddButtonEventHandler( button, UIE_CHANGE, OnSettingButtonPressed  )
	}
	
	foreach ( var textPanel in GetElementsByClassname( GetMenu( "CustomMatchSettingsMenu" ), "MatchSettingTextEntry" ) )
		Hud_AddEventHandler( textPanel, UIE_LOSE_FOCUS, SendTextPanelChanges )
}

void function OnNorthstarCustomMatchSettingsMenuOpened()
{
	array<var> buttons = GetElementsByClassname( GetMenu( "CustomMatchSettingsMenu" ), "MatchSettingButton" )
	array<var> textPanels = GetElementsByClassname( GetMenu( "CustomMatchSettingsMenu" ), "MatchSettingTextEntry" )

	foreach ( var button in buttons )
	{
		Hud_SetEnabled( button, false )
		Hud_SetVisible( button, false )
	}
	
	foreach ( var textPanel in textPanels )
	{
		Hud_SetEnabled( textPanel, false )
		Hud_SetVisible( textPanel, false )
	}
	
	int i = 0;
	foreach ( CustomMatchSettingContainer setting in GetPrivateMatchCustomSettingsForCategory( file.currentCategory ) )
	{
		Hud_SetEnabled( buttons[ i ], true )
		Hud_SetVisible( buttons[ i ], true )
		Hud_SetText( buttons[ i ], setting.localizedName )
		Hud_SetDialogListSelectionValue( buttons[ i ], "main" )
		
		Hud_SetEnabled( textPanels[ i ], true )
		Hud_SetVisible( textPanels[ i ], true )
		
		// manually resolve default gamemode/playlist vars since game won't do it for us if we aren't using GetCurrentPlaylistVar
		string gamemode = PrivateMatch_GetSelectedMode()
		if ( gamemode != "speedball" ) // hack since lf is weird
			gamemode = GetPlaylistGamemodeByIndex( gamemode, 0 )
		
		string gamemodeVar = GetGamemodeVarOrUseValue( PrivateMatch_GetSelectedMode(), setting.playlistVar, setting.defaultValue )
		string playlistVar = GetPlaylistVarOrUseValue( PrivateMatch_GetSelectedMode(), setting.playlistVar, setting.defaultValue )
		
		if ( playlistVar != gamemodeVar && playlistVar == setting.defaultValue )
			playlistVar = gamemodeVar

		if ( setting.isEnumSetting )
		{
			// setup internal state for enums 
			int enumIndex = int ( max( 0, setting.enumValues.find( playlistVar ) ) )
			
			file.enumRealValues[ int( Hud_GetScriptID( textPanels[ i ] ) ) ] <- enumIndex
			Hud_SetText( textPanels[ i ], setting.enumNames[ enumIndex ] )
		}
		else
			Hud_SetText( textPanels[ i ], playlistVar )
					
		i++
	}
}

void function OnSettingButtonPressed( var button )
{
	CustomMatchSettingContainer setting = GetPrivateMatchCustomSettingsForCategory( file.currentCategory )[ int( Hud_GetScriptID( button ) ) ]
	var textPanel = GetElementsByClassname( GetMenu( "CustomMatchSettingsMenu" ), "MatchSettingTextEntry" )[ int( Hud_GetScriptID( button ) ) ]
	
	if ( setting.isEnumSetting )
	{
		string selectionVal = Hud_GetDialogListSelectionValue( button )
		if ( selectionVal == "main" )
			return
						
		int enumVal = file.enumRealValues[ int( Hud_GetScriptID( button ) ) ]
		if ( selectionVal == "next" ) // enum val += 1
			 enumVal = ( enumVal + 1 ) % setting.enumValues.len()
		else // enum val -= 1
		{
			enumVal--
			if ( enumVal == -1 )
				enumVal = setting.enumValues.len() - 1
		}
		
		file.enumRealValues[ int( Hud_GetScriptID( button ) ) ] = enumVal
		Hud_SetText( textPanel, setting.enumNames[ enumVal ] )
		
		ClientCommand( "PrivateMatchSetPlaylistVarOverride " + setting.playlistVar + " " + setting.enumValues[ enumVal ] )
	}
	else
	{
		// this doesn't work for some reason
		Hud_SetFocused( textPanel )
	}
	
	Hud_SetDialogListSelectionValue( button, "main" )
}

void function SendTextPanelChanges( var textPanel ) 
{
	CustomMatchSettingContainer setting = GetPrivateMatchCustomSettingsForCategory( file.currentCategory )[ int( Hud_GetScriptID( textPanel ) ) ]
	
	// enums don't need to do this
	if ( !setting.isEnumSetting )
		ClientCommand( "PrivateMatchSetPlaylistVarOverride " + setting.playlistVar + " " + Hud_GetUTF8Text( textPanel ) )
}