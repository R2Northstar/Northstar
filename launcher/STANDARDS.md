# Code standards

There are exceptions, ask for them!

### Preamble

You are more than welcome to reformat any existing files using these rules should they fail to match them but please SPLIT your formatting changes from the rest by making a separate PR!

### General rules

> Basic rules that apply all the time.

Always assert your assumptions!

Use PascalCase for all names.

Suffix structs with `_t`.

Prefix classes with `C` (class) and `I` (abstract class).

Prefix all class member variables with `m_`.

Prefixes `g_` for global variables and `s_` for static variables are welcome.

For hooking we use `o_<function name>` for function pointers pointing to the original implementation and `h_<function name>` for functions we replace them with.

Document all function implementations and their arguments (if the argument is self explanatory you don't need to document it) valve style:
```
//-----------------------------------------------------------------------------
// Purpose: MH_MakeHook wrapper
// Input  : *ppOriginal - Original function being detoured
//          pDetour - Detour function
// Output : true on success, false otherwise
//-----------------------------------------------------------------------------
```

Don't overcomment your code unless nescessary, expect the reader to have limited knowledge.

Use `FIXME` comments for possible improvements/issues, `NOTE` for important information one might want to look into.

### Valve source files

> Rules that apply to all files from original valve code base.

When adding or just modifying a file that's present in valve source place it where valve put it.

Always use hungarian notation in these files.

### New files

> Rules that apply to Respawn or our own files.

When adding new files follow the general rules, you don't have to use hungarian notation. Put the file where you think it makes the most sense.
