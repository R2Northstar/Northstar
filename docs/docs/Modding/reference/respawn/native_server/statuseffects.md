# Status Effects

!!! cpp-function "int StatusEffect_AddTimed( entity ent, int eStatusEffect, float severity01, float "duration, float easeOut )

  Adds a status effect that will stop automatically after a given time.

!!! cpp-function "int StatusEffect_AddEndless( entity ent, int eStatusEffect, float severity01 )"

  Adds a status effect

!!! cpp-function "bool StatusEffect_Stop( entity ent, int effectHandle )"

    Stops a status effect given its handle (return value of StatusEffect_AddTimed or StatusEffect_AddEndless).

!!! cpp-function "int StatusEffect_StopAll( entity ent, int eStatusEffect )"

  Stops all status effects of a given type. Returns the number that were stopped.

!!! cpp-function "float StatusEffect_Get( entity ent, int eStatusEffect )"

!!! cpp-function "array<float> StatusEffect_GetAll( entity ent )"
