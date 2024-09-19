# Strings

Unlike in other languages, strings in squirrel are primitive types and immutable. That means you can't change the value of a string but will need to copy and change it in another variable.

The default value of strings is an empty string with a length of 0.

The type keyword for strings is `string`.

To create strings, simply write the text of the literals in `"` quotes.

```squirrel
  string s = "this is an example string literal"
```


## Verbatim Strings

Verbatim strings do not escape sequences. They begin with a `@` token before a regular string literal.
Verbatim strings can also extend over multiple lines.
If they do they include any white space between the matching string quotes.

```squirrel

  string a = "simple string\nover two lines"
  string b = @"simple string
  over two lines"

  Assert( a == b )
```

However, a doubled quotation mark within a verbatim string is replaced by a single quotation mark.

```squirrel

  string a = "extra quotation mark\""
  string b = @"extra quotation mark """

  Assert( a == b )
```

## Assets

Assets and strings are internally the same but at compile time they are different types.

Assets are used to reference a specific resource (often in rpak files).

The type keyword for assets is `asset`.

Asset literals are regular string literals prefixed with the `$` token. Verbatim strings can't be an asset.

```squirrel

  asset a = $"my/resource"
```

Northstar added the `StringToAsset` function that allows converting any string into an asset.
