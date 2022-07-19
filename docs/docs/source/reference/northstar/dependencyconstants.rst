Dependency Constants
====================

Dependency constants can be used to load constants from another mod.

Inside your ``mod.json`` define a constant as:

.. code:: javascript

    {
        // mod.json stuff
        "Dependencies": {
            // sets the constant to 0 or 1, depending if the mod with the name "Mod Name" exists and is enabled
            "CONSTANT_NAME": "Mod Name"
        }
    }

For Example:

.. code:: javascript

    "PLAYER_HAS_ROGUELIKE_MOD": "TF|Roguelike"

Will define a constant ``PLAYER_HAS_ROGUELIKE_MOD`` that is set to ``0`` or ``1`` depending if the mod is enabled. It then can be used as a constant/compiler flag.


.. code:: csharp

    #if PLAYER_HAS_ROGUELIKE_MOD
    print("player has roguelike mod")
    Roguelike_Function();
    #else
    print("Can't use the function because the mod is off :'(")
    #endif

