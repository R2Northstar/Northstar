Tables, Arrays, Structs and storing values
=================================

Within squirrel there are many ways to store information, but when storing an unspecified amount of information, or storing information on a player-by-player basis, you need to use ``arrays`` or ``tables``.

Arrays
------

Arrays can store large sets of data and are indexed using numbers, starting from 0, and are declared using ``array<type> arrayname`` the <type> identifier can be ignored but will result in the array being of the type ``var``.
  
.. code-block:: javascript

    array<int> numbers = [1,2,3,4,5,6,7,8,9,10]

    print(numbers[0])
    >>1
    print(numbers[5])
    >>6


adding and removing values from arrays can be done using ``.append(value)`` and ``.remove(index)``. 

additionally the index of values can be found using the ``.find`` function and the length by using the ``.len()`` function:

.. code-block:: javascript

    array<int> numbers = [1,2,3,4,5,6,7,8,9,10]

    print(numbers.find(3))
    >>2
    print(numbers[5])
    >>6
    numbers.remove(5)
    print(numbers[5])
    >>7
    print(numbers.len())
    >>9
    array<int> empty = []
    empty.append(5)
    print(empty[0])
    >>5


Tables
------
Tables are similar to arrays but with one primary difference, rather than use a numerical index system tables allow you do define your own indexes, similar to pythons ``dict`` type.
Creation of a table is done in a similar way to arrays, however may have 2 types declared for the type of the index and the type of the content, much like arrays this will default to ``var`` if ignored

.. code-block:: javascript

    table<string, int> numberofletters = {"hello": 5}

unlike arrays however adding values to tables cannot be done using ``.append`` or similar means, as the index must also be declared, adding to tables is done using the ``<-`` operator like so.

.. code-block:: javascript

    table<entity, int> playerkills = {}
    foreach(entity player in GetPlayerArray())
        playerkills[player] <- 5


2D arrays and Tables of Arrays
------------------------------
Another attribute of tables and arrays is that they can store any value type, including tables and arrays themselves. this can be used to store an array within a table, useful if you want to store multiple values related to each index in a single variable

to create a 2d array you simply define the data type as beign an array of arrays like so.

.. code-block:: javascript

    array<array<int>> 2darray = [[1,2,3],[4,5,6],[7,8,9]]
    print(2darray[1][1])
    >>5
Structs
--------
Structs are a way of storing multiple variables in one object. To create a struct you just write:

.. code-block:: javascript

    struct ExampleStruct {}
    
Inside the brackets you can declare all the variables your struct should contain, you can also directly assign a standard value to a variable, if you dont override this value it will automatically be assigned.

You can not only pass variables but also functions with:``*return type* functionref(*argument type*) *Name in the struct*``.

.. code-block:: javascript
  
    struct ExampleStruct {
      int VariableInt
      string VariableString
      array<int> VariableArray
      int Optional = 1
      
      void functionref() ExampleVoidFuncton //you need to assign a function that returns nothing and takes no arguments
      string functionref(string) ExampleStringFunction //here you need to assign a function that returns a string and takes a string as an argument
    }
    
You then need to create instances of your struct to use it, like this:

.. code-block:: javascript
      
      //functions we need to assign, they are placeholders
      void function VoidFuntion(){
        //do sth
        return
      }
      void function StringFunction(string s){
        return s
      }

      ExampleStruct structOne = {VariableInt = 1, VariableString = "Hello World", VariableArray = [1,2,3],
                                  ExampleVoidFunction = VoidFunction, ExampleStringFunction = StringFuntion, ... }
                                  
      ExampleStruct stuctTwo =  {VariableInt = 3, VariableString = "Hello Modders", VariableArray = [4,5,6],
                                  ExampleVoidFunction = VoidFunction, ExampleStringFunction = StringFuntion, Optional = 2}
      

For values that we do not declare like ``Optional`` in the case of ``structOne`` we just add a ``...`` as an argument.
Now that we have two instances we can get the values out of it like this:

.. code-block:: javascript

      print(structOne.VariableInt)
      >> 1
      print(structOne.VariableString)
      >> Hello World
      print(stuctOne.Optional)
      >> 1
      // here you can see that we did not specifically declare the variable but it still has a value that was assigned in the struct directly
      foreach(int a in structOne.VariableArray)
        print(a)
      >>1
      >>2
      >>3
      print(structOne.ExampleStringFunction("Hello"))
      >>Hello
 
In struct one we have defined that ``ExampleStringFunction`` is assigned to ``StringFunction`` so we get the output if that function as a result.
      
We can do the same thing for ``structTwo``:


.. code-block:: javascript

      print(structTwo.VariableInt)
      >> 2
      print(structTwo.VariableString)
      >> Hello Modders
      print(stuctTwo.Optional)
      >> 2
      // Now that we gave Optional a value the old one is overriten 
      foreach(int a in structTwo.VariableArray)
        print(a)
      >>4
      >>5
      >>6
      print(structTwo.ExampleStringFunction("Hello"))
      >>Hello
      //Since we gave it the same function the result is also the same

Now that we have a struct we can also pass it as an argument in functions or return the struct from a function:

.. code-block:: javascript 

    ExampleStruct function ChangeTheStruct(ExampleStruct struct){
        if(struct.VariableInt == 1)
            return struct
        else{
          struct.VariableInt = 1        
        }
        return struct
        
    }

You can also nest structs like this:

.. code-block:: javascript

    struct NewStruct{
      Examplestruct CoolStruct
      int CoolVariable
    }
    NewStruct s = { CoolStruct = structOne, CoolVariable = 1}
    //we now have a struct inside a struct
    print(s.CoolStruct.VariableInt)
    >>1
    
    
``CoolStruct`` has the value of ``structOne`` we defined above thus the value output is the value from ``structOne.VariableInt``.

In the same way you can also use it as a type for arrays or tables:

.. code-block:: javascript 

    array<ExampleStruct> StructArray = []
    StructArray.append( structOne )
    print(StructArray[0].VariableInt)
    >>1
    
    table<ExampleStruct, bool> StuctTable= {structOne: false}
    print(StuctTable[stuctOne])
    >>false
    
Alternatively you can define a struct and directly have it as an instance, the difference is that you can not create multiple strcuts of this type.
This might be particularly useful when you want to share multiple variables at once between multiple files.
You create one just like a regular struct, but the name is behind the closing bracket, like this:

.. code-block:: javascript

    struct {
      int CoolInt
      string CoolString
    } file
    
Now you do not need to create an instance to give the struct a value:

.. code-block:: javascript

    file.CoolInt = 5
    print(file.CoolInt)
    >>5

When interacting with this type of struct the same rules apply as for the regular struct.

Global variables and fucntions
-------

Often when creating a mod you need to access a ``variable`` or a ``function`` from another file, this can be achieved by using the ``global`` keyword.
Global variables are just like regular variables and are declared the same way just with the keyword ``global`` in front of it.
However they need to be declared at the very beginning of the file, but only in one file. NOT in all of them.

.. code-block:: javascript

    global int GlobalInt 
    global array<int> GlobalArray
    global function GlobalFunction //here you only need to give the function name not return type or arguments
    
    //ofc you can also directly give global variables a value
    global string GlobalString = "This is a global message"
    
Now you are able to use ``GlobalInt``, ``GlobalArray``, ``GlobalFunction`` and ``GlobalString`` in all your files.
When using this make sure you do not accidentally make a new variable with the same name and type as a global variable as this will likely brake your code
