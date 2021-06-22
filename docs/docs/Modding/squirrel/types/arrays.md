# Arrays

Unlike the data types previously covered, arrays can hold multiple values.

Their size is dynamic and you can add and remove elements at will.

The type keyword is `array`.

By default, uninitialized arrays are empty.

Arrays are always zero indexed with `[ <expression> ]`. The indexes are always numbers. If you index an array with a key that does not exist, an error will get thrown.

## Literals

Array literals are a comma or newline seperated sequence of expressions delimited by an opening bracket `[` and a corresponding closing bracket `]`.

```squirrel
array a = [ 1, 2, 3 ]
array b = [
    1
    2
    3
]
```

## Primitive Arrays

Primitive arrays are arrays that can hold any value. Their content is therefore untyped.

```squirrel
array a
a.append( 1 ) // add a number
a.append( "str" ) // add a string
a.append( [] ) // add an empty array

// because the content type of the array is not defined, all content will be var
var n = a[0]
var str = a[1]
var arr = a[2]
```

## Complex Arrays

Complex Arrays are arrays that can only hold values that have a specific type.

The content type needs to be specified within `<` and `>` brackets.

There is no way to define a complex array that holds multiple different types.

```squirrel
array<int> a
a.append( 1 )
a.append( 0x2 )
a.append( "3" ) // this will throw a compile error because the array can only contain integers
```


## Static Arrays

Static arrays are a different kind of complex type. Like complex arrays they can only hold values of one specific type. However unlike complex arrays static arrays have a set length that cannot be changed.

The typing for static arrays is `type[size]`, where `type` is the content type of the array and `size` is an **integer literal** of the total size of the array.

Uninitialized static arrays have their size by default and all content values are the **default values of their content type**.

You can index and change content values like with regular arrays.

When initializing a static array you can omit all values after your initial values with `...`. All following values will get default initialized with the content's default.

```squirrel
float[3] v1
float[8] v2 = [ 1.0, 2.0, ... ]
v2[2] = 3.0

print( v1[0] ) // notice how no value needs to be pushed into the vector
print( v2[7] ) // will print 0.0 because it has been default initialized
```

## Compatability

It is not possible to cast or convert an array between their different forms. For example you can't assign an `array<string>` variable to a different variable that has the type `array` or the other way around.

Instead you need to create an entirely new array with the target type or add all contents manually.

```squirrel
array<string> orig = [ "a", "b", "c" ]
array target

target.clear() // clear all contents from the target array
foreach( v in orig ) // iterate over the original array and add all contents to the target array
    target.append( v )
```

Furthermore it's important to understand that `array` and `array<var>` behave the same but **are not identical**.
