Complex types
=============

Within squirrel there are many ways to store information, but when storing an unspecified amount of information, or storing information on a player-by-player basis, you need to use ``arrays`` or ``tables``.


.. _strings-overview:

Strings
-------

Strings in squirrel represent an array of chars, however chars are not their own type in squirrel, as they are represent by integers. To initialize a string, use the ``string`` keyword:

.. code-block::

  string Hello = "World"

You can get the integer value of any char with the ``[index]`` like in arrays, however this only returns the ASCII value of that character.
To get the string of the char, you need to:

.. code-block::
  :force:

  int charInt = Hello[0]
  string charString = charInt.tochar()

built in functions can be found on the official site `here <http://www.squirrel-lang.org/squirreldoc/reference/language/builtin_functions.html#string>`_ .

Assets
~~~~~~

Assets are strings that describe a path to a resource like models or RUI assets.

You can declare asset literals with a $ symbol

.. code-block::

  asset m = $"path/to/my/model.mdl"

You can convert strings to assets with the ``StringToAsset`` method added by Northstar.

.. code-block::

  string s = format( "path/to/my/%s", "model.mdl" )
  asset m = StringToAsset( s )

.. _arrays_overview:

Arrays
------

Arrays can store large sets of data and are indexed using numbers, starting from 0, and are declared using ``array<type> arrayname`` the <type> identifier can be ignored but will result in the array being of the type ``var``.
  
.. code-block::

    array<int> numbers = [1,2,3,4,5,6,7,8,9,10]

    printt(numbers[0]) // 1
    printt(numbers[5]) // 6


adding and removing values from arrays can be done using ``.append(value)`` and ``.remove(index)``. 

additionally the index of values can be found using the ``.find()`` function and the length by using the ``.len()`` function:

.. code-block::

    array<int> numbers = [1,2,3,4,5,6,7,8,9,10]

    printt(numbers.find(3)) // 2
    printt(numbers[5]) // 6
    numbers.remove(5)
    printt(numbers[5]) // 7
    printt(numbers.len()) // 9
    array<int> empty = []
    empty.append(5)
    printt(empty[0]) // 5


Built in functions for arrays can be found `here <http://www.squirrel-lang.org/squirreldoc/reference/language/builtin_functions.html#id1>`_

Static Arrays
-------------

If you know the exact length of the array ahead of time, you can use static arrays. Static arrays are initialized with default values so you can access values without writing them.

The syntax for static arrays is ``type[size]``.

.. code-block::

  int[3] stArr
  printt( stArr[2] ) // note that this index isn't explicitly initialized

.. note::

  Static arrays don't have access to inbuilt functions of regular arrays.

.. _table_overview:

Tables
------
Tables are similar to arrays but with one primary difference, rather than use a numerical index system tables allow you do define your own indexes, similar to pythons ``dict`` type.
Creation of a table is done in a similar way to arrays, however may have 2 types declared for the type of the index and the type of the content, like arrays this will default to ``var`` if ignored

There are multiple ways to define a table with the ``[]`` when declaring a key you type a literal

.. code-block::

    table<string, int> numberofletters = {
      ["hello"] = 5,
      world = 5
    }

    table<int, int> numberSquared = {
      [2] = 4,
      [4] = 16
    }

unlike arrays however adding values to tables cannot be done using ``.append`` or similar means, as the index must also be declared, adding to tables is done using the ``<-`` operator like so.

.. code-block::

    table<entity, int> playerkills = {}
    foreach(entity player in GetPlayerArray())
        playerkills[player] <- 5

To read a value from a table you use the array syntax but instead of an index you write your key:

.. code-block::
    
    printt(playerKills[player]) // 5

To check if the table has a certain key, you can use the "in" keyword:

.. code-block::
    
    table<string, int> playerNames = {}
    if( "key" in playerNames ) 
    {
       //Do stuff
    }

The built in functions for arrays can be found `here <http://www.squirrel-lang.org/squirreldoc/reference/language/builtin_functions.html#table>`_

.. warning:: 

  The functions ``table.key()`` and ``table.value()`` are not available in rSquirrel, as an alternative you can use ``TableKeysToArray(table)``


Structs
--------
Structs are a way of storing multiple variables in one object. To create a struct type you just write:

.. code-block::

    struct ExampleStruct {}
    
Inside the brackets you can declare all the variables your struct should contain, you can also directly assign a standard value to a variable, if you dont override this value it will automatically be assigned.

.. code-block::
  
    struct ExampleStruct {
      int VariableInt
      string VariableString
      array<int> VariableArray
      int Optional = 1
      
      void functionref() ExampleVoidFuncton //you need to assign a function that returns nothing and takes no arguments
      string functionref(string) ExampleStringFunction //here you need to assign a function that returns a string and takes a string as an argument
    }
    
You then need to create instances of your struct to use it, like this:

.. code-block::
      
      //functions we need to assign, they are placeholders
      void function VoidFuntion(){
        //do smth
        return
      }
      void function StringFunction(string s){
        return s
      }

      ExampleStruct structOne = {
        VariableInt = 1,
        VariableString = "Hello World",
        VariableArray = [1,2,3],
        ExampleVoidFunction = VoidFunction,
        ExampleStringFunction = StringFuntion,
        ... 
      }
                                  
      ExampleStruct stuctTwo =  {
        VariableInt = 3,
        VariableString = "Hello Modders",
        VariableArray = [4,5,6],
        ExampleVoidFunction = VoidFunction,
        ExampleStringFunction = StringFuntion,
        Optional = 2
      }
      

For values that we do not declare like ``Optional`` in the case of ``structOne`` we just add a ``...`` as an argument.
Now that we have two instances we can get the values out of it like this:

.. code-block::

      printt(structOne.VariableInt) // 1
      printt(structOne.VariableString) // "Hello World"
      printt(stuctOne.Optional) // 1

      // here you can see that we did not specifically declare the variable but it still has a value that was assigned in the struct directly
      foreach(int a in structOne.VariableArray)
        printt(a)
        // 0: 1
        // 1: 2
        // 2: 3
      print(structOne.ExampleStringFunction("Hello")) // "Hello"
 
In struct one we have defined that ``ExampleStringFunction`` is assigned to ``StringFunction`` so we get the output if that function as a result.
      
We can do the same thing for ``structTwo``:

.. code-block::

      printt(structTwo.VariableInt)
      >> 2
      printt(structTwo.VariableString)
      >> Hello Modders
      printt(stuctTwo.Optional)
      >> 2
      // Now that we gave Optional a value the old one is overriten 
      foreach(int a in structTwo.VariableArray)
        printt(a)
      >>4
      >>5
      >>6
      printt(structTwo.ExampleStringFunction("Hello"))
      >>Hello
      //Since we gave it the same function the result is also the same

Now that we have a struct we can also pass it as an argument in functions or return the struct from a function:

.. code-block:: 

    ExampleStruct function ChangeTheStruct(ExampleStruct struct){
        if(struct.VariableInt == 1)
            return struct
        else{
          struct.VariableInt = 1        
        }
        return struct
        
    }

You can also nest structs like this:

.. code-block::

    struct NewStruct{
      Examplestruct CoolStruct
      int CoolVariable
    }
    NewStruct s = {
      CoolStruct = structOne,
      CoolVariable = 1
    }
    //we now have a struct inside a struct
    printt(s.CoolStruct.VariableInt)
    >>1
    
    
``CoolStruct`` has the value of ``structOne`` we defined above thus the value output is the value from ``structOne.VariableInt``.

In the same way you can also use it as a type for arrays or tables:

.. code-block:: 

    array<ExampleStruct> StructArray = []
    StructArray.append( structOne )
    printt(StructArray[0].VariableInt)
    >>1
    
    table<ExampleStruct, bool> StuctTable= {structOne: false}
    printt(StuctTable[stuctOne])
    >>false
    
Alternatively you can define a struct and directly have it as an instance, the difference is that you can not create multiple strcuts of this type.
This might be particularly useful when you want to share multiple variables at once between multiple files.
You create one just like a regular struct, but the name is behind the closing bracket, like this:

.. code-block::

    struct {
      int CoolInt
      string CoolString
    } file
    
Now you do not need to create an instance to give the struct a value:

.. code-block::

    file.CoolInt = 5
    printt(file.CoolInt)
    >>5

When interacting with this type of struct the same rules apply as for the regular struct.


Complex types can also all be nested.


Vectors
--------

Vectors are a type that store three floats in one object. They are declared using the ``< >`` operators. The values are seperated with a ``,``.
Here the first number represents the X, the 2nd the Y, and the 3rd the Z coordinate.

.. code-block::

  vector myFirstVector = <0, 120, 40>
  

We can then get the coordinates out of the vector with:

.. code-block::

  float x = myFirstVector.x
  float y = myFirstVector.y 
  float z = myFirstVector.z 

Entities
------

Entities are objects thats the interacts with. These includ players, NPCs, Guns etc.

There are a variety of fucntions to create an entity, there is no standard format for all of them.

Most in game entities inherit from the ``CBaseEntity`` or ``C_BaseEntity`` class respectively. Read more about them here: :doc:`../../reference/respawn/entities`

A fast way to create an entity is to use:


.. code-block::
  
  entity myFisrtNPC = CreateNPC( NpcName, team, origin, angles )
  
However there are a lot more functions to create entities, a lot of them are very specific, here it is useful to look at reference code.

By default an entity can be of value ``null`` and does not need to be ``ornull`` casted

.. _functionref_overview:

Functionrefs
-----------

You can declare a function as a variable, this is especially useful in function arguments.

You declare a functionref with the return type, the ``functionref`` key word, the arugment types and the variable name.

That variable will be of type ``functionref``

.. code-block::

  void functionref(string) MyReference = void function(string str){ /* your code could be here */}


You can then just call the fucntion by its functionref name.

.. code-block::

  void CallFunction(void functionref(string) func ){
    func("hello")
  }

ornull
------

To declare a type to contain a value or ``null``, declare the variable like this: ``type ornull identifier``.

.. code-block::
  
  int ornull number = CoinFlip() ? null : 0
  if( number == null )
    return
  expect int( number ) // cast `number` to an integer since it can now never be null
  
typedef
-----

To alias a type, use ``typedef``. Typedefs can optionally be global as well

.. code-block::
  
  global typedef DontDoThis var
  typedef crazyArray array<MyStruct[1]>[2] ornull
