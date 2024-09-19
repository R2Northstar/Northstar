# Topologies

RUI elements are rendered on topologies.

The position of topologies are relative to the position of their parent.

Since the number of topologies that can be created is very limited and Vanilla uses most of the slots already, try to minimize your topology uses. Instead of creating new ones, check if you can use one that already exists:

```squirrel

            clGlobal.topoFullScreen
            clGlobal.topoCockpitHudPermanent
            clGlobal.topoTitanCockpitLowerHud
            clGlobal.topoTitanCockpitInstrument1 // yes, with a 1
            clGlobal.topoTitanCockpitHud
            clGlobal.topoCockpitHud
```

## Creating Topologies

!!! cpp-function "void RuiTopology_CreatePlane( vector origin, vector angles, vector right, vector down, bool doClipping )"

    This creates a simple topology at the specified origin relative to the parent position.

    The parameters `right` and `down` specify the dimensions of the topology relative to the origin. For example, passing `<GetScreenSize()[0],0,0>` and `<0,GetScreenSize()[1],0>` will create a topology that covers the entire screen. Note that in this example the origin is the top left corner. The unit used is pixels.

!!! cpp-function "void RuiTopology_CreateSphere( vector origin, vector angles, vector right, vector down, COCKPIT_RUI_RADIUS, COCKPIT_RUI_WIDTH, COCKPIT_RUI_HEIGHT, float subDiv  )"

    Similar to `RuiTopology_CreatePlane` but creates an arched sphere instead of a plane. Unlike in `RuiTopology_CreatePlane`, **right and down are angles and not relative positions**. The width and height are instead controlled by their respective parameters.

!!! cpp-function "void RuiTopology_Destroy( var topology )"

    This destroys the passed topology. However, ruis that are already drawn on top of it do **not** get destroyed.

!!! cpp-function "void RuiTopology_SetParent( var topology, entity anchor, string attachName = "" )"

    Parents the given topology to the anchor entity. The topology moves and rotates relative to the parent.

    Set the position of the topology to `<0,0,0>` to render at the parent's position.

!!! cpp-function "void RuiTopology_UpdatePos( topo, updateOrg, right, down )"

    Update the position and dimensions of the topology

!!! cpp-function "void RuiTopology_ShareWithCode( topology, ruiCode ) "


## Drawcalls

Drawcalls determine how and where RUIs on a topology are being rendered.

* `RUI_DRAW_NONE`: Don't render rui at all
* `RUI_DRAW_HUD`: Render rui on screen. Uses screen coordinates in pixels.
* `RUI_DRAW_WORLD`: Render rui in worldspace on a two dimensional surface facing the direction of the topology.
* `RUI_DRAW_COCKPIT`: Similiar to `RUI_DRAW_HUD` but follows the cockpit headbob movement.

**Drawcalls are not set for a topology but for each rui individually**

## HUD Topology example

```squirrel

    // Cover the top left quadrant of the screen with a basic image
    float[2] s = GetScreenSize()
    var topo = RuiTopology_CreatePlane( <0,0,0>, <s[0] / 2,0,0>, <0,s[1] / 2,0>, true ) // RUIs scale with the topology they are being drawn on so make sure to use the correct dimensions
    RuiCreate( $"ui/basic_image.rpak", topo, RUI_DRAW_HUD, 0 )
```

## Worldspace Topology example

```squirrel

    // REMEMBER TO DESTROY ALL TOPOS, RUIS AND PROPS YOU CREATE WHEN YOU NO LONGER NEED THEM
    // ripped from respawn
    var function Worldspace_CreateRUITopology( vector org, vector ang, float width, float height )
    {
        // adjust so the RUI is drawn with the org as its center point
        org += ( (AnglesToRight( ang )*-1) * (width*0.5) )
        org += ( AnglesToUp( ang ) * (height*0.5) )

        // right and down vectors that get added to base org to create the display size
        vector right = ( AnglesToRight( ang ) * width )
        vector down = ( (AnglesToUp( ang )*-1) * height )

        return RuiTopology_CreatePlane( org, right, down, true )
    }

    void function WorldSpaceTopoTest()
    {
        // To rotate a topology without manually calculating and updating position and dimensions you can parent the topology to  a client side prop
        entity player = GetLocalClientPlayer()
        entity weapon = player.GetActiveWeapon()

        vector fwd = AnglesToForward( weapon.GetAngles() )
        vector right = AnglesToRight( weapon.GetAngles() )
        vector up = AnglesToUp( weapon.GetAngles() )
        vector conf = < 20, -40, 30 > // float next to the player's weapon

        int attachIndex = weapon.LookupAttachment( "muzzle_flash" )
        entity anchor = CreateClientSidePropDynamic( weapon.GetAttachmentOrigin( attachIndex ) + fwd * conf.x + right * conf.y + up * conf.z, <0,0,0>, $"models/dev/empty_model.mdl") // props need a model but this one is invisible so we don't need to set visibility manually
        var topo = Worldspace_CreateRUITopology( <0,0,0>, <0,90,0>, 128, 64 ) // origin <0,0,0> so the topo sits at the origin of the prop

        var tm_box = RuiCreate( $"ui/helmet_scanning_percentbar.rpak", topo, RUI_DRAW_WORLD, 0 )
        RuiSetString( tm_box, "stage3TextTop", "Top" )
        RuiSetString( tm_box, "stage3TextBottom", "Bottom" )

        anchor.SetParent( weapon )
        RuiTopology_SetParent( topo, anchor )
    }
```
