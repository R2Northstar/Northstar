untyped

global function GameState_Init
global function InitGameState

global function SetRoundBased
global function SetCustomIntroLength

global function SetGetDifficultyFunc
global function GetDifficultyLevel

//********************************************************************************************
//	Game State
//********************************************************************************************
global const PREMATCH_TIMER_INTRO_DEFAULT = 46
global const PREMATCH_TIMER_NO_INTRO = 7	//shows 5 when fade from black
global const CLEAR_PLAYERS_BUFFER = 2.0

global const ENDROUND_FREEZE = 0
global const ENDROUND_MOVEONLY = 1
global const ENDROUND_FREE = 3

global const NO_DETERMINED_WINNING_TEAM_YET = -1

struct
{
	int functionref() difficultyFunc
} file

global enum eWinReason
{
	DEFAULT,
	SCORE_LIMIT,
	TIME_LIMIT,
	ELIMINATION
}


function GameState_Init()
{
	FlagInit( "GamePlaying" )
	FlagInit( "DisableTimeLimit" )
	FlagInit( "DisableScoreLimit" )
	FlagInit( "AnnounceWinnerEnabled", true )
	FlagInit( "AnnounceProgressEnabled", true )
	FlagInit( "DefendersWinDraw" )

	RegisterSignal( "RoundEnd" )
	RegisterSignal( "GameEnd" )
	RegisterSignal( "GameStateChanged" )
	RegisterSignal( "CatchUpFallBehindVO" )
	RegisterSignal( "ClearedPlayers" )


	level.devForcedWin <- false  //For dev purposes only. Used to check if we forced a win through dev command
	level.devForcedTimeLimit <- false

	level.lastTimeLeftSeconds <- null

	level.lastScoreSwapVOTime <- null

	level.nextMatchProgressAnnouncementLevel <- MATCH_PROGRESS_EARLY //When we make a matchProgressAnnouncement, this variable is set

	level.endOfRoundPlayerState <- ENDROUND_FREEZE

	level._swapGameStateOnNextFrame <- false
	level.clearedPlayers <- false

	level.customEpilogueDuration <- null

	level.lastTeamTitans <- {}
	level.lastTeamTitans[TEAM_IMC] <- null
	level.lastTeamTitans[TEAM_MILITIA] <- null
	level.lastTeamPilots <- {}
	level.lastTeamPilots[TEAM_IMC] <- null
	level.lastTeamPilots[TEAM_MILITIA] <- null

	level.firstTitanfall <- false

	level.lastPlayingEmptyTeamCheck <- 0

	level.doneWaitingForPlayersTimeout <- 0

	level.attackDefendBased <- false

	level.roundBasedUsingTeamScore <- false

	level.roundBasedTeamScoreNoReset <- false

	level.customIntroLength <- null

	level.sendingPlayersAway <- false

	level.forceNoMoreRounds <- false

	// prevents ties... need an option to disable in the future
	level.firstToScoreLimit <- TEAM_UNASSIGNED
	level.allowPointsOverLimit <- false

	file.difficultyFunc = DefaultDifficultyFunc

	#if MP
	AddCallback_EntitiesDidLoad( GameState_EntitiesDidLoad )
	#endif
}


int function DefaultDifficultyFunc()
{
	return 0
}

void function SetGetDifficultyFunc( int functionref() difficultyFunc )
{
	Assert( file.difficultyFunc == DefaultDifficultyFunc )

	file.difficultyFunc = difficultyFunc
}


// This function is meant to init stuff that _gamestate uses, as opposed
// to stuff that any particular gamestate like Playing uses
function InitGameState()
{
	#if MP
		PIN_GameStart()
	#endif
}

function SetRoundBased( state )
{
	level.nv.roundBased = state
}

function SetCustomIntroLength( time )
{
	level.customIntroLength = time
}

int function GetDifficultyLevel()
{
	return file.difficultyFunc()
}

