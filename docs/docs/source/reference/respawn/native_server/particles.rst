.. _particles-doc:

Particles
=========

Methods to create and manage particles

.. cpp:function:: int PrecacheParticleSystem( asset particle )

.. cpp:function:: int GetParticleSytemIndex( asset particle )

.. cpp:function:: string GetParticleSystemName( asset particle )

.. cpp:function:: void StartParticleEffectInWorld( number particleIndex, vector origin, vector angles )

.. cpp:function:: void StartParticleEffectInWorldWithControlPoint( number particleIndex, vector origin, vector angles, vector controlPoint )

.. cpp:function:: entity StartParticleEffectInWorld_ReturnEntity( number particleIndex, vector origin, vector angles )

.. cpp:function:: void StartParticleEffectOnEntity( entity ent, number particleIndex, number attachPoint, number attachID )

.. cpp:function:: void StartParticleEffectOnEntityWithControlPoint( entity ent, number particleIndex, number attachPoint, number attachID, number unk1, number unk2 )

.. cpp:function:: void StartParticleEffectOnEntityWithPos( entity ent, number particleIndex, number attachPoint, number attachID, vector origin, vector angles )

.. cpp:function:: void StartParticleEffectOnEntityWithPosWithControlPoint( entity ent, number particleIndex, number attachPoint, number attachID, vector unk2, vector unk3, number unk4, number unk5 )

.. cpp:function:: entity StartParticleEffectOnEntity_ReturnEntity( entity ent, number particleIndex, number attachPoint, number attachID )

.. cpp:function:: entity StartParticleEffectOnEntityWithPos_ReturnEntity( entity ent, number particleIndex, number attachPoint, number attachID, vector origin, vector angles )

.. cpp:function:: void EffectStop( entity effect )

.. cpp:function:: void EffectSleep( entity effect )

.. cpp:function:: void EffectWake( entity effect )

.. cpp:function:: void EffectSetControlPointVector( entity effect, number unk1, vector origin_maybe )

.. cpp:function:: void EffectSetControlPointAngles( entity effect, number unk1, vector angles )

.. cpp:function:: void EffectSetControlPointEntity( entity effect, number unk1, entity ent )

.. cpp:function:: void EffectAddTrackingForControlPoint( entity effect, number unk1, entity unk3, number unk4, number unk5 )
