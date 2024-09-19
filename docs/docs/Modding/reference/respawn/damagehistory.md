# Damage History

After a player receives damage it is stored by the game in an array of the following struct. The information in that struct is final and changing it does not affect the game.

## DamageHistoryStruct

!!! cpp-struct "DamageHistoryStruct"

    !!! cpp-var "string attackerName"

        Name of the attacker
    !!! cpp-var "string attackerPetName"

        Name of the titan
    !!! cpp-var "vector origin"

        Position of the victim
    !!! cpp-var "float damage"

        The amount of damage inflicted
    !!! cpp-var "int damageType"

        A value from the [Damage Flags](native_server/damageinfo.md#damage-flags-damage-flag-overview)
    !!! cpp-var "int damageSourceId"

        Damage souce ID from the gun ( damage-source-id-overview )
    !!! cpp-var "entity attacker"

        Entity of the attacker
    !!! cpp-var "int attackerEHandle"


    !!! cpp-var "float attackerHealthPercent"

        How much health the attacker has in %

    !!! cpp-var "float time"

        When the damage was inflicted

    !!! cpp-var "array<string> weaponMods"

        Array of mods on the attacking gun

    !!! cpp-var "bool victimIsTitan"

        `true` if the victim died in the Titan

    !!! cpp-var "bool rodeoDamage"

        `true` if the damage was inflicted in rodeo mode


### Getting the info from the entity

You can get the damage history for any player entity with `player.e.recentDamageHistory`, this is of the type `array<DamageHistoryStruct>` and gets automatically updated by the game. The higher the index the older the `DamageHistoryStruct` is ( so to get the most recent struct you do `player.e.recentDamageHistory[ 0 ]` ).

### Getter functions

!!! cpp-function "array<DamageHistoryStruct> GetDamageEventsForTime( entity player, float time )"

    - `entity player` The player you want the damage history from.

    - `float time` How old the damage history can be in seconds.

    - Returns: All `DamageHistoryStruct` found in the given time frame.

### Setter functions

!!! cpp-function "DamageHistoryStruct function StoreDamageHistoryAndUpdate( entity storeEnt, float maxTime, float damage, vector damageOrigin, int damageType, int damageSourceId, entity attacker = null, array<string> weaponMods = [] )"

!!! cpp-function "void function UpdateDamageHistory( entity player, float maxTime, float time )"

    Removes all `DamageHistoryStruct` in the time frame `time - maxTime`

    - `entity player` The player you want to update the damage history from.

    - `float maxTime` How old the damage history can maximally be

    - `float time` How old the damage history can be in seconds.


## Built in Checks

!!! cpp-function "float function GetLastDamageTime( entity player )"
!!! cpp-function "bool function WasRecentlyHitByEntity( entity player, entity ent, float hitTime )"
!!! cpp-function "bool function WasRecentlyHitForDamage( entity player, float damageAmount, float hitTime )"
!!! cpp-function "bool function WasRecentlyHitForDamageType( entity player, float damageType, float hitTime )"
!!! cpp-function "float function GetTotalDamageTaken( entity player )"
!!! cpp-function "float function GetTotalDamageTakenInTime( entity player, float hitTime )"
!!! cpp-function "array<entity> function GetTitansHitMeInTime( entity player, float hitTime )"
!!! cpp-function "float function GetTotalDamageTakenByPlayer( entity player, entity attacker )"
!!! cpp-function "array<AttackerDamage> function GetDamageSortedByAttacker( entity ent, float totalTime )"
!!! cpp-function "bool function WasRecentlyHitByDamageSourceId( entity player, int damageSourceId, float hitTime )"
!!! cpp-function "AssistingPlayerStruct function GetLatestAssistingPlayerInfo( entity ent )"

    !!! note

        !!! cpp-struct "AssistingPlayerStruct"

            !!! cpp-var "entity player"
            !!! cpp-var "int damageSourceId"
            !!! cpp-var "float assistTime"

!!! cpp-function "array<DamageHistoryStruct> function GetRodeoAttacksByPlayer( entity player, entity attacker, float time )"
!!! cpp-function "string function GetLastDamageSourceStringForAttacker( entity victim, entity attacker )"
!!! cpp-function "float function TotalDamageOverTime_BlendedOut( entity soul, float start, float end )"
!!! cpp-function "void function ClearRecentDamageHistory( entity player )"
