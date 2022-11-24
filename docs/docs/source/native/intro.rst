Introduction to Squirrel
========================
Squirrel is a programming language used in Titanfall 2 and Northstar mods, it is worth noting that the version of squirrel used by titanfall appears to be a modified version of the language, based on version 2.3.0

File format
-----------

All files using squirrel are typically saved as ``.nut`` or ``.gnut``, though any extension will be run, as long as it is  in the ``scripts/vscripts/`` directory.

when creating mods your mod will typically be a series of functions and callbacks

Squirrel as a typed language
----------------------------
All variables and functions in squirrel must have a type defined on declaration

.. code-block:: javascript

    function dosomething()


is only acceptable in ``untyped`` scripts. In general, prefer the following:

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
* ``string``: text. Squirrel does not have native chars, so calling an index of a string will return a number in standart ascii format. e.g. "a"[0] = 97
* ``entity``: an entity and all its associated information
* ``bool``: ``true`` or ``false`` (Squirrel treats ``null`` and ``0`` as false and every other number or object that's ``!= null`` as true)
* ``array``: an ordered list of items indexed from 0, increasing with the number of items such as: 0:"hello",1:1000,2:entity player
* | ``table``: a list of items with indexes defined on object entry such as: ``"word":"hello"``, ``"kilo":1000"``, ``"pilot":entity player``.
  | You have to create new slots with the ``<-`` operator and overwrite values in slots with ``=``. Tables are explained in more detail in the `squirrel documentation <http://www.squirrel-lang.org/squirreldoc/reference/language/tables.html>`_
* ``struct``: a series of attributes assigned to a structure and accessed through with ``structname.variablename``
* ``var``: Var typically refers to variables that lack any stated type, this will cause issues with many functions unless you use the ``untyped`` identifier at the start of your file, or if you use ``expect type(variable)`` when passing the variable to that function

Content types
-----

tables and arrays can have their content types specified. If none are given, they will default to ``var``.

For tables you can set the types of their keys and contents.

.. code-block:: javascript

    // table<key_type, value_type> identifier
    table<string, entity> players
    foreach( entity player in GetPlayerArray() ) // insert every player into the table indexable by their usernames
    {
        players[ player.GetPlayerName() ] <- player
    }

Arrays can only have their content typed as they will only be indexable by integers.

.. code-block:: javascript

    array<entity> players = GetPlayerArray()
      
.. error:: 

    The rsquirrel lexer recognizes the bitwise right shift operator instead of nested content types, so you are required to leave a space between types containing more content types.

    .. code-block:: javascript

        array<array<int>> badNested // COMPILE ERROR
        array< array<int> > nested
