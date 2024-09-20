# Functionrefs

Function references are a complex type that can reference any function or closure.

The type keyword is `functionref` and needs to include any parameter types and optionally return types.

```squirrel
void function CallDelayed( void functionref() fn )
{
    wait 1
    fn()
}
```

You can call functionrefs like a regular function. The return type of a functionref will default to `var` if omitted. Omitting the return type is only possible in `untyped` files.

Parameter names are optional in functionrefs. Otherwise the parameter syntax is like in regular functions.

```squirrel
   void function Example( int n, ... ) {}

   void functionref( int, ... ) fn = Example
```
