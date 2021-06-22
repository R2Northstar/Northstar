# Miscellaneous

!!! cpp-function "bool IsServer()"

!!! cpp-function "bool IsClient()"

!!! cpp-function "bool IsToolsMode()"

!!! cpp-function "bool IsFNF()"

!!! cpp-function "bool IsGameFromReload()"

!!! cpp-function "int GetCPULevel()"

!!! cpp-function "bool IsEnemyTeam( int ownTeam, int otherTeam )"

  Returns if `otherTeam` is an enemy of `ownTeam`

!!! cpp-function "void SetMaxActivityMode( int mode )"

!!! cpp-function "int CalculateHashForString( string s )"

!!! cpp-function "void CreateRope( vector start, vector end, float length = 0, entity startEnt = null, entity endEnt = null, int startAttachment = 0, int endAttachment = 0, string material = "", int segmentCount = 0 )"

  Creates a rope between two points or entities.

!!! cpp-function "float GetTeamSkill( int team )"

!!! cpp-function "void SendToConsole( string cmd )"

  Execute `cmd` on the local host

!!! cpp-function "void RecordAchievementEvent( string s1, number n1 )"

!!! cpp-function "void ServiceEventQueue()"

!!! cpp-function "void SetDucking( string s1, string s2, number n1 )"

!!! cpp-function "void GrantClientSidePickup_MatchCandy( entity player, int amount, vector origin, int flags, int recieptID )"

!!! cpp-function "void NoteMatchState( number a1, number a2, number a3, number a4, number a5, number a6, number a7, number a8, number a9 )"

!!! cpp-function "void NoteLobbyState( number a1, string a2 )"

!!! cpp-function "bool IsHighPerfDevServer()"

!!! cpp-function "bool ShouldAwardHappyHourBonus( entity player )"

!!! cpp-function "bool InPrediction()"

!!! cpp-function "bool IsFirstTimePredicted()"

!!! cpp-function "string GetMapName()"

  Get the map name of the current map

!!! cpp-function "bool IsFastIterationEnabled()"

!!! cpp-function "bool BuildingCubeMaps()"

!!! cpp-function "bool IsTestMap()"

  Returns value of IsTestMap from the level's script list .rson file

## Parents & Children

!!! cpp-function "void AssertNoPlayerChildren( entity parent )"

!!! cpp-function "void TryClearParent( entity parent )"

!!! cpp-function "void SetForceDrawWhileParented( entity child, bool force )"

## Visual Options

!!! cpp-function "void SetCrosshairTeamColoringDisabled( entity player, bool disabled )"

!!! cpp-function "void SetHideOnCloak( entity ent, bool hide )"

## VPK

!!! cpp-function "void VPKNotifyFile( string file )"

## Player Utils

!!! cpp-function "bool IsPlayerSafeFromNPCs( entity player )"

!!! cpp-function "bool IsPlayerSafeFromProjectiles( entity player, vector origin )"

!!! cpp-function "entity GetWindowHint( vector startPos, number radius, number height, vector dir, number distance, number gravity, number margin, entity ignoreEnt )"

  Returns the best window hint.

!!! cpp-function "void ScreenFade( entity player, number r, number g, number b, number fadeTime, number fadeHold, int fadeFlags )"

  Fade the player's scren.

  Fade flags start with `FFADE_`

## Levels

!!! cpp-function "void SetXPForLevel( int a, int b )"

  Sets the XP required for a player to get to a certain level

!!! cpp-function "int GetLevelForXP( int n )"

## Entity Utils

!!! cpp-function "float GetHealthFrac( entity ent )"

!!! cpp-function "bool IsMagneticTarget( entity ent )"

  Returns if an entity is a magnetic target

!!! cpp-function "bool IsTurret( entity ent )"

!!! cpp-function "int GetHitgroupForHitboxOnEntity( var a, number b )"

!!! cpp-function "void PutEntityInSafeSpot( entity ent, entity referenceEnt, entity movingGroundEnt, vector, safeStartingLocationForEntity, vector positionAtEndOfAnimationForEntity )"

!!! cpp-function "float GetHealthFrac( entity ent )"

!!! cpp-function "bool IsMagneticTarget( entity ent )"

  Returns if an entity is a magnetic target

!!! cpp-function "bool IsTurret( entity ent )"

  Is entity a turret

## Weapon Utils

!!! cpp-function "void Weapon_SetDespawnTime( number time )"

!!! cpp-function "int GetImpactEffectTable( string weapon )"

!!! cpp-function "float CalcWeaponDamage( entity owner, entity target, entity weapon, number distanceToTarget, int extraMods )"

## Preinstall

!!! cpp-function "bool IsGameFullyInstalled()"

  Returns true if the full game is installed. You can't start mp or any sp map but sp_training and sp_crashsite if this is false.

!!! cpp-function "bool IsGamePartiallyInstalled()"

  Returns true if the game is partially installed. You can't start sp training this is false.

!!! cpp-function "float GetGameFullyInstalledProgress()"

  Returns fraction 0.0 to 1.0 of downloading of full game progress.

!!! cpp-function "bool Script_IsRunningTrialVersion()"

  Only call when we have an active user.

## Script Reloads

!!! cpp-function "void ReloadScriptCallbacks()"

!!! cpp-function "void ReloadingScriptsBegin()"

!!! cpp-function "void ReloadingScriptsEnd()"
