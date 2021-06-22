# Sounds

## Playing Sounds

!!! cpp-function "void EmitSoundOnEntity( entity ent, string sound )"

!!! cpp-function "void EmitSoundOnEntityNoSave( entity ent, string sound )"

!!! cpp-function "void EmitSoundOnEntityAfterDelay( entity ent, string sound, number delay )"

!!! cpp-function "void EmitSoundOnEntityOnlyToPlayerWithSeek( entity ent, entity reciever, string sound, number duration_maybe )"

!!! cpp-function "void EmitSoundOnEntityExceptToPlayerWithSeek( entity ent, entity reciever, string sound, number duration_maybe )"

!!! cpp-function "void EmitSoundOnEntityToTeam( entity ent, string sound, int team )"

!!! cpp-function "void EmitSoundOnEntityToEnemies( entity ent, string sound, int team )"

!!! cpp-function "void EmitSoundAtPosition( int team, vector origin, string sound )"

!!! cpp-function "void EmitSoundAtPositionOnlyToPlayer( int team, vector origin, entity player, string sound )"

!!! cpp-function "void EmitSoundAtPositionExceptToPlayer( int team, vector origin, entity player, strign sound )"

!!! cpp-function "void StopSoundOnEntity( entity ent, string sound )"

!!! cpp-function "void StopSoundAtPosition( vector pos, string sound )"

!!! cpp-function "void FadeOutSoundOnEntity( entity ent, string sound, number fadeOut )"

!!! cpp-function "void EmitSoundOnEntityOnlyToPlayer( entity ent, entity reciever, string sound )"

!!! cpp-function "void EmitSoundOnEntityOnlyToPlayerWithFadeIn( entity ent, entity reciever, string sound, number fadeIn )"

!!! cpp-function "void EmitSoundOnEntityExceptToPlayer( entity ent, entity exception, string sound )"

!!! cpp-function "void EmitSoundOnEntityExceptToPlayerNotPredicted( entity ent, entity exception, string sound )"

!!! cpp-function "bool DoesAliasExist( string dialogueAlias )"

!!! cpp-function "int GetSoundTags( string sound )"

!!! cpp-function "void SetRapidShiftOffset( number offset )"

## AI Sounds

Sounds the AI can react to

!!! cpp-function "void EmitAISound( int soundFlags, int contextFlags, vector pos, float radius, float duration )"

  Create a new sound event that AI can response to.

!!! cpp-function "void EmitAISoundWithOwner( entity owner, int soundFlags, int contextFlags, vector pos, float radius, float duration )"

  Create a sound event that AI can respond to, specifying the owner of the sound.

!!! cpp-function "void EmitAISoundToTarget( entity target, int soundFlags, int contextFlags, vector pos, float radius, float duration )"

  Create a sound event that AI can respond to, specifying who the sound should target.

!!! cpp-function "void EmitAISoundWithOwnerToTarget( entity ownerEnt, entity targetEnt, int soundFlags, int contextFlags, vectorPos, float radius, float duration )"

  Create a sound event that AI can respond to, specifying who the sound should target, and the owner of the sound.
