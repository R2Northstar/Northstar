# Floats

Floats are 32 bit floating point numbers that can be any decimal number.

An unitilized float will have the default value `0.0`.

The type keyword for floats is `float`.

## Literals

Float literals need to contain a `.` to distinguish them from integer literals.

They may omit the decimal before the period, however after the period a value is required.

```squirrel
  float a = 1.1
  float b = 0.0
  float c = .0 // 0.0
  float d = 0. // INVALID, this will throw a compile error because the value after the period is missing.
```
