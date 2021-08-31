global function InitModesMenu

struct {
	int currentModePage
} file

const int MODES_PER_PAGE = 15

void function InitModesMenu()
{
	var menu = GetMenu( "ModesMenu" )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnOpenModesMenu )

	AddEventHandlerToButtonClass( menu, "ModeButton", UIE_GET_FOCUS, ModeButton_GetFocus )
	AddEventHandlerToButtonClass( menu, "ModeButton", UIE_CLICK, ModeButton_Click )

	AddMenuFooterOption( menu, BUTTON_A, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
	
	AddMenuFooterOption( menu, BUTTON_SHOULDER_LEFT, "#PRIVATE_MATCH_PAGE_PREV", "#PRIVATE_MATCH_PAGE_PREV", CycleModesBack, IsNorthstarServer )
	AddMenuFooterOption( menu, BUTTON_SHOULDER_RIGHT, "#PRIVATE_MATCH_PAGE_NEXT", "#PRIVATE_MATCH_PAGE_NEXT", CycleModesForward, IsNorthstarServer )
}

void function OnOpenModesMenu()
{
	UpdateVisibleModes()
	
	if ( level.ui.privatematch_mode == 0 ) // set to the first mode if there's no mode focused
		Hud_SetFocused( GetElementsByClassname( GetMenu( "ModesMenu" ), "ModeButton" )[ 0 ] )
}

void function UpdateVisibleModes()
{	
	// ensures that we only ever show enough buttons for the number of modes we have
	array<var> buttons = GetElementsByClassname( GetMenu( "ModesMenu" ), "ModeButton" )
	foreach ( var button in buttons )
	{
		Hud_SetEnabled( button, false )
		Hud_SetVisible( button, false )
	}
		
	array<string> modesArray = GetPrivateMatchModes()
	for ( int i = 0; i < MODES_PER_PAGE; i++ )
	{
		if ( i + ( file.currentModePage * MODES_PER_PAGE ) >= modesArray.len() )
			break
		
		int modeIndex = i + ( file.currentModePage * MODES_PER_PAGE )
		SetButtonRuiText( buttons[ i ], GetGameModeDisplayName( modesArray[ modeIndex ] ) )
		
		Hud_SetEnabled( buttons[ i ], true )		
		Hud_SetVisible( buttons[ i ], true )
		
		if ( !ModeSettings_RequiresAI( modesArray[ modeIndex ] ) )
			Hud_SetLocked( buttons[ i ], false )
		else
			Hud_SetLocked( buttons[ i ], true )
		
		if ( !PrivateMatch_IsValidMapModeCombo( PrivateMatch_GetSelectedMap(), modesArray[ modeIndex ] ) && !IsNorthstarServer() )
		{
			Hud_SetLocked( buttons[ i ], true )
			SetButtonRuiText( buttons[ i ], Localize( "#PRIVATE_MATCH_UNAVAILABLE", Localize( GetGameModeDisplayName( modesArray[ modeIndex ] ) ) ) )
		}		
	}
}

void function ModeButton_GetFocus( var button )
{
	int modeId = int( Hud_GetScriptID( button ) ) + ( file.currentModePage * MODES_PER_PAGE )

	var menu = GetMenu( "ModesMenu" )
	var nextModeImage = Hud_GetChild( menu, "NextModeImage" )
	var nextModeIcon = Hud_GetChild( menu, "ModeIconImage" )
	var nextModeName = Hud_GetChild( menu, "NextModeName" )
	var nextModeDesc = Hud_GetChild( menu, "NextModeDesc" )

	array<string> modesArray = GetPrivateMatchModes()

	if ( modeId > modesArray.len() )
		return

	string modeName = modesArray[modeId]

	asset playlistImage = GetPlaylistImage( modeName )
	RuiSetImage( Hud_GetRui( nextModeImage ), "basicImage", playlistImage )
	RuiSetImage( Hud_GetRui( nextModeIcon ), "basicImage", GetPlaylistThumbnailImage( modeName ) )
	Hud_SetText( nextModeName, GetGameModeDisplayName( modeName ) )

	string mapName = PrivateMatch_GetSelectedMap()
	bool mapSupportsMode = PrivateMatch_IsValidMapModeCombo( mapName, modeName )
	if ( !mapSupportsMode && !IsNorthstarServer() )
		Hud_SetText( nextModeDesc, Localize( "#PRIVATE_MATCH_MODE_NO_MAP_SUPPORT", Localize( GetGameModeDisplayName( modeName ) ), Localize( GetMapDisplayName( mapName ) ) ) )
	else if ( IsFDMode( modeName ) ) // HACK!
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

	int modeID = int( Hud_GetScriptID( button ) ) + ( file.currentModePage * MODES_PER_PAGE )

	array<string> modesArray = GetPrivateMatchModes()
	string modeName = modesArray[ modeID ]

	// on modded servers set us to the first map for that mode automatically
	// need this for coliseum mainly which is literally impossible to select without this
	if ( IsNorthstarServer() && !PrivateMatch_IsValidMapModeCombo( PrivateMatch_GetSelectedMap(), modesArray[ modeID ] ) )
		ClientCommand( "SetCustomMap " + GetPrivateMatchMapsForMode( modeName )[ 0 ] )
		
	// set it
	ClientCommand( "PrivateMatchSetMode " + modeName )
	CloseActiveMenu()
}

void function CycleModesBack( var button )
{
	if ( file.currentModePage == 0 )
		return

	file.currentModePage--
	UpdateVisibleModes()
}

void function CycleModesForward( var button )
{
	if ( ( file.currentModePage + 1 ) * MODES_PER_PAGE >= GetPrivateMatchModes().len() )
		return

	file.currentModePage++
	UpdateVisibleModes()
}