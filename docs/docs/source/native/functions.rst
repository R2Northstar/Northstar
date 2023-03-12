Functions
=========

The vast majority of GNUT modding within northstar will be done through functions, so understanding the formatting of functions is important.

Declaring Functions
--------------------

Functions in squirrel are first defined by stating the **output** followed by the keyword **function**. For example, if you wanted to define a function that returns TRUE or FALSE you would type:

It is not possible to override a function with different parameters or return types. Every function needs a unique name from every function in the same script and every global function or variable.

.. code-block:: javascript

  bool function ReturnTrueOrFalse()
  {
    return bool( RandomInt( 2 ) )
  }


If you don't want to return anything, use ``void`` as the return type. This indicates that your function returns ``null``.

If a function is lacking a ``return`` statement or a return value, it will return ``null``. For example:

.. code-block:: javascript

  void function ThisDoesStuff()
  {
    switch( RandomInt( 3 ) )
    {
      case 0:
        return
      case 1:
        return null
      case 2:
        break
    }
    // only if a 2 was rolled, code here will be executed.
    // because the function ends without a return statement, null is getting returned implicitly 
  }

Optional Parameters
-----

Optional parameters aren't required to call the function and will be assigned a default value if nothing was passed.

To make a parameter optional, add a default after the parameter

.. code-block:: javascript

  void function OptionalExample( string msg = "default parameter", optional2 = 1 )
  {
    printt( msg )
  }

  OptionalExample( "passed parameter" ) // passed parameter
  OptionalExample() // default parameter

Optional parameters must be declared after all required parameters.

Passing Functions as parameters
-----

If you want to pass a function as a parameter to another function, for example as a callback set their type as ``functionref( [parameters] )``.

.. code-block:: javascript

  void function FnLiteral( int req, int opt = 2 )
  {
    print( req + opt )
  }

  void function CallLiteral( functionref( int, int ) literal )
  {
    literal( RandomInt( 5 ) )
  }

  CallLiteral( FnLiteral )

Calling Functions
-----

You can call functions with opening and closing brackets containing all parameters or with the call function.

You can also call functions with an array of parameters

.. code-block:: javascript

  void function FnLiteral( int opt = 2, int opt2 = 2 )
  {
    print( opt + opt2 )
  }

  FnLiteral() // 4
  FnLiteral( 1, 2 ) // 3
  FnLiteral.call( 3, 4 ) // 7

  array<int> args = [ 6, 7 ]
  FnLiteral.acall( args ) // 13

Implicit parameters
-----

If you don't know how many parameters you get at compile time, you can use implicit parameters.

.. code-block:: javascript

  void function XParameters( string required, string optional = "", ... )
  {
    for( int i; i < vargc, i++)
    {
      var parameter = vargv[i]
      print( parameter )
    }
  }

  XParameters( "req", "optional", 1, 2, [ 3, 4, 5 ], { tableKey = "string" } ) // prints 1, 2, [array instance], [table instance]
  XParameters( "req", "opt" )

Implicit Capture
-----

It's not possible to use locals from a parent function, but it is possible to capture them in anonymous functions. 

.. code-block:: javascript

  void function ParentFunc()
  {
    var capture = Hud_GetChild( GetMenu( "ModListMenu" ), "MouseMovementCapture" )
    AddMouseMovementCaptureHandler( capture, void function( int x, int y ) : ( capture ) { print( format( "registered mouse input from capture %s in x: %i; y: %i", capture.tostring(), x, y ) ) } )
  }

Statements
====

If statements
---------------

If statements use a similar style to most programming languages and will execute their asigned code if the test placed inside returns the boolean value true. If I wanted to have something occur if, and only if, our previous ``ReturnTrueOrFalse`` function returned true, then you can use:

.. code-block:: javascript

  if( ReturnTrueOrFalse() )

Conditional operators can also be used to make comparisons, such as ``==`` (equals), ``<`` (less than), ``<=`` (less than or equal), ``!=`` (not equal), etc., returning true if their condition is satisfied. For example, to execute code if a dice roll landed on 5:

.. code-block:: javascript

  if( RandomInt( 6 ) + 1 == 5 )

Like other languages, if statements can be connected to ``else if`` and ``else`` statements. ``else if`` statements must be used immediately after an ``if`` or ``else if`` and will only check their condition if the preceding statements failed. ``else`` statements behave similarly, but always run if the preceding statements failed and must be last.

Squirrel supports ternary operations like most languages. The value of the expression depends if a condition is truthy or not. However, if not used carefully this can worsen readability.
The Syntax is ``condition ? if_condition_true : if_condition_false``. This is especially useful when declaring variables or passing parameters.

.. code-block:: javascript

  // shortenedUsername is "longus..."" if username is "longusername" or "short" if username is "short"
  string shortenedUsername = username.len() > 9 ? username.slice(0,6) + "..." : username;

Loops
------

Loops are used to execute the same code n times.

While Loops
~~~~

A while loop runs as long as the condition evaluates to a truthy value.

.. code-block:: javascript

  while( true )
  {
    // this will result in an endless loop because the probe condition will never be false 
  }

  while( RandomInt( 2 ) )
  {
    // This will run until a 1 is generated by chance, because squirrel treats 0 as a falsy value and 1 as truthy.
  }

Do While Loop
~~~~

A do while loop is the same as a while loop but the condition is checked **after** the body is executed.

.. code-block:: javascript

  do
  {
    // this will execute only one time
  } while( false )

For Loop
~~~~

A for loop also runs until a condition is met however it provides you with a counter variable.

The Syntax is as follows: ``for( int counter; condition; behaviour_after_body_execution )``

.. code-block:: javascript

  // prints 0, 1, 2, 3, 4
  for( int i; i < 5; i++ )
  {
    print( i )
  }

  array<int> arr = [ 14, 2, 18, 9 ]
  // prints 14, 2, 18, 9
  for( int i; i < arr.len() * 2; i += 2 )
  {
    print( arr[i] )
  }

Foreach Loop
~~~~

A foreach loop iterates over a ``table`` or an ``array`` and executes for each entry. The loop provides you with an optional counter for arrays or key for tables.

.. code-block:: javascript

  array<int> arr = [ 1, 2, 3, 4 ]
  table<string, string> map = {
    key1 = "mapped value 1",
    key2 = "mapped value 2"
  }

  // prints 0 1, 1 2, 2 3, 3 4
  foreach( int index, int value in arr )
  {
    printt( index, value )
  }

  // prints key1 mapped value 1, key2 mapped value 2
  foreach( string key, string value in map )
  {
    printt( key, value )
  }

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
    printt("Only called if true")

Now let's make a more complicated function that will use the previous script to determine true or false, printing a list each time it returns true:

.. code-block:: javascript

  array<int> someinformation = [1,2,3,4,5,6]
  void function ThisDoesStuff(){
    while(ReturnTrueOrFalse()){
      foreach( int information in someinformation){
        printt(information)
      }
    }
  }

