# Materials

in the new Repak materials are defined as their own, seperate jsons nested in the `assetsDir` of the repak map
Materials also need to be accompanied by a .uber file with the same name, see [UBER](#uber-files)

## Example material json

```json
{
    "name": "mymaterialname",
    "width": 4096,
    "height": 4096,
    "depth": 0,
    "glueFlags": "0x56000020",
    "glueFlags2": "0x100000",
    "blendStates": [
        "0xF0138004",
        "0xF0138004",
        "0xF0138004",
        "0x138004",
        "0x0",
        "0x0",
        "0x0",
        "0x0"
    ],
    "blendStateMask": "0x4",
    "depthStencilFlags": "0x17",
    "rasterizerFlags": "0x6",
    "uberBufferFlags": "0x0",
    "features": "0x40D33E8F",
    "samplers": "0x1D0300",
    "surfaceProp": "metal",
    "surfaceProp2": "",
    "shaderType": "skn",
    "shaderSet": "0xC3ACAF7F1DC7F389",
    "$textures": {
        "0": "texture/models/testmodel/emtpy.rpak",
        "1": "texture/models/testmodel/emtpy.rpak",
        "2": "texture/models/testmodel/emtpy.rpak",
        "3": "texture/models/testmodel/emtpy.rpak",
        "4": "texture/models/testmodel/emtpy.rpak",
        "11":"texture/models/testmodel/emtpy.rpak",
        "12": "texture/defaults/cav.rpak"
    },
    "$depthShadowMaterial": "0xA4728358C3B043CA",
    "$depthPrepassMaterial": "0x370BABA9D9147F3D",
    "$depthVSMMaterial": "0x12DCE94708487F8C",
    "$depthShadowTightMaterial": "0x0",
    "$colpassMaterial": "material/models/testmodel/mycoolmaterial_colpass_skn.rpak",
    "$textureAnimation": "0x0"
}
```

### Options

```name``` - string - Debug name of the material, will be omitted from the final `.rpak` if `keepDevOnly` is not set

```width``` - int - textures width in pixels (doesnt seem to actually have an effect in Titanfall 2, would still make accurate to your textures)
```height``` - int - textures height in pixels (doesnt seem to actually have an effect in Titanfall 2, would still make accurate to your textures)
```depth``` - int - texture depth (keep at 0, not used in titanfall 2)

```glueFlags``` - string - engine flag mask for material behavior
```glueFlags2``` - string - additional engine flag mask

```blendStates``` - array(string) - blend state values for different passes
```blendStateMask``` - string - blend state mask
```depthStencilFlags``` - string - depth-stencil configuration
```rasterizerFlags``` - string - rasterizer pipeline configuration
```uberBufferFlags``` - string - flags for the uber buffer of a material

```features``` - string - material features settings
```samplers``` - string - material samplers settings

```surfaceProp``` - string - primary surface property
```surfaceProp2``` - string - secondary surface property (used for blendmodulate materials)

```shaderType``` - string - (skn/fix/wld) most materials, for guns etc are skn
```shaderSet``` - string - shaderset used for the material

```$textures``` - json object - a key/value pair of key (slot number), value (texture path relative to `assetsDir`)
see [Texture Slots](#texture-slots) for more info

```$depthShadowMaterial``` - string - material used for shadow depth pass
```$depthPrepassMaterial``` - string - material used for prepass depth
```$depthVSMMaterial``` - string - material for VSM depth operations
```$depthShadowTightMaterial``` - string - tightshadow depth material

```$colpassMaterial``` - string - colpass material reference
```$textureAnimation``` - string - texture animation configuration, not used in Titanfall 2

!!! note
    ```shaderSet```
    ```depthShadowMaterial```
    ```depthPrepassMaterial```
    ```depthVSMMaterial```
    ```depthShadowTightMaterial```
    ```colpassMaterial```
    ```textures``` (the actual texture in the k/v pair)
    can all use a [GUID](../index.md#guid) instead of an relative string, in this case Repak will NOT pack a file for thoose and instead just write the guid as a reference in the final `.rpak`, this is usefull if you, for example want to overwrite a material but use the same textures it had before, enabling you to just pack the material and not all the textures but still use them

    At the same time, if these options are set to a string that you have in your `assetsDir` repak will automatically try to pack these dependencies, thus removing the need for you to add them to the main Repak `.json` map


### Texture Slots

these slots can differ from material/shader to material/shader but in general this is roughly how they are bound 99% of the time

```
1 Diffuse / Albedo / Color
2 Normal
3 Glossiness
4 Specular
5 Emissive
6
7
8
9
10
11
12 Ambient Occlusion
13 Cavity
14 Opacity / Alpha map
15 detail Color / Camo
16 Detail Normal
17 Mask map
18
19
20
21
22
23 Blendmap
24 Diffuse / Albedo / Color (used for blendmap materials)
25 Normal (used for blendmap materials)
26 Glossiness (used for blendmap materials)
27 Specular (used for blendmap materials)
```

### Uber Files

Uber files are binary files that [RSX](https://github.com/r-ex/rsx) can export from a material, these files are the raw Uber Buffer of a material, you need one to pack a material as Repak will try to include it.
You can find a simple [ImHex](https://github.com/WerWolv/ImHex) pattern for them [here](https://github.com/EM4Volts/rspn_imhex_patterns/blob/main/Titanfall2/CBufUberStatic.hexpat
)