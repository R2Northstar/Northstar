Tables, Arrays and storing values
=================================

Within squirrel there are many ways to store information, but when storing an unspecified ammount of information, or storing information on a player-by-player basis, you need to use ``arrays`` or ``tables``.

Arrays
------

Arrays can store large sets of data and are indexed using numbers, starting from 0, and are declared using ``array<type> arrayname`` the <type> identifier can be ignored but will result in the array being of the type ``var``.
  
.. code-block:: cpp

    array<int> numbers = [1,2,3,4,5,6,7,8,9,10]

    print(numbers[0])
    >>1
    print(numbers[5])
    >>6


adding and removing values from arrays can be done using ``.append(value)`` and ``.remove(index)``. 

additionally the index of values can be found using the ``.find`` function and the length by using the ``.len()`` function

.. code-block:: cpp

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

.. code-block:: cpp

    table<string, int> numberofletters = {"hello": 5}

unlike arrays however adding values to tables cannot be done using ``.append`` or similar means, as the index must also be declared, adding to tables is done using the ``<-`` operator like so.

.. code-block:: cpp

    table<entity, int> playerkills = {}
    foreach(entity player in GetPlayerArray())
        playerkills[player] <- 5


2D arrays and Tables of Arrays
------------------------------
Another attribute of tables and arrays is that they can store any value type, including tables and arrays themselves. this can be used to store an array within a table, useful if you want to store multiple values related to each index in a single variable

to create a 2d array you simply define the data type as beign an array of arrays like so.

.. code-block:: cpp

    array<array<int>> 2darray = [[1,2,3],[4,5,6],[7,8,9]]
    print(2darray[1][1])
    >>5
