# ornull

`ornull` is a type suffix that flags the variable to be able to contain `null`.
This is required for nesting structs inside themselves to ensure they are fixed size.

`ornull` makes any type complex and stops you from using any inbuilt functions or passing it to a function that does not expect that exact `ornull` type.

To use the value of an `ornull` variable you need to ensure that it is not `null` and then cast to the correct type.

```squirrel
   int ornull n = null
   n = 1

   if( n != null )
   {
    expect int( n ) // n is now in this scope an int
    n += 2
   }

   print( n ) // 3
```

Being required to cast the value of `ornull` variables makes it impossible to use it with types that cannot be casted like complex arrays. You can still make complex ornull variables, just be aware that the content type can never be recasted.

You can use `ornull` types in complex type as well, for example in complex arrays.

```squirrel
   array<int ornull> a = [ 1, null ]
   a.append( 2 )
   a.append( null )
```

Additionally, `ornull` is useful for adding optional parameters to functions that need to preserve backwards compatability.

```squirrel
   SomeAPIFunction( int ornull n = null ) {}

   // both are valid
   SomeAPIFunction()
   SomeAPIFunction( 1 )
```

## Default Values

`ornull`-ing a type will make a variable always default initia will make a variable always default initialize with `null` instead of the types respective default value.lize with `null` instead of the types respective default value.
