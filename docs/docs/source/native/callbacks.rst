Callbacks
======================

Callbacks within squirrel trigger functions when certain events occur and are defined serverside. 

They will also often pass arguments to those functions based on the callbacks used

A few examples
--------------

``AddCallback_OnPlayerRespawned(OnRespawn)``

This script will trigger the function "OnRespawn" when any player respawns, this function can be defined later in the mods file and this callback will pass one argument, the player entity that respawned


``AddCallback_OnPlayerKilled(AddPoints)``

This callback triggers the function "AddPoints" when a player is killed. this function passes 3 arguments: an entity (the attacking player), an entity (the killed player), and the damage informtion

``AddCallback_OnClientConnected(Connected)``

This callback triggers the function "Connected" whenever a player joins and passes 1 argument, the player entity.

List of callbacks
-----------------
This is an **incomplete** list of callbacks, a better list can be found in the list of all functions can be found `here <https://github.com/ScureX/Titanfall2-ModdingDocumentation/blob/main/AllMethodsClean.md>`_.

.. code-block:: javascript

    AddCallback_EntitiesDidLoad()
    AddCallback_GameStateEnter(gamestate, function to trigger)
    AddCallback_KillReplayEnded()
    AddCallback_KillReplayStarted()
    AddCallback_LocalClientPlayerSpawned()
    AddCallback_LocalViewPlayerSpawned()
    AddCallback_MinimapEntSpawned()
    AddCallback_OnClientConnected()
    AddCallback_OnClientScriptInit()
    AddCallback_OnNPCKilled()
    AddCallback_OnPetTitanChanged()
    AddCallback_OnPetTitanModeChanged()
    AddCallback_OnPilotBecomesTitan()
    AddCallback_OnPlayerDisconnected()
    AddCallback_OnPlayerGetsNewPilotLoadout()
    AddCallback_OnPlayerKilled()
    AddCallback_OnPlayerLifeStateChanged()
    AddCallback_OnPlayerRespawned()
    AddCallback_OnSatchelPlanted()
    AddCallback_OnSelectedWeaponChanged()
    AddCallback_OnTimeShiftAbilityUsed()
    AddCallback_OnTimeShiftTitanAbilityUsed()
    AddCallback_OnTitanBecomesPilot()
    AddCallback_OnUseEntity()
    AddCallback_PlayerClassChanged()
    AddCallback_ScriptTriggerEnter()
    AddCallback_ScriptTriggerLeave()
    AddCallback_UseEntGainFocus()
    AddCallback_UseEntLoseFocus()
