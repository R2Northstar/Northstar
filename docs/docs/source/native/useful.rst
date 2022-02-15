Useful functions and variables from respawn
===========================================

Throughout this guide many functions and values made by respawn will be referenced in examples, in the interest of not confusing people those functions, and other frequently used ones, will be listed and explained here
for a full list (although without explaination) go `here <https://github.com/ScureX/Titanfall2-ModdingDocumentation/blob/main/AllMethodsClean.md>`_

General functions
-----------------

``GetplayerArray()``
^^^^^^^^^^^^^^^^^^^^
Returns and array of entities representing each player, not that it does not just return return the playername but the actual entities, as such all values associated with players can be called like his

``array.len()``
^^^^^^^^^^^^^^^
Returns the number of objects in an array, thats about it. 

``GameTime_TimeLeftSeconds()``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
returns the remaining game time

``weapon.GetWeaponClassName``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
returns the name of a weapon entity

Player functions
----------------
This section contains many functions that can be applied to the player entity

``player.GetMainWeapons()``
^^^^^^^^^^^^^^^^^^^^^^^^^^^
returns a list of all weapons equipped by that player. this is a list of entities

``player.GetOffHandWeapons()``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Returns a list of all offhand weapons (grenades, boosts, abilities). this is a list of entities

``player.TakeWeaponNow( weaponname )``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
removes weapon of that name, best used with a foreach using the previous functions

``player.GiveWeapon( Weaponname, mods)``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
gives the player a weapon, the mods field must be empty or a list of strings ``["mod","mod2"]``

