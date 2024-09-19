# Structs

Structs are statically typed, fixed size structures that contain other values. Similar to tables they are used to store mutliple values, however structs allow for each value to have a seperate type.

## Declaration

Before using a struct you need to define it and all contents.

The fields are typed like any regular variable.

```squirrel

   struct MyStruct
   {
    int field1
    string field2
    array<float> field3
   }
```

You can then use `MyStruct` as a type anywhere in the file.
Structs are default initialized by assigning each field it's appropriate default value.
Struct fields can be indexed by writing `instance.field`, just like with tables.

```squirrel

  MyStruct myStructInstance
  printt( myStructInstance.field1 ) // 0
```

Structs are passed by reference so if a function changes a field that field is changed for everything that uses the struct instance.

Struct instances can also get initiaized with different default values if required.

Similar like in static arrays, you can omit any fields that should have their type's default value with `...`.

```squirrel

   MyStruct ins = { field3 = [], field1 = 1, ... }
   printt( ins.field1, ins.field2 ) // 1, ""
```

## Nesting Structs

Struct fields can be any type, this includes previously declared structs as well.

```squirrel

   struct Engine
   {
    string manufacturer
   }

   struct Tire
   {
    string material
   }

   struct Car
   {
    Engine engine,
    Tire[4] tires
   }
```

### Self Nesting Structs

Structs can contain fields of their own type, however they need to be **null initialized**. You can achieve this by specifying their type as `ornull`.

```squirrel

   struct LinkedList
   {
    var content
    LinkedList ornull nextNode
   }
```

## Field Default Values

Any struct field can have an optional default value. If omitted, the type's default value is used instead.

Default values need to be a constant expression that can be evaluated at compile time.

```squirrel

   struct Dice
   {
    int[6] sides = [ 1, 2, 3, 4, 5, 6 ]
   }
```

## Singleton Instances

You can define a struct and initialize a local variable of that struct instantly with singletons. These are often used to have global variables that are only used in a single script file.

```squirrel

   struct {
    var menu
   } file

   void function InitMyMenu()
   {
    file.menu = GetMenu( "SomeMenu" )
   }
```

Singletons can also be used for struct fields.

```squirrel

   struct Car
   {
    struct {
      string manufacturer
      } engine
   }

   // ...
   Car car
   car.engine.manufacturer = "Vinson Dynamics"
```
