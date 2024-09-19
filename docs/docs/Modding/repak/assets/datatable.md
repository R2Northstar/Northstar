# Datatables

## Examples:

### 1. Example Datatable Asset

```json

    {
        "$type": "dtbl",
        "path": "datatable/custom_datatable",
    }
```

### 2. Example Datatable `.csv` File


|`setFile`|`titanRef`|`difficulty`|`isPrime`|`coreBuildingIcon`|
|---------|----------|------------|---------|------------------|
|`titan_buddy`|`bt`|`1`|`0`|`rui\titan_loadout\core\titan_core_burst_core`|
|`titan_atlas_tracker`|`tone`|`2`|`0`|`rui\titan_loadout\core\titan_core_salvo`|
|`titan_ogre_meteor`|`scorch`|`3`|`0`|`rui\titan_loadout\core\titan_core_flame_wave`|
|`string`|`string`|`int`|`bool`|`asset`|


## Asset Structure:

### `$type`

For an asset to be a datatable asset, the `$type` field must be `"dtbl"`.

### `path`

The `path` field of a datatable asset is used to determine the location in the RPak's `assetsDir` that the `.csv` file is in.

!!! warning
    If the .csv file has no columns, RePak will output the following warning to the console, before skipping the asset.
    `Attempted to add dtbl asset with no columns. Skipping asset...`

!!! warning
    If the .csv file has fewer than 2 rows, RePak will output the following warning to the console, before skipping the asset.
    `Attempted to add dtbl asset with invalid row count. Skipping asset...
    DTBL    - CSV must have a row of column types at the end of the table`


## File Structure:

The file must be a valid `.csv` file, with at least 2 rows, and at least 1 column.

The final row of the `.csv` determines the type of each column, and each entry must be one of the following values:

* `bool` - either `0` (false) or `1` (true)
* `int` - any integer value
* `float` - any float value
* `vector` - three float values in the format `<val1,val2,val3>`
* `string` - any string value
* `asset` - any string value (must be a valid asset)
* `assetnoprecache` - any string value (must be a valid asset)
