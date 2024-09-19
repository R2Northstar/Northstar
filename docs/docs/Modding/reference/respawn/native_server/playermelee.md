# PlayerMelee

!!! cpp-function "entity PlayerMeleeLungeConeTrace( entity plaer, int callback )"

  Do a lunge cone trace returning the target closest to center of screen

!!! cpp-function "array<VisibleEntityInCone> PlayerMelee_FindVisibleEntitiesInCone( entity playerTitan )"

  Returns an array of entities that are inside a cone and visible to the player

!!! cpp-function "table PlayerMelee_AttackTrace( entity player, float range, bool functionref( entity attacker, entity target ) isValidTargetFunc )"

  Do a trace for potential melee targets in front of player.
  Returns a table with keys `entity` and `position`, which is the hit entity and position

!!! cpp-function "bool PlayerMelee_IsExecutionReachable( entity attacker, entity target, number dist )"

!!! cpp-function "bool PlayerMelee_IsServerSideEffects()"

!!! cpp-function "void PlayerMelee_StartLagCompensateTarget( entity attacker, entity target )"

!!! cpp-function "void PlayerMelee_StartLagCompensateTargetForLunge( entity attacker, entity target )"

!!! cpp-function "void PlayerMelee_FinishLagCompensateTarget( entity attacker )"
