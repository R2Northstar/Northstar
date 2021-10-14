untyped


global function MenuMapSelect_Init

global function InitMapsMenu

struct {
	int mapsPerPage = 21
	int currentMapPage
} file

// note: this does have a scrolling system in vanilla, but it's honestly really weird and jank and i don't like it
// so for parity with menu_mode_select i'm removing it in favour of a page system

function MenuMapSelect_Init()
{
	RegisterSignal( "OnCloseMapsMenu" )
}

void function InitMapsMenu()
{
	var menu = GetMenu( "MapsMenu" )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnOpenMapsMenu )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, OnCloseMapsMenu )

	AddEventHandlerToButtonClass( menu, "MapButtonClass", UIE_GET_FOCUS, MapButton_Focused )
	AddEventHandlerToButtonClass( menu, "MapButtonClass", UIE_LOSE_FOCUS, MapButton_LostFocus )
	AddEventHandlerToButtonClass( menu, "MapButtonClass", UIE_CLICK, MapButton_Activate )

	AddMenuFooterOption( menu, BUTTON_A, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
	
	AddMenuFooterOption( menu, BUTTON_SHOULDER_LEFT, "#PRIVATE_MATCH_PAGE_PREV", "#PRIVATE_MATCH_PAGE_PREV", CycleModesBack, IsNorthstarServer )
	AddMenuFooterOption( menu, BUTTON_SHOULDER_RIGHT, "#PRIVATE_MATCH_PAGE_NEXT", "#PRIVATE_MATCH_PAGE_NEXT", CycleModesForward, IsNorthstarServer )
}

void function OnOpenMapsMenu()
{
	if ( IsNorthstarServer() )
		file.mapsPerPage = 15
	else
		file.mapsPerPage = 21

	UpdateVisibleMaps()
}

void function UpdateVisibleMaps()
{
	array<var> buttons = GetElementsByClassname( GetMenu( "MapsMenu" ), "MapButtonClass" )
	array<string> mapsArray = GetPrivateMatchMaps()

	foreach ( button in buttons )
	{
		int buttonID = int( Hud_GetScriptID( button ) )
		int mapID = buttonID + ( file.currentMapPage * file.mapsPerPage )

		if ( buttonID < file.mapsPerPage && mapID < GetPrivateMatchMaps().len() )
		{
			string name = mapsArray[ mapID ]
			
			bool sp = name.find( "sp_" ) == 0
			if ( sp )
				SetButtonRuiText( button, Localize( "#PRIVATE_MATCH_SINGLEPLAYER_LEVEL", Localize( GetMapDisplayName( name ) ) ) )
			else
				SetButtonRuiText( button, GetMapDisplayName( name ) )
			Hud_SetEnabled( button, true )

			if ( IsItemInEntitlementUnlock( name ) && IsValid( GetUIPlayer() ) )
	 		{
	 			if ( IsItemLocked( GetUIPlayer(), name ) && GetCurrentPlaylistVarInt( name + "_available" , 0 ) == 0 )
	 			{
	 				SetButtonRuiText( button, Localize( "#MAP_LOCKED", Localize( GetMapDisplayName( name ) ) ) )
	 			}
	 		}

			bool mapSupportsMode = PrivateMatch_IsValidMapModeCombo( name, PrivateMatch_GetSelectedMode() )
			Hud_SetLocked( button, !mapSupportsMode )

			if ( !mapSupportsMode && !sp )
				SetButtonRuiText( button, Localize( "#PRIVATE_MATCH_UNAVAILABLE", Localize( GetMapDisplayName( name ) ) ) )
		}
		else
		{
			SetButtonRuiText( button, "" )
			Hud_SetEnabled( button, false )
		}

		if ( mapID == level.ui.privatematch_map )
		{
			printt( buttonID, mapsArray[buttonID] )
			Hud_SetFocused( button )
		}
	}
}

void function OnCloseMapsMenu()
{
	Signal( uiGlobal.signalDummy, "OnCloseMapsMenu" )
}

void function MapButton_Focused( var button )
{
	int mapID = int( Hud_GetScriptID( button ) ) + ( file.currentMapPage * file.mapsPerPage )

	var menu = GetMenu( "MapsMenu" )
	var nextMapImage = Hud_GetChild( menu, "NextMapImage" )
	var nextMapName = Hud_GetChild( menu, "NextMapName" )
	var nextMapDesc = Hud_GetChild( menu, "NextMapDesc" )

	array<string> mapsArray = GetPrivateMatchMaps()
	string mapName = mapsArray[ mapID ]

	asset mapImage = GetMapImageForMapName( mapName )
	RuiSetImage( Hud_GetRui( nextMapImage ), "basicImage", mapImage )
	Hud_SetText( nextMapName, GetMapDisplayName( mapName ) )

	string modeName = PrivateMatch_GetSelectedMode()
	bool mapSupportsMode = PrivateMatch_IsValidMapModeCombo( mapName, modeName )
	if ( !mapSupportsMode )
		Hud_SetText( nextMapDesc, Localize( "#PRIVATE_MATCH_MAP_NO_MODE_SUPPORT", Localize( GetMapDisplayName( mapName ) ), Localize( GetGameModeDisplayName( modeName ) ) ) )
	else
		Hud_SetText( nextMapDesc, GetMapDisplayDesc( mapName ) )

}

void function MapButton_LostFocus( var button )
{
	HandleLockedCustomMenuItem( GetMenu( "MapsMenu" ), button, [], true )
}

void function MapButton_Activate( var button )
{
	if ( Hud_IsLocked( button ) )
		return

	if ( !AmIPartyLeader() && GetPartySize() > 1 )
		return

	array<string> mapsArray = GetPrivateMatchMaps()
	int mapID = int( Hud_GetScriptID( button ) )
	string mapName = mapsArray[ mapID + ( file.currentMapPage * file.mapsPerPage ) ]

	printt( mapName, mapID )

	ClientCommand( "SetCustomMap " + mapName )
	CloseActiveMenu()
}

void function CycleModesBack( var button )
{
	if ( file.currentMapPage == 0 )
		return
	
	file.currentMapPage--
	UpdateVisibleMaps()
}

void function CycleModesForward( var button )
{
	if ( ( file.currentMapPage + 1 ) * file.mapsPerPage >= GetPrivateMatchMaps().len() )
		return
	
	file.currentMapPage++
	UpdateVisibleMaps()
}
