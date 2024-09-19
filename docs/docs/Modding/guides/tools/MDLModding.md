# MDL Modding

## MDL Overview

Model (MDL) is the extension for Source's proprietary model format. It defines the structure of the model along with animation, bounding box, hit box, materials, mesh and LOD information. Unlike other Source games in Titanfall 2 files like the .phy, .vtx, .vvd etc. are not separate files and are instead included in the .mdl file.

[VALVe developer docs "Model"](https://developer.valvesoftware.com/wiki/.mdl)


## Editing an existing Model

While creating an entire Model from scratch is possible it would be an extremely long and tedious task. Instead its recommended to use an existing Model as your base.


## Prequisites

- [Blender](https://www.blender.org/download/) (min. 2.92)
- [Blender Source Tools](https://developer.valvesoftware.com/wiki/Blender_Source_Tools)
    (refer to Download page for install instructions)
- [Crowbar](https://steamcommunity.com/groups/CrowbarTool) (min 0.74)

        - One of the following on Steam:
        - [Portal 2](https://store.steampowered.com/app/620/Portal_2/) (and its Authoring Tools [Portal 2 SDK](https://developer.valvesoftware.com/wiki/Authoring_Tools/SDK_(Portal_2)))
        - [SourceFilmMaker](https://store.steampowered.com/app/1840/Source_Filmmaker/) (FREE)
- [mdlshit](https://github.com/headassbtw/mdlshit)
- [Harmony VPK](https://github.com/harmonytf/HarmonyVPKTool) (optional if you want to extract the model yourself)

!!! note
    This Guide is tailored towards users with atleast some experience with Blender. If you are new to Blender I recommend you to first familiarize yourself with the basics of Blender. There are many tutorials on the Internet that can help you with that.
    Especially the following topics are important for modifying or creating game assets:

    •   Modeling
    •   UV Mapping
    •   Texturing
    •   Rigging

    These things work in conjunction with each other and are all important for creating a game ready model. An understanding of these topics is very helpful for proper usage of Blender.


## Workflow

The workflow for editing a model is as follows:

- Extract the model using [HARMONY VPK](#harmony-vpk) or Downloading the model from the [Titanfall 2 Skin Modding Repo](https://github.com/BigSpice/TitanFall-2-Skin-Modding/tree/main/Models_MDL_Format)
- Decompile the model using [CROWBAR](#crowbar)
- Importing the model in [BLENDER](#blender)
- Editing the model to our liking
- Assigning a material to parts of our model
- Exporting the model from [BLENDER](#blender)
- Compiling using [CROWBAR](#crowbar)
- Converting the MDL file with other output files using [MDLSHIT](#mdlshit)

## Short Video Guide

This is a short video guide on MDL Editing, there are some discrepancies between the video and this guide but the general workflow is the same.
Its relatively quick but shows the process quite well.

<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/mZg5AlWvXZs" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

## Blender

Blender will be used to edit the model. It is a free and open-source 3D computer graphics software toolset with many features. It is widely used for animation, modeling, scene creation, and game development.

The Source Tools add-on for Blender allows us to import and export Source Engine assets. It is a community-driven project that aims to provide users with a convenient way to import and export Source Engine assets from and to Blender, for a wide range of applications, including animation, modeling, scene creation, and game development.

We will use both in conjunction to edit the model.


## Crowbar

Crowbar is a tool written by ZeqMacaw. It is used to decompile and compile Source Engine assets, such as models, textures, and sounds.

We will use it to decompile and compile the model.


## MDLShit

MDLShit is a tool written by headassbtw. It is used to combine the MDL file with the other output files from Crowbar.

We will use it to combine the MDL file with the other output files from Crowbar.


## Harmony VPK

Harmony VPK is a tool written by the Harmony Team. It's an electron-based GUI for VPKTool, and is used to extract files from VPK files.

We will use it to extract the model from the game files.


## Workflow in Detail

In this section we will go through the workflow in detail by using the Flatline as an example.
We will add a cube to the side of the Flatline and assign a custom material to it.


## Step 1: Extracting

!!! note
    Can be skipped if you downloaded the model from the [Titanfall 2 Skin Modding Repo](https://github.com/BigSpice/TitanFall-2-Skin-Modding/tree/main/Models_MDL_Format).

- Open HARMONY VPK.
- On the top right click on the `Open VPK` button.
- Navigate to the location of your Titanfall 2 installions `/vpk/` folder.
- Open the `.vpk` file you want to extract (most multiplayer weapons are in `client_mp_common.bsp.pak000_000.vpk` since you most likely want one of those).
- You will now see a list of all files in the `.vpk` file on the left side looking something like this:

``` text

    RootDir
    ├── materials
    ├── resource
    ├── cfg
    ├── scripts
    ├── models
    ├── maps
    └── depot
```

- Navigate to the `models` folder (this is where all models in this file are located).
- Navigate to the folder of the model you want to extract (for example `weapons/vinson` which is the internal name for the Flatline).
- Select the `.mdl` file you want to extract (for example `ptpov_vinson.mdl`).

!!! note
    Weapons are mostly split into two models, one for the first person view(`ptpov_` and the world model `w_`.

    `ptpov` is used when you are in first person.

    `w_` is used when the weapon is viewed in the world (for example when its dropped on the ground).

- Click on the `Unpack` button on the top right.
- You are now prompted to select a folder to extract the model to, select a folder of your choice and click on `Select Folder`.
- Your model is now extracted and you can close Harmony VPK.


## Step 2: Decompiling the model

!!! note
    In order to use Crowbar the way we will we need to setup a few things first.

    This step only needs to be done once


### Setup Crowbar (one time only)

- Uppon first launch select the `Set Up Games` tab on the top left.
- Select either `Portal 2` or `Source Filmmaker` in the dropdown menu on the top.
- Make sure your Library Path is set to the location of the Steam library you have the game installed in on the bottom.
- The `Game Setup` section should now be filled with the correct paths.

- Select the `Decompile` tab on the top.
- In this tab make sure the following settings are set:

  - `MDL input`: `File`
  - `Output to`: `Subfolder (of MDL input)` (change the text in the box to the right of that to `decompiled`)

  Check the following boxes:

  - `QC file`
  - `Each $texturegroup skin-familiy on single line`
  - `Include $definebones lines (typical for view models)`
  - `Use MixedCase for keywords`
  - `Reference mesh SMD file`
  - `Physics mesh SMD file`
  - `Vertex animation VTA file (flexes)`
  - `Procedural bones VRD file`
  - `Bone animation SMD files`
  - `Place in "anims" subfolder`
  - `Prefix mesh file names with model name`

- Select the `Compile` tab on the top.
- In this tab make sure the following settings are set:

  - `QC input`: `File`
  - `Output to`: `Subfolder (of QC input)` (change the text in the box to the right of that to `compiled`)
  Check the following boxes:

  - `No P4`
  - `Verbose`

  Set `Game that has the model compiler` to the game you selected in the `Set Up Games` tab on the top left.

- This concludes the setup for crowbar these settings will be saved and you will not need to do this again.


### Decompiling the model

- Click on the `Browse` button on the top right.
- Navigate to the folder you extracted the model to in the previous step.
- Select the `.mdl` file you want to decompile (for example `ptpov_vinson.mdl`).
- Press the `Decompile` button.
- Crowbar now decompiles the model and outputs the files to the `decompiled` folder in the same folder as the `.mdl` file.


## Step 3: Importing to Blender

- Open Blender.
- In the top left corner select `File` -> `Import` -> `Source Engine`.
- Navigate to the folder you extracted the model to in the previous step and select the `.qc` file (for example `ptpov_vinson.qc`) and uncheck the `Import Animations` box and check the `Create Collections` box.


## Step 4: Editing the model

!!! note
    This step is entirely up to you and depends on what you want to do with the model.
    In this example we will add a cube to the side of the Flatline and assign a custom material to it.

Before editing let me explain how the model is structured in Blender.
By selecting a qc file in the import menu we told Blender to import all SMD files referenced in that qc file.
This means that the model is split into multiple collections based on the SMD files referenced in the qc file.
For example the `ptpov_vinson.qc` file references the `ptpov_vinson_v_vinson.smd` file which contains the model for the Flatline.
For now the smd file will be imported into blender when you import the qc file, later we will change this to be an dmx file instead.

- Select the `ptpov_vinson_v_vinson.smd` mesh in the outliner.
- Enter `EDIT Mode`.
- In `EDIT Mode` add a cube to the side of the Flatline.
- Exit `EDIT Mode`.
- This cube should now be part of the `ptpov_vinson_v_vinson` mesh.
- Make sure that you now weight paint the cube to the correct bones.
- !!! note
    On Weapons the most safe bone to weight paint to is `def_c_base` since it is the root bone of the weapon. This means that the cube will always move with the weapon.
    If you want the cube to move with a specific part of the weapon you can also weight paint it to the bone that moves that part of the weapon.
    Again, remember to somewhat learn how rigging works in Blender to properly understand this process.

- Now that we have our cube we want to assign a material to it.


## Step 5: Assigning Materials

This step has two ways of being done, using a `qc` file that references `smd` files or references `dmx` files.
Usually the `smd` way is what you will want todo when first importing and editing a model, however if you want to reimport a EDITED model you will need to use the `dmx` way.

### Assigning Materials (smd)

This is the way you will usually do it when first importing a vanilla model that you have not edited yet.

- Enter `EDIT Mode`.
- Select the cube.
- In the `Material Properties` tab on the right click on the `New` button.
- Set the name of the material to its path in the game files, to learn more about materials and how to make them see [RPak Modding](rpakmodding.md) or [VTF Modding](VTFModding.md). (for example `models\weapons_r2\coolmaterial\cool_material`)
- Exit `EDIT Mode`.
- Your cube should now have the material assigned to it ingame after compiling.

### Assigning Materials (dmx)

This is the way you will usually do it when reimporting a model that you have edited.

- Enter `EDIT Mode`.
- Select the cube.
- In the `Material Properties` tab on the right click on the `New` button.
- Set the name of the material to its NAME in the game files

    !!! note
        with dmx files you can set the material path later on in the export menu. If you have multiple needed paths we will talk about that in the next step [Multiple Material Paths](#step-5-5-multiple-material-paths-dmx).
        This is why we set the name of the material to its name in the game files instead of its path.

- Exit `EDIT Mode`.
- Your cube should now have the material assigned to it ingame after compiling.

    !!! note
        To clearify: the material of a mesh or individual faces in the game will be associated using the name of the assigned material in Blender.


## Step 5.5: Multiple Material Paths (dmx)

If you have materials with multiple paths (different folders in the game files) you will want to use the `$renamematerial` command in the qc file.
Usage:

```text

        $renamematerial <current material> <new material>
```

Example:

```text

        $renamematerial "models\weapons_r2\coolmaterial\cool_material" "models\amazing\uncoolmaterial\cool_material2"
```

Command docs: [VALVe developer docs $renamematerial](https://developer.valvesoftware.com/wiki/$renamematerial)

## Step 6: Exporting from Blender

- In the `Source Engine Export` Menu in the `Scene Properties` select an `Export Path` usually the same folder as the original qc file.
- Set the `Export Format` to `DMX`.

    !!! note
        This is important since we want to export the model as a dmx file instead of an smd file, this is because of limitation in the smd format that we want to avoid.
        dmx by default will, uppon importing set a "material path" which is the path to the material in the game files, if you reimport this model later on you will need to

- Press the `Export` button and select `Scene Export` (this will export all meshes in the scene to DMX files, you can also individually export meshes by selecting them in the outliner and then pressing the `Export` button and selecting the mesh in the Export Menu).
- Your DMX files are now exported and you can close Blender.


## Step 7: Compiling the model

- Open your `.qc` file in a text editor of your choice.
- On the top of the file you will see so called "bodygroup" lines, these are used to define the bodygroups of the model. They look a bit like this:
    ```

            $bodygroup "body"
            {
                studio "ptpov_vinson_v_vinson.smd"
                blank
            }
    ```

- For each bodygroup you will want to change the files to be the dmx files you exported in the previous step. (in most cases its gonna be just renaming all the files to `.dmx` instead of `.smd`).

    !!! note

        If you have multiple bodygroups you will need to do this for each bodygroup, if you have multiple meshes in a bodygroup you will need to do this for each mesh in the bodygroup.
        We do this so Crowbar uses the dmx files instead of the smd files when compiling the model.

- Open Crowbar.
- Select the `Compile` tab on the top.
- Click on the `Browse` button on the top right.
- Select the `.qc` file you want to compile (for example `ptpov_vinson.qc`).
- Choose your game from the dropdown labeled `Games that has the model compiler` (for example `Portal 2`)
- Press the `Compile` button.
- Crowbar now compiles the model and outputs the files to the `compiled` folder in the same folder as the `.qc` file, inside the `compiled` folder you will find the full folder path of the model (for example `models\weapons\vinson\`).

    !!! note
        Usually the error is self explainatory and you can fix it by yourself.
        By default Crowbar will not output a compiled file if any errors occur during the compilation process.

        If you have Visual Studio Code installed you can also use the `Valve KeyValue Files Support` extension to have a better overview of the qc file, extension id: `GEEKiDoS.vdf`

## Step 8: Combining model files

- Open MDLShit.
- In a file explorer navigate to the compiled folder of your model (for example `compiled\models\weapons\vinson\`).
- In this folder you will find the `.mdl` file and multiple other files, in our case there will be 3 files `.mdl`, `.vvd` and `.vtx`) all with the same name.
- In MDLShit drag these into their respective boxes.
- Make sure they are checked and the boxes you dont have files for are unchecked.
- Press the `Check` button.
- Press the `Convert` button.
- MDLShit will now combine the files into a single `_conv.mdl` file, this is our final exported and working model you can now close MDLShit and use that model in a mod.



## Common errors

In this list the word `<filename>` will be used to refer to the name of the file that is causing the error and X will refer to a number depending on your file, `line` will refer to the line in the qc file that is causing the error.
The following words correspond to the following:

- `<filename>`: The name of the file that is causing the error.
- `<line>`: The line in the qc file that is causing the error.

`modelpath.qc(<line>): - could not load file '<<filename>.smd'`:
    This error means that the qc file is trying to reference a file that does not exist, make sure that the file is in the same folder as the qc file and that the name of the file is correct.
    If the above solution does not work think about if you need said file actually, if not you can remove it from the qc file. Or if you need it you can create it yourself.
    You can also see if a Physics or LOD file is the missing file, if it is make sure you have the correct settings in Crowbar for the file to be generated.

`Crowbar ERROR: The model compiler, "<filename>", does not exist.`

`Crowbar ERROR: The game's "<filename>" file does not exist.`
    Mostly happens if you did not properly set up Crowbar, make sure you set the `Game that has the model compiler` to [your prerequisite game](https://r2northstar.readthedocs.io/en/latest/guides/tools/MDLModding.html#prequisites).
