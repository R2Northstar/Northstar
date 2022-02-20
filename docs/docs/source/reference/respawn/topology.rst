Topology
------

Functions for creating a Topology, and methods of the Topology object

.. code-block:: javascript
            
            RuiTopology_CreatePlane( origin, right, down, doClipping )
            RuiTopology_CreateSphere()
            
            // example
            var topo = RuiTopology_CreateSphere( 
            COCKPIT_RUI_OFFSET - <0, positionHorizontal, positionVertical>, // POSITION | in screen, left/right, up/down
            <0, -1, transformVertical>, // ?, ?, left side down right side up
            <0, transformHorizontal, -1>, // ?, bottom left top right, ?
            COCKPIT_RUI_RADIUS, 
            COCKPIT_RUI_WIDTH * width, 
            COCKPIT_RUI_HEIGHT * height, 
            COCKPIT_RUI_SUBDIV
            )

Topologies

.. code-block:: javascript
            
            clGlobal.topoFullScreen
            clGlobal.topoCockpitHudPermanent
            clGlobal.topoTitanCockpitLowerHud
            clGlobal.topoTitanCockpitInstrument1 // yes, with a 1
            clGlobal.topoTitanCockpitHud
            clGlobal.topoCockpitHud

.. cpp:class:: topology : public var	

    .. cpp:function:: void CreateRUITopology_Worldspace( origin, angles, width, height )
    
    .. cpp:function:: void CreateOrientedTopology( vector org, vector ang, float width, float height )
  
    .. cpp:function:: void RuiTopology_CreatePlane( origin, right, down, doClipping )
    
    .. cpp:function:: void RuiTopology_CreateSphere( origin, right, down, COCKPIT_RUI_RADIUS, COCKPIT_RUI_WIDTH, COCKPIT_RUI_HEIGHT, float subDiv )

    .. cpp:function:: void RuiTopology_Destroy( topoInfo.topo )
    
    .. cpp:function:: void RuiTopology_SetParent( topo, knife, attachName )
    
    .. cpp:function:: void RuiTopology_UpdatePos( topoInfo.topo, updateOrg, right, down )
        
    .. cpp:function:: void RuiTopology_ShareWithCode( topology, ruiCode ) 
            
            not sure what ruiCode is. examples: RUI_CODE_TOPO_ANIMATED_COCKPIT, RUI_CODE_TOPO_PERMANENT_COCKPIT 
