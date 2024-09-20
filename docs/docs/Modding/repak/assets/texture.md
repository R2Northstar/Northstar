# Textures

Textures are the foundation of some RPak asset types. They cannot be used directly by
the game, but are instead referenced by other asset types which the game can use by
itself.

The image used by a texture must be in the .dds format and must be in one of the
following compression types:

- BC1 SRGB
- BC2 SRGB
- BC3 SRGB
- BC7
- BC7 SRGB
- DXT1
- DXT3
- DXT5
- BC4U
- BC5U UNORM

!!! warning

    SRGB DDS compression types are preferred, as they can prevent the texture's colour
    from looking "washed out"

## Examples:

### 1. Basic Texture Asset - No streaming

```json
    {
        "$type": "txtr",
        "path": "textures/models/humans/test_texture",
        "disableStreaming": true
    }
```

!!! note

    The image file in this texture asset will be called `test_texture.dds` and will be
    at `<ASSETSDIR>/textures/models/humans/test_texture.dds`

!!! note

    Because `disableStreaming` is `true`, this texture will not be stored in a
    .starpak file, and all mip levels will be stored in the .rpak file

### 2. Streamed Texture Asset

```json
    {
        "$type": "txtr",
        "path": "textures/models/humans/test_texture_2",
        "starpakPath": "test_texture_2.starpak"
    }
```

!!! note

    The image file in this texture asset will be called `test_texture_2.dds` and will
    be at `<ASSETSDIR>/textures/models/humans/test_texture_2.dds`

!!! note

    Because `disableStreaming` is not present, this texture will have it's higher
    resolution mip levels stored in `test_texture_2.starpak`, as defined by the
    `starpakPath`. It will not use the default `starpakPath` if one is defined
    outside of the `files` array

## Asset Structure:

### `$type`

For an asset to be a texture asset, the `$type` field must be `"txtr"`.

### `path`

The `path` field of a texture asset is used to determine the location in the RPak's
`assetsDir` that the image file is in.

It is also used as the asset's unique identifier, allowing other assets to reference and
use it.

The `path` field must start with `textures/` and must not end with a file extension.

!!! error

    If RePak is unable to locate a file at the given `path`, it will output the
    following error to the console:

    `Failed to find texture source file %s. Exiting...` where `%s` is the `path`
    field of the texture.

!!! error

    If the file at the given `path` is not a .dds file, RePak will output the
    following error to the console:

    `Attempted to add txtr asset '%s' that was not a valid DDS file (invalid magic).`
    where `%s` is the `path` field of the texture.

!!! error

    If an unsupported .dds compression type is used, RePak will output the following
    error to the console:

    `Attempted to add txtr asset '%s' that was not using a supported DDS type.
    Exiting...` where `%s` is the `path` field of the texture.

### `starpakPath`

The `starpakPath` field of a texture asset determines the path of the starpak in which
the higher resolution mip levels should be stored.

If no `starpakPath` value is specified, RePak will default to using the default
`starpakPath`, defined at file scope in the map file.

The `starpakPath` field should be a string, and importantly, should end in
`.starpak`.

!!! note

    If the starpak name ends in `_hotswap.starpak` (e.g. `my_thing_hotswap.starpak`)
    then Titanfall 2 will view it as optional. This allows the starpak to be moved,
    removed, or replaced while the game is running and streaming the texture. This can
    be useful for debugging.

!!! error

    If the `starpakPath` is not present, and no `starpakPath` is defined at file
    scope, RePak will output the following error to the console.

    `attempted to add asset '%s' as a streaming asset, but no starpak files were
    available. to fix: add 'starpakPath' as an rpak-wide variable or: add 'starpakPath'
    as an asset specific variable` where %s is the `path` of the texture asset

### `disableStreaming`

The `disableStreaming` field of a texture asset determines if the texture should use a
starpak to store the higher resolution mip levels.

It should be a boolean value, with `true` disabling the use of a starpak,

`disableStreaming` defaults to `false` if it is not present.
