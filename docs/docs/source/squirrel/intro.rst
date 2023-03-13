Primitive Types
========================

Squirrel has similar primitive types to most programming languages like java or C.

Integer
------

The type for an interger (whole number) in squirrel is ``int``. It represents a 32-bit whole number.
It is declared like this:

.. code-block:: javascript

    int number = 5

They can be assigned expressions

.. code-block:: javascript

    number = 5 + 10 - 5

Alternatively you can also write the number in HEX code or as a single ASCII character with ``''``

.. code-block:: javascript

    number = 'c' // IS VALID
    number = "c" // NOT VALID

A list of all the ASCII values can be found `here <https://de.wikipedia.org/wiki/American_Standard_Code_for_Information_Interchange#ASCII-Tabelle>`_  

Built-in functions to cast integers to other types:

.. cpp:function:: float integer.tofloat()

.. cpp:function:: string integer.tostring()

.. cpp:function:: string integer.tochar()


Float 
-----

Floating-point numbers are numbers with decimal places, they are declared with the ``float`` keyword.

.. code-block:: javascript

    float number = 5.69420

You can also assign fractions but you need to use decimal points:

.. code-block:: javascript

    float number = 5.0/2.0 // has the value 2.5
    float number = 5/2 // Will compile BUT with value 2

Built-in functions to cast floats to other types:

.. cpp:function:: int float.tointeger()

.. cpp:function:: string float.tostring()

.. cpp:function:: string float.tochar()

Boolean 
-------

Booleans are a value that either represent ``true`` or ``false`` and are declared with the keyword ``bool``

.. code-block:: javascript

    bool TrueOrFalse = true

They can also accept comnparison expressions, which return a boolean

.. code-block:: javascript

    bool TrueOrFalse = 1 == 2

Built-in functions to cast a boolean:

.. cpp:function:: int boolean.tointeger()

    returns ``1`` or ``0`` 

.. cpp:function:: string bolean.tostring()

    returns ``"true"`` or ``"false"``

.. cpp:function:: float boolean.tofloat()

    returns ``1.0`` or ``0.0``

Variables
----

Variables that can represent any type (complex or primitive) can be initialized with the keyword ``var``

There are no build-in function to cast to var.

.. code-block:: javascript

    var anyValue = "String"
    var two = 2

Alternatively, you can use the ``local`` keyword from vanilla squirrel, allthough this is highly discouraged it acts the same.


Easy casting
------------

For all previous types you can also cast them by using the ``type( variable )`` notation:

.. code-block:: javascript

    int number = int ( "5" ) 

To convert a ``var`` to other types you need use the ``expect`` keyword:

.. code-block:: javascript

    var numberVar = 2
    int numberInt = expect int(numberVar)


Global variables and functions
-------

When creating a mod, you might want to allow other files or mods to access a ``variable`` or a ``function``, this can be achieved by declaring them using the ``global`` keyword.
They act like any other variable or function, but can be accessed from any other file or mod. They should be declared at the top of your file, and have a unique name which doesn't appear as a global in any other file, mod, or built-in squirrel code.

.. code-block:: javascript

    global int GlobalInt 
    global array<int> GlobalArray
    global function GlobalFunction //here you only need to give the function name not return type or arguments
    
    //ofc you can also directly give global variables a value
    global string GlobalString = "This is a global message"
    
Now you are able to use ``GlobalInt``, ``GlobalArray``, ``GlobalFunction`` and ``GlobalString`` in all your files.
When using this make sure you do not accidentally make a new variable with the same name and type as a global variable as this will likely brake your code

