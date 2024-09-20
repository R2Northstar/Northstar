# Titan

Functions for getting titan, and methods of the titan object

```squirrel
            entity soul = player.IsTitan() ? player.GetTitanSoul() : player.GetPetTitan().GetTitanSoul()
            // getting the titan depends on wether the player is in the titan or not
```


!!! cpp-class "titan : public entity"

    !!! cpp-function "unknown GetAISettingsName()"

    !!! cpp-function "entity GetOffhandWeapon()"

    !!! cpp-function "float GetTitanSoulNetFloat( string )"

        e.g. "coreAvailableFrac"

    !!! cpp-function "void SetShieldHealth()"

    !!! cpp-function "bool HasSoul()"

    !!! cpp-function "bool IsArcTitan()"

    !!! cpp-function "bool IsDoomed()"

    !!! cpp-function "bool IsPetTitan()"

    !!! cpp-function "bool IsPhaseShifted()"

    !!! cpp-function "bool IsTitanNPC()"
