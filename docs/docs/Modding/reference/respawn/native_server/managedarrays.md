Script Managed Entity Arrays
============================

.. cpp:function:: int CreateScriptManagedEntArray()

  Returns the index of the new array

.. cpp:function:: void AddToScriptManagedEntArray( int index, entity ent )

.. cpp:function:: void RemoveFromScriptManagedEntArray( int index, entity ent )

.. cpp:function:: int GetScriptManagedEntArrayLen( int index )

.. cpp:function:: array<entity> GetScriptManagedEntArray( int index )

  Get the script managed ent array for the given index

.. cpp:function:: array<entity> GetScriptManagedEntArrayWithinCenter( int index, int notTeam, vector origin, float dist )

  Get the script managed ent array for the given index within distance of a point
