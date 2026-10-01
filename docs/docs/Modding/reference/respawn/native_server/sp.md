# Singleplayer

## SaveGames

!!! cpp-function "void SaveGame_Create( string saveName, int saveVersion, int start_point )"

  Do a save.

!!! cpp-function "void SaveGame_CreateWithCommitDelay( string saveName, int saveVersion, float delay, int trycount )"

  Do a save.

  Will call back `bool CodeCallback_SaveGameIsSafeToCommit()` to validate if it is ok to commit the save file.

!!! cpp-function "void SaveGame_Commit()"

  If there is an outstanding save commit, accept it asap.

!!! cpp-function "void SaveGame_Reject()"

  If there is an outstanding save commit, reject it asap.

!!! cpp-function "void SaveGame_Load( string saveName )"

  Do a restore.

!!! cpp-function "bool SaveGame_IsValid( string saveName )"

  Checks if a file is ok to use.

!!! cpp-function "int SaveGame_GetVersion( string saveName )"

  Return the script version of a save load.

!!! cpp-function "int SaveGame_GetStartPoint( string saveName )"

  Return the script start point of a save load.

!!! cpp-function "string SaveGame_GetMapName( string saveName )"

  Return the map name of a save load.

## Level Loading

!!! cpp-function "void ChangeLevel( string mapName, LevelTransitionStruct transitionStruct )"

  Loads a new level. The data in `transitionStruct` can be read in the next level with `GetLevelTransitionStruct()`.

!!! cpp-function "LevelTransitionStruct ornull GetLevelTransitionStruct()"

  Reads the transition data set by `ChangeLevel()` on the previous map.
  Return `null` if this is the first map or the previous map didn't supply any data.

## Timeshift

!!! cpp-function "void SetTimeshiftOfDay_Night()"

!!! cpp-function "void SetTimeshiftOfDay_Day()"

!!! cpp-function "void SetTimeshiftArmDeviceSkin( int skinIndex )"

## BT Loadouts

!!! cpp-function "void SetBTLoadoutUnlocked( int loadout )"

!!! cpp-function "void SetBTLoadoutsUnlockedBitfield( int unlockedBits )"

!!! cpp-function "int GetBTLoadoutsUnlockedBitfield()"

!!! cpp-function "bool IsBTLoadoutUnlocked( int loadout )"
