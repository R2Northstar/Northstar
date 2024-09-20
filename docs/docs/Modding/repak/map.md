# Map Files

## Examples:

### 1. Bare Minimum - No Assets

`example1.json`

```json
    {
        "version": 7
    }
```

```text
    root
    ├── RePak.exe
    ├── example1.json
    └── build
        └─ example1.rpak
```

!!! note

    This example map file is honestly pretty useless. It has no assets, because there is
    no `files` field.

    It also will have the name `new.rpak` and will be created in the `./build`
    folder.

### 2. Single Texture + Single Starpak

`example2.json`

```json
    {
        "name": "example2",
        "assetsDir": "../depot",
        "outputDir": "../output",
        "version": 7,
        "starpakPath": "example2.starpak",
        "files":
        [
            {
                "$type": "txtr",
                "path": "textures/models/my_texture"
            }
        ]
    }
```

```text
    root
    ├── RePak.exe
    ├── maps
    |   └─ example2.json
    ├── depot
    |   └─ textures
    |       └─ models
    |           └─ my_texture.dds
    └── output
        ├─ example2.starpak
        └─ example2.rpak
```

!!! note
    This example map file creates an RPak named `example2.rpak` which contains 1
    texture asset. This texture will have it's higher resolution mip levels stored in
    example2.starpak

!!! note

    The texture will replace any vanilla textures that have the same path. (
    `textures/models/my_texture` )

    This is useful for creating basic skins and camos.

### 3. Multiple Textures + Multiple Starpaks

`example3.json`

```json
    {
        "name": "example3",
        "assetsDir": "../depot",
        "outputDir": "../output",
        "version": 7,
        "starpakPath": "example3.starpak",
        "files":
        [
            {
                "$type": "txtr",
                "path": "textures/models/my_texture_col"
            },
            {
                "$type": "txtr",
                "path": "textures/models/my_texture_nml"
            },
            {
                "$type": "txtr",
                "starpakPath": "example3-spc.starpak",
                "path": "textures/models/my_texture_spc"
            }
        ]
    }
```

```text
    root
    ├── RePak.exe
    ├── maps
    |   └─ example3.json
    ├── depot
    |   └─ textures
    |       └─ models
    |           ├─ my_texture_col.dds
    |           ├─ my_texture_nml.dds
    |           └─ my_texture_spc.dds
    └── output
        ├─ example3.starpak
        ├─ example3-spc.starpak
        └─ example3.rpak
```

!!! note

    This example map file creates an RPak named `example3.rpak` which contains 3
    texture assets. These textures each have their higher resolution mip levels stored
    in starpaks.

    `my_texture_col` and `mp_texture_nml` use `example3.starpak`, as they do not
    specify their own `starpakPath`. This makes them use the default `starpakPath`
    that is defined at the file scope, instead of in the individual textures.

    `my_texture_spc` uses `example3-spc.starpak`, as it specifies it's own
    `starpakPath`.

!!! note

    This RPak is a good example of a skin that would normally require the skin tool to
    install. The advantage of this method is that the skin can be uninstalled or
    temporarily disabled when packed as a mod.

## Structure:

### `name`

The `name` field of a map file determines the name of the resulting RPak.

The `name` is appended with `.rpak` and defaults to `new` if no `name` is
provided. This results in a default RPak called `new.rpak`.

!!! warning

    In the event that no `name` is provided in the map file, RePak will output the
    following warning to the console:

    `Map file should have a 'name' field containing the string name for the new rpak,
    but none was provided. Defaulting to 'new.rpak' and continuing...\n`

### `assetsDir`

The `assetsDir` field of a map file determines the root path which the program
combines with the `path` for assets in order to find the correct file. This path may
be a relative path, or an absolute path.

The `assetsDir` provided in the map file is appended with a slash ( `\` ) if
necessary

!!! warning

    If no `assetsDir` is provided, it defaults to the working directory ( `.\` ) as
    well as outputting the following warning to the console:

    `No assetsDir field provided. Assuming that everything is relative to the working
    directory.\n`

### `outputDir`

The `outputDir` field of a map file determines the folder that the program will write
the RPak and StaRPak files to once they have been created. This path may be a relative
path, or an absolute path.

The `outputDir` provided in the map file is appended with a slash ( `\` ) if
necessary

If no `outputDir` is provided in the map file, RePak defaults to `.\build\`

### `version`

The `version` field of a map file determines the RPak version that RePak will create.

!!! error

    If no `version` field is provided, RePak will output the following error and the
    program will stop:

    `Map file doesn't specify an RPak version\nUse 'version: 7' for Titanfall 2 or
    'version: 8' for Apex\n`

!!! error

    If an invalid `version` field is provided, RePak will output the following error
    and the program will stop:

    `Invalid RPak version specified\nUse 'version: 7' for Titanfall 2 or 'version: 8'
    for Apex\n`

#### List of known `version` values:

- `6`: Titanfall 2: Tech Test **[UNSUPPORTED]**
- `7`: Titanfall 2
- `8`: Apex Legends

### `starpakPath`

The `starpakPath` field of a map file determines the default starpak path for textures
(and other streamed assets) to use.

!!! note

    If the starpak name ends in `_hotswap.starpak` (e.g. `my_thing_hotswap.starpak`)
    then Titanfall 2 will view it as optional. This allows the starpak to be moved,
    removed, or replaced while the game is running and streaming the texture. This can
    be useful for debugging.

!!! note

    RePak will not throw any errors if no `starpakPath` field is specified, however
    the individual textures may throw errors if they do not have a `starpakPath`
    specified

### `files`

The `files` field of a map file is an array of JSON objects, each one representing an
RPak asset.

RePak will not throw any errors if no `files` field is specified, however the
resulting RPak will contain no assets, rendering it useless.
