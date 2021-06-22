### Assets


## Datatable
```json
{
    "_type": "dtbl",
    "_path": "datatable/custom_datatable",
}
```
see [Datatable](datatable.md) for more info about Datatables

## Material
```json
{
    "_type": "matl",
    "_path": "material/models/testmodel/test_m_skn.rpak"
}
```
see [Material](material.md) for more info about Materials

## Texture
```json
{
    "_type": "txtr",
    "_path": "texture/models/testmodel/test_col.rpak"
}
```
Textures have to be in one of the following `.dds` compression types:
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

## Shader
```json
{
  "_type": "shdr",
  "_path": "shader/uberVcoltVcolaCutSamp2222_wld_ps.rpak"
}
```
see [ShaderModding](../../guides/tools/ShaderModding.md) for more info about Shaders

## Shaderset
```json
{
  "_type": "shds",
  "_path": "shaderset/uberCutSamp2222_fix.rpak"
}
```
see [ShaderModding](../../guides/tools/ShaderModding.md) for more info about Shadersets

## UIAtlas

see [UIAtlas](uiatlas.md) for more info about how to define Image Atlases

## UI
```json
{
    "_type": "ui",
    "_path": "ui/crosshair_testgun.rpak"
}
```
ui docs, for sere TBD
