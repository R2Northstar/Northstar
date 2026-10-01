# Vectors

Vectors are a primitive data type to describe velocities or positions of objects in the game.

Usually the positions are absolute in the game world, but that may depend on the function.

Vectors store 3 float values that can be accessed with the `x`, `y` and `z` keys.

## Literals

A vector literal is a comma seperated list of expressions that evaluate to either a **float** or **integer** delimited by `<` and `>` brackets.

```squirrel
   vector v = < 1, 2.5, 3 >
   v.y = 2
   printt( v.x, v.y, v.z ) // 1 2 3
```
