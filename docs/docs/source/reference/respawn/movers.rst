Movers
======


movers are entites that move smoothly.
``script_mover`` allows for smooth movement and rotation contrary to ``script_mover_lightweight`` which is not able to rotate.

Functions for creating movers and examples.

these function are found in ``_utility.nut``

.. cpp:function:: entity CreateExpensiveScriptMover( vector origin , vector angles )

   returns ``script_mover``
    
.. cpp:function:: entity CreateExpensiveScriptMover( asset model, vector origin, vector angles, int solidType, float fadeDist )

    returns ``script_mover`` which has a model

.. cpp:function:: entity CreateScriptMover( vector origin, vector angles )

    returns ``script_mover_lightweight``

.. cpp:function:: entity CreateScriptMoverModel( asset model, vector origin, vector angles, int solidType, float fadeDist )

    returns ``script_mover_lightweight`` which has a model

.. cpp:function:: entity CreateOwnedScriptMover( entity owner )
    
     returns ``script_mover`` which will be at the location of the owner

to actually move movers you can use ``NonPhysicsMoveTo( dest, time, easeIn, easeOut )``

.. code-block:: javascript

    entity mover = CreateScriptMover( <0,0,0> ) 
    
    // moving the mover to <0,0,10> in 1 second
    mover.NonPhysicsMoveTo( <0,0,10>, 1, 0, 0 )
    
    // wating so the mover gets to the destination
    wait 1
    
    // sending it back
    mover.NonPhysicsMoveTo( <0,0,0>, 1, 0, 0 )
    
    // then stoping the mover in 0.5 seconds
    wait 0.5
    mover.NonPhysicsStop()

Pushers
-------

Pushers are movers but you make them pushers like this :
``mover.SetPusher( true )``

Pushers are great at moving anything and also can be used as a crusher.


Examples
--------

.. code-block:: javascript
    
    // creating a elevator 
    // using a mover with a model
    entity mover = CreateScriptMoverModel( $"models/props/turret_base/turret_base.mdl", < -40.5605, -1827.87, -223.944 >, <0,0,0>, SOLID_VPHYSICS, 1000 )
    mover.SetPusher( true ) // making it into a pusher
    
    // for loop to move the elevator up and down
    for(;;)
    {
        mover.NonPhysicsMoveTo( < -35.4312, -1827.87, 523.046 >, 4.8, 0.1, 0.1 )
        wait 6

        mover.NonPhysicsMoveTo( < -35.4312, -1827.87, -223.944 >, 4.8, 0.1, 0.1 )
        wait 6
    }


.. code-block:: javascript

    // Phase shifting the player to a destination
    // setting a position
    vector destination = <250,1000,100>
    // checking if the player is valid
    if ( IsValid( player ) )
    {
        // creating the mover
        entity mover = CreateOwnedScriptMover( player )
        player.SetParent( mover ) // parenting the player ( so they move with the mover )
        mover.NonPhysicsMoveTo( destination, 0.5, 0, 0 ) // saying to the moveer to move
        vector angles = player.GetAngles() // angles saved
        PhaseShift( player, 0.1, 1 ) // phase shifitng the player
        player.SetAngles( angles ) // setting the player to the original angles
    }
    wait 0.6 // wating so the mover moves

    if ( IsValid( player ) )
    {
        player.ClearParent() // removing the player from the mover
    }
