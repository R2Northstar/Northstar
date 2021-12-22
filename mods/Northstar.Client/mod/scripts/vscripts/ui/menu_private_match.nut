untyped

global function MenuPrivateMatch_Init

global function InitPrivateMatchMenu

global function HandleLockedCustomMenuItem
global function GetMapImageForMapName

struct
{
	var menu

	array matchStatusRuis

	array MMDevStringElems

	array teamSlotBackgrounds
	array teamSlotBackgroundsNeutral

	var enemyTeamBackgroundPanel
	var friendlyTeamBackgroundPanel
	var enemyTeamBackground
	var friendlyTeamBackground
	var enemyPlayersPanel
	var friendlyPlayersPanel

	var listFriendlies
	var listEnemies

	var nextMapNameLabel
	var nextGameModeLabel

	var inviteRoomButton
	var inviteFriendsButton

	int inboxHeaderIndex

	int customizeHeaderIndex
	var pilotButton
	var titanButton
	var boostsButton
	var storeButton
	var factionButton
	var bannerButton
	var patchButton
	var statsButton
	var dpadCommsButton

	var playHeader
	var customizeHeader
	var callsignHeader
	var storeHeader

	var startMatchButton
	var selectMapButton
	var selectModeButton
	var matchSettingsButton

	var callsignCard

	var spectatorLabel

	var matchSettingsPanel

	ComboStruct &lobbyComboStruct
} file

const table<asset> mapImages =
{
	mp_forwardbase_kodai = $"loadscreens/mp_forwardbase_kodai_lobby",
	mp_grave = $"loadscreens/mp_grave_lobby",
	mp_homestead = $"loadscreens/mp_homestead_lobby",
	mp_thaw = $"loadscreens/mp_thaw_lobby",
	mp_black_water_canal = $"loadscreens/mp_black_water_canal_lobby",
	mp_eden = $"loadscreens/mp_eden_lobby",
	mp_drydock = $"loadscreens/mp_drydock_lobby",
	mp_crashsite3 = $"loadscreens/mp_crashsite3_lobby",
	mp_complex3 = $"loadscreens/mp_complex3_lobby",
	mp_angel_city = $"loadscreens/mp_angle_city_r2_lobby",
	mp_colony02 = $"loadscreens/mp_colony02_lobby",
	mp_glitch = $"loadscreens/mp_glitch_lobby",
	mp_lf_stacks = $"loadscreens/mp_stacks_lobby",
	mp_lf_meadow = $"loadscreens/mp_meadow_lobby",
	mp_lf_deck = $"loadscreens/mp_lf_deck_lobby",
	mp_lf_traffic = $"loadscreens/mp_lf_traffic_lobby",
	mp_coliseum = $"loadscreens/mp_coliseum_lobby",
	mp_coliseum_column = $"loadscreens/mp_coliseum_column_lobby",
	mp_relic02 = $"loadscreens/mp_relic02_lobby",
	mp_wargames = $"loadscreens/mp_wargames_lobby",
	mp_rise = $"loadscreens/mp_rise_lobby",
	mp_lf_township = $"loadscreens/mp_lf_township_lobby",
	mp_lf_uma = $"loadscreens/mp_lf_uma_lobby",
	
	// not really sure if this should be here, whatever
	// might be good to make this modular in the future?
	sp_training = $"rui/menu/level_select/level_image1",
	sp_crashsite = $"rui/menu/level_select/level_image2",
	sp_sewers1 = $"rui/menu/level_select/level_image3",
	sp_boomtown_start = $"rui/menu/level_select/level_image4",
	sp_hub_timeshift = $"rui/menu/level_select/level_image5",
	sp_beacon = $"rui/menu/level_select/level_image6",
	sp_tday = $"rui/menu/level_select/level_image7",
	sp_s2s = $"rui/menu/level_select/level_image8",
	sp_skyway_v1 = $"rui/menu/level_select/level_image9",

	// mp converted variants
	mp_training = $"rui/menu/level_select/level_image1",
	mp_crashsite = $"rui/menu/level_select/level_image2",
	mp_sewers1 = $"rui/menu/level_select/level_image3",
	mp_boomtown_start = $"rui/menu/level_select/level_image4",
	mp_hub_timeshift = $"rui/menu/level_select/level_image5",
	mp_beacon = $"rui/menu/level_select/level_image6",
	mp_tday = $"rui/menu/level_select/level_image7",
	mp_s2s = $"rui/menu/level_select/level_image8",
	mp_skyway_v1 = $"rui/menu/level_select/level_image9",
}

void function MenuPrivateMatch_Init()
{
	PrecacheHUDMaterial( $"ui/menu/common/menu_background_neutral" )
	PrecacheHUDMaterial( $"ui/menu/common/menu_background_imc" )
	PrecacheHUDMaterial( $"ui/menu/common/menu_background_militia" )
	PrecacheHUDMaterial( $"ui/menu/common/menu_background_imc_blur" )
	PrecacheHUDMaterial( $"ui/menu/common/menu_background_militia_blur" )
	PrecacheHUDMaterial( $"ui/menu/common/menu_background_neutral_blur" )
	PrecacheHUDMaterial( $"ui/menu/common/menu_background_blackMarket" )
	PrecacheHUDMaterial( $"ui/menu/rank_menus/ranked_FE_background" )

	PrecacheHUDMaterial( $"ui/menu/lobby/friendly_slot" )
	PrecacheHUDMaterial( $"ui/menu/lobby/friendly_player" )
	PrecacheHUDMaterial( $"ui/menu/lobby/enemy_slot" )
	PrecacheHUDMaterial( $"ui/menu/lobby/enemy_player" )
	PrecacheHUDMaterial( $"ui/menu/lobby/neutral_slot" )
	PrecacheHUDMaterial( $"ui/menu/lobby/neutral_player" )
	PrecacheHUDMaterial( $"ui/menu/lobby/player_hover" )
	PrecacheHUDMaterial( $"ui/menu/main_menu/motd_background" )
	PrecacheHUDMaterial( $"ui/menu/main_menu/motd_background_happyhour" )

	AddUICallback_OnLevelInit( OnPrivateLobbyLevelInit )
}

asset function GetMapImageForMapName( string mapName )
{
	if ( mapName in mapImages )
		return mapImages[mapName]
		
	// no way to convert string => asset for dynamic stuff so
	// pain
	return expect asset ( compilestring( "return $\"loadscreens/" + mapName + "_lobby\"" )() )
}


void function InitPrivateMatchMenu()
{
	var menu = GetMenu( "PrivateLobbyMenu" )
	file.menu = menu

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnPrivateMatchMenu_Open )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, OnLobbyMenu_Close )
	AddMenuEventHandler( menu, eUIEvent.MENU_NAVIGATE_BACK, OnLobbyMenu_NavigateBack )

	file.startMatchButton = Hud_GetChild( menu, "StartMatchButton" )
	Hud_AddEventHandler( file.startMatchButton, UIE_CLICK, OnStartMatchButton_Activate )

	RegisterUIVarChangeCallback( "privatematch_map", Privatematch_map_Changed )
	RegisterUIVarChangeCallback( "privatematch_mode", Privatematch_mode_Changed )
	RegisterUIVarChangeCallback( "privatematch_starting", Privatematch_starting_Changed )
	RegisterUIVarChangeCallback( "gameStartTime", GameStartTime_Changed )

	file.matchStatusRuis = GetElementsByClassnameForMenus( "MatchmakingStatusRui", uiGlobal.allMenus )
	file.MMDevStringElems = GetElementsByClassnameForMenus( "MMDevStringClass", uiGlobal.allMenus )

	file.friendlyPlayersPanel = Hud_GetChild( menu, "MatchFriendliesPanel" )
	file.enemyPlayersPanel = Hud_GetChild( menu, "MatchEnemiesPanel" )

	file.listFriendlies = Hud_GetChild( file.friendlyPlayersPanel, "ListFriendlies" )
	file.listEnemies = Hud_GetChild( file.enemyPlayersPanel, "ListEnemies" )

	file.friendlyTeamBackgroundPanel = Hud_GetChild( file.friendlyPlayersPanel, "LobbyFriendlyTeamBackground" )
	file.enemyTeamBackgroundPanel = Hud_GetChild( file.enemyPlayersPanel, "LobbyEnemyTeamBackground" )

#if PC_PROG
	var panelSize = Hud_GetSize( file.enemyPlayersPanel )
	Hud_SetSize( Hud_GetChild( menu, "LobbyChatBox" ), panelSize[0], panelSize[1] )
#endif // #if PC_PROG

	file.friendlyTeamBackground = Hud_GetChild( file.friendlyTeamBackgroundPanel, "TeamBackground" )
	file.enemyTeamBackground = Hud_GetChild( file.enemyTeamBackgroundPanel, "TeamBackground" )

	file.teamSlotBackgrounds = GetElementsByClassnameForMenus( "LobbyTeamSlotBackgroundClass", uiGlobal.allMenus )
	file.teamSlotBackgroundsNeutral = GetElementsByClassnameForMenus( "LobbyTeamSlotBackgroundNeutralClass", uiGlobal.allMenus )

	file.nextMapNameLabel = Hud_GetChild( menu, "NextMapName" )
	file.nextGameModeLabel = Hud_GetChild( menu, "NextGameModeName" )

	file.callsignCard = Hud_GetChild( menu, "CallsignCard" )

	file.spectatorLabel = Hud_GetChild( menu, "SpectatorLabel" )

	file.matchSettingsPanel = Hud_GetChild( menu, "MatchSettings" )

	SetupComboButtons( menu, file.startMatchButton, file.listFriendlies )

	AddMenuFooterOption( menu, BUTTON_A, "#A_BUTTON_SELECT", "" )
	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )

	AddMenuFooterOption( menu, BUTTON_Y, "#Y_BUTTON_SWITCH_TEAMS", "#SWITCH_TEAMS", PCSwitchTeamsButton_Activate, CanSwitchTeams )
	AddMenuFooterOption( menu, BUTTON_X, "#X_BUTTON_MUTE", "#MOUSE2_MUTE", null, CanMute )
	AddMenuFooterOption( menu, BUTTON_SHOULDER_RIGHT, "#RB_TRIGGER_TOGGLE_SPECTATE", "#SPECTATE_TEAM", PCToggleSpectateButton_Activate, CanSwitchTeams )

	AddMenuVarChangeHandler( "focus", UpdateFooterOptions )
	AddMenuVarChangeHandler( "isFullyConnected", UpdateFooterOptions )
	AddMenuVarChangeHandler( "isPartyLeader", UpdateFooterOptions )
	AddMenuVarChangeHandler( "isPrivateMatch", UpdateFooterOptions )
	#if DURANGO_PROG
		AddMenuVarChangeHandler( "DURANGO_canInviteFriends", UpdateFooterOptions )
		AddMenuVarChangeHandler( "DURANGO_isJoinable", UpdateFooterOptions )
		AddMenuVarChangeHandler( "DURANGO_isGameFullyInstalled", UpdateFooterOptions )
	#elseif PS4_PROG
		AddMenuVarChangeHandler( "PS4_canInviteFriends", UpdateFooterOptions )
	#elseif PC_PROG
		AddMenuVarChangeHandler( "ORIGIN_isEnabled", UpdateFooterOptions )
		AddMenuVarChangeHandler( "ORIGIN_isJoinable", UpdateFooterOptions )
	#endif
}


void function OnSelectMapButton_Activate( var button )
{
	if ( Hud_IsLocked( button ) )
		return

	AdvanceMenu( GetMenu( "MapsMenu" ) )
}

void function OnSelectModeButton_Activate( var button )
{
	if ( Hud_IsLocked( button ) )
		return

	AdvanceMenu( GetMenu( "ModesMenu" ) )
}

void function OnSelectMatchSettings_Activate( var button )
{
	if ( Hud_IsLocked( button ) )
		return

	if ( !IsNorthstarServer() )
		AdvanceMenu( GetMenu( "MatchSettingsMenu" ) )
	else
		AdvanceMenu( GetMenu( "CustomMatchSettingsCategoryMenu" ) )
}

void function SetupComboButtons( var menu, var navUpButton, var navDownButton  )
{
	ComboStruct comboStruct = ComboButtons_Create( menu )
	file.lobbyComboStruct = comboStruct

	comboStruct.navUpButton = navUpButton
	comboStruct.navDownButton = navDownButton

	int headerIndex = 0
	int buttonIndex = 0
	file.playHeader = AddComboButtonHeader( comboStruct, headerIndex, "#MENU_HEADER_PRIVATE_MATCH" )
	var selectModeButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_SELECT_MODE" )
	file.selectModeButton = selectModeButton
	Hud_AddEventHandler( selectModeButton, UIE_CLICK, OnSelectModeButton_Activate )
	var selectMapButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_SELECT_MAP" )
	file.selectMapButton = selectMapButton
	Hud_AddEventHandler( selectMapButton, UIE_CLICK, OnSelectMapButton_Activate )

	file.matchSettingsButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_MATCH_SETTINGS" )
	Hud_AddEventHandler( file.matchSettingsButton, UIE_CLICK, OnSelectMatchSettings_Activate )

	if ( !IsNorthstarServer() )
	{
		var friendsButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_INVITE_FRIENDS" )
		file.inviteFriendsButton = friendsButton
		Hud_AddEventHandler( friendsButton, UIE_CLICK, InviteFriendsIfAllowed )
	}

	headerIndex++
	buttonIndex = 0
	file.customizeHeader = AddComboButtonHeader( comboStruct, headerIndex, "#MENU_HEADER_LOADOUTS" )
	file.customizeHeaderIndex = headerIndex
	var pilotButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_PILOT" )
	file.pilotButton = pilotButton

	Hud_AddEventHandler( pilotButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "EditPilotLoadoutsMenu" ) ) )
	var titanButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_TITAN" )
	file.titanButton = titanButton
	Hud_AddEventHandler( titanButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "EditTitanLoadoutsMenu" ) ) )
	file.boostsButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_BOOSTS" )
	Hud_AddEventHandler( file.boostsButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "BurnCardMenu" ) ) )
	file.dpadCommsButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_COMMS" )
	Hud_AddEventHandler( file.dpadCommsButton, UIE_CLICK, OnDpadCommsButton_Activate )

	headerIndex++
	buttonIndex = 0
	file.callsignHeader = AddComboButtonHeader( comboStruct, headerIndex, "#MENU_HEADER_CALLSIGN" )
	file.bannerButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_BANNER" )
	Hud_AddEventHandler( file.bannerButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "CallsignCardSelectMenu" ) ) )
	file.patchButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_PATCH" )
	Hud_AddEventHandler( file.patchButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "CallsignIconSelectMenu" ) ) )
	file.factionButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_FACTION" )
	Hud_AddEventHandler( file.factionButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "FactionChoiceMenu" ) ) )
	file.statsButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_STATS" )
	Hud_AddEventHandler( file.statsButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "ViewStatsMenu" ) ) )

	file.callsignCard = Hud_GetChild( menu, "CallsignCard" )

	headerIndex++
	buttonIndex = 0
	file.storeHeader = AddComboButtonHeader( comboStruct, headerIndex, "#MENU_HEADER_STORE" )
	file.storeButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_STORE_BROWSE" )
	Hud_AddEventHandler( file.storeButton, UIE_CLICK, OnStoreButton_Activate )
	var storeNewReleasesButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_STORE_NEW_RELEASES" )
	Hud_AddEventHandler( storeNewReleasesButton, UIE_CLICK, OnStoreNewReleasesButton_Activate )
	var storeBundlesButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_STORE_BUNDLES" )
	Hud_AddEventHandler( storeBundlesButton, UIE_CLICK, OnStoreBundlesButton_Activate )

	headerIndex++
	buttonIndex = 0
	var settingsHeader = AddComboButtonHeader( comboStruct, headerIndex, "#MENU_HEADER_SETTINGS" )
	var controlsButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_CONTROLS" )
	Hud_AddEventHandler( controlsButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "ControlsMenu" ) ) )
	#if CONSOLE_PROG
		var avButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#AUDIO_VIDEO" )
		Hud_AddEventHandler( avButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "AudioVideoMenu" ) ) )
	#elseif PC_PROG
		var videoButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#AUDIO" )
		Hud_AddEventHandler( videoButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "AudioMenu" ) ) )
		var soundButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#VIDEO" )
		Hud_AddEventHandler( soundButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "VideoMenu" ) ) )
	#endif
	var knbButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#KNB_MENU_HEADER" )
	Hud_AddEventHandler( knbButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "KnowledgeBaseMenu" ) ) )

	ComboButtons_Finalize( comboStruct )
}


bool function IsPlayerListFocused()
{
	var focusedItem = GetFocus()

	// The check for GetScriptID existing isn't ideal, but if the text chat text output element has focus it will script error otherwise
	return ( (focusedItem != null) && ("GetScriptID" in focusedItem) && (Hud_GetScriptID( focusedItem ) == "PlayerListButton") )
}

bool function MatchResultsExist()
{
	return true // TODO
}

bool function CanSwitchTeams()
{
	return ( GetMenuVarBool( "isPrivateMatch" ) && ( level.ui.privatematch_starting != ePrivateMatchStartState.STARTING ) )
}

bool function CanMute()
{
	return IsPlayerListFocused()
}

void function OnLobbyMenu_Open()
{
	Assert( IsConnected() )

	UpdatePrivateMatchButtons()

	thread UpdateLobbyUI()
	thread LobbyMenuUpdate( GetMenu( "PrivateLobbyMenu" ) )

	if ( uiGlobal.activeMenu == GetMenu( "PrivateLobbyMenu" ) )
		UI_SetPresentationType( ePresentationType.NO_MODELS )

	if ( IsFullyConnected() )
	{
		entity player = GetUIPlayer()
		if ( !IsValid( player ) )
			return

		while ( player.GetPersistentVarAsInt( "initializedVersion" ) < PERSISTENCE_INIT_VERSION )
		{
			WaitFrame()
		}

		UpdateCallsignElement( file.callsignCard )
		RefreshCreditsAvailable()

		bool emotesAreEnabled = EmotesEnabled()
		// "Customize"
		{
			bool anyNewPilotItems = HasAnyNewPilotItems( player )
			bool anyNewTitanItems = HasAnyNewTitanItems( player )
			bool anyNewBoosts = HasAnyNewBoosts( player )
			bool anyNewCommsIcons = false // emotesAreEnabled ? HasAnyNewDpadCommsIcons( player ) : false
			bool anyNewCustomizeHeader = (anyNewPilotItems || anyNewTitanItems || anyNewBoosts || anyNewCommsIcons)

			RuiSetBool( Hud_GetRui( file.customizeHeader ), "isNew", anyNewCustomizeHeader )
			ComboButton_SetNew( file.pilotButton, anyNewPilotItems )
			ComboButton_SetNew( file.titanButton, anyNewTitanItems )
			ComboButton_SetNew( file.boostsButton, anyNewBoosts )
			ComboButton_SetNew( file.dpadCommsButton, anyNewCommsIcons )

			if ( !emotesAreEnabled )
			{
				Hud_Hide( file.dpadCommsButton )
				ComboButtons_ResetColumnFocus( file.lobbyComboStruct )
			}
			else
			{
				Hud_Show( file.dpadCommsButton )
			}
		}

		// "Store"
		{
			bool storeIsNew = DLCStoreShouldBeMarkedAsNew()
			RuiSetBool( Hud_GetRui( file.storeHeader ), "isNew", storeIsNew )
			ComboButton_SetNew( file.storeButton, storeIsNew )
		}

		// "Callsign"
		{
			bool anyNewBanners = HasAnyNewCallsignBanners( player )
			bool anyNewPatches = HasAnyNewCallsignPatches( player )
			bool anyNewFactions = HasAnyNewFactions( player )
			bool anyNewCallsignHeader = (anyNewBanners || anyNewPatches || anyNewFactions)

			RuiSetBool( Hud_GetRui( file.callsignHeader ), "isNew", anyNewCallsignHeader )
			ComboButton_SetNew( file.bannerButton, anyNewBanners )
			ComboButton_SetNew( file.patchButton, anyNewPatches )
			ComboButton_SetNew( file.factionButton, anyNewFactions )
		}
	}
}

void function LobbyMenuUpdate( var menu )
{
	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )

	while ( GetTopNonDialogMenu() == menu )
	{
		WaitFrame()
	}
}



void function OnLobbyMenu_Close()
{
	Signal( uiGlobal.signalDummy, "OnCloseLobbyMenu" )
}

void function OnLobbyMenu_NavigateBack()
{
	LeaveDialog()
}

function GameStartTime_Changed()
{
	printt( "GameStartTime_Changed", level.ui.gameStartTime )
	UpdateGameStartTimeCounter()
}

function UpdateGameStartTimeCounter()
{
	if ( level.ui.gameStartTime == null )
	{
		MatchmakingSetSearchText( "" )
		MatchmakingSetCountdownTimer( 0.0 )
		HideMatchmakingStatusIcons()
		return
	}

	MatchmakingSetSearchText( "#STARTING_IN_LOBBY" )
	MatchmakingSetCountdownTimer( expect float( level.ui.gameStartTime + 0.0 ) )
	ShowMatchmakingStatusIcons()
}

function UpdateDebugStatus()
{
	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )

	OnThreadEnd(
		function() : ()
		{
			foreach ( elem in file.MMDevStringElems )
				Hud_Hide( elem )
		}
	)

	foreach ( elem in file.MMDevStringElems )
		Hud_Show( elem )

	while ( true )
	{
		local strstr = GetLobbyDevString()
		foreach ( elem in file.MMDevStringElems )
			Hud_SetText( elem, strstr )

		WaitFrameOrUntilLevelLoaded()
	}
}

void function SetMapInfo( string mapName )
{
	var nextMapImage = Hud_GetChild( file.menu, "NextMapImage" )

	asset mapImage = GetMapImageForMapName( mapName )
	RuiSetImage( Hud_GetRui( nextMapImage ), "basicImage", mapImage )
	Hud_Show( nextMapImage )

	Hud_SetText( file.nextMapNameLabel, GetMapDisplayName( mapName ) )
}

void function SetModeInfo( string modeName )
{
	var nextModeIcon = Hud_GetChild( file.menu, "NextModeIcon" )
	RuiSetImage( Hud_GetRui( nextModeIcon ), "basicImage", GetPlaylistThumbnailImage( modeName ) )
	Hud_Show( nextModeIcon )

	Hud_SetText( file.nextGameModeLabel, GetGameModeDisplayName( modeName ) )
}

function Privatematch_map_Changed()
{
	if ( !IsPrivateMatch() )
		return
	if ( !IsLobby() )
		return

	string mapName = PrivateMatch_GetSelectedMap()
	SetMapInfo( mapName )
}

function Privatematch_mode_Changed()
{
	if ( !IsPrivateMatch() )
		return
	if ( !IsLobby() )
		return

	string modeName = PrivateMatch_GetSelectedMode()
	SetModeInfo( modeName )

	UpdatePrivateMatchButtons()
	UpdateMatchSettingsForGamemode()
}


function Privatematch_starting_Changed()
{
	if ( !IsPrivateMatch() )
		return
	if ( !IsLobby() )
		return

	UpdatePrivateMatchButtons()
	UpdateFooterOptions()
}


function UpdatePrivateMatchButtons()
{
	var menu = file.menu

	if ( level.ui.privatematch_starting == ePrivateMatchStartState.STARTING )
	{
		RHud_SetText( file.startMatchButton, "#STOP_MATCH" )
		Hud_SetLocked( file.selectMapButton, true )
		Hud_SetLocked( file.selectModeButton, true )
		Hud_SetLocked( file.matchSettingsButton, true )
		
		if ( !IsNorthstarServer() )
			Hud_SetLocked( file.inviteFriendsButton, true )
	}
	else
	{
		RHud_SetText( file.startMatchButton, "#START_MATCH" )
		Hud_SetLocked( file.selectMapButton, false )
		Hud_SetLocked( file.selectModeButton, false )
		if ( !IsNorthstarServer() )
			Hud_SetLocked( file.inviteFriendsButton, false )

		string modeName = PrivateMatch_GetSelectedMode()
		bool settingsLocked = IsFDMode( modeName )

		if ( settingsLocked && uiGlobal.activeMenu == GetMenu( "MatchSettingsMenu" ) )
			CloseActiveMenu()

		Hud_SetLocked( file.matchSettingsButton, settingsLocked )
	}
}

function UpdateLobbyUI()
{
	if ( uiGlobal.updatingLobbyUI )
		return
	uiGlobal.updatingLobbyUI = true

	thread UpdateLobby()
	thread UpdateDebugStatus()
	thread UpdatePlayerInfo()

	if ( uiGlobal.EOGOpenInLobby )
		EOGOpen()

	WaitSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )
	uiGlobal.updatingLobbyUI = false
}

function UpdateLobby()
{
	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )

	var menu = file.menu

	WaitFrameOrUntilLevelLoaded()

	while ( true )
	{
		if ( !IsConnected() )
		{
			WaitFrameOrUntilLevelLoaded()
			continue
		}

		menu.RunAnimationScript( "PrivateMatchLobby" )
		// Force the animation scripts (which have zero duration) to complete before anything can cancel them.
		ForceUpdateHUDAnimations()

		UpdatePrivateMatchButtons()

		int gamemodeIdx = expect int( level.ui.privatematch_mode )
		int numPlaylistOverrides = GetPlaylistVarOverridesCount()
		string playlistOverridesDesc = ""
		for ( int varIdx = 0; varIdx < numPlaylistOverrides; ++varIdx )
		{	
			// temp fix for playlistoverrides that aren't handled by private match
			string varName = GetPlaylistVarOverrideNameByIndex( varIdx )
			
			if ( varName in MatchSettings_PlaylistVarLabels )
			{
				float varOrigVal = float( GetCurrentPlaylistGamemodeByIndexVar( gamemodeIdx, varName, false ) )
				float varOverrideVal = float( GetCurrentPlaylistGamemodeByIndexVar( gamemodeIdx, varName, true ) )
				if ( varOrigVal == varOverrideVal && !IsNorthstarServer() ) // stuff seems to break outside of northstar servers since we dont always use private_match playlist
					continue
	
				string label = Localize( MatchSettings_PlaylistVarLabels[varName] ) + ": "
				string value = MatchSettings_FormatPlaylistVarValue( varName, varOverrideVal )
				playlistOverridesDesc = playlistOverridesDesc + label + "`2" + value + " `0\n"
			}
			else
			{
				bool shouldBreak = false
				
				foreach ( string category in GetPrivateMatchSettingCategories( true ) )
				{
					foreach ( CustomMatchSettingContainer setting in GetPrivateMatchCustomSettingsForCategory( category ) )
					{
						if ( setting.playlistVar == varName )
						{
							if ( setting.isEnumSetting )
								playlistOverridesDesc += Localize( setting.localizedName ) + ": `2" + Localize( setting.enumNames[ setting.enumValues.find( expect string ( GetCurrentPlaylistVar( varName ) ) ) ] ) + "`0\n"
							else
								playlistOverridesDesc += Localize( setting.localizedName ) + ": `2" + GetCurrentPlaylistVar( varName ) + "`0\n"
							
							shouldBreak = true
							break
						}
					}
					
					if ( shouldBreak )
						break
				}
			}
		}

		if ( playlistOverridesDesc.len() )
		{
			RuiSetString( Hud_GetRui( file.matchSettingsPanel ), "description", playlistOverridesDesc )
			Hud_Show( file.matchSettingsPanel )
		}
		else
		{
			Hud_Hide( file.matchSettingsPanel )
		}

		if ( GetUIPlayer() && GetPersistentVar( "privateMatchState" ) == 1 )
			Hud_SetVisible( file.spectatorLabel, true )
		else
			Hud_SetVisible( file.spectatorLabel, false )

		WaitFrameOrUntilLevelLoaded()
	}
}

void function OnSettingsButton_Activate( var button )
{
	if ( level.ui.privatematch_starting == ePrivateMatchStartState.STARTING )
		return

	AdvanceMenu( GetMenu( "MatchSettingsMenu" ) )
}


void function OnPrivateMatchButton_Activate( var button )
{
	ShowPrivateMatchConnectDialog()
	ClientCommand( "match_playlist private_match" )
	ClientCommand( "StartPrivateMatchSearch" )
}

void function OnStartMatchButton_Activate( var button )
{
	if ( AmIPartyLeader() || GetPartySize() == 1 )
		ClientCommand( "PrivateMatchLaunch" )
}

function HandleLockedCustomMenuItem( menu, button, tipInfo, hideTip = false )
{
	array<var> elements = GetElementsByClassname( menu, "HideWhenLocked" )
	var buttonTooltip = Hud_GetChild( menu, "ButtonTooltip" )
	var toolTipLabel = Hud_GetChild( buttonTooltip, "Label" )

	if ( Hud_IsLocked( button ) && !hideTip )
	{
		foreach( elem in elements )
			Hud_Hide( elem )

		local tipArray = clone tipInfo
		tipInfo.resize( 6, null )

		Hud_SetText( toolTipLabel, tipInfo[0], tipInfo[1], tipInfo[2], tipInfo[3], tipInfo[4], tipInfo[5] )

		local buttonPos = button.GetAbsPos()
		local buttonHeight = button.GetHeight()
		local tooltipHeight = buttonTooltip.GetHeight()
		local yOffset = ( tooltipHeight - buttonHeight ) / 2.0

		buttonTooltip.SetPos( buttonPos[0] + button.GetWidth() * 0.9, buttonPos[1] - yOffset )
		Hud_Show( buttonTooltip )

		return true
	}
	else
	{
		foreach( elem in elements )
			Hud_Show( elem )
		Hud_Hide( buttonTooltip )
	}
	return false
}

void function PrivateMatchSwitchTeams( button )
{
	if ( !IsPrivateMatch() )
		return

	if ( !IsConnected() )
		return

	if ( uiGlobal.activeMenu != file.menu )
		return

	EmitUISound( "Menu_GameSummary_ScreenSlideIn" )

	ClientCommand( "PrivateMatchSwitchTeams" )
}

void function HideMatchmakingStatusIcons()
{
	foreach ( element in file.matchStatusRuis )
		RuiSetBool( Hud_GetRui( element ), "iconVisible", false )
}

void function ShowMatchmakingStatusIcons()
{
	foreach ( element in file.matchStatusRuis )
		RuiSetBool( Hud_GetRui( element ), "iconVisible", true )
}

void function MatchmakingSetSearchText( string searchText, var param1 = "", var param2 = "", var param3 = "", var param4 = "" )
{
	foreach ( element in file.matchStatusRuis )
	{
		RuiSetBool( Hud_GetRui( element ), "statusHasText", searchText != "" )

		RuiSetString( Hud_GetRui( element ), "statusText", Localize( searchText, param1, param2, param3, param4 ) )
	}
}


void function MatchmakingSetCountdownTimer( float time )
{
	foreach ( element in file.matchStatusRuis )
	{
		RuiSetBool( Hud_GetRui( element ), "timerHasText", time != 0.0 )
		RuiSetGameTime( Hud_GetRui( element ), "timerEndTime", time )
	}
}


void function OnPrivateLobbyLevelInit()
{
	UpdateCallsignElement( file.callsignCard )
	RefreshCreditsAvailable()
}


function UpdatePlayerInfo()
{
	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )

	var menu = file.menu

	WaitFrameOrUntilLevelLoaded()

	while ( true )
	{
		RefreshCreditsAvailable()
		WaitFrame()
	}
}

void function OnPrivateMatchMenu_Open()
{
	Lobby_SetFDMode( false )
	OnLobbyMenu_Open()
}