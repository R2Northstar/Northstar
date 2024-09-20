# Tables

Like arrays, tables are dynamically sized data structures that can have entries added or removed at runtime.

In other languages tables might be called Hashmaps, Maps or Objects.

Entries are added with a key that can subsequently be used to read that object from the table back.

The type keyword is `table`.

To index an array with a string you can write `t.index`, or with an expression just like in arrays with `t.["index"]`.

```squirrel
   table t = { val = "value" }
   string v = t.val
   string v2 = t["val"]
```

## Literals

Table literals are comma or newline seperated expressions that are delimited by `{` and `}`.

Each entry needs to have a key, seperated from the initial value with a `=`.

Table keys will be by default strings if you just write their identifier in the literal. However they can also be any expression if wrapped with `[` and `]`.

```squirrel
table t = { key1 = 1, key2 = "2" }
table t2 = {
    randomValue = getSomethingRandom()
    [1] = 0x1
}

printt( t["key1"], t2[1] ) // 1 1
```

## Primitive Tables

Like arrays primitive tables can hold any type, both as values and keys.

Any value of key of the table will therefore be `var` if retrieved.

## Complex Tables

Complex tables are tables that have their content types defined. It is necessary to both define the key and value types.

```squirrel
table<string, int> numbers = {
    one = 1,
    two = 2,
    three = 3,
    four = 4,
    five = 5,
    six = 6,
    seven = 7,
    eight = 8,
    nine = 9
}
```

