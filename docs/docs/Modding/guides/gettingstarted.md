# Getting Started

Northstar supports the creation of many user mods. This guide will teach you the basics
of modding to get you started.

Check out the `usage` section for further information, including
`installation`.

## Basics

This guide assumes you have basic understanding with programming and know how to use
developer environments. Listed below are tools useful for exporting file formats.

If you'd like a more lengthy set of tutorials covering many topics. Look at: [NoSkill modding guide](https://noskill.gitbook.io/titanfall2/)

## Tools

To get started with modding for Northstar, we recommend getting yourself some tools.
Check out the `tools` section for more information.

## Quick Start

In order to get started with making your mod, create a folder in `R2Northstar/mods`.
While it isn't required, it is best practise by mod authors to follow the naming scheme
`Author.ModName`, such as `Northstar.Client`.

After making this folder, inside it add a folder named `mod` and a file named
`mod.json`.

Provided is a template `mod.json`, for a detailed list of values read the
`cheatsheet`

```json
    {
       "Name": "Yourname.Modname",
       "Description": "Woo yeah wooo!",

       "LoadPriority": 0,
       "ConVars": [],
       "Scripts": [],
       "Localisation": []
    }
```

Inside the `mod` folder, existing files found in the engine's virtual file system will
be overwritten and new files can be added. If you need to define new Squirrel files
`(.nut/.gnut)` they *must* be declared in the `"Scripts"` array in `mod.json`. An
example for this might be:

```json
    "Scripts": [
       {
          "Path": "path/to/file.nut",
          "RunOn": "( CLIENT || SERVER ) && MP"
       },
       {
          "Path": "path/to/another_file.nut",
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

`"Path"` indicates where the script is, `"RunOn"` is the Squirrel VM context (see
`../native/sqvm`) as an expression, and `"ClientCallback"` and
`"ServerCallback"` specify a function call that can be `"Before"` and/or `"After"`
map-spawn.

## Detailed `mod.json` architecture

Located at your mod's root folder, the `mod.json` file is the entrypoint of your mod;
it contains human-readable information about it, which scripts to load, and a bunch of
interesting stuff.

This guide will dig into each of the possible `mod.json` fields. Please note that
`mod.json` keys must start with an uppercase letter.

This is what a well-formatted `mod.json` looks like:

```json
    {
        "Name": "Northstar.CustomServers",
        "Description": "Attempts to recreate the behaviour of vanilla Titanfall 2 servers, as well as changing some scripts to allow better support for mods",
        "Version": "1.5.0",
        "LoadPriority": 0,
        "ConVars": [
            {
                "Name": "ns_private_match_last_mode",
                "DefaultValue": "tdm"
            },
            {
                "Name": "ns_private_match_last_map",
                "DefaultValue": "mp_forwardbase_kodai"
            }
        ],
        "Scripts": [
            {
                "Path": "sh_northstar_utils.gnut",
                "RunOn": "CLIENT || SERVER || UI"
            },
            {
                "Path": "mp/_classic_mp_dropship_intro.gnut",
                "RunOn": "SERVER && MP"
            }
        ],
        "Localisation": [
            "resource/northstar_custom_%language%.txt"
        ]
    }
```

!!! note

    The real `Northstar.CustomServers` mod contains more convars and scripts, some
    have been removed for the readability of the example.

### Name and description

Those ones are pretty self-explanatory. Both fields are used by Northstar itself to
display in-game information about your mod in the main screen `Mods` menu.

Best pratice for your mod's name is to use the `Author.ModName` convention.

### Version

This field specifies version of your mod using `X.Y.Z` scheme; this field must be
updated each time you release a new version of your mod.

Common use is to increase *Z* when you publish a fix (*e.g.* `1.5.0` to `1.5.1`),
and increase *Y* when you release new features (*e.g.* `1.5.1` to `1.6.0`).

Best practise is to follow semantic versioning (https://semver.org/).

### LoadPriority

This field defines the order in which all mods will be loaded by Northstar. For example,
a mod with `"LoadPriority": 1` will be loaded after a mod with `"LoadPriority": 0`.

If your mod uses code from another mod, make sure to set a greater LoadPriority than the
mod you're using code from.

### ConVars

This field lists configuration variables, that can be set by servers owners to modify
behaviour of your mod.

Each configuration variable must have a `"Name"` and a `"DefaultValue"`. ConVars can
also have an optional `"Flags"` field which specifies special behaviour and an
optional `"HelpString"` field which specifies the usage of the ConVar which can be
view in-game by running `help <convar>`.

You can access configuration variables from squirrel code using `GetConVarInt`,
`GetConVarFloat`, `GetConVarBool` or `GetConVarString` calls.

!!! warning

    No matter the type of your variables, they have to be JSON strings, otherwise game
    won't start!

#### Example

If I don't want to wait 15 seconds for matches to start on my server,
`Northstar.CustomServers` mod exposes a ConVar named
`ns_private_match_countdown_length` in its `mod.json` manifesto:

```json
    "ConVars": [
        {
            "Name": "ns_private_match_countdown_length",
            "DefaultValue": "15"
        },

        ...
    ]
```

I can setup the `ns_private_match_countdown_length` variable in my
`R2Northstar/mods/Northstar.CustomServers/mod/cfg/autoexec_ns_server.cfg`
configuration file.

When starting a match, `Northstar.CustomServers` mod will retrieve the configuration
variable value, or its default value if it hasn't been specified in configuration file:

```squirrel
    // start countdown
    SetUIVar( level, "gameStartTime", Time() + GetConVarFloat( "ns_private_match_countdown_length" ) )
```

!!! note

    All `Northstar.CustomServers` ConVars are listed here:
    https://r2northstar.gitbook.io/r2northstar-wiki/hosting-a-server-with-northstar/basic-listen-server

#### Flags

You can assign flags to configuration variables; to use several flags at once, just add
their values.

|Name|Value|Description|
|----|-----|-----------|
|FCVAR_UNREGISTERED|1|If this is set, don't add to linked list, etc.|
|FCVAR_DEVELOPMENTONLY|2|Hidden in released products. Flag is removed automatically if ALLOW_DEVELOPMENT_CVARS is defined.|
|FCVAR_GAMEDLL|4|Defined by the game DLL|
|FCVAR_CLIENTDLL|8|Defined by the client DLL|
|FCVAR_HIDDEN|16|Hidden. Doesn't appear in find or auto complete. Not deterred by ALLOW_DEVELOPMENT_CVARS.|
|FCVAR_PROTECTED|32|It's a server cvar, but we don't send the data since it's a password, etc. Sends 1 if it's not bland/zero, 0 otherwise as value.|
|FCVAR_SPONLY|64|This cvar cannot be changed by clients connected to a multiplayer server.|
|FCVAR_ARCHIVE|128|Save this ConVar's value to vars.rc - this works both server and client-side.|
|FCVAR_NOTIFY|256|Notifies players when this ConVar's value was changed.|
|FCVAR_USERINFO|512|Changes the client's info string|
|FCVAR_PRINTABLEONLY|1024|This cvar's string cannot contain unprintable characters ( e.g., used for player name etc ).|
|FCVAR_UNLOGGED|2048|If this is a FCVAR_SERVER, don't log changes to the log file / console if we are creating a log|
|FCVAR_NEVER_AS_STRING|4096|never try to print that cvar|
|FCVAR_REPLICATED (AKA FCVAR_SERVER)|8192|This value is set by server and replicated by clients.|
|FCVAR_CHEAT|16384|Do NOT allow changing of this convar by console, unless sv_cheats is 1.|
|FCVAR_SS|32768|causes varnameN where N == 2 through max splitscreen slots for mod to be autogenerated|
|FCVAR_DEMO|65536|Record this cvar in a demo.|
|FCVAR_DONTRECORD|131072|Don't record this.|
|FCVAR_SS_ADDED|262144|This is one of the "added" FCVAR_SS variables for the splitscreen players|
|FCVAR_RELEASE|524288|This value is available to the end user.|
|FCVAR_RELOAD_MATERIALS|1048576|If this cvar changes, it forces a material reload|
|FCVAR_RELOAD_TEXTURES|2097152|If this cvar changes, it forces a texture reload|
|FCVAR_NOT_CONNECTED|4194304|cvar cannot be changed by a client that is connected to a server|
|FCVAR_MATERIAL_SYSTEM_THREAD|8388608|Indicates this cvar is read from the material system thread|
|FCVAR_ARCHIVE_PLAYERPROFILE|16777216|Save this, but to profile.cfg instead - meaning this only works for clients.|
|FCVAR_ACCESSIBLE_FROM_THREADS|33554432|used as a debugging tool necessary to check material system thread convars|
|FCVAR_SERVER_CAN_EXECUTE|268435456|the server is allowed to execute this command on clients via ClientCommand/NET_StringCmd/CBaseClientState::ProcessStringCmd|
|FCVAR_SERVER_CANNOT_QUERY|536870912|If this is set, then the server is not allowed to query this cvar's value (via IServerPluginHelpers::StartQueryCvarValue).|
|FCVAR_CLIENTCMD_CAN_EXECUTE|1073741824|IVEngineClient::ClientCmd is allowed to execute this command. Note: IVEngineClient::ClientCmd_Unrestricted can run any client command.|

!!! note

    Some flags have been skipped due to them being generally useless unless you have
    very specific requirements.

### Scripts

The scripts field lets you declare an array of Squirrel files to import into your mod.

Each script entry must have a "Path" value and a "RunOn" value.

```json
     "Scripts": [
         {
             "Path": "path/to/file.nut",
             "RunOn": "( CLIENT || SERVER ) && MP"
         },
         {
             "Path": "path/to/another_file.nut",
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

#### Path

Path of the Squirrel file to import, without `mod/scripts/vscripts` prefix (that's
where your script files should go).

#### RunOn

A boolean expression which tells the game when and in which context to compile the script.


|Name|Description|
|----|-----------|
|SERVER|Server script VM, recompiles on map change|
|CLIENT|Client script VM, recompiles on map change|
|UI|UI script VM, recompiles on when `uiscript_reset` is ran|
|SP|Singleplayer|
|MP|Multiplayer|
|DEV|Value of developer convar|
|LOBBY|True in mp_lobby. (Server and client VMs only)|
|MAP_mp_box|True if the given map name is being loaded|
|GAMEMODE_at|True if the given game mode is being loaded|

`CLIENT && !LOBBY` - Compiles on client and not in the lobby. So during actual singeplayer and multiplayer gameplay.

`CLIENT && MP && !LOBBY` - Compiles on client, only in multiplayer and not in the lobby.

`( CLIENT || SERVER ) && MP` - Compiles on both client and server only in multiplayer.

`CLIENT && SP && MAP_sp_boomtown` - Compiles only on client in singleplayer only when the map `sp_boomtown` is loaded. ( Here `SP` isn't needed as `sp_boomtown` is singleplayer only )

`CLIENT && GAMEMODE_aitdm` - Compiles on client on both singleplayer and multiplayer only when the `aitdm` gamemode is set. ( `aitdm` is attrition which is multiplayer only so this script only compiles on multiplayer )


#### ClientCallback / ServerCallback

Specify methods that will be called before/after map spawn.

### Localisation

This field is an array listing localisation files relative paths.

For more info about localisation works on Northstar, read the `localisation`
section.

!!! note

    This project is under active development.
