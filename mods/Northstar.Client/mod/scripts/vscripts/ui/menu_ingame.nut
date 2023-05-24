//global function InitLobbyStartMenu
global function InitInGameMPMenu
global function InitInGameSPMenu
global function ServerCallback_UI_ObjectiveUpdated
global function ServerCallback_UI_UpdateMissionLog
global function SP_ResetObjectiveStringIndex
global function SCB_SetDoubleXPStatus

global function SCB_SetCompleteMeritState
global function SCB_SetEvacMeritState
global function SCB_SetMeritCount
global function SCB_SetScoreMeritState
global function SCB_SetWinMeritState
global function SCB_SetWeaponMeritCount
global function SCB_SetTitanMeritCount

const DATA_TABLE = $"datatable/sp_difficulty.rpak"

struct
{
	var menuMP
	var menuSP
	var BtnTrackedChallengeBackground
	var BtnTrackedChallengeTitle
	array trackedChallengeButtons
	var BtnLastCheckpoint
	int objectiveStringIndex
	bool SP_displayObjectiveOnClose
	var settingsHeader
	var faqButton
	int titanHeaderIndex
	var titanHeader
	var titanSelectButton
	var titanEditButton

	ComboStruct &comboStruct

	array<var> loadoutButtons
	array<var> loadoutHeaders
} file

void function InitInGameMPMenu()
{
	var menu = GetMenu( "InGameMPMenu" )
	file.menuMP = menu

	SP_ResetObjectiveStringIndex()
	file.SP_displayObjectiveOnClose = true

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnInGameMPMenu_Open )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, OnInGameMPMenu_Close )

	AddUICallback_OnLevelInit( OnInGameLevelInit )

	ComboStruct comboStruct = ComboButtons_Create( menu )

	int headerIndex = 0
	int buttonIndex = 0
	var pilotHeader = AddComboButtonHeader( comboStruct, headerIndex, "#MENU_HEADER_PILOT" )
	file.loadoutHeaders.append( pilotHeader )
	var pilotSelectButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#SELECT" )
	Hud_AddEventHandler( pilotSelectButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "PilotLoadoutsMenu" ) ) )
	file.loadoutButtons.append( pilotSelectButton )
	var pilotEditButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#EDIT" )
	Hud_AddEventHandler( pilotEditButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "EditPilotLoadoutsMenu" ) ) )
	file.loadoutButtons.append( pilotEditButton )

	headerIndex++
	buttonIndex = 0
	var titanHeader = AddComboButtonHeader( comboStruct, headerIndex, "#MENU_HEADER_TITAN" )
	file.titanHeader = titanHeader
	file.titanHeaderIndex = headerIndex
	file.loadoutHeaders.append( titanHeader )
	var titanSelectButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#SELECT" )
	file.titanSelectButton = titanSelectButton
	file.loadoutButtons.append( titanSelectButton )
	Hud_AddEventHandler( titanSelectButton, UIE_CLICK, TitanSelectButtonHandler )
	var titanEditButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#EDIT" )
	Hud_AddEventHandler( titanEditButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "EditTitanLoadoutsMenu" ) ) )
	file.titanEditButton = titanEditButton
	file.loadoutButtons.append( titanEditButton )

	headerIndex++
	buttonIndex = 0
	var gameHeader = AddComboButtonHeader( comboStruct, headerIndex, "#MENU_HEADER_GAME" )
	var leaveButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#LEAVE_MATCH" )
	Hud_AddEventHandler( leaveButton, UIE_CLICK, OnLeaveButton_Activate )
	#if DEV
		var devButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "Dev" )
		Hud_AddEventHandler( devButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "DevMenu" ) ) )
	#endif

	headerIndex++
	buttonIndex = 0
	var dummyHeader = AddComboButtonHeader( comboStruct, headerIndex, "" )
	var dummyButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "" )
	Hud_SetVisible( dummyHeader, false )
	Hud_SetVisible( dummyButton, false )

	headerIndex++
	buttonIndex = 0
	file.settingsHeader = AddComboButtonHeader( comboStruct, headerIndex, "#MENU_HEADER_SETTINGS" )
	var controlsButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#CONTROLS" )
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

	// MOD SETTINGS
	var modSettingsButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "Mod Settings" )
	Hud_AddEventHandler( modSettingsButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "ModSettings" ) ) )

	// Nobody reads the FAQ so we replace it with ModSettings because of the limited combobutton space available
	//file.faqButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#KNB_MENU_HEADER" )
	//Hud_AddEventHandler( file.faqButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "KnowledgeBaseMenu" ) ) )

	//var dataCenterButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#DATA_CENTER" )
	//Hud_AddEventHandler( dataCenterButton, UIE_CLICK, OpenDataCenterDialog )

	ComboButtons_Finalize( comboStruct )

	file.comboStruct = comboStruct

	AddMenuFooterOption( menu, BUTTON_A, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_CLOSE", "#CLOSE" )
}

void function OnInGameMPMenu_Open()
{
	Lobby_SetFDMode( GetCurrentPlaylistVarInt( "ingame_menu_fd_mode", 0 ) == 1 )
	UI_SetPresentationType( ePresentationType.DEFAULT )

	bool faqIsNew = !GetConVarBool( "menu_faq_viewed" ) || HaveNewPatchNotes() || HaveNewCommunityNotes()
	RuiSetBool( Hud_GetRui( file.settingsHeader ), "isNew", faqIsNew )
	//ComboButton_SetNew( file.faqButton, faqIsNew )

	UpdateLoadoutButtons()
	RefreshCreditsAvailable()
	thread UpdateCachedNewItems()
}

void function OnInGameMPMenu_Close()
{
	UI_SetPresentationType( ePresentationType.INACTIVE )

	if ( IsConnected() && !IsLobby() && IsLevelMultiplayer( GetActiveLevel() ) )
	{
		//printt( "OnInGameMPMenu_Close() uiGlobal.updatePilotSpawnLoadout is:", uiGlobal.updatePilotSpawnLoadout )
		//printt( "OnInGameMPMenu_Close() uiGlobal.updateTitanSpawnLoadout is:", uiGlobal.updateTitanSpawnLoadout )

		string updatePilotSpawnLoadout = uiGlobal.updatePilotSpawnLoadout ? "1" : "0"
		string updateTitanSpawnLoadout = uiGlobal.updateTitanSpawnLoadout ? "1" : "0"

		ClientCommand( "InGameMPMenuClosed " + updatePilotSpawnLoadout + " " + updateTitanSpawnLoadout )

		uiGlobal.updatePilotSpawnLoadout = false
		uiGlobal.updateTitanSpawnLoadout = false

		RunClientScript( "RefreshIntroLoadoutDisplay", GetLocalClientPlayer(), uiGlobal.pilotSpawnLoadoutIndex, uiGlobal.titanSpawnLoadoutIndex )
	}
}

void function UpdateLoadoutButtons()
{
	bool loadoutSelectionEnabled = (GetCurrentPlaylistVarInt( "loadout_selection_enabled", 1 ) == 1)

	SetTitanSelectButtonVisibleState( true )

	foreach ( button in file.loadoutButtons )
	{
		Hud_SetEnabled( button, loadoutSelectionEnabled )
	}

	foreach ( header in file.loadoutHeaders )
	{
		if ( loadoutSelectionEnabled )
			Hud_Show( header )
		else
			Hud_Hide( header )
	}

	entity player = GetUIPlayer()

	if ( GetAvailableTitanRefs( player ).len() > 1 )
	{
		SetComboButtonHeaderTitle( file.menuMP, file.titanHeaderIndex, "#MENU_HEADER_TITAN" )
		ComboButton_SetText( file.titanSelectButton, "#SELECT" )
		Hud_Show( file.titanEditButton )
	}
	else if ( GetAvailableTitanRefs( player ).len() == 1 )
	{
		TitanLoadoutDef loadout = GetCachedTitanLoadout( uiGlobal.titanSpawnLoadoutIndex )

		SetComboButtonHeaderTitle( file.menuMP, file.titanHeaderIndex, GetTitanLoadoutName( loadout ) )
		ComboButton_SetText( file.titanSelectButton, "#EDIT" )

		Hud_Hide( file.titanEditButton )
		ComboButtons_ResetColumnFocus( file.comboStruct )
	}
	else
	{
		SetTitanSelectButtonVisibleState( true )
	}
}

//////////

//////////

void function InitInGameSPMenu()
{
	var menu = GetMenu( "InGameSPMenu" )
	file.menuSP = menu

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnOpenInGameSPMenu )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, OnCloseInGameSPMenu )

	ComboStruct comboStruct = ComboButtons_Create( menu )

	int headerIndex = 0
	int buttonIndex = 0

	// MISSION Menu
	var missionHeader = AddComboButtonHeader( comboStruct, headerIndex, "#MENU_HEADER_MISSION" )
	var resumeButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#RESUME_GAME_SHORT" )
	Hud_AddEventHandler( resumeButton, UIE_CLICK, OnResumeGame_Activate )
	var lastCheckpointButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#LAST_CHECKPOINT" )
	Hud_AddEventHandler( lastCheckpointButton, UIE_CLICK, OnReloadCheckpoint_Activate )
	file.BtnLastCheckpoint = lastCheckpointButton
	var restartButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#RESTART_LEVEL_SHORT" )
	Hud_AddEventHandler( restartButton, UIE_CLICK, OnRestartLevel_Activate )

	// GAME Menu
	// headerIndex++
	// buttonIndex = 0
	// var gameHeader = AddComboButtonHeader( comboStruct, headerIndex, "#MENU_HEADER_GAME" )
	// var difficultyButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#CHANGE_DIFFICULTY" )
	// Hud_AddEventHandler( difficultyButton, UIE_CLICK, OnChangeDifficulty_Activate )
	// var leaveButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#QUIT" )
	// Hud_AddEventHandler( leaveButton, UIE_CLICK, OnLeaveButton_Activate )

	// SETTINGS Menu
	headerIndex++
	buttonIndex = 0
	var settingsHeader = AddComboButtonHeader( comboStruct, headerIndex, "#MENU_HEADER_SETTINGS" )
	var controlsButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#CONTROLS" )
	Hud_AddEventHandler( controlsButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "ControlsMenu" ) ) )
	#if CONSOLE_PROG
		var avButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#AUDIO_VIDEO" )
		Hud_AddEventHandler( avButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "AudioVideoMenu" ) ) )
	#elseif PC_PROG
		var audioButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#AUDIO" )
		Hud_AddEventHandler( audioButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "AudioMenu" ) ) )
		var videoButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#VIDEO" )
		Hud_AddEventHandler( videoButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "VideoMenu" ) ) )
	#endif
	
	// MOD SETTINGS
	var modSettingsButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "Mod Settings" )
	Hud_AddEventHandler( modSettingsButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "ModSettings" ) ) )

	array<var> orderedButtons

	var changeDifficultyBtn = Hud_GetChild( menu, "BtnChangeDifficulty" )

	AddButtonEventHandler( changeDifficultyBtn, UIE_CLICK, OnChangeDifficulty_Activate )
	Hud_Show( changeDifficultyBtn )
	orderedButtons.append( changeDifficultyBtn )

	var quitBtn = Hud_GetChild( menu, "BtnQuit" )
	SetButtonRuiText( quitBtn, "#QUIT" )
	AddButtonEventHandler( quitBtn, UIE_CLICK, OnLeaveButton_Activate )
	Hud_Show( quitBtn )
	orderedButtons.append( quitBtn )

	// DEV button
	var devButton = Hud_GetChild( menu, "BtnDev" )
	#if DEV
		SetButtonRuiText( devButton, "--- Dev" )
		AddButtonEventHandler( devButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "DevMenu" ) ) )
		Hud_Show( devButton )
		orderedButtons.append( devButton )
		comboStruct.navUpButton = devButton
	#else
		Hud_Hide( devButton )
		comboStruct.navUpButton = quitBtn
	#endif // DEV

	SetNavUpDown( orderedButtons )
	comboStruct.navDownButton = changeDifficultyBtn

	ComboButtons_Finalize( comboStruct )

	AddMenuFooterOption( menu, BUTTON_A, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_CLOSE", "#CLOSE" )
}


void function OnOpenInGameSPMenu()
{
	var collectiblesFoundDesc = Hud_GetChild( file.menuSP, "CollectiblesFoundDesc" )
	var missionLogDesc = Hud_GetChild( file.menuSP, "MissionLogDesc" )
	var changeDifficultyBtn = Hud_GetChild( file.menuSP, "BtnChangeDifficulty" )

	Hud_SetEnabled( file.BtnLastCheckpoint, HasValidSaveGame() )

	int currentDifficulty = GetConVarInt( "sp_difficulty" )
	string newDifficultyString

	switch ( currentDifficulty )
	{
		case 0:
			newDifficultyString = "#CHANGE_DIFFICULTY_EASY"
			break

		case 1:
			newDifficultyString = "#CHANGE_DIFFICULTY_REGULAR"
			break

		case 2:
			newDifficultyString = "#CHANGE_DIFFICULTY_HARD"
			break

		case 3:
			newDifficultyString = "#CHANGE_DIFFICULTY_MASTER"
			break

		default:
			Assert( 0, "Unknown difficulty " + currentDifficulty )
			break
	}
	SetButtonRuiText( changeDifficultyBtn, newDifficultyString )

	string activeLevelName = GetActiveLevel()
	if ( activeLevelName != "" )
	{
		var dataTable = GetDataTable( $"datatable/sp_levels_data.rpak" )

		// Make sure this level actually has data to display.
		bool levelHasData = false
		int numRows = GetDatatableRowCount( dataTable )
		for ( int i = 0; i < numRows; i++ )
		{
			string levelName = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "level" ) )
			if ( activeLevelName == levelName )
			{
				levelHasData = true
				break
			}
		}

		if ( levelHasData )
		{
			// Mission Log
			int row = GetDataTableRowMatchingStringValue( dataTable, GetDataTableColumnByName( dataTable, "level" ), activeLevelName )
			string missionLog = GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, "missionLog" ) )

			if ( uiGlobal.sp_showAlternateMissionLog )
			{
				string alternateMissionLog = GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, "alternateMissionLog" ) )
				missionLog = alternateMissionLog
			}

			Hud_SetText( missionLogDesc, missionLog )

			// Collectibles
			int foundLions = GetCollectiblesFoundForLevel( activeLevelName )
			int maxLions = GetMaxLionsInLevel( activeLevelName )
			Hud_SetText( collectiblesFoundDesc, "#MENU_SP_COLLECTIBLE_DESC", foundLions, maxLions )
		}
		else
		{
			Hud_SetText( missionLogDesc, "#MENU_SP_OBJECTIVES_NO_ENTRY" )
			Hud_SetText( collectiblesFoundDesc, "#MENU_SP_COLLECTIBLE_DESC", 0, 0 )
		}

		// Make sure trial mode doesn't reveal any spoilers!
		if ( Script_IsRunningTrialVersion() )
			Hud_SetText( missionLogDesc, "#MENU_SP_OBJECTIVES_NO_ENTRY" )
	}

	SPMenu_UpdateReloadCheckpointButton()
}


void function OnCloseInGameSPMenu()
{
	if ( file.SP_displayObjectiveOnClose )
		ClientCommand( "ShowObjective closedSPMenu" )
}

void function SPMenu_UpdateReloadCheckpointButton()
{
	if ( level.ui.playerRunningGauntlet )
		ComboButton_SetText( file.BtnLastCheckpoint, "#GAUNTLET_RESTART" )
	else
		ComboButton_SetText( file.BtnLastCheckpoint, "#LAST_CHECKPOINT" )
}

void function MobilityDifficultyButton_Activate( var button )
{
	OpenMobilityDifficultyMenu()
}

void function OnLeaveButton_Activate( var button )
{
	file.SP_displayObjectiveOnClose = false
	LeaveDialog()
}

void function OnRestartLevel_Activate( var button )
{
	ShowAreYouSureDialog( "#MENU_RESTART_MISSION_CONFIRM", RestartMission, "#WARNING_LOSE_PROGRESS" )
}

void function OnChangeDifficulty_Activate( var button )
{
	SPDifficultyButton_Click( button )
}

void function OnResumeGame_Activate( var button )
{
	CloseActiveMenu()
}

void function OnReloadCheckpoint_Activate( var button )
{
	if ( level.ui.playerRunningGauntlet )
	{
		CloseActiveMenu()
		ClientCommand( "Gauntlet_PlayerRestartedFromMenu" )
	}
	else
	{
		ShowAreYouSureDialog( "#MENU_RESTART_CHECKPOINT_CONFIRM", ReloadLastCheckpoint, "#EMPTY_STRING"  )
	}
}

void function ShowAreYouSureDialog( string header, void functionref() func, string details )
{
	DialogData dialogData
	dialogData.header = header
	dialogData.message = details

	AddDialogButton( dialogData, "#NO" )
	AddDialogButton( dialogData, "#YES", func )

	AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )
	AddDialogFooter( dialogData, "#B_BUTTON_BACK" )

	OpenDialog( dialogData )
}

void function RestartMission()
{
	file.SP_displayObjectiveOnClose = false
	ClientCommand( "RestartMission" )
}

void function ReloadLastCheckpoint()
{
	file.SP_displayObjectiveOnClose = false

	printt( "SAVEGAME: Trying to load saveName" )
	if ( HasValidSaveGame() )
	{
		printt( "SAVEGAME: Trying to load checkpoint from menu_ingame" )
		SaveGame_LoadWithStartPointFallback()
		return
	}

	ClientCommand( "RestartFromLevelTransition" )
}

void function SP_ResetObjectiveStringIndex()
{
	file.objectiveStringIndex = -1
}

void function ServerCallback_UI_ObjectiveUpdated( int stringIndex )
{
	file.objectiveStringIndex = stringIndex
}

void function ServerCallback_UI_UpdateMissionLog( bool showAltLog )
{
	uiGlobal.sp_showAlternateMissionLog = showAltLog
}

void function SPDifficultyButton_Click( var button )
{
	DialogData dialogData
	dialogData.header = "#SP_DIFFICULTY_MISSION_SELECT_TITLE"

	int currentDifficulty = GetConVarInt( "sp_difficulty" )
	dialogData.coloredButton[ currentDifficulty ] <- true

	if ( currentDifficulty == DIFFICULTY_EASY )
		AddDialogButton( dialogData, "#SP_DIFFICULTY_EASY_TITLE", SPPickEasy, "#SP_DIFFICULTY_EASY_DESCRIPTION", true )
	else
		AddDialogButton( dialogData, "#SP_DIFFICULTY_EASY_TITLE", SPPickEasy, "#SP_DIFFICULTY_EASY_DESCRIPTION", false )


	if ( currentDifficulty == DIFFICULTY_NORMAL )
		AddDialogButton( dialogData, "#SP_DIFFICULTY_NORMAL_TITLE", SPPickNormal, "#SP_DIFFICULTY_NORMAL_DESCRIPTION", true )
	else
		AddDialogButton( dialogData, "#SP_DIFFICULTY_NORMAL_TITLE", SPPickNormal, "#SP_DIFFICULTY_NORMAL_DESCRIPTION", false )


	if ( currentDifficulty == DIFFICULTY_HARD )
		AddDialogButton( dialogData, "#SP_DIFFICULTY_HARD_TITLE", SPPickHard, "#SP_DIFFICULTY_HARD_DESCRIPTION", true )
	else
		AddDialogButton( dialogData, "#SP_DIFFICULTY_HARD_TITLE", SPPickHard, "#SP_DIFFICULTY_HARD_DESCRIPTION", false )


	if ( currentDifficulty == DIFFICULTY_MASTER )
		AddDialogButton( dialogData, "#SP_DIFFICULTY_MASTER_TITLE", SPPickMaster, "#SP_DIFFICULTY_MASTER_DESCRIPTION", true )
	else
		AddDialogButton( dialogData, "#SP_DIFFICULTY_MASTER_TITLE", SPPickMaster, "#SP_DIFFICULTY_MASTER_DESCRIPTION", false )


	AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )
	AddDialogFooter( dialogData, "#B_BUTTON_BACK" )
	AddDialogPCBackButton( dialogData )

	OpenDialog( dialogData )
}

void function SPPickEasy()
{
	RequestSPDifficultyChange( DIFFICULTY_EASY )
	CloseAllMenus()
}

void function SPPickNormal()
{
	RequestSPDifficultyChange( DIFFICULTY_NORMAL )
	CloseAllMenus()
}

void function SPPickHard()
{
	RequestSPDifficultyChange( DIFFICULTY_HARD )
	CloseAllMenus()
}

void function SPPickMaster()
{
	RequestSPDifficultyChange( DIFFICULTY_MASTER )
	CloseAllMenus()
}

void function RequestSPDifficultyChange( int selectedDifficulty )
{
	var dataTable = GetDataTable( DATA_TABLE )
	int difficulty = GetDataTableInt( dataTable, selectedDifficulty, GetDataTableColumnByName( dataTable, "index" ) )

	ClientCommand( "ClientCommand_RequestSPDifficultyChange " + difficulty )
}

void function SCB_SetDoubleXPStatus( int status )
{
	var doubleXPWidget = Hud_GetChild( file.menuMP, "DoubleXP" )
	RuiSetInt( Hud_GetRui( doubleXPWidget ), "doubleXPStatus", status )

	// update this menu too
	TTSUpdateDoubleXPStatus( status )
}

void function OnInGameLevelInit()
{
	var doubleXPWidget = Hud_GetChild( file.menuMP, "DoubleXP" )
	var rui = Hud_GetRui( doubleXPWidget )
	RuiSetInt( rui, "doubleXPStatus", 0 )
	RuiSetBool( rui, "isVisible", false )

	string gameModeScoreHint = expect string( GetCurrentPlaylistVar( "gamemode_score_hint" ) )
	if ( gameModeScoreHint != "" )
	{
		RuiSetString( rui, "scoreMeritText", Localize( gameModeScoreHint ) )
		RuiSetInt( rui, "matchScoreMerit", MERIT_STATE_AVAILABLE )
	}
	else
	{
		RuiSetString( rui, "scoreMeritText", "" )
		RuiSetInt( rui, "matchScoreMerit", MERIT_STATE_HIDDEN )
	}

	Hud_SetVisible( doubleXPWidget, !IsPrivateMatch() )
}
/*
int matchScoreMerit = MERIT_STATE_AVAILABLE
int matchCompleteMerit = MERIT_STATE_AVAILABLE
int matchWinMerit = MERIT_STATE_AVAILABLE
int matchEvacMerit = MERIT_STATE_HIDDEN
int happyHourMerits = MERIT_STATE_HIDDEN

int meritCount = 0
*/

void function SCB_SetScoreMeritState( int meritState )
{
	var doubleXPWidget = Hud_GetChild( file.menuMP, "DoubleXP" )
	var rui = Hud_GetRui( doubleXPWidget )

	RuiSetInt( rui, "matchScoreMerit", meritState )
}

void function SCB_SetCompleteMeritState( int meritState )
{
	var doubleXPWidget = Hud_GetChild( file.menuMP, "DoubleXP" )
	var rui = Hud_GetRui( doubleXPWidget )

	RuiSetInt( rui, "matchCompleteMerit", meritState )
}

void function SCB_SetWinMeritState( int meritState )
{
	var doubleXPWidget = Hud_GetChild( file.menuMP, "DoubleXP" )
	var rui = Hud_GetRui( doubleXPWidget )

	RuiSetInt( rui, "matchWinMerit", meritState )
}

void function SCB_SetEvacMeritState( int meritState )
{
	var doubleXPWidget = Hud_GetChild( file.menuMP, "DoubleXP" )
	var rui = Hud_GetRui( doubleXPWidget )

	RuiSetInt( rui, "matchEvacMerit", meritState )
}

void function SCB_SetMeritCount( int meritCount )
{
	var doubleXPWidget = Hud_GetChild( file.menuMP, "DoubleXP" )
	var rui = Hud_GetRui( doubleXPWidget )

	RuiSetInt( rui, "meritCount", meritCount )
}

void function SCB_SetWeaponMeritCount( int meritCount )
{
	var doubleXPWidget = Hud_GetChild( file.menuMP, "DoubleXP" )
	var rui = Hud_GetRui( doubleXPWidget )

	RuiSetInt( rui, "weaponMeritCount", meritCount )
}

void function SCB_SetTitanMeritCount( int meritCount )
{
	var doubleXPWidget = Hud_GetChild( file.menuMP, "DoubleXP" )
	var rui = Hud_GetRui( doubleXPWidget )

	RuiSetInt( rui, "titanMeritCount", meritCount )
}

void function TitanSelectButtonHandler( var button )
{
	if ( !IsFullyConnected() )
		return

	entity player = GetUIPlayer()
	if ( GetAvailableTitanRefs( player ).len() > 1 )
	{
		AdvanceMenu( GetMenu( "TitanLoadoutsMenu" ) )
	}
	else if ( GetAvailableTitanRefs( player ).len() == 1 )
	{
		uiGlobal.updateTitanSpawnLoadout = false
		SetEditLoadout( "titan", uiGlobal.titanSpawnLoadoutIndex )

		RunMenuClientFunction( "SetEditingTitanLoadoutIndex", uiGlobal.titanSpawnLoadoutIndex )
		AdvanceMenu( GetMenu( "EditTitanLoadoutMenu" ) )
	}
	else
	{
		// HIDE
	}
}

void function SetTitanSelectButtonVisibleState( bool state )
{
	if ( state )
	{
		Hud_Show( file.titanHeader )
		Hud_Show( file.titanEditButton )
		Hud_Show( file.titanSelectButton )
	}
	else
	{
		ComboButtons_ResetColumnFocus( file.comboStruct )
		Hud_Hide( file.titanHeader )
		Hud_Hide( file.titanEditButton )
		Hud_Hide( file.titanSelectButton )
	}
}
