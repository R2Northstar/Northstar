# Hosting a Dedicated Server

## Setup

Dedicated servers allow you to host a Northstar server without having to use a full client, making them more lightweight and easier to host for longer periods of time. Dedicated servers are still in development for Northstar, so while they do work, expect some bugs and general jank.\
To start a dedicated server on Northstar, launch NorthstarLauncher.exe with the argument `-dedicated`, this can be done manually, but releases also provide the batch file `r2ds.bat`, which will also do this.\
When using a dedicated server, arguments are read from `ns_startup_args_dedi.txt`, rather than `ns_startup_args.txt`.

### Useful configuration files
* `ns_startup_args_dedi.txt`\
   contains the [startup arguments](#Startup_args)
* `R2Northstar\mods\Northstar.CustomServers\mod.json`\
   contains ConVars and their default values
* `R2Northstar\mods\Northstar.CustomServers\mod\cfg\autoexec_ns_server.cfg`\
   contains the server name, port, and description

## Dedicated Server Caveats

At the moment, dedicated servers still require DirectX 11 to work, which typically requires a physical GPU, though they use almost no GPU processing power while in use, this can be an issue especially on GPU-less setups, so the launch argument `-softwared3d11` can be used to force DirectX to run in software mode.\
While this is absolutely not ideal, it's the best solution for truely headless dedicated servers at the moment, and surprisingly hardly uses any CPU time, though it can use roughly up to 1GB of RAM.\
Regarding RAM usage, dedicated servers also use significant amounts of RAM at the moment, often requiring 1.5-2GB, though I expect this to lower as development continues.

## <a name="Startup_args">Startup Arguments</a>
Startup arguments can be added in the `ns_startup_args_dedi.txt` file.

| Arguments                                                     | Accepted Values                             | Description                                        |
|---------------------------------------------------------------|---------------------------------------------|----------------------------------------------------|
| `+setplaylist`                                                | `private_match`                             | Currently needed to make servers work              |
| `port`                                                        | int beteween `1-65535`                      | Determines which UDP port the server will listen to|
|<a name="Startup_args-plstovrd">`+setplaylistvaroverrides`</a> | see [PlaylistOverrides](#PlaylistOverrides) | Edits the behaviour of the server                  |

| Flags                  | Description                                 |
|------------------------|---------------------------------------------|
| `-maxplayersplaylist`  | Allows convars to override max player count |

### <a name="PlaylistOverrides">PlaylistOverrides</a>
PlaylistOverrides determines the behaviour of the server. PlaylistOverrides can be added using the `+setplaylistvaroverrides` argument in the `ns_startup_args_dedi.txt` file.

| PlaylistOverrides      | Accepted Values | Description                                        |
|------------------------|-----------------|----------------------------------------------------|
| `+setplaylist`         | `private_match` | Currently needed to make servers work              |
| `port`                 | `1-65535`       | Determines which UDP port the server will listen to|
