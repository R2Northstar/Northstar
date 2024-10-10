# RPak Modding

## What Are RPaks/Starpaks?

.rpak files are a file format created by Respawn as the main way to store and load in-game assets, such as textures, materials, datatables, animation recordings, etc.
The assets in the .rpak file are kept stored in memory as long as the .rpak file is loaded.

.starpak files are another file format created by Respawn to complement the .rpak file format.
They contain streamed asset data, saving hardware resources by only loading the data when needed.
The most common example of streamed asset data is high resolution textures. The low resolution versions are kept permanently loaded in a .rpak file, whilst the higher resolution versions are loaded as needed.

### What can RPak mods do?

RPak mods can be used for the following:

* Custom UI
* Skins
* World Materials
* Texture replacements

## RePak First-Time Setup

The lastest RePak release can be downloaded from [here](https://github.com/r-ex/RePak/releases).
Once it has been downloaded, it is recommended to set up your file structure as follows:

!!! note

    Depending on the version of RePak, some of these folders and files might be already there for you

```text
RePak
├── RePak.exe
├── pack_all.bat
├── rpaks
├── maps
└── assets
```

- `RePak`: the base folder where your RePak/RPak related files go
- `RePak.exe`: the `unzipped` file you downloaded from GitHub
- `pack_all.bat`: a .bat file that will pack all of your RPaks when opened (outlined below)
- `rpaks`: the folder where RePak.exe will put your RPaks when they have been created
- `maps`: the folder where you will write your "map" files, these define the contents of your RPaks
- `assets`: the folder where you will put your various different images and folders, used to create your RPaks

### Making pack_all.bat

`pack_all.bat` is recommended for using RePak, as it allows for quick and easy packing of all of your RPaks.
Below is the script that should be copied into the file.

```bat
for %%i in ("%~dp0maps\*") do "%~dp0RePak.exe" "%%i"
pause
```

## Making RPaks

This section will walk you through the process of making an RPak that replaces a camo.
For information on making other types of RPaks, check the RePak Docs:

* `../repak/map`
* `../repak/index`


### Finding the camo

Before you can make your RPak, you need to know which assets you want to replace.
Camos in Titanfall 2 tend to have their own RPaks, with the naming scheme `camo_skin<number>_col.rpak`

Firstly, make sure you have LegionPlus downloaded, if you don't, it can be downloaded from [here](https://github.com/r-ex/LegionPlus/releases).

Then use LegionPlus to open one of the `camo_skin<number>_col.rpak` RPaks, it should look like this:

![CamoRPak](https://user-images.githubusercontent.com/66967891/181027612-e5f7af74-9e1a-496e-a2d7-783423f7b179.png)

!!! note
    If your LegionPlus doesn't show the "Name" as a full path, go into "Settings" and make sure that "Show Full Asset Paths" is ticked, then click "Refresh"

Extract the asset by double clicking on it, or by selecting it and clicking "Export Selected"

Make a note of the Name of the asset, in this example it's `models\camo_skins\camo_skin04_col`


### Editing the texture

Find the extracted file that LegionPlus created, and open it in some image editing software

!!! warning
    The image editing software you choose must be able to export images as .dds files

    Examples of image editing software that supports .dds files:

    - [GIMP](https://www.gimp.org/) (No SRGB support)
    - [paint.net](https://www.getpaint.net/)
    - [Adobe Photoshop](https://www.adobe.com/uk/products/photoshop.html)

After you have made the desired changes to the image, export it as a .dds file with DXT1 (BC1) compression and the same name as it had originally.

![ExportDDS](https://user-images.githubusercontent.com/66967891/181824740-c8a6d1d7-234f-405d-a348-1287aa9bb168.png)

!!! warning
    Try to make your textures have dimensions that are powers of two, so that [mipmaps](https://en.wikipedia.org/wiki/Mipmap#Overview) can be used.
    For example `256x256` `512x512` `1024x512` `4096x1024` are all fine, but `350x700` might cause issues.

    ![MipMaps](https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/Mipmap_Aliasing_Comparison.png/1280px-Mipmap_Aliasing_Comparison.png)


Place your newly created .dds file in the `assets\texture` folder, following the path in the Name you noted down above.
In this example the .dds file would go in `RePak\assets\texture\models\camo_skins`, with the path of the image being `..\RePak\assets\texture\models\camo_skins\camo_skin04_col.dds`


### Making a map file

Once you have edited your texture image and placed it in the right folder, you are ready to make your map file.

Map files are what RePak uses to create the .rpak file (and .starpak files if needed) and are in the .json file format.
They can be named anything you want, but should be put in the `RePak\maps` folder.

Below is an example of a map file that creates an RPak called `example.rpak` which contains 1 texture asset.

```json
{
    "name":"example",
    "assetsDir":"../assets",
    "outputDir":"../rpaks",
    "starpakPath": "example.starpak",
    "version": 7,
    "files":[
        {
            "$type":"txtr",
            "path":"texture/models/camo_skins/camo_skin04_col"
        }
    ]
}
```

- `name`: the name of the file that gets created by RePak.
- `assetsDir`: the folder that RePak bases the file path on when looking for textures.
- `outputDir`: the folder that RePak will put the files that it creates in.
- `starpakPath`: the path of the starpak file for streaming textures.
- `version`: the RPak version RePak will use when creating the RPaks. **Version 7 is Titanfall 2, version 8 is Apex Legends.**
- `files`: an array of all of the assets that RePak will create in the RPak.
- `$type`: the type of asset that this asset is, use `txtr` for textures.
- `path`: the path of the asset, used in texture assets for finding the image. **This should start with** `texture/` **and the rest should match the Name given by LegionPlus.**

!!! warning
    If the `path` doesn't match up with the location of your file, RePak will throw an error

!!! warning
    If the `path` contains any `\` characters, make sure that you either replace them with `/` or you duplicate them (`\\`)

    This is because `\` is the escape character in JSON, and will therefore break the `path`

### Creating the RPak

To create your RPak file, simply open `pack_all.bat`.

Alternatively, click and drag your map file over `RePak.exe`. (I don't recommend this, it's a pain)

**Look at the console for any errors.**
If there are no errors, a .rpak file should have been created in the `rpaks` folder.


### Using the RPak in a mod

Create the basis of the mod using the [Getting Started](../gettingstarted.md) guide.

Inside the mod's folder, create a new folder, called `paks`. Move your .rpak file (and .starpak files if you have any) into the folder.

![ModStructure](https://user-images.githubusercontent.com/66967891/181840035-3cfa24e0-efdd-49fa-85f6-60e6c4cc9a12.png)

Inside the `paks` folder that you created, make a new .json file called `rpak.json`.
In this example, the `camo_skin04_col.rpak` rpak is completely replaced by `example.rpak`.
This is fine for camo RPaks, but isn't suitable for more complex RPaks

```json
{
    "Preload":
    {
        "example.rpak": false
    },
    "Aliases":
    {
        "camo_skin04_col.rpak": "example.rpak"
    },
    "Postload":
    {

    }
}
```

- `Preload`: if set to `true` this makes RPaks get loaded as soon as possible.
- `Aliases`: this completely replaces the RPak with the specified RPak. In this example `camo_skin04_col.rpak` is replaced by `example.rpak`.
- `Postload`: this makes RPaks get loaded directly after the specified RPak.

#### Preload

This field tells Northstar whether or not to load a specific RPak as soon as RPak loading starts.

The field is a boolean. (`true` or `false`) and should be formatted like `"<target_rpak>": true` or `"<target_rpak>": false`

Example: `"my_new.rpak": true`

#### Aliases

This field tells Northstar that a specific RPak should never be loaded, and a different RPak should be loaded instead.

The field should be formatted like `"<target_rpak>": "<replacement_rpak>"`

Example: `"common.rpak": "my_new.rpak"`

#### Postload

This field tells Northstar that a specific RPak must be loaded directly after another specified RPak has finished loading.

The field should be formatted like `"<target_rpak>": "<rpak_to_load_after>"`

Example: `"my_new.rpak": "common.rpak"`

!!! warning
    If an asset in your RPak references another asset, it must be loaded after the asset that it references, or the game will infinitely loop when launched.
    This is mostly a problem for `matl` assets, `txtr` assets don't reference other assets.

The file structure of your `paks` folder should be similar to this:

![PaksStructure](https://user-images.githubusercontent.com/66967891/181840126-98e48860-84d0-496d-8f2e-1cea4dea7363.png)

```text
paks
├── example.rpak
├── example.starpak
└── rpak.json
```

- `example.rpak`: this is the RPak file that you made.
- `rpak.json`: this controls how the game loads your RPak files

**After** `rpak.json` **is set up correctly, your RPak mod should be complete and functional!**

!!! note
    If when you test the rpak the colour looks weird, use SRGB in the .dds compression, or use non-SRGB if you were already using SRGB
