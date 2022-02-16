Creating mutators and settings
==============================================

Mutators or setting mods are mods that apply additional functions to otherwise normal gamemodes, they should be able to support all gamemodes and care should be taken to ensure that when the setting is disabled they do nothing.

This section will explain how to create a basic randomiser mutator 

Creating Gamemodes
------------------
In this section we will be creating our custom gamemode. this is more complicated than creating setting mods however also allows for more freedom at the cost of being required clientside as well

The Gamemode itself
^^^^^^^^^^^^^^^^^^^
We are going to make a simplified version of the "infection" gamemode.

Lets break it down into steps before we make the gamemode itself

1. Set the gamerules such as player count, team layout and score system
2. force all players on to 1 team at the start of the game
3. randomly select 1 player as being the zombie
    * equip this player with the correct weapons
    * modify their health
    * provide them a speedboost
4. have players become zombies on death
5. have players joining mid way become zombies
6. end the game when the last player dies.

Now lets breakdown the callbacks we will need

for steps 2 and 5 we will need ``AddCallback_OnClientConnected( PlayerJoined )`` to trigger on join

for step 3 we will need to ``AddCallback_GameStateEnter( eGameState.Playing, StartGame )``

for step 4 we need ``AddCallback_OnPlayerRespawned( RespawnInfected )``

and finally to decide the winner we need a new function we havent seen yet. ``SetTimeoutWinnerDecisionFunc( DecideWinners )``

this function is used to decide the winner when the game runs out of time by calling a function.

now that we know our steps its time to start our initialisation function

Initialisation function
-----------------------

first, lets declare our game settings

.. code-block:: javascript

    global function SimpleInfection_init
    void function SimpleInfection_init() {
        SetSpawnpoint GamemodeOverrde( FFA )// This line makes the player spawn locations like those from ffa
        SetLoadoutGracePeriodEnabled( false )// we dont want the zombies to be able to change loadouts and grab their guns, so lets disable that
        SetWeaponDropsEnabled(false )// we dont want zombies grabbing the weapons for dead survivors, so lets disable that.
        Riff_ForceTitanAvailability( eTitanAvailability.Never )// we dont want zombies to have titans either, so lets disable that
        Riff_ForceBoostAvailability( eBoostAvailability.Disabled )// we also dont want the zombies grabbing smart pistols and turrets, so lets disable that
        ClassMP_ForceDisableEpilogue( true )// As the goal is surviving till the timer runs out, we dont need the evac dropship


Next lets setup our callbacks:

.. code-block:: javascript

        AddCallback_OnClientConnected( PlayerJoined )
        AddCallback_GameStateEnter( eGameState.Playing, StartGame )
        AddCallback_OnPlayerRespawned( RespawnInfected )
        SetTimeoutWinnerDecisionFunc( DecideWinners )
    }

great, now we have our gamemodes initialisation function we need a way for our callbacks to know some things, such as whether the game has started or not, you will see why later

.. code-block:: javascript

    struct {
        bool HasStarted = false
    } file

Structs like this allow us to store Values that can be accessed elsewhere in the script, without having to pass them as arguments in all our functions. we place them in a struct instead of just defining them as a global variable cannot 
be modified by a function in squirrel, wheras a struct like this one can.

to access a variable in a struct you must format it using the name of the stuct followed by the variable itself, in this case ``file.HasStarted``

Main functions
--------------

Now it time to start writing our callbacks

.. code-block:: javascript

    void function PlayerJoined(entity player){
        if (file.HasStarted){
            InfectPlayer( player, player)
            RespawnInfected( player )
        }
        else{
            SetTeam( player, 0)
        }
    }

This manages what happens when a player joins, but it calls a function we dont have yet ``InfectPlayer`` so lets define it now

.. code-block:: javascript

    void function InfectPlayer(entity player, entity attacker){
        SetTeam( player, 1)
        if ((GetPlayerArrayOfteam(0).len()) == 0){
            SetRespawnsEnabled(false)
            SetKillcamsEnabled(false)
            SetWinner( 1 )
        }
    }

This function simply changes the players team, then checks if there are any survivors left, and if not sets the zombies as the winners.

Now for the script that chooses the first zombie, in order to allow more time for players to join lets put a delay on it using a ``thread``

.. code-block:: javascript

    void function StartGame(){
        firstinfected = GetPlayerArray()[RandomInt(GetPlayerArray().len())]
        InfectPlayer( firstinfected, firstinfected)
        file.HasStarted = true
    }

This function changes the file.HasStarted value to true and randomly selects a player from the player array as a target for the infectplayer function. 

Next lets create the function that provides the zombies the correct equipment

.. code-block:: javascript

    void function RespawnInfected( entity player ){
        if (player.GetTeam() != 1){//this makes sure players dont accidentally get given zombie weapons when first spawning as a survivor
            return
        }
        //lets give them stim, followed by increased air accel
        StimPlayer( player, 9999)
        player.kv.airAcceleration = 2000
        //lets give them less health than normal
        payer.SetMaxHealth(20)
        //lets set their loadout
        foreach ( entity weapon in player.GetMainWeapons() )
            player.TakeWeaponNow( weapon.GetWeaponClassName() )

        foreach ( entity weapon in player.GetOffhandWeapons() )
            player.TakeWeaponNow( weapon.GetWeaponClassName() )

        player.GiveOffhandWeapon( "melee_pilot_emptyhanded", OFFHAND_MELEE )
        //unfortunately the game requires that you have a weapon of some kind in order to use secondaries, so lets give zombies an MGL
        player.GiveWeapon( "mp_weapon_mgl" )
    }

Finally lets define what occurs when the match ends

.. code-block:: javascript

    void function DecideWinners(){
        SetRespawnsEnabled( false )
        SetKillcamsEnabled( false )
        return 0
    }

Now we can save this file as _gamemode_simpleinf.gnut and place it in
``"ourmodsname"/mod/scripts/vscripts/gamemodes``
