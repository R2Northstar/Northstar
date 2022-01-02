# Getting Started

## Basics

This guide assumes you have basic understanding with programming and know how to use developer environments. Listed below are tools useful for exporting file formats

If you'd like a more lengthy set of tutorials covering many topics. Look at:

{% content-ref url="squirrel/what-is-squirrel.md" %}
[what-is-squirrel.md](squirrel/what-is-squirrel.md)
{% endcontent-ref %}

> TODO: Actually link tools

### Tools

* RSPNVPK
* Cra0 VPK Tool (Titanfall VPK Tool)
* Legion by DZXTPorter

## Quick start

In order to get started with making your mod, create a folder in `R2Northstar/mods`. While it isn't required, it is best practise by mod authors to follow the naming scheme "Author.ModName", such as "Northstar.Client".

After making this folder, inside it add a folder named `mod` and a file named `mod.json`.

Provided is a template `mod.json`, for a detailed list of values read [Cheatsheet](tutorials/modding-tutorials.md)

```json
{
    "Name": "My.Mod",
    "Description": "Woo yeah wooo!",

    "LoadPriority": 0,
    "ConVars": [],
    "Scripts": [],
    "Localisation": []
}
```

Inside the `mod` folder, existing files found in the engine's virtual file system will be overwritten and new files can be added. If you need to define new Squirrel files (.nut/.gnut) they _must_ be declared in the `"Scripts"` array in `mod.json`. An example for this might be:

```json
    "Scripts": [
        {
            "Path": "path/to/my.nut",
            "RunOn": "( CLIENT || SERVER ) && MP"
        },
        {
            "Path": "path/to/my_second.nut",
            "RunOn": "( CLIENT || SERVER ) && MP",
            "ClientCallback": {
                "Before": "ClientPreMapspawnThing",
                "After": "AfterMapspawnClientThing"
            },
            "ServerCallback": {
                "Before": "ServerPreMapspawncrap",
                "After": "ServerAfterMapspawnWoo"
            }
        }
    ]
```

> TODO: Create and link Squirrel VM documentation

`"Path"` indicates where the script is, `"RunOn"` is the Squirrel VM context (see [Squirrel VM](getting-started.md)) as an expression, and `"ClientCallback"` and `"ServerCallback"` specify a function call that can be `"Before"` and/or `"After"` map-spawn.
