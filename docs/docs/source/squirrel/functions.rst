Functions
=========

The vast majority of GNUT modding within northstar will be done through functions, so understanding the syntax of functions is important.

Declaring Functions
-------------------

Functions in squirrel are first defined by stating the **return type** (output) followed by the keyword **function**. For example, if you wanted to define a function that returns TRUE or FALSE you would type:

.. code-block:: javascript

  bool function ReturnTrueOrFalse()
  {
    return bool( RandomInt( 2 ) ) // generate a number from 0 - 1
  }

It is not possible to override a function with different parameters or return types. Every function needs a unique name from every function in the same script and every global function or variable.

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
-------------------

Optional parameters aren't required to call the function and will be assigned a default value if nothing was passed.

To make a parameter optional, add a default after the parameter

.. code-block:: javascript

  void function OptionalExample( string msg = "default parameter", optional2 = 1 )
  {
    printt( msg )
  }

  OptionalExample( "passed parameter" ) // prints: "passed parameter"
  OptionalExample() // prints "default parameter"

Optional parameters must be declared after all required parameters.

Passing Functions as parameters
-------------------------------

If you want to pass a function as a parameter to another function, for example as a callback set their type as ``functionref( [parameters] )``.

.. code-block:: javascript

  void function FnLiteral( int req, int opt = 2 )
  {
    printt( req + opt )
  }

  void function CallLiteral( functionref( int, int ) literal )
  {
    literal( RandomInt( 5 ) )
  }

  CallLiteral( FnLiteral )

Calling Functions
-----------------

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
-------------------

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
----------------

It's not possible to use locals from a parent function, but it is possible to capture them in an anonymous functions. 

.. code-block:: javascript

  void function ParentFunc()
  {
    var capture = Hud_GetChild( GetMenu( "ModListMenu" ), "MouseMovementCapture" )
    AddMouseMovementCaptureHandler( capture, void function( int x, int y ) : ( capture ) { print( format( "registered mouse input from capture %s in x: %i; y: %i", capture.tostring(), x, y ) ) } )
  }

