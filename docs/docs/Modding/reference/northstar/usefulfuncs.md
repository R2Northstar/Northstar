# Useful Functions

## Custom Ejection Messages

### How ejection messages are chosen

When ejecting the game selects a random number between 0 and 1, if this number is greater than 0.15 then a random common eject message is returned, if it is less than 0.15 then a rare ejection message is returned.

### Adding new messages

Using `AddCommonEjectMessage( String message )` and `AddRareEjectMessage( String message )` in script additional messages can be added to the pool of potential ejection messages

### Localisation

Like most things custom ejection messages can be localised through keyvalues

There are no functions to remove ejection messages, however existing ones can be altered by modifying localisation files

Below are a list of useful functions added by Northstar.

## Player functions

### Check for different weapon types on a player

!!! cpp-function "bool function HasWeapon( entity ent, string weaponClassName, array<string> mods = [] )"

!!! cpp-function "bool function HasOrdnance( entity ent, string weaponClassName, array<string> mods = [] )"

!!! cpp-function "bool function HasCoreAbility( entity ent, string weaponClassName, array<string> mods = [] )"

!!! cpp-function "bool function HasSpecial( entity ent, string weaponClassName, array<string> mods = [] )"

!!! cpp-function "bool function HasAntiRodeo( entity ent, string weaponClassName, array<string> mods = [] )"

!!! cpp-function "bool function HasMelee( entity ent, string weaponClassName, array<string> mods = [] )"

!!! cpp-function "bool function HasOffhandForSlot( entity ent, int slot, string weaponClassName, array<string> mods = [] )"

!!! cpp-function "bool function WeaponHasSameMods( entity weapon, array<string> mods = [] )"

!!! cpp-function "bool function HasOffhandWeapon( entity ent, string weaponClassName )"

!!! cpp-function "bool function PilotHasSniperWeapon( entity player )"

!!! cpp-function "bool function PilotActiveWeaponIsSniper( entity player )"


### Get weapon from entity

!!! cpp-function "string function GetActiveWeaponClass( entity player )"

!!! cpp-function "entity function GetPilotAntiPersonnelWeapon( entity player )"

!!! cpp-function "entity function GetPilotSideArmWeapon( entity player )"

!!! cpp-function "entity function GetPilotAntiTitanWeapon( entity player )"


### Take weapon from Entity

!!! cpp-function "bool function TakePrimaryWeapon( entity player )"

!!! cpp-function "bool function TakeSecondaryWeapon( entity player )"

!!! cpp-function "bool function TakeSidearmWeapon( entity player )"

!!! cpp-function "void function EnableOffhandWeapons( entity player )"

!!! cpp-function "void function DisableOffhandWeapons( entity player )"

!!! cpp-function "void function EnableOffhandWeapons( entity player )"

!!! cpp-function "void function TakeAllWeapons( entity ent )"

!!! cpp-function "void function TakeWeaponsForArray( entity ent, array<entity> weapons )"


### Validity checks for player

!!! cpp-function "bool function PlayerCanTeleportHere( entity player, vector testOrg, entity ignoreEnt = null )"

    !!! note
        Respawn comment next to the function:

        `TODO: This is a copy of SP's PlayerPosInSolid(). Not changing it to avoid patching SP. Merge into one function next game`


!!! cpp-function "bool function PlayerSpawnpointIsValid( entity ent )"

!!! cpp-function "bool function EntityInSolid( entity ent, entity ignoreEnt = null, int buffer = 0 ) "

    !!! note
        Respawn comment next to the function:

        `TODO:  This function returns true for a player standing inside a friendly grunt. It also returns true if you are right up against a ceiling.Needs fixing for next game`

!!! cpp-function "bool function EntityInSpecifiedEnt( entity ent, entity specifiedEnt, int buffer = 0 )"


### Change a players invincibility

!!! cpp-function "void function MakeInvincible( entity ent )"

!!! cpp-function "void function ClearInvincible( entity ent )"

!!! cpp-function "bool function IsInvincible( entity ent )"



!!! cpp-function "bool function IsFacingEnemy( entity guy, entity enemy, int viewAngle = 75 )"

!!! cpp-function "bool function PlayerHasTitan( entity player )"

!!! cpp-function "void function ScaleHealth( entity ent, float scale )"

## Entity functions

!!! cpp-function "float function GetEntHeight( entity ent )"

!!! cpp-function "float function GetEntWidth( entity ent )"

!!! cpp-function "float function GetEntDepth( entity ent )"

!!! cpp-function "void function PushEntWithVelocity( entity ent, vector velocity )"

!!! cpp-function "vector function GetCenter( array<entity> ents )"

### Turret functions

!!! cpp-function "void function TurretChangeTeam( entity turret, int team )"

!!! cpp-function "void function MakeTurretInvulnerable( entity turret )"

!!! cpp-function "void function MakeTurretVulnerable( entity turret )"

!!! cpp-function "void function UpdateTurretClientSideParticleEffects( entity turret )"

### Rest so far to be sorted

!!! cpp-function "array<entity> function GetAllMinions()"

!!! cpp-function "entity function GetLocalClientPlayer()"

    !!! note
        this function only exists on clients

!!! cpp-function "array<entity> function GetPlayerArray()"

    !!! note
        A cleaner way to get a player:

        !!! cpp-function "entity function GetPlayerByIndex( int index )"

!!! cpp-function "array<entity> function GetPlayerArrayOfTeam(int team)"

!!! cpp-function "void function DropWeapon( entity npc )"

    !!! note
        this function only works on NPCs and not on players

!!! cpp-function "void function ClearDroppedWeapons( float delayTime = 0.0 )"

!!! cpp-function "void function ClearActiveProjectilesForTeam( int team, vector searchOrigin = <0,0,0>, float searchDist = -1 )"

!!! cpp-function "void function ClearChildren( entity parentEnt )"

### Titans

!!! cpp-function "bool function TitanHasRegenningShield( entity soul )"

!!! cpp-function "void function DelayShieldDecayTime( entity soul, float delay )"

!!! cpp-function "void function GiveAllTitans()"

!!! cpp-function "float ornull function GetTitanCoreTimeRemaining( entity player )"


## Gamemode functions

!!! cpp-function "int function GetCurrentWinner( int defaultWinner = TEAM_MILITIA )"

    !!! note

        Does not work for FFA modes


!!! cpp-function "string NSGetLocalPlayerUID()"

    Returns the local player's UID, else `null`.
    Available on CLIENT, UI and SERVER VM.

!!! cpp-function "bool function IsMultiplayer()"

!!! cpp-function "bool function IsSingleplayer()"

!!! cpp-function "string function GetMapName()"


## Threaded conditonals

!!! cpp-function "void function WaitTillLookingAt( entity player, entity ent, bool doTrace, float degrees, float minDist = 0, float timeOut = 0, entity trigger = null, string failsafeFlag = "" )"

!!! cpp-function "void function WaitUntilShieldFades( entity player, entity titan, entity bubbleShield, float failTime )"

!!! cpp-function "entity function WaitUntilPlayerPicksUp( entity ent )"

!!! cpp-function "void function WaitForHotdropToEnd( entity titan )"

!!! cpp-function "var function WaittillGameStateOrHigher( state )"

!!! cpp-function "void function WaitTillCraneUsed( entity craneModel )"

!!! cpp-function "void function WaitTillHotDropComplete( entity titan )"

!!! cpp-function "var function WaitForNPCsDeployed( npcArray )"

!!! cpp-function "var function WaittillPlayDeployAnims( ref )"


## Random functions

!!! cpp-function "bool function IsPlayerMalePilot( entity player )"

!!! cpp-function "bool function IsPlayerFemalePilot( entity player )"

!!! cpp-function "void function RandomizeHead( entity model ) "

    Randomize head across all available heads

!!! cpp-function "void function RandomizeHeadByTeam( entity model, int headIndex, int numOfHeads ) "

    Randomize head across heads available to a particular team. Assumes for a model all imc heads are first, then all militia heads are later.

!!! cpp-function "void function CreateZipline( vector startPos, vector endPos )"

!!! cpp-function "bool function HasTeamSkin( entity model )"

!!! cpp-function "void function DropToGround( entity ent )"

!!! cpp-function "void function DropTitanToGround( entity titan, array<entity> ignoreEnts )"


## Type Utilities

### Table

!!! cpp-function "void function TableRemoveInvalid( table<entity, entity> Table )"

!!! cpp-function "void function TableRemoveInvalidByValue( table<entity, entity> Table )"

!!! cpp-function "void function TableRemoveDeadByKey( table<entity, entity> Table )"

!!! cpp-function "array<var> TableKeysToArray( table Table )"


### Arrays

!!! cpp-function "int function array.find(var value)"

    !!! warning "this returns `-1` if the item was not found in the array"

!!! cpp-function "array.fastremove(var)"

    Removes a variable by value instead of index.

!!! cpp-function "array.randomize()"

    Reorders the array randomly.

!!! cpp-function "array.getrandom()"

    returns a random element from array

!!! cpp-function "array.resize(int newSize, var fillValue = 0)"

    changes the size of the array to the first int, new slots will be filled with the 2nd argument.

!!! cpp-function "array.sort( compare_func = null )"

!!! note

    A few built-in functions you can give as arguments to sort an array.

    ??? dropdown "Array Sort Functions"

        !!! cpp-function "int function SortLowest( var a, var b )"

        !!! cpp-function "int function SortHighest( var a, var b )"

        !!! cpp-function "int function SortItemsAlphabetically(var a, var b )"

        !!! cpp-function "int function SortAlphabetize( var a, var b )"

        !!! cpp-function "int function SortStringAlphabetize( string a, string b )"

        !!! cpp-function "int function SortStringAsset( asset a, asset b )"

        !!! cpp-function "int function SortBySpawnTime( entity a, entity b )"

        Functions for score comparison

        !!! cpp-function "int function CompareKills( entity a, entity b )"

        !!! cpp-function "int function CompareAssaultScore( entity a, entity b )"

        !!! cpp-function "int function CompareScore( entity a, entity b )"

        !!! cpp-function "int function CompareAssault( entity a, entity b )"

        !!! cpp-function "int function CompareDefense( entity a, entity b )"

        !!! cpp-function "int function CompareLTS( entity a, entity b )"

        !!! cpp-function "int function CompareCP( entity a, entity b )"

        !!! cpp-function "int function CompareCTF( entity a, entity b )"

        !!! cpp-function "int function CompareSpeedball( entity a, entity b )"

        !!! cpp-function "int function CompareMFD( entity a, entity b )"

        !!! cpp-function "int function CompareScavenger( entity a, entity b )"

        !!! cpp-function "int function CompareFW( entity a, entity b )"

        !!! cpp-function "int function CompareHunter( entity a, entity b )"

        !!! cpp-function "int function CompareATCOOP( entity a, entity b )"

        !!! cpp-function "int function CompareFD( entity a, entity b )"

        !!! cpp-function "int function CompareTitanKills( entity a, entity b )"



!!! cpp-function "array.reverse()"

    reverse the array in place

!!! cpp-function "array.slice(int start, int end = null)"

    !!! note
        Returns a section of the array as new array. Copies from start to the end (not included). If start is negative the index is calculated as length + start, if end is negative the index is calculated as length + end. If end is omitted end is equal to the array length.

### String

!!! cpp-function "var function UniqueString( titleString = "" )"

    returns a unique string

!!! cpp-function "string function StringReplace(string original, string toReplace, string replacement)"

    !!! note
        Returns the new string with the first occurance of the toReplace string."

!!! cpp-function "string function format( string template, ... )"

    Returns a formatted template

!!! cpp-function "string function Localize( string token )"

    !!! note

        replaces text that should be localized on the client

        ```squirrel
            string localized = Localize( token )
        ```

!!! cpp-function "int ornull function string.find( string s )"

    !!! warning

        returns `null` if the string is not found.

        You can eliminate the possibility of the returned index being null by casting like this:

        ```squirrel
            int ornull index = GetMapName().find( "mp" )

            if( !index )
                return
            int( index )
            int n = index + 1 //now we do not need the ornull anymore
        ```

!!! cpp-function "string function string.slice( int start, int end = null )"


### Float

!!! cpp-function "float function RandomFloatRange( float min, float max)"

### Integer

!!! cpp-function "int function RandomIntRange( int min, int max )"

!!! cpp-function "int function RandomIntRangeInclusive( int min, int max )"

### Vectors

!!! cpp-function "vector function RandomVec( float range )"

