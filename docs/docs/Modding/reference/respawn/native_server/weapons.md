# Weapon Utilities

## Explosions

!!! cpp-function "void Explosion( vector center, entity attacker, entity inflictor, number damage, number damageHeavyArmor, number innerRadius, number outerRadius, int flags, vector projectileLaunchOrigin, number explosionForce, int scriptDamageFlags, int scriptDamageSourceIdentifier, string impactEffectTableName )"

  "Creates an explosion. Does damage in an area, moves physics objects, plays effects.

!!! cpp-function "void Explosion_DamageDefSimple( int damageDefID, vector center, entity attacker, entity inflictor, vector projectileLaunchOrigin )"

  Creates an explosion. Does damage in an area, moves physics objects, plays effects.

!!! cpp-function "void Explosion_DamageDef( int damageDefID, vector center, entity attacker, entity inflictor, number damage, number damageHeavyArmor, vector innerRadius, vector outerRadius, vector projectileLaunchOrigin )"

  Same as Explosion_DamageDefSimple but specify damage and radius.

!!! cpp-function "void RadiusDamage( vector center, entity attacker, entity, inflictor, number damage, number damageHeavyArmor, number innerRadius, number outerRadius, int flags, number distanceFromAttacker, number explosionForce, int scriptDamageFlags, int scriptDamageSourceIdentifier )"

  Does silent, invisible damage in a spherical area.

!!! cpp-function "void RadiusDamage_DamageDefSimple( int damageDefID, vector center, entity attacker, entity inflictor,  number distanceFromAttacker )"

  Does silent, invisible damage in a spherical area.

!!! cpp-function "void RadiusDamage_DamageDef( int damageDefId, vector center, entity attacker, entity inflictor, number damager, number damageHeavyArmor, number innerRadius, number outerRadius, number distanceFromAttacker )"

  Same as RadiusDamage_DamageDefSimple but specify damage and radius.

## Weapon Utils

!!! cpp-function "void Weapon_SetDespawnTime( number time )"

!!! cpp-function "int GetImpactEffectTable( string weapon )"

!!! cpp-function "float CalcWeaponDamage( entity owner, entity target, entity weapon, number distanceToTarget, int extraMods )"
