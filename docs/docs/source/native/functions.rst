Functions
=========

The vast majority of GNUT modding within northstar will be done through functions, so understanding the formatting of functions is important.

Declaring Functions
--------------------
Functions in squirrel are first defined by stating the **output** followed by the keyword **function**. For example, if you wanted to define a function that returns TRUE or FALSE you would type:

.. code-block:: javascript

  bool function ReturnTrueOrFalse()


But what if I want my function not to give stuff, but only DO stuff? For that you can define your function as ``void``, this indicates that your function does not return anything. For example:

.. code-block:: javascript

  void function ThisDoesStuff()


If statements
---------------
If statements use a similar style to most programming languages and will execute their asigned code if the test placed inside returns the boolean value true. If I wanted to have something occur if, and only if, our previous ``ReturnTrueOrFalse`` function returned true, then you can use:

.. code-block:: javascript

  if(ReturnTrueOrFalse())

Conditional operators can also be used to make comparisons, such as ``==`` (equals), ``<`` (less than), ``<=`` (less than or equal), ``!=`` (not equal), etc., returning true if their condition is satisfied. For example, to execute code if a dice roll landed on 5:

.. code-block:: javascript

  if(RandomInt(6)+1 == 5)
  
Like other languages, if statements can be connected to ``else if`` and ``else`` statements. ``else if`` statements must be used immediately after an ``if`` or ``else if`` and will only check their condition if the preceding statements failed. ``else`` statements behave similarly, but always run if the preceding statements failed and must be last.

Loops
------
There are three primary loops: ``while``, ``for``, and ``foreach``. ``while`` loops are similar to ``if`` statements, but repeat endlessly so long as the test remains true:

.. code-block:: javascript

  while(ReturnTrueOrFalse())

This script will repeat endlessly until ``ReturnTrueOrFalse`` returns false.

``for`` loops are similar to ``while`` loops, but also run code once at the start and after every loop. These are primarily used to loop a specific number of times, such as over the length of a list:

.. code-block:: javascript
  
  array<int> somelist = [0, 5, 6, 4, 11]
  for(int i = 0; i < somelist.len(); i++)
  
``int i = 0`` runs immediately; ``i < somelist.len()`` is the test for the loop, only executing the loop if it is true; ``i++`` runs after every loop iteration.

``foreach`` loops only loop over a set of data, such as a list or table, and will execute for each entry. They don't loop in any order and data should not be added or removed from the set during the loop:

.. code-block:: javascript

  foreach( number in somelist)

Implicit conditional behavior
-----------------
Conditional statements, such as while loops and if statements, also implictly cast non-boolean inputs to booleans. For numbers, this means 0 is considered false and anything else is considered true. For instance variables like arrays and entities, ``null`` is considered false and anything else is considered true. For example, these inputs are considered true by the if statements:

.. code-block:: javascript
  
  if(2)
  
.. code-block:: javascript
  
  array somelist = [0, 1]
  if(somelist)
  
Be aware that empty arrays and strings, ``[]`` and ``""``, are considered true by this logic.

Formatting of actions
---------------------
So great, we can loop and check things, but what can we do with this information? Squirrel uses ``{}`` to denote the contents of a series of actions caused by such a statement.

For example, lets make our ``ReturnTrueOrFalse`` function, that randomly picks either true or false, first:

.. code-block:: javascript

  bool function ReturnTrueOrFalse() {
    return RandomInt(2) == 1
  }

Note that while functions always need ``{}``, single-line ``if``/``else`` statements and loops do not:


.. code-block:: javascript

  if(ReturnTrueOrFalse())
    print("Only called if true")

Now let's make a more complicated function that will use the previous script to determine true or false, printing a list each time it returns true:

.. code-block:: javascript

  array<int> someinformation = [1,2,3,4,5,6]
  void function ThisDoesStuff(){
    while(ReturnTrueOrFalse()){
      foreach( int information in someinformation){
        print(information)
      }
    }
  }

