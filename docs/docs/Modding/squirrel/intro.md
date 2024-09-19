# Introduction

[Squirrel](http://squirrel-lang.org/) is a high level imperative, object-oriented programming language used in Titanfall to script large amounts of content in the game.

Respawn modified large parts of the language to fit their needs, for example adding a static type compiler to the language.

Squirrel still allows you to write dynamically typed code but this is discouraged if possible.

The syntax of squirrel is very similar to C++ or Javascript and very easy to learn.

The programmer doesn't need to think about memory management in scripts since all objects are refcounted and the garbage collector can be invoked manually.

```squirrel

   int function fibonacci( int n )
   {
    if ( n < 2 )
      return n

    return fibonacci( n - 1 ) + fibonacci( n - 2 )
   }
```

The language provides easy interfaces for coroutines and asynchronous code.

```squirrel

   void main()
   {
    thread timer( 1.0, timercallback )
   }

   void function timercallback( int iteration )
   {
    print( iteration )
   }

   // call the callback function every n seconds
   void function timer( float n, void functionref( int ) callback )
   {
    int iterations
    while ( true )
    {
      wait n
      iterations += 1
      callback( iterations )
    }
   }
```

Signals and Flags allow you to control code execution based on events that happen elsewhere in the code or in the ingame world.

```squirrel

   void main()
   {
    AddCallback_OnPlayerRespawned( OnPlayerRespawned )
   }

   void function OnPlayerRespawned( entity player )
   {
    thread CountPlayerTimeAlive( Time() ) // execute this function as threaded so we can use Signals in there
   }

   void function CountPlayerTimeAlive( entity player, float time )
   {
    player.WaitSignal( "OnDestroy" ) // wait until the player dies or disconnects
    print( Time() - time ) // print how long the player was alive
   }
```
