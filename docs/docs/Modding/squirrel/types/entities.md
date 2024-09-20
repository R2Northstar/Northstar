# Entities

Entities are a primitive type that can refer to any in-game object.

The type keyword is `entity`.

Entities are always class instances of classes that are defined by native code. The classes differ between the CLIENT or UI, and SERVER vm.

You can not specify which entity class a variable is supposed to hold so you need to be careful you know what entity is expected where.

If you need to check the class of an entity at runtime you can do so with the `instanceof` operator.

```squirrel
bool function IsCPlayer( entity e )
{
    return e instanceof CPlayer
}
```

Entities are `null` initialized and there are no literals for entities.

```squirrel
   entity e
   Assert( e == null )
```
