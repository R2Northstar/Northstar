# Functions & Closures

Functions are an integral part of any programming language. They allow to repeat blocks of code whenever and however often is needed.

## Declaring Functions

Functions in squirrel are defined with this syntax: `<return type> function <name>(<parameters>) <body>`

For example, a simple function that returns either `true` or `false` would look like this:

```squirrel
  bool function CoinFlip()
  {
    return RandomInt( 2 ) == 0 // generate a random number from 0 - 1
  }
```

It is not possible to have multiple functions that share the same name (often called "overriding" functions). Every function needs to have an unique name from any global or local variable or function.

## Returning Data

If you need some data after a function is finished (for example after a calculation), you need to return that data.

You can return anything, however the type of the returned variable needs to match with the return type of the function.

```squirrel
   string function GetNorthstarName()
   {
    return "Northstar" // this would be valid
    return 1 // this would be invalid because the function needs to return a string
   }
```

Keep in mind that no code after a return statement will get executed.

If you don't want to return any value, use `void` as the return type. This indicates that your function returns `null`.

If nothing is returned by a function, `null` will get returned implicitly.

```squirrel
  void function ReturnNull()
  {
    // return null regardless what happens, this all does the same
    switch( RandomInt( 3 ) )
    {
      case 0:
        return
      case 1:
        return null
    }

    // only if a 2 was rolled, code here will be executed before the other paths already returned.
    // because a return statement is lacking, null is getting returned implicitly.
  }
```

In `untyped` files you may leave out the return type. In those cases the return type will default to `var`.

## Parameters

Parameters are the input a function gets when called. They are local variables whose values come from the calling function.

```squirrel
   void function main()
   {
    int refcount = 0
    refcount = IncreaseRefcount( refcount )
    Assert( refcount == 1 )
   }

   int function IncreaseRefcount( int n )
   {
    return n + 1
   }
```

## Optional parameters

Sometimes you need parameters that are optional for a function, like extra options. If a parameter name is followed by `= <default-value>`, that parameter is not required to call the function.

Optional parameters need to be the last parameters of a function.

```squirrel
   void function main()
   {
    array a = [ 1, 2, 3, 4 ]
    PopN( a )
    PopN( a, 2 )

    Assert( a.len() == 1 )
   }

   void function PopN( array arr, int n = 1 )
   {
    for ( int i; i < n; i++ )
    {
      arr.pop()
    }
   }
```

## vargs

With vargs you can pass a function an unlimited amount of parameters. The parameters will be inside a pseudo array called `vargv`. The length of the vargs the function receives will be stored inside a variable called `vargc`.

You can denote a function to have vargs with adding `...` to the end of the parameter list.

```squirrel
   string function CombineStuff( string base, ... )
   {
    string s = base
    for ( int i; i < argc; i++ )
    {
      base += vargv[i].tostring()
    }
   }
```

## Closures

Closures are functions that are anonymous (unnamed) functions created in a specific script context that can use variables from the parent scope.

```squirrel
   void function main()
   {
    void functionref() fn = void function(){ print( "I'm a closure" ) } // create a closure
    fn() // call the closure
   }
```

Closures can capture variables from their parent scope.

```squirrel
   void function PlayFXOnEntity( entity ent )
   {
      int fxHandle = StartParticleEffectOnEntity( ent, PILOT_THROWN_TICK_WARNING, FX_ATTACH_POINT_FOLLOW, ent.LookupAttachment( "head_base" )
      OnThreadEnd( void function() : ( fxHandle ){ EffectStop( fxHandle, false, true ) } ) // create a function to stop the fx effect and give it the fx handle it needs
      ent.EndSignal( "OnDestroy" ) // stop the thread when the entity dies
      WaitForever()
   }
```
