# Dependency Constants and Compiler Directives

## Compiler Directives

Compiler directives are a way to compile code only if a specific condition is met. To
use this you have the `#if`, `#endif`, `#else` and `#elseif` keyword.

Contditons you can check for are

- `SERVER` Checks if the code is compiled on the server VM.
- `CLIENT` Checks if the code is compiled on the client VM.
- `UI` Checks if the code is compiled on the UI VM.
- `MP` Checks if the code is compiled in a multiplayer match.
- `SP` Checks if the code is compiled in a singeplayer match.
- `DEV` Checks if the code is compiled with the `-dev` keyword in the startup
    arguments.

These conditions can also be combined with the regular squirrel boolean expressions

```squirrel
    #if SERVER
    Chat_ServerBroadcast("Message from the server VM")
    #endif
```

```squirrel
    #if (CLIENT && MP) || DEV
    ...
    #elseif SP
    ...
    #endif
```

## Dependency Constants

Dependency constants are used to only compile code if a dependency your mod requires is
loaded, these use the Compiler directives syntax.

Inside your `mod.json` define a constant as:

```squirrel
    {
        // mod.json stuff
        "Dependencies": {
            // sets the constant to 0 or 1, depending if the mod with the name "Mod Name" exists and is enabled
            "CONSTANT_NAME": "Mod Name"
        }
    }
```

For Example:

```json
    "PLAYER_HAS_ROGUELIKE_MOD": "TF|Roguelike"
```

Will define a constant `PLAYER_HAS_ROGUELIKE_MOD` that is set to `0` or `1`
depending if the mod is enabled. It then can be used as a constant/compiler flag.

```squirrel
    #if PLAYER_HAS_ROGUELIKE_MOD
    print("player has roguelike mod")
    Roguelike_Function();
    #else
    print("Can't use the function because the mod is off :'(")
    #endif
```
