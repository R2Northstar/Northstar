# Integers

Integers in Squirrel are 32 bit signed integers and can be any whole number (in the 32 bit confines).

An Integer is a primitive type with a default value of `0`.

The type keyword for Integers is `int`.

## Literals

Integers can be represented with multiple different literals.

- Decimal

    Regular decimal letters will always be an integer decimal literal.
    ```squirrel
    int n = 123
    ```

- Hexadecimal

    If any number is prefixed with `0x`, it is a hexadecimal literal.

    ``` squirrel
    int n = 0x0012 // 18
    ```

- Octal

    Numbers starting with a `0` are octal literals.

    ``` squirrel
    int n = 075 // 61
    ```

- Chars

    A single letter or escaped sequence are character literals. Their value is the ASCII value of the letter.

    ``` squirrel
    int a = 'a' // 97
    int newline = '\n' // 10
    ```
