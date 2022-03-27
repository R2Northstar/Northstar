Creating gamemodes
==================================

Creating a gamemode is significantly more complex than making mutators, but takes on the same form. the main differences are the number of things you must define to make a functioning gamemode, the points system, respawn system and team mechanics must all be considered.

The ``mod.json``
----------------

The ``mod.json`` is responsible for governing when, and where your mod is loaded, and follows a layout that is fairly complicated at first glance.
However, once you get the hang of it, it should be fairly easy to use.

.. code-block:: json

    {
        "Name" : "SimpleRandomiser",
        "Description" : "SimpleRandomiser",
        "Version": "0.1.0",
        "LoadPriority": 1,


The script above defines the pubic and listed details of the mod.

.. code-block:: json
    
            "Scripts": [
            {
                "Path": "sh_SimpleRandomiser.gnut",
                "RunOn": "MP",
                "ClientCallback": {
                    "After": "simplerandomiser_init"
                },

                "ServerCallback": {
                    "After": "simplerandomiser_init"
                }
            }
        ],

The script above defines both what functions to run, when to run them and WHERE to run them, in this case it runs your ``simplerandomiser_init``, when on multiplayer and for both the server and the client.

.. code-block:: json

        "Localisation": [
            "resource/simplerandomiser_localisation_%language%.txt"
        ]
    }

This defines the path to the language file.

Name this file ``mod.json``, and it should go in the mods root folder, that being /yourmodname.

Here's what the end result would look like:

.. code-block:: json

    {
        "Name" : "SimpleRandomiser",
        "Description" : "SimpleRandomiser",
        "Version": "0.1.0",
        "LoadPriority": 1,
        "Scripts": [
            {
                "Path": "sh_SimpleRandomiser.gnut",
                "RunOn": "MP",
                "ClientCallback": {
                    "After": "simplerandomiser_init"
                },

                "ServerCallback": {
                    "After": "simplerandomiser_init"
                }
            }
        ],
        "Localisation": [
            "resource/simplerandomiser_localisation_%language%.txt"
        ]
    }

Language file
-------------
This follows a fairly simple template, the only thing of note is that you often get strange behaviour using ``UTF-8`` when saving the file instead of using ``UTF-16 LE``.

.. code-block::

    "lang"
    {
        "Language" "english"
        "Tokens"
        {
            "MODE_SETTING_CATEGORY_SIMPLERANDOMISER" "Simple Randomiser"
            "SIMPLERANDOMISER" "Randomise"
        }
    }

Name this file ``simplerandomiser_localisation_english.txt`` and place it in the ``yourmodsname/mod/resource/`` folder.

Creating the mod
----------------
Creating a gamemode mod will involve 3 things primarily, which being: 
    1. A mod.json, 
    2. A language file and 
    3. The mod itself.
Since we are done with the first two, we need to get started with the mod itself.

To begin with, we need to answer the simple question of "What are we making?"

For our example, let's make a simple randomiser that randomises your weapon on each spawn.
Because this is a mod that only affects server settings, it will only need to be installed on the serverside but it won't appear in the browser unless the host puts it in the server name.
So let's get started with our **initial function**

The initial function
^^^^^^^^^^^^^^^^^^^^
The initial function is the function that is called on server startup and contains 2 important things.
The **callbacks** and the **settings**. 
To add settings to the private match settings we need to use a new function:

``AddPrivateMatchModeSettingEnum("string", "string", ["#SETTING_ENABLED", "#SETTING_ENABLED"], "0")``

This might look complicated, but really its just (Category, settingname, [setting options], default value) however we use terms like ``"#MODE_SETTING_CATEGORY_RANDOMISER"`` in place of the category name so that we can create language files for different languages.
(we will make that later)

.. code-block:: javascript

    void function simplerandomiser_init(){
        AddPrivateMatchModeSettingEnum("#MODE_SETTING_CATEGORY_SIMPLERANDOMISER", "SimpleRandomiser", ["#SETTING_ENABLED", "#SETTING_ENABLED"], "0")
        
        #if SERVER
        AddCallback_OnPlayerRespawned(GiveRandomGun)
        #endif
    }

As you may have noticed, checking if it is a server is a special case, so we use ``#if SERVER`` and ``#endif`` instead of the usual ``if(thing){stuff}``

Now that our initial function is created we now have the game triggering `GiveRandomGun` on spawn, but we dont have any such function, so lets make one. but before we can do that, we need to know what weapons we can equip. 
For this we define an array:

.. code-block:: javascript

    array<string> pilotWeapons = [
            "mp_weapon_alternator_smg",
            "mp_weapon_autopistol",
            "mp_weapon_car",
            "mp_weapon_dmr"]
    
Here we have defined an array with only 4 weapons in it, you can make this list however you like but remember to separate all but the last item with a ``,``

Now let's make a function to check if you enabled the setting:

.. code-block:: javascript

        bool function SimpleRandomiserEnabled() 
            return GetCurrentPlaylistVarInt("SimpleRandomiser", 0) == 1


Randomise function
^^^^^^^^^^^^^^^^^^
As we already know its going to call the function ``GiveRandomGun`` when a player respawns, let's define that now.
First we strip any existing weapons:

.. code-block:: javascript

    void function GiveRandomGun(entity player){
        foreach ( entity weapon in player.GetMainWeapons() )
            player.TakeWeaponNow( weapon.GetWeaponClassName() )

This iterates through each weapon (that being the primary, secondary and anti-titan weapons) and removes them individually. 

Then lets give them a new, random weapon by selecting a random item from our previous array:

.. code-block:: javascript

    player.GiveWeapon(pilotweapons[RandomInt(pilotweapons.len())])

And done, surprisingly short script huh?

.. code-block:: javascript

    void function simplerandomiser_init(){
        AddPrivateMatchModeSettingEnum("#MODE_SETTING_CATEGORY_SIMPLERANDOMISER", "SimpleRandomiser", ["#SETTING_ENABLED", "#SETTING_ENABLED"], "0")
        
        #if SERVER
        AddCallback_OnPlayerRespawned(GiveRandomGun)
        #endif
    }

    array<string> pilotWeapons = [
            "mp_weapon_alternator_smg",
            "mp_weapon_autopistol",
            "mp_weapon_car",
            "mp_weapon_dmr"]

    void function GiveRandomGun(entity player){
    foreach ( entity weapon in player.GetMainWeapons() )
        player.TakeWeaponNow( weapon.GetWeaponClassName() )
    player.GiveWeapon(pilotweapons[RandomInt(pilotweapons.len())])
    }

Name this ``sh_SimpleRandomiser.gnut`` and place it in the ``yourmodsname/mod/scripts/vscripts/`` folder.
Make sure to double check that all spellings are correct in your mod as everything is case-sensitive.
