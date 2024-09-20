# UI Image Atlases

UI Image Atlases (`uimg`) are what the game uses to store multiple UI assets, they
reference a single texture asset, known as the `atlas` and have an array of
`textures` which defines the different usable UI assets.

## Examples:

### 1. Basic UI Image Atlas with 2 Textures

```json
    {
        "$type":"uimg",
        "path":"rui/atlas/example1",
        "atlas":"rui/example1",
        "textures":
        [
            {
                "path":"rui/example1/texture1",
                "width":128,
                "height":128,
                "posX":0,
                "posY":0
            },
            {
                "path":"rui/example1/texture2",
                "width":128,
                "height":128,
                "posX":128,
                "posY":0
            }
        ]
    }
```

!!! note

    This UI Image Atlas expects a texture with the path of `rui/example1` which is at
    least 256x128

### 2. Full Map File With a UI Image Atlas

```json
    {
        "name":"blue_fire",
        "assetsDir":"../depot",
        "outputDir":"../rpaks",
        "version": 7,
        "files":[
            {
                "$type":"txtr",
                "path":"rui/blue_fire"
            },
            {
                "$type":"uimg",
                "path":"rui/atlas/blue_fire",
                "atlas":"rui/blue_fire",
                "textures":[
                    {
                        "path":"blue_fire/hud/flame_wall",
                        "width":128,
                        "height":128,
                        "posX":0,
                        "posY":0
                    },
                    {
                        "path":"blue_fire/menu/flame_wall",
                        "width":128,
                        "height":128,
                        "posX":128,
                        "posY":0
                    },
                    {
                        "path":"blue_fire/hud/flame_shield",
                        "width":128,
                        "height":128,
                        "posX":0,
                        "posY":128
                    },
                    {
                        "path":"blue_fire/menu/flame_shield",
                        "width":128,
                        "height":128,
                        "posX":128,
                        "posY":128
                    }
                ]
            }
        ]
    }
```

!!! note

    This map file is a shortened version of the one used in EXRILL's
    [Blue Fire](https://northstar.thunderstore.io/package/EXRILL/Exrills_BlueFire_mod_Beta/) mod

## Asset Structure:

### `$type`

For an asset to be a UI Image Atlas asset, the `$type` field must be `"uimg"`.

### `path`

The `path` field for a UI Image Atlas asset is mostly unused, and as such can be set
to almost any value. It is used when logging information about the asset.

### `atlas`

The `atlas` field for a UI Image Atlas asset determines which texture asset it will
use.

!!! error

    If the uimg asset doesn't contain a valid `atlas` field, RePak will output one of
    the following errors to the console:

    `Required field 'atlas' not found for uimg asset '%s'. Exiting...`

    `'atlas' field is not of required type 'string' for uimg asset '%s'. Exiting...`

    where `%s` is the `path` field of the UI Image Atlas

!!! error

    If the texture asset cannot be found, RePak will output the following message to the
    console before exiting:

    `Atlas asset was not found when trying to add uimg asset '%s'. Make sure that the
    txtr is above the uimg in your map file. Exiting..."`

    where `%s` is the `path` field of the UI Image Atlas

### `textures`

The `textures` array in a UI Image Atlas asset defines the different UI textures that
the atlas contains. Any number of UI textures may be contained within one UI Image
Atlas.

#### `path`

An entry in the `textures` array must have a `path` field, as the game must use it
to identify and show the texture.

!!! error

    If the entry in the `textures` array doesn't contain a valid `path` field, RePak
    will output one of the following errors to the console:

    `Required field 'path' not found for a texture in uimg asset '%s'. Exiting...`

    `'path' field is not of required type 'string' for a texture in uimg asset '%s'.
    Exiting...`

    where `%s` is the `path` field of the UI Image Atlas

#### `width` and `height`

An entry in the `textures` array must have both a `width` and a `height` field,
these values should both be integers.

!!! error

    If the entry in the `textures` array doesn't contain a valid `width` or a valid
    `height` field, RePak will output one of the following errors to the console:

    `Required field 'width' not found for texture '%s' in uimg asset '%s'. Exiting...`

    `Required field 'height' not found for texture '%s' in uimg asset '%s'.
    Exiting...`

    `'width' field is not of required type 'number' for texture '%s' in uimg asset
    '%s'. Exiting...`

    `'height' field is not of required type 'number' for texture '%s' in uimg asset
    '%s'. Exiting...`

    where the first `%s` is the `path` field of the texture, and the second `%s`
    is the `path` field of the UI Image Atlas

#### `posX` and `posY`

An entry in the `textures` array must have both a `posX` and a `posY` field, these
values should both be integers. These fields determine the location of the top-left
pixel in the UI texture.

!!! error

    If the entry in the `textures` array doesn't contain a valid `posX` or a valid
    `posY` field, RePak will output one of the following errors to the console:

    `Required field 'posX' not found for texture '%s' in uimg asset '%s'. Exiting...`

    `Required field 'posY' not found for texture '%s' in uimg asset '%s'. Exiting...`

    `'posX' field is not of required type 'number' for texture '%s' in uimg asset '%s'.
    Exiting...`

    `'posY' field is not of required type 'number' for texture '%s' in uimg asset '%s'.
    Exiting...`

    where the first `%s` is the `path` field of the texture, and the second `%s`
    is the `path` field of the UI Image Atlas
