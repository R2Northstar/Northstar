# Classes

!!! note

    The version Respawn is using differs in some places from classes that are in use in
    Squirrel 3.x

    This is by no means complete. Please add anything you know.

## Declaring Classes

To declare a class, first add the `untyped` keyword and the class as a variable at
file level.

```squirrel
untyped
var ExampleClass
```

The `untyped` declaration is required because instances have an unknown type and it's
not possible to use classes as types.

`var [classname]` represents the class. After declaring the class inside of a function
you can use it in the script. You can use any type that can hold vars to store classes.
Refer to [Namespaces](#namespaces) for more info.

If needed, add the global keyword for the variable to make the class usable everywhere
in the vm.

It's not possible to declare classes on local variables. It's required to declare the
class inside of a function.

Most classes use a constructor. A constructor is a function of the instance that gets
executed on object creation.

```squirrel
void function initClient() {
    class ExampleClass {
        constructor(){print("Instance of ExampleClass created");}
    }
}
```

You can require parameters in the constructor. Keep in mind that you have to pass those
when creating an object.

Function parameters are passed as type `var`, but the type keyword is not required.
`constructor( parameter ){}; func( parameter ){};` and `constructor( var parameter
){}; func( var parameter ){};` are both correct.

```squirrel
class ExampleClass {
        propertyString = null // Actual type is var
        propertyInt = null // Actual type is var
        constructor( var pString, var pInt ) {
            this.propertyString = expect string(pString);
            this.propertyInt = expect int(pInt);
        }
}

// See section "Declaring Objects" for more information on object creation
var obj = ExampleClass( "foo", 1 );
printt(obj.propertyString, obj.propertyString ) // foo, 1
var lObj = ExampleClass(); tObj = ExampleClass( "" , 0 , 0); // Both throw an error compile time because parameters don't match with the constructor
```

Usually objects have properties. To define them, just add their identifier into the
class without type declaration. The properties will be of type `var`. However, you are
required to set a default value of a property. This may be `null`.

Every object has a reference to itself called `this`. You can change parameters of an
object by reference.

```squirrel
void function initClient() {
    class ExampleClass {
        property = null
        constructor( var parameter ) {
            this.property = expect int(parameter);
        }
    }
}
```

You can't use the class name as a type. Use `var` instead. You can't `expect` them
either.

## Declaring Functions of Classes

Functions of a class have to return a value of type `var`. This may be `null`.
Define functions like this:

```squirrel
global var ExampleClass;
void function initClassF(){
    class ExampleClass {
        variable = "default value"

        // Set field 'variable' of this instance to passed parameter
        function setV( pV ){
            this.variable = pV
        }

        // Return field 'variable' of this instance
        function getV(){
            return this.variable; // return value can be of any type
        }
    }
    var inst = ExampleClass();
    print(inst.getV()); // -> default value
    inst.setV("new value");
    print(inst.getV()); // -> new value
}
```

## Inserting Properties Into Classes

It's possible to insert more properties into a class at runtime. To achieve this, use
the `<-` operator.

```squirrel
// Using `ExampleClass` and `exampleObject` from example above
ExampleClass.newProperty <- "New property in class"
// The value of the new index may be of any type.
ExampleClass.newFunc <- function(){return "Function return value";}
```

!!! note

    It is not possible to insert new fields into an instance or a class *after
    instantiation*

    ```squirrel
    var ExampleErrorClass;

    func(){
        class ExampleErrorClass {};
        var eInst = ExampleErrorClass()
        eInst.e <- "Instance error value"; // Asserts error: class instances do not support the new slot operator
        ExampleErrorClass.e <- "Class error value"; // Fails because an instance of class ExampleErrorClass has already been created. Asserts error: trying to modify a class that has already been instantiated
    }
    ```

Inserting functions is also possible using the `::` operator

```squirrel
function ExampleClass::AddOne( var param /* parameters have to be var */ ){ return expect int( param ) + 1 }
var e = ExampleClass()
print( expect int( e.AddOne( 1 ) ) ) // prints 2
```

This allows mods to extend functionality of classes declared in the base game and other
mods that have already been loaded.

For example, extending functionality of the CPlayer class might look like this:

```squirrel
global function InitCPlayerInsert

void function InitCPlayerInsert()
{
    CPlayer.afkCount <- 0 // Insert new property into the CPlayer class
    CPlayer.maxAFKCount <- 3
    function CPlayer::AFK(){ // Kick a player when they are afk multiple times in a match
        if ( this.afkCount >= this.maxAFKCount )
            ClientCommand( this, "disconnect You have been AFK too often in a match")
        else
        {
            this.afkCount++
            SendHudMessage( this, format( "You are AFK!\nYou will get kicked after %i more violations", this.maxAFKCount - this.afkCount ), -1, 0.4, 255, 255, 255, 0, 0.5, 5, 0.9 )
        }
    }

    // To trigger the method, do GetPlayerArray()[0].AFK()
}
```

This will allow scripts to run the `AFK` method on CPlayer entities, which will kick a
player after 3

Make sure to load this script **after** the class has been declared and **before** it's
instantiated!

Note that any properties added to classes don't apply to other classes that are
inherited from a modified class.

## Instantiating Objects

To create an instance, do:

```squirrel
class ExampleClass {
    property = null
    constructor( var parameter ) {
        this.property = expect int(parameter);
    }
}

var exampleObject = ExampleClass(1);
int n = exampleObject.property // n = 1
exampleObject.property++;
n = exampleObject.property // n = 2
```

It's also possible to create an instance without calling the constructor.

```squirrel
// Using 'ExampleClass' from previous examples
var e = ExampleClass.instance()
e.constructor(1) // Constructor is a normal function so you can call it manually.
```

Like the example above shows you can manipulate properties of a class directly. There is
no way to make a private property.

Methods from a class can be accessed without an instance. Note that the class itself
doesn't have a reference to itself, meaning that the `this` keyword refers to the root
table.

```squirrel
var class = ExampleClass
var instance = class.constructor()
```

## Cloning Instances

Unlike other types, passing an object does not pass a copy of the object, but a
reference to itself. This means that any modifications inside of a function are applied
to the original object.

```squirrel
void function initClass(){
    class Container {
        content = null
        constructor ( var pString ) {
            this.content = expect string(pString);
        }
    }
    var con = Container("original string")
    manipulateContainer( con )
    print(con.content) // -> manipulated string
}

void function manipulateContainer( var con ){
    con.content = "manipulated string";
}
```

You can avoid this by using cloned objects. Use the `clone` keyword to create a copy
of an object.

```squirrel
// Assumes the 'Container' class from the previous example has already been declared
void function initClass(){
    var originalObj = Container("original string")
    var clonedObj = clone originalObj
    manipulateContainer( clonedObj )
    printt(orignalObj.content, clonedObj.content) // -> original string, manipulated string
}

void function manipulateContainer( var con ){
    con.content = "manipulated string";
}
```


## Emulating Namespaces {#namespaces}

Instead of declaring classes as a global var, you can use other types such as tables to
hold multiple class objects that emulate the behaviour of namespaces to a certain
extend.

```squirrel
global table<string, var> fakeNamespace = {
    class1 = null,
    class2 = null
}
```

This allows you to group classes together in a single global variable.

You can use the classes inside of the table like this:

```squirrel
// Create a class object in field
class fakeNamespace.class1 { constructor(){ print("constructing instance of class1") } }
class fakeNamespace.class2 { constructor(){ print("constructing instance of class2") } }

// Access class object in field
var c1 = fakeNamespace.class1()
var c2 = fakeNamespace.class2()

// Insert functions into class object in field
fakeNamespace.class1.testfunc <- var function(){ print( "inserted function in class1" ) }
```

You can also declare classes in an array:

```squirrel
array<var> classes // This has to be at file level

// This has to be inside of a function:
classes.append( class { constructor(){ print( "inline constructor" ) } )
var instance = classes[0]()
```

And in a similar fashion in structs:

```squirrel
struct {
    var class1 = null
    var class2 = null
} classes // This has to be at file level

// This has to be inside of a function:
classes.class1 = class { constructor(){ print( "inline constructor" ) } )
classes.class2 = class { constructor(){ print( "inline constructor" ) } )
var c1 = classes.class1()
var c2 = classes.class2()
```

!!! warning

    Respawn's fork doesn't appear to support inheritance. Using the `extend` keyword
    won't compile.

    ```squirrel
    class Child extends Parent{}
    ```

Make sure you check out the squirrel documentation on
[classes](http://www.squirrel-lang.org/squirreldoc/reference/language/classes.html) and built
in [class instance](http://www.squirrel-lang.org/squirreldoc/reference/language/builtin_functions.html#class-instance)
methods for more information.
