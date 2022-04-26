Movers
======


movers are entites that move smoothly.
``script_mover`` allows for smooth movement and rotation contrary to ``script_mover_lightweight`` which is not able to rotate.

Functions for creating movers and examples.

these function are found in `_utility.nut`

.. cpp:function:: entity function CreateExpensiveScriptMover( vector origin = <0,0,0>, vector angles = <0,0,0> )

   returns ``script_mover``
    
.. cpp:function:: entity function CreateExpensiveScriptMover( asset model, vector origin = <0.0, 0.0, 0.0>, vector angles = <0.0, 0.0, 0.0>, int solidType = 0, float fadeDist = -1 )

    returns ``script_mover`` which has a model

.. cpp:function:: entity function CreateScriptMover( vector origin = <0,0,0>, vector angles = <0,0,0> )

    returns ``script_mover_lightweight``

.. cpp:function:: entity function CreateScriptMoverModel( asset model, vector origin = <0.0, 0.0, 0.0>, vector angles = <0.0, 0.0, 0.0>, int solidType = 0, float fadeDist = -1 )

    returns ``script_mover_lightweight`` which has a model

.. cpp:function:: entity function CreateOwnedScriptMover( entity owner )
    
     returns ``script_mover`` which will be at the location of the owner

to actually move movers you can use `NonPhysicsMoveTo`

.. code-block:: javascript
    mover = CreateScriptMover( <0,0,0> ) 

Pushers
-------

Pushers are movers but you make them pushers like this :
`mover.SetPusher( true )`
Pushers are great at moving anything and also crushing you(r dreams).


Examples
-------
    
    this code makes a elevator which going up and down

.. code-block:: javascript
 
    entity mover = CreateScriptMoverModel( $"models/props/turret_base/turret_base.mdl", < -40.5605, -1827.87, -223.944 >, <0,0,0>, SOLID_VPHYSICS, 1000 )
    mover.SetPusher( true )

    for(;;)
    {
        mover.NonPhysicsMoveTo( < -35.4312, -1827.87, 523.046 >, 4.8, 0.1, 0.1 )
        wait 6

        mover.NonPhysicsMoveTo( < -35.4312, -1827.87, -223.944 >, 4.8, 0.1, 0.1 )
        wait 6
    }
    
    this makes the player PhaseShift to a destination

.. code-block:: javascript
 
    if ( IsValid( player ) )
    {
        entity mover = CreateOwnedScriptMover( player )
        player.SetParent( mover )
        mover.NonPhysicsMoveTo( newPos, 0.5, 0, 0 )
        vector angles = player.GetAngles()
        PhaseShift( player, 0.1, 1 )
        player.SetAngles( angles )

        player.SetHealth( player.GetMaxHealth() )
    }

	wait 0.6
    if ( IsValid( player ) )
    {
        player.ClearParent()
        player.SetVelocity( <0,0,50> )
    }
