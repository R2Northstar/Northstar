# VTF Modding

## VTF Overview

VTF, short for "Valve Texture Format", is a texture type used by Valve in the source engine and is occasionally in Titanfall. vtf's are used for fx, animation, and other textures.


## VMT Overview

VMT, short for "Valve Material Type", is a text [material](https://developer.valvesoftware.com/wiki/Material) system that dictates how the game perceives a vtf outside of how it looks. It uses [parameters](https://developer.valvesoftware.com/wiki/Category:List_of_Shader_Parameters) and [proxies](https://developer.valvesoftware.com/wiki/Material_proxies) to dictate how [shaders](https://developer.valvesoftware.com/wiki/Shader) will show the game. We will go into greater detail later.

## Editing FX that use VTFs

A lot of fx in Titanfall use vtf's as textures. Therefore, if the corresponding vtf can be found, we can do almost anything with the fx's appearence.
Example Mod: [Exrill's Blue L-Star](https://northstar.thunderstore.io/package/EXRILL/Exrills_Blue_Lstar/).
Since the L-Star has a physical bullet that is counted as fx, we can edit how it looks.

## VTF Skins

Since vtf modding was originally for introducing custom weapon skins, most of the development on it was focused on that. The same concepts apply to modding other textures though.

Most textures in the game use .dds but we can make them use .vtf.

What we'll be doing is:

- Extracting the model.
- Replacing the texture path in the mdl to point to our texture.
- Creating our directory.
- Setting up a .vmt file.

[VPK Tool](https://github.com/Wanty5883/Titanfall2/blob/master/tools/Titanfall_VPKTool3.4_Portable.zip)

## VPK Tool

You have 2 options for a VPK tool. Pick either the older VPK tool:
[cra0 VPKTool](https://github.com/Wanty5883/Titanfall2/blob/master/tools/Titanfall_VPKTool3.4_Portable.zip)
or the Newer VPK tool: [Harmony VPKTool](https://github.com/harmonytf/HarmonyVPKTool) (better).

With your VPK tool opened. 'Open' `englishclient_mp_common.pak000_dir.vpk` which is located in `Titanfall2/vpk`.

Inside of the VPK, not all guns filenames match their ingame names. Here is [list of weapon names](https://noskill.gitbook.io/titanfall2/documentation/file-location/weapon/weapon-model) to help you out.

Navigate to `models/weapons/car101`. Extract all the viewmodel versions (ptpov) and normal model (w) mdl's.

## Hex Editor

To change the path in the .mdl to the custom .vmt.
We need a hex editor. Before editing with hex editors, you need to be aware that hex editors cannot add or delete data, only replace it. I will use [HxD](https://mh-nexus.de/en/hxd/), but you can also use [ida](https://hex-rays.com/ida-free/), or anything else as its personal preference.

Open your .mdl in your hex editor.

We want to get closer to the path we need or else you'll be scrolling and searching for hours. Search:(CTRL+F) for skin_31. If you don't get any matches, try skn_31, skin31, elite, or prime. The path should look something like `.models\Weapons_R2\weaponname\weaponname_skin_31`.
Don't change this unless you want to effect skin31 textures.

The path we do need to change is `.models\Weapons_R2\weaponname\weaponname`. This comes before the `skin_31` path.
I recommend only changing the last section of the path. We'll change `.models\Weapons_r2\car_smg\CAR_smg` to `.models\weapons_r2\car_smg\car_ctm`. Note the capitalization, as some vpk repacking tools cannot repack properly if the changed path contains capitals.

Now copy these changes for `ptpov_` and/or `w_` model(s). As these are the stow (On your back) and main menu models. If don't change these. Your texture will only work when in a match.

## Creating VMT

In the same folder you extracted your mdl's. Make a `materials` folder next to the `models` folder.

Example:
```

    models
    materials
```

Recreate the path you changed in the `materials` folder, such that the last section is a .vmt file:

```text

    materials
    └─ models
          └─ weapons_r2
                └─ car_smg
                     └─ car_ctm.vmt

```

Inside your .vmt paste:

```

    "UnlitTwoTexture"
    {

        "$surfaceprop" "metal"
        "$basetexture" ""
        "$texture2" ""
        "$bumpmap" ""
        "$allowoverbright" "1"
        "$vertexcolor" 1
        "$vertexalpha" 1
        "$decal" "1"
        "$model" 1
        "$nocull" "1"
    }

```

When we use vtf textures, we can only use the albedo and normal. Learn more about [texture maps](https://retryy.gitbook.io/tf2/wiki/create/texturemaps) here.

## VTFEdit

[VTFEdit](https://nemstools.github.io/pages/VTFLib-Download.html) is a tool to edit, view, and create .vtf files.


Launch [VTFEdit](https://nemstools.github.io/pages/VTFLib-Download.html). Top left, click `File`, `Import`, find and Import your custom texture(s).

When importing your normal map. Choose to import as a `Volume Map`
When importing your diffuse map. Choose to import as a `Animated Map`

More info about .vtf format possibilities [here](https://retryy.gitbook.io/tf2/wiki/create/formats), or the official source docs [here](https://developer.valvesoftware.com/wiki/Valve_Texture_Format).

After that, save your new .vtf's into the same folder as your custom .vmt with a simple name.

## Configuring your .vmt

In the `"$basetexture"` argument enter your .vtf texture directory. We'll use `models\weapons_r2\car_smg\car_ctm\NAMEOFVTF`. This should point to your custom diffuse .vtf with the simple name. The game expects these paths to be without the `.vtf` file extension - don't add it.

Do the same for adding your normal map with the `"$bumpmap"` argument.

In some cases you might have to create another vtf with literally any image. Put its path in the `"$texture2"` argument. As far as i know, this is sometimes necessary even though the texture isn't used.

## Final VPK folder

Your root folder should look somewhat like this

```text

    root
    ├─ materials
    │  └─ models
    │     └─ weapons_r2
    │        └─ car_smg
    │           ├─ YOURTEXTURE.vtf
    │           ├─ YOURTEXTURE.vtf
    │           └─ car_ctm.vmt
    └─ models
       └─ weapons
          └─car101
            ├─ ptpov_car101.mdl
            └─ w_car101.mdl

```

## Finished.

You're done! You just need to pack it into a vpk with a vpk tool (for our gun mod, we'd repack to `englishclient_mp_common.pak000_dir.vpk`), and put the vpk into a Northstar mod inside a `vpk` folder.

Help with repacking [here](https://noskill.gitbook.io/titanfall2/intro/duction/vpk-packpack), and help with Northstar mods [here](https://r2northstar.readthedocs.io/en/latest/guides/gettingstarted.html).

## Making your Skin Animated

To add animation functionality, all we need to do is add a Proxie; which is just a modifier inside a `.vmt`, and change our albedo vtf texture.

You need to create a .vtf texture with multiple frames imported to a single .vtf texture, that's your animated texture. You can do this with [VTFEdit](https://nemstools.github.io/pages/VTFLib-Download.html). Then assign the texture in `$basetexture`.

At the bottom of your vmt but before the `}`, add this:

```text

    "Proxies"
    {
            AnimatedTexture
            {
                animatedTextureVar $basetexture
                animatedTextureFrameNumVar $frame
                animatedTextureFrameRate 30
            }
    }
```


To change the fps of the texture, change the value after `animatedTextureFrameRate`, and you'll be done making your texture animated!
