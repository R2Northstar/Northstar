Introduction to Squirrel
========================
Squirrel is a programming language used in Titanfall 2 and Northstar mods, it is worth noting that the version of squirrel used by titanfall appears to be a modified version of the language, based on version 2.3.0

File format
-----------

All files using squirrel are saved as ``.nut`` or ``.gnut``

when creating mods your mod will typically be a series of functions and callbacks

Squirrel as a typed language
----------------------------
All variables and functions in squirrel must have a type defined on declaration

.. code-block:: javascript

    function dosomething()


is not acceptable and should instead be

.. code-block:: javascript

    void function dosomething()

Similarly when declaring a variable

.. code-block:: javascript

    funnynumber = 69

will not work, instead use:

.. code-block:: javascript

    int funnynumber = 69

Variable types
--------------

* ``void``: can be used to define functions that do not return a value, but still do things. most of your functions will be void
* ``integer``: a whole number
* ``float``: any floating-point number.
* ``string``: text
* ``entity``: an entity and all its associated information
* ``bool``: ``true`` or ``false`` (Squirrel does not treat 1 as true or 0 as false)
* ``array``: an ordered list of items indexed from 0, increasing with the number of items such as: 0:"hello",1:1000,2:entity player
* ``table``: a list of items with indexes defined on object entry such as: ``"word":"hello"``, ``"kilo":1000"``, ``"pilot":entity player``
* ``struct``: a series of attributes assigned to a structure and accessed through with ``structname.variablename``
* ``var``: Var typically refers to variables that lack any stated type, this will cause issues with many functions unless you use the ``untyped`` identifier at the start of your file, or if you use ``expect type(variable)`` when passing the variable to that function
