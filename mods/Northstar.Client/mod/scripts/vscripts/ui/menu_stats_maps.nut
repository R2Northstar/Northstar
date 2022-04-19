global function InitViewStatsMapsMenu
global function setit
struct
{
	var menu
	GridMenuData gridData
	bool isGridInitialized = false
	array<string> allMaps
} file

// Why this file is included in Northstar:
// As it turns out, the Respawn developers in all their infinite wisdom decided to add a check to floats for NaN and Inf
// which does not exist in base Squirrel
// The code looks a bit like this:
// 		if ( strcpy_s(fos + 4, 0x16ui64, "1#QNAN") )
//    		invoke_watson(0i64, 0i64, 0i64, 0, 0i64);
// 		goto LABEL_27; 
// As if turns out, there is NO way to check if a float is one of these values in script
// This alone, however, wouldn't be that bad, as it would simply result in a 1#QNAN being output to the screen.
// Unfortunately, Respawns universe sized brains did not stop there.
// One day, a dev at Respawn had to write a function to convert an amount of hours into a timestring.
// Now, you and i dear reader would, being mortals, opt for the O(1) time solution of using the floor() and modulo functions
// You may think this would work perfectly, but you would be wrong. This is not the respawn Way!
// Instead, they opted to write the following piece of O(n) time algorithm:
// 	while ( minutes >= 60 )
//		{
//			minutes -= 60
//			hours++
//		}
// Now you may ask: "Is this horribly inefficient and bug-prone?", but you must understand: This is the Respawn Way
// Passing in a NaN does not simply output a NaN to the screen, for that would be too simple.
// Nay, instead, it hangs the UI thread for all eternity, as it tries to subtract 60 from a NaN
// In fact, i think we should thank that developer for all the fun times we have had tracking and fixing this bug
// However, we mortals cannot possibly wield the greatness of Respawn's code, and we must settle for a lowly O(1) algorithm instead
// P.S: The other part of this fix is menu_stats_utility.nut

void function InitViewStatsMapsMenu()
{
	var menu = GetMenu( "ViewStats_Maps_Menu" )
	file.menu = menu

	Hud_SetText( Hud_GetChild( file.menu, "MenuTitle" ), "#STATS_MAPS" )

	file.gridData.rows = 5
	file.gridData.columns = 1
	//file.gridData.numElements // Set in OnViewStatsWeapons_Open after itemdata exists
	file.gridData.pageType = eGridPageType.VERTICAL
	file.gridData.tileWidth = 224
	file.gridData.tileHeight = 112
	file.gridData.paddingVert = 6
	file.gridData.paddingHorz = 6

	Grid_AutoAspectSettings( menu, file.gridData )

	file.gridData.initCallback = MapButton_Init
	file.gridData.getFocusCallback = MapButton_GetFocus
	file.gridData.clickCallback = MapButton_Activate

	AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, OnViewStatsWeapons_Open )

	AddMenuFooterOption( file.menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
}

void function OnViewStatsWeapons_Open()
{
	UI_SetPresentationType( ePresentationType.NO_MODELS )

	file.allMaps = GetPrivateMatchMaps()

	file.gridData.numElements = file.allMaps.len()

	if ( !file.isGridInitialized )
	{
		GridMenuInit( file.menu, file.gridData )
		file.isGridInitialized = true
	}

	file.gridData.currentPage = 0

	Grid_InitPage( file.menu, file.gridData )
	Hud_SetFocused( Grid_GetButtonForElementNumber( file.menu, 0 ) )
	UpdateStatsForMap( file.allMaps[ 0 ] )
}

bool function MapButton_Init( var button, int elemNum )
{
	string mapName = file.allMaps[ elemNum ]

	asset mapImage = GetMapImageForMapName( mapName )

	var rui = Hud_GetRui( button )
	RuiSetImage( rui, "buttonImage", mapImage )

	Hud_SetEnabled( button, true )
	Hud_SetVisible( button, true )

	return true
}

void function MapButton_GetFocus( var button, int elemNum )
{
	if ( IsControllerModeActive() )
		UpdateStatsForMap( file.allMaps[ elemNum ] )
}

void function MapButton_Activate( var button, int elemNum )
{
	if ( !IsControllerModeActive() )
		UpdateStatsForMap( file.allMaps[ elemNum ] )
}

int function GetGameStatForMapInt( string gameStat, string mapName )
{
	array<string> privateMatchModes = GetPrivateMatchModes()

	int totalStat = 0
	int enumCount = PersistenceGetEnumCount( "gameModes" )
	for ( int modeId = 0; modeId < enumCount; modeId++ )
	{
		string modeName = PersistenceGetEnumItemNameForIndex( "gameModes", modeId )

		totalStat += GetGameStatForMapAndModeInt( gameStat, mapName, modeName )
	}

	return totalStat
}

int function GetGameStatForMapAndModeInt( string gameStat, string mapName, string modeName, string difficulty = "1" )
{
	string statString = GetStatVar( "game_stats", gameStat, "" )
	string persistentVar = Stats_GetFixedSaveVar( statString, mapName, modeName, difficulty )

	return GetUIPlayer().GetPersistentVarAsInt( persistentVar )
}

float function GetGameStatForMapFloat( string gameStat, string mapName )
{
	array<string> privateMatchModes = GetPrivateMatchModes()

	float totalStat = 0
	int enumCount = PersistenceGetEnumCount( "gameModes" )
	for ( int modeId = 0; modeId < enumCount; modeId++ )
	{
		string modeName = PersistenceGetEnumItemNameForIndex( "gameModes", modeId )

		if ( (GetGameStatForMapAndModeFloat( gameStat, mapName, modeName ).tostring() ) != "1.#QNAN" )
			totalStat += GetGameStatForMapAndModeFloat( gameStat, mapName, modeName )
		else
			print("Hey buddy, I just saved you from a game freeze. You're welcome :)")
	}

	return totalStat
}

float function GetGameStatForMapAndModeFloat( string gameStat, string mapName, string modeName )
{
	string statString = GetStatVar( "game_stats", gameStat, "" )
	string persistentVar = Stats_GetFixedSaveVar( statString, mapName, modeName, "1" )

	return expect float( GetUIPlayer().GetPersistentVar( persistentVar ) )
}


void function UpdateStatsForMap( string mapName )
{
	entity player = GetUIPlayer()
	if ( player == null )
		return

	Hud_SetText( Hud_GetChild( file.menu, "WeaponName" ), GetMapDisplayName( mapName ) )

	// Image
	var imageElem = Hud_GetRui( Hud_GetChild( file.menu, "WeaponImageLarge" ) )
	RuiSetImage( imageElem, "basicImage", GetMapImageForMapName( mapName ) )
	var hoursplayed = GetGameStatForMapFloat( "hoursPlayed", mapName ) 
	string timePlayed = HoursToTimeString( GetGameStatForMapFloat( "hoursPlayed", mapName ) )
	string gamesPlayed = string( GetGameStatForMapInt( "game_completed", mapName ) )

	SetStatBoxDisplay( Hud_GetChild( file.menu, "Stat0" ), Localize( "#STATS_HEADER_TIME_PLAYED" ), 		timePlayed )
	SetStatBoxDisplay( Hud_GetChild( file.menu, "Stat1" ), Localize( "#STATS_GAMES_PLAYED" ), 				gamesPlayed )
	//SetStatBoxDisplay( Hud_GetChild( file.menu, "Stat2" ), Localize( "#STATS_GAMES_PLAYED" ), 				gamesPlayed )
	//SetStatBoxDisplay( Hud_GetChild( file.menu, "Stat3" ), Localize( "#STATS_GAMES_PLAYED" ), 				gamesPlayed )

	string winPercent = GetPercent( float( GetGameStatForMapInt( "game_won", mapName ) ), float( GetGameStatForMapInt( "game_completed", mapName ) ), 0 )

	SetStatsLabelValue( file.menu, "KillsLabel0", 				"#STATS_GAMES_WIN_PERCENT" )
	SetStatsLabelValue( file.menu, "KillsValue0", 				("" + winPercent + "%") )

	SetStatsLabelValue( file.menu, "KillsLabel1", 				"#STATS_GAMES_WON" )
	SetStatsLabelValue( file.menu, "KillsValue1", 				GetGameStatForMapInt( "game_won", mapName ) )

	SetStatsLabelValue( file.menu, "KillsLabel2", 				"#STATS_GAMES_MVP" )
	SetStatsLabelValue( file.menu, "KillsValue2", 				GetGameStatForMapInt( "mvp", mapName ) )

	SetStatsLabelValue( file.menu, "KillsLabel3", 				"#STATS_GAMES_TOP3" )
	SetStatsLabelValue( file.menu, "KillsValue3", 				GetGameStatForMapInt( "top3OnTeam", mapName ) )

	SetStatsLabelValue( file.menu, "KillsLabel4", 				"--" )
	SetStatsLabelValue( file.menu, "KillsValue4", 				"--" )

	//var anchorElem = Hud_GetChild( file.menu, "WeaponStatsBackground" )
	//printt( Hud_GetX( anchorElem ) )
	//printt( Hud_GetX( anchorElem ) )
	//printt( Hud_GetX( anchorElem ) )
	//printt( Hud_GetX( anchorElem ) )
	//Hud_SetX( anchorElem, 0 )
	//
	array<string> gameModesArray = GetPersistenceEnumAsArray( "gameModes" )

	array<PieChartEntry> modes
	foreach ( modeName in gameModesArray )
	{
		float modePlayedTime = GetGameStatForMapAndModeFloat( "hoursPlayed", mapName, modeName )
		if ( modePlayedTime > 0 )
			AddPieChartEntry( modes, GameMode_GetName( modeName ), modePlayedTime, GetGameModeDisplayColor( modeName ) )
	}

	const MAX_MODE_ROWS = 8

	if ( modes.len() > 0 )
	{
		modes.sort( ComparePieChartEntryValues )

		if ( modes.len() > MAX_MODE_ROWS )
		{
			float otherValue
			for ( int i = MAX_MODE_ROWS-1; i < modes.len() ; i++ )
				otherValue += modes[i].numValue

			modes.resize( MAX_MODE_ROWS-1 )
			AddPieChartEntry( modes, "#GAMEMODE_OTHER", otherValue, [127, 127, 127, 255] )
		}
	}

	PieChartData modesPlayedData
	modesPlayedData.entries = modes
	modesPlayedData.labelColor = [ 255, 255, 255, 255 ]
	SetPieChartData( file.menu, "ModesPieChart", "#GAME_MODES_PLAYED", modesPlayedData )

	array<string> fdMaps = GetPlaylistMaps( "fd" )

	if ( fdMaps.contains( mapName ) )
	{
		array<var> pveElems = GetElementsByClassname( file.menu, "PvEGroup" )
		foreach ( elem in pveElems )
		{
			Hud_Show( elem )
		}

		vector perfectColor = TEAM_COLOR_FRIENDLY / 219.0

		var iconLegendRui = Hud_GetRui( Hud_GetChild( file.menu, "PvEIconLegend" ) )
		RuiSetImage( iconLegendRui, "basicImage", $"rui/menu/gametype_select/playlist_fd_normal" )
		RuiSetFloat3( iconLegendRui, "basicImageColor", perfectColor )

		var icon0Rui = Hud_GetRui( Hud_GetChild( file.menu, "PvEIcon0" ) )
		RuiSetImage( icon0Rui, "basicImage", $"rui/menu/gametype_select/playlist_fd_easy" )
		int easyWins = GetGameStatForMapAndModeInt( "games_completed_fd", mapName, "fd", "0" )
		SetStatsLabelValue( file.menu, "PvELabel0", 				"#FD_DIFFICULTY_EASY" )
		SetStatsLabelValue( file.menu, "PvEValueA0", 				easyWins )
		if ( GetGameStatForMapAndModeInt( "perfectMatches", mapName, "fd", "0" ) )
			RuiSetFloat3( icon0Rui, "basicImageColor", perfectColor )
		else
			RuiSetFloat3( icon0Rui, "basicImageColor", easyWins > 0 ? <1, 1, 1> : <0.15, 0.15, 0.15> )

		var icon1Rui = Hud_GetRui( Hud_GetChild( file.menu, "PvEIcon1" ) )
		RuiSetImage( icon1Rui, "basicImage", $"rui/menu/gametype_select/playlist_fd_normal" )
		int normalWins = GetGameStatForMapAndModeInt( "games_completed_fd", mapName, "fd", "1" )
		SetStatsLabelValue( file.menu, "PvELabel1", 				"#FD_DIFFICULTY_NORMAL" )
		SetStatsLabelValue( file.menu, "PvEValueA1", 				normalWins )
		if ( GetGameStatForMapAndModeInt( "perfectMatches", mapName, "fd", "1" ) )
			RuiSetFloat3( icon1Rui, "basicImageColor", perfectColor )
		else
			RuiSetFloat3( icon1Rui, "basicImageColor", normalWins > 0 ? <1, 1, 1> : <0.15, 0.15, 0.15> )

		var icon2Rui = Hud_GetRui( Hud_GetChild( file.menu, "PvEIcon2" ) )
		RuiSetImage( icon2Rui, "basicImage", $"rui/menu/gametype_select/playlist_fd_hard" )
		int hardWins = GetGameStatForMapAndModeInt( "games_completed_fd", mapName, "fd", "2" )
		SetStatsLabelValue( file.menu, "PvELabel2", 				"#FD_DIFFICULTY_HARD" )
		SetStatsLabelValue( file.menu, "PvEValueA2", 				hardWins )
		if ( GetGameStatForMapAndModeInt( "perfectMatches", mapName, "fd", "2" ) )
			RuiSetFloat3( icon2Rui, "basicImageColor", perfectColor )
		else
			RuiSetFloat3( icon2Rui, "basicImageColor", hardWins > 0 ? <1, 1, 1> : <0.15, 0.15, 0.15> )

		var icon3Rui = Hud_GetRui( Hud_GetChild( file.menu, "PvEIcon3" ) )
		RuiSetImage( icon3Rui, "basicImage", $"rui/menu/gametype_select/playlist_fd_master" )
		int masterWins = GetGameStatForMapAndModeInt( "games_completed_fd", mapName, "fd", "3" )
		SetStatsLabelValue( file.menu, "PvELabel3", 				"#FD_DIFFICULTY_MASTER" )
		SetStatsLabelValue( file.menu, "PvEValueA3", 				masterWins )
		if ( GetGameStatForMapAndModeInt( "perfectMatches", mapName, "fd", "3" ) )
			RuiSetFloat3( icon3Rui, "basicImageColor", perfectColor )
		else
			RuiSetFloat3( icon3Rui, "basicImageColor", masterWins > 0 ? <1, 1, 1> : <0.15, 0.15, 0.15> )

		var icon4Rui = Hud_GetRui( Hud_GetChild( file.menu, "PvEIcon4" ) )
		RuiSetImage( icon4Rui, "basicImage", $"rui/menu/gametype_select/playlist_fd_insane" )
		int insaneWins = GetGameStatForMapAndModeInt( "games_completed_fd", mapName, "fd", "4" )
		SetStatsLabelValue( file.menu, "PvELabel4", 				"#FD_DIFFICULTY_INSANE" )
		SetStatsLabelValue( file.menu, "PvEValueA4", 				insaneWins )
		if ( GetGameStatForMapAndModeInt( "perfectMatches", mapName, "fd", "4" ) )
			RuiSetFloat3( icon4Rui, "basicImageColor", perfectColor )
		else
			RuiSetFloat3( icon4Rui, "basicImageColor", insaneWins > 0 ? <1, 1, 1> : <0.15, 0.15, 0.15> )
	}
	else
	{
		array<var> pveElems = GetElementsByClassname( file.menu, "PvEGroup" )
		foreach ( elem in pveElems )
		{
			Hud_Hide( elem )
		}
	}
}


var function setit( vector color )
{
	var iconLegendRui = Hud_GetRui( Hud_GetChild( file.menu, "PvEIconLegend" ) )
	RuiSetImage( iconLegendRui, "basicImage", $"rui/menu/gametype_select/playlist_fd_normal" )
	RuiSetFloat3( iconLegendRui, "basicImageColor", color )
}