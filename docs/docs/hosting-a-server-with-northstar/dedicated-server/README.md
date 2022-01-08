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
|<a name="Startup_args-plstovrd">`+setplaylistvaroverrides`</a> | see [PlaylistOverrides](#PlaylistOverrides) | Edits the behaviour of the server                  |
| `-port`                                                       | int beteween `1-65535`                      | Determines which UDP port the server will listen to|
| <a name="Startup_args-mpgamemode">`+mpgamemode`</a>           | see [Gamemodes](#Gamemodes)                 | Forces the gamemode of the server                  |


| Flags                                                         | Description                                                                 |
|---------------------------------------------------------------|-----------------------------------------------------------------------------|
| <a name="Startup_flags-maxplrplst">`-maxplayersplaylist`</a>  | Allows [PlaylistOverrides](#PlaylistOverrides) to override max player count |

### <a name="PlaylistOverrides">Playlist overrides</a>
Playlist overrides determines the behaviour of the server. PlaylistOverrides can be added using the `+setplaylistvaroverrides` argument in the `ns_startup_args_dedi.txt` file.

The list of playlist overrides needs to be quoted and separated by spaces (example : `+setplaylistvaroverrides "run_epilogue 0 featured_mode_amped_tacticals 1"`)

| PlaylistOverrides                            | Accepted Values      | Default Value   | Description                                                                              |
|----------------------------------------------|----------------------|-----------------|------------------------------------------------------------------------------------------|
| `max_players`                                |                      |                 | Needs to be in combination with the [`-maxplayersplaylist`](#Startup_flags-maxplrplst) flag |
| `custom_air_accel_pilot`                     |                      |                 |                                                                                          |
| `pilot_health_multiplier`                    |                      |                 |                                                                                          |
| `run_epilogue`                               | `0-1`                | `1`             | Enables escape dropship                                                                  |
| `respawn_delay`                              |                      |                 |                                                                                          |
| `boosts_enabled`                             | `0-1`                | `1`             | Enable boosts. Doesn't disables Titanmeter.                                              |
| `earn_meter_pilot_overdrive`                 | `0-1`                |                 |                                                                                          |
| `earn_meter_pilot_multiplier`                |                      |                 |                                                                                          |
| `earn_meter_titan_multiplier`                |                      |                 |                                                                                          |
| `aegis_upgrades`                             | `0-1`                | `0`             |                                                                                          |
| `infinite_doomed_state`                      | `0-1`                |                 |                                                                                          |
| `titan_shield_regen`                         | `0-1`                | `0`             |                                                                                          |
| `scorelimit`                                 |                      |                 |                                                                                          |
| `roundscorelimit`                            |                      |                 |                                                                                          |
| `timelimit`                                  |                      |                 |                                                                                          |
| `oob_timer_enabled`                          | `0-1`                |                 |                                                                                          |
| `roundtimelimit`                             |                      |                 |                                                                                          |
| `classic_rodeo`                              | `0-1`                |                 |                                                                                          |
| `classic_mp`                                 | `0-1`                | `1`             | Enables intro dropship                                                                   |
| `fp_embark_enabled`                          |                      |                 |                                                                                          |
| `promode_enable`                             | `0-1`                | `0`             |                                                                                          |
| `riff_floorislava`                           | `0-1`                | `0`             | Covers the whole map with deadly electric smoke                                          |
| `featured_mode_all_holopilot`                | `0-1`                | `0`             |                                                                                          |
| `featured_mode_all_grapple`                  | `0-1`                | `0`             |                                                                                          |
| `featured_mode_all_phase`                    | `0-1`                | `0`             |                                                                                          |
| `featured_mode_all_ticks`                    | `0-1`                | `0`             |                                                                                          |
| `featured_mode_tactikill`                    | `0-1`                | `0`             |                                                                                          |
| `featured_mode_amped_tacticals`              | `0-1`                | `0`             |                                                                                          |
| `featured_mode_rocket_arena`                 | `0-1`                | `0`             |                                                                                          |
| `featured_mode_shotguns_snipers`             | `0-1`                | `0`             |                                                                                          |
| `iron_rules`                                 | `0-1`                | `0`             | Disables ejection and disembark                                                          |
| `riff_player_bleedout`                       |                      |                 |                                                                                          |
| `player_bleedout_forceHolster`               |                      |                 |                                                                                          |
| `player_bleedout_forceDeathOnTeamBleedout`   |                      |                 |                                                                                          |
| `player_bleedout_bleedoutTime`               |                      |                 |                                                                                          |
| `player_bleedout_firstAidTime`               |                      |                 |                                                                                          |
| `player_bleedout_firstAidTimeSelf`           |                      |                 |                                                                                          |
| `player_bleedout_firstAidHealPercent`        |                      |                 |                                                                                          |
| `player_bleedout_aiBleedingPlayerMissChance` |                      |                 |                                                                                          |

### <a name="Gamemodes">Gamemodes</a>
Gamemodes can be forced by the server using the [`+mpgamemode`](#Startup_args-mpgamemode) [startup arg](#Startup_args)

if ran on a server with 

| Value           | Description                  |
|-----------------|------------------------------|
| `private_match` | Private Match                |
| `ps`            | Pilots vs Pilots             |
| `gg`            | Gungame                      |
| `tt`            | Titan Tag                    |
| `inf`           | Infected                     |
| `fastball`      | Fastball                     |
| `ctf_comp`      | Competitive Capture the Flag |
| `hs`            | Hide and Seek                |
| `cp`            | Hardpoint                    |
| `lts`           | Last Titan Standing          |
| `ctf`           | Capture the Flag             |
| `ttdm`          | Titan Brawl                  |
| `turbo_ttdm`    | Turbo Titan Brawl            |
| `attdm`         | Aegis Titan Brawl            |
| `ffa`           | Free for all                 |
| `fra`           | Free Agents                  |
| `coliseum`      | Coliseum                     |
| `lf`            | Live Fire                    |
| `rocket_lf`     | Rocket Arena                 |
| `mfd`           | Marked for Death             |
