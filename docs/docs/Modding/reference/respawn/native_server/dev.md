# Developer Functions

!!! warning

    Most of these functions are stripped and have no functionality.

## Command Line

!!! cpp-function "bool Dev_CommandLineHasParam( string param )"

!!! cpp-function "string Dev_CommandLineParmValue( string param )"

!!! cpp-function "void Dev_CommandLineRemoveParam( string param )"

!!! cpp-function "void Dev_CommandLineAddParm( string param )"

## Developer Utils

!!! cpp-function "array<asset> GetModelViewerList()"

  Returns list of files in `scripts/model_view_list.txt`, which is written by reRun (respawn internal tool)

!!! cpp-function "void NativeFuncTest( number a, bool b, number c )"

!!! cpp-function "int GetDeveloperLevel()"

!!! cpp-function "int GetBugReproNum()"

!!! cpp-function "bool DevLobbyIsFrozen()"

!!! cpp-function "void TriggerBreakpoint()"

!!! cpp-function "void SpamLog( string text )"

  Prints to the game's spam logfile (usually stored in DevNet).

!!! cpp-function "void CodeWarning( string s )"

## Performance

!!! cpp-function "void PerfInitLabel( string s, int n )"

!!! cpp-function "void PerfStart( int n )"

!!! cpp-function "void PerfEnd( int n)"

!!! cpp-function "void PerfClearAll()"

!!! cpp-function "void PerfReset()"

!!! cpp-function "void PerfDump()"

!!! cpp-function "void RProfStart( string, int n )"

!!! cpp-function "void RProfEnd( int n )"

## DevP4

!!! error
    Stripped in Northstar for security.

!!! cpp-function "void DevP4Checkout( string s )"

!!! cpp-function "void DevP4Add( string s )"

## DevTextBuffer

!!! error

    Stripped in Northstar for security.

!!! cpp-function "void DevTextBufferWrite( string s )"

  Append string to a temp buffer. Dev only.

!!! cpp-function "void DevTextBufferClear()"

!!! cpp-function "void DevTextBufferDumpToFile( string file )"

  Dump temp buffer out to specified path/filename.

## Match Stat Loggers

!!! cpp-function "void LogPlayerMatchStat_KilledAPilot( entity e )"

!!! cpp-function "void LogPlayerMatchStat_Death( entity e )"

!!! cpp-function "void LogPlayerMatchStat_EarnedXP( entity e )"

!!! cpp-function "void LogPlayerMatchStat_UsedBurncard( entity e )"

!!! cpp-function "void LogPlayerMatchStat_HappyHourMeritsGiven( entity e )"

!!! cpp-function "void LogPlayerStat_BurncardDiscard( entity e )"
