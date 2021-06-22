# Var

`var` stands for a variable of any type. Any **primitive** can be `var`, however complex types can never be `var`.

```squirrel
  // var can be just about anything.
  var v = 1
  v = "string"
  v = []
  v = {}
```

in `untyped` files you can also use the `local` keyword instead of `var`. However the keyword is deprecated and should not be used.

If possible, usage of `var` should be avoided and other static types should be used instead to benefit from the type checking of squirrel.
