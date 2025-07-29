# Shader Modding

Docs about shaders inside of Titanfall 2's rpak system

## Prerequisites

- [The latest release of RSX](https://github.com/r-ex/rsx/releases)
- [The latest release of repak](https://github.com/r-ex/RePak/releases)
- [MSWUnpacker](https://github.com/RoyalBlue1/MSWUnPacker) (you will need to build this yourself)
- [MSW Shaderset Modifier](https://github.com/EM4Volts/MSW_shds_modifier)
- A working decompiler for dxbc shaders, we will use [HLSLDecompiler](https://github.com/zxxyye/HLSLDecompiler)
- The "Effect Compiler Tool" from Microsoft, source this from a [compatible DirectX SDK](https://www.microsoft.com/en-us/download/details.aspx?id=6812) or download from [My uploaded one](https://mega.nz/file/jYsUkKbD#Vur3NnpoP25xrZ-UMAgH8Edo7i1o5nGbqFA7XWyIthk)
- A modern installation of [Python](https://www.python.org/downloads/)



!!! note
    These docs are not going to teach you how to write shaders, or any basic HLSL.
    Refer to the many online resources for thoose topics to learn them.



# The Basics

!!! note
    In RSX make sure that the export for Shaders and Shadersets are both set to `.msw`

In rpak's there are two type of assets related to shaders, `Shadersets [shds]` and `Shaders [shdr]`.

A Shader asset is comprised of multiple (mostly 1-15) individual compiled shader files, alone they do nothing and are useless inside an rpak.
A Shaderset asset is a pretty small definition of, well, a set of two Shader assets, a Vertex and a Pixel Shader. This is what a Material references so the game knows what combination of Vertex and Pixel shader to use for said Material.

So, to figure out what shader you want to modify, or what shader you want to use as a base you need to find the shaderset used in a Material u want to replicate, then find the individual Shaders, this is pretty easy via RSX.

If after unpacking the exported shader you are unsure which compiled `.fxc` file to modify try the first one first, most of the time its `0.fxc`.



# Unpacking your Shader

Once you found a shader you will need to unpack the `.msw` file.
Do so using the [MSWUnpacker](https://github.com/RoyalBlue1/MSWUnPacker) with the commandline.

``` .\MSWUnPacker.exe unpack <your msw file> ```

The unpacked shader files will now be in a newly created folder named after your ```.msw``` file.

# Repacking your Shader

Once you have done your modifications to the Shader's `.fxc` files you'll want to pack it back into a .msw to use in repak
Do so using the [MSWUnpacker](https://github.com/RoyalBlue1/MSWUnPacker) with the commandline.

``` .\MSWUnPacker.exe pack <your shader folder> ```

There should be an packed `.msw` file next to the unpacked shader folder.

# Decompiling your Shader

To decompile the compiled `.fxc` file to a readable, and recompilable file use the [HLSLDecompiler](https://github.com/zxxyye/HLSLDecompiler)
Do so using the commandline

``` .\cmd_Decompiler.exe -D <your fxc file> ``` 

!!! note
    Make sure to use a capital D, a lowercase d will not decompile but instead disassemble.

# Compiling your Shader

You can compile your modified `.hlsl` file using the Effect Compiler Tool mentioned in the Prerequisites.

Firstly you need to know which shader model you are compiling to.

If you are compiling a pixel shader its propably gonna be ps_5_0
If you are compiling a vertex shader its propably gonna be vs_5_0

Should you be unsure of which model your shader is supposed to be disassemble your original `.fxc` file using the `-d` option and you will see the model as the first line underneath the commented signatures.

To compile your `.hlsl` file do so using the commandline.

``` ./fxc.exe /T <shadermodel> /Fo <output fxc filename> <input hlsl filename> ```

This will attempt to compile your `.hlsl` source file, if it fails it will show you warnings and errors for you to track down issues.


# Making a new Shaderset
Its quite important to make a new Shaderset for your modified Shader if its supposed to only appear on a single Material of your choice instead of overwriting the original Shader and Shaderset.

Next we make sure that both our vertex shader and pixel shader have unique names.
Usually we wanna name them in a way that makes them recognizable, in my example i would name them something like `uberCustomShaderEM4Vtestshader_vs.msw` and `uberCustomShaderEM4Vtestshader_ps.msw`.
Note the Sufix's of `_vs` and `_ps` for vertex and pixel shader respectivly.
From here on out do not change their names again as these are quite important from here on out to properly link everything later on in the `.rpak` file.

Lets get the GUID's of the shaders now, for this open a Commandline next to `repak` and execute the following, replacing <yourshader> with the name of your shader without its file extension:

``` .\RePak.exe -pakguid shader/<yourshader>.rpak```

Do this for both your vertex and pixel shader.

Now get your base Shaderset `.msw` file and put it next to the [MSW Shaderset Modifier](https://github.com/EM4Volts/MSW_shds_modifier) python script.

Execute the script in a Commandline using the base `.msw` file as an argument.
The script will now ask you for the GUID's of the shaders, enter the output given from repak and then enter a new name for your shaderset when prompted.
A new `.msw` file will now have been generated.


# Paking the `.rpak`

In order to pack the shaders and shaderset into an .rpak first prepare the following folder structure somewhere, with the json having whatever name you want:

```
Main Folder
├── RePak.exe
├── <mapname>.json
└── assets
    ├── shader
    └── shaderset
```

Now open the `.json` file and copy in the following example repak map:

```
{
  "keepDevOnly": true,
  "version": 7,
  "name": "example_map",
  "streamFileMandatory": "example_map.starpak",
  "assetsDir": "assets",
  "outputDir": "out/",
  "compressLevel": 0,
  "compressWorkers": 16,
  "files": [
    {
      "_type": "shdr",
      "_path": "shader/<shadername_ps>.rpak"
    },
    {
      "_type": "shdr",
      "_path": "shader/<shadername_vs>.rpak"
    },
    {
      "_type": "shds",
      "_path": "shaderset/<shadersetname>.rpak"
    }
    ]
} 
```

Replace the <> names with your file names without the `.msw` extension.

Now open a Commandline and execute

``` ./RePak.exe <mapname>.json ```

Repak should now spit out an `.rpak` file with the Shaderset and Shaders packed which you can now use in your mod.
