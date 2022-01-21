# Hosting a Dedicated Server

## Hosting a Dedicated Server

### Setup

Dedicated servers allow you to host a Northstar server without having to use a full client, making them more lightweight and easier to host for longer periods of time. Dedicated servers are still in development for Northstar, so while they do work, expect some bugs and general jank.\
To start a dedicated server on Northstar, launch NorthstarLauncher.exe with the argument `-dedicated`, this can be done manually, but releases also provide the batch file `r2ds.bat`, which will also do this.\
When using a dedicated server, arguments are read from `ns_startup_args_dedi.txt`, rather than `ns_startup_args.txt`.

#### Useful configuration files

* `ns_startup_args_dedi.txt`\
  contains the [startup arguments](./#startup-arguments)
* `R2Northstar\mods\Northstar.CustomServers\mod.json`\
  contains [ConVars](./#convars) default values
* `R2Northstar\mods\Northstar.CustomServers\mod\cfg\autoexec_ns_server.cfg`\
  contains [ConVars](./#convars) and overrides `R2Northstar\mods\Northstar.CustomServers\mod.json`

### Dedicated Server Caveats

At the moment, dedicated servers still require DirectX 11 to work, which typically requires a physical GPU, though they use almost no GPU processing power while in use, this can be an issue especially on GPU-less setups, so the launch argument `-softwared3d11` can be used to force DirectX to run in software mode.\
While this is absolutely not ideal, it's the best solution for truely headless dedicated servers at the moment, and surprisingly hardly uses any CPU time, though it can use roughly up to 1GB of RAM.\
Regarding RAM usage, dedicated servers also use significant amounts of RAM at the moment, often requiring 1.5-2GB, though I expect this to lower as development continues.

### Troubleshoot

See [troubleshoot](troubleshoot.md)

## Startup Arguments

Startup arguments can be added in the `ns_startup_args_dedi.txt` file.

| Arguments                  | Accepted Values                                | Description                                         |
| -------------------------- | ---------------------------------------------- | --------------------------------------------------- |
| `+setplaylist`             | `private_match`                                | Currently needed to make servers work               |
| `+setplaylistvaroverrides` | see [PlaylistOverrides](./#playlist-overrides) | Edits the behaviour of the server                   |
| `-port`                    | int beteween `1-65535`                         | Determines which UDP port the server will listen to |
| `+mpgamemode`              | see [Gamemodes](./#gamemodes)                  | Forces the gamemode of the server                   |

| Flags                 | Description                                                                    |
| --------------------- | ------------------------------------------------------------------------------ |
| `-maxplayersplaylist` | Allows [PlaylistOverrides](./#playlist-overrides) to override max player count |

### Playlist overrides

Playlist overrides determines the behaviour of the server. PlaylistOverrides can be added using the `+setplaylistvaroverrides` argument in the `ns_startup_args_dedi.txt` file.

The list of playlist overrides needs to be quoted and separated by spaces (example : `+setplaylistvaroverrides "run_epilogue 0 featured_mode_amped_tacticals 1"`)

| PlaylistOverrides                            | Accepted Values | Default Value | Description                                                                                    |
| -------------------------------------------- | --------------- | ------------- | ---------------------------------------------------------------------------------------------- |
| `max_players`                                | `int`           |               | Needs to be in combination with the [`-maxplayersplaylist`](./#Startup\_flags-maxplrplst) flag |
| `custom_air_accel_pilot`                     |                 |               |                                                                                                |
| `pilot_health_multiplier`                    |                 |               |                                                                                                |
| `run_epilogue`                               | `0-1`           | `1`           | Enables escape dropship                                                                        |
| `respawn_delay`                              |                 |               | Delay before respawn                                                                            |
| `boosts_enabled`                             | `0-1`           | `1`           | Enable boosts. Doesn't disables Titanmeter.                                                    |
| `earn_meter_pilot_overdrive`                 | `0-1`           |               |                                                                                                |
| `earn_meter_pilot_multiplier`                |                 |               |                                                                                                |
| `earn_meter_titan_multiplier`                |                 |               |                                                                                                |
| `aegis_upgrades`                             | `0-1`           | `0`           | Enable titan aegis upgrades                                                                    |
| `infinite_doomed_state`                      | `0-1`           |               |                                                                                                |
| `titan_shield_regen`                         | `0-1`           | `0`           | Enable regenerating titan shields                                                             |
| `scorelimit`                                 |                 |               |                                                                                                |
| `roundscorelimit`                            |                 |               |                                                                                                |
| `timelimit`                                  |                 |               |                                                                                                |
| `oob_timer_enabled`                          | `0-1`           |               | Out of bounds timer enable                                                                      |
| `roundtimelimit`                             |                 |               |                                                                                                |
| `classic_rodeo`                              | `0-1`           |               |                                                                                                |
| `classic_mp`                                 | `0-1`           | `1`           | Enables intro dropship                                                                         |
| `fp_embark_enabled`                          |                 |               | First person embark and terminations                                                            |
| `promode_enable`                             | `0-1`           | `0`           |                                                                                                |
| `riff_floorislava`                           | `0-1`           | `0`           | Covers the whole map with deadly electric smoke                                                |
| `featured_mode_all_holopilot`                | `0-1`           | `0`           |                                                                                                |
| `featured_mode_all_grapple`                  | `0-1`           | `0`           |                                                                                                |
| `featured_mode_all_phase`                    | `0-1`           | `0`           |                                                                                                |
| `featured_mode_all_ticks`                    | `0-1`           | `0`           |                                                                                                |
| `featured_mode_tactikill`                    | `0-1`           | `0`           |                                                                                                |
| `featured_mode_amped_tacticals`              | `0-1`           | `0`           |                                                                                                |
| `featured_mode_rocket_arena`                 | `0-1`           | `0`           |                                                                                                |
| `featured_mode_shotguns_snipers`             | `0-1`           | `0`           |                                                                                                |
| `iron_rules`                                 | `0-1`           | `0`           | Disables ejection and disembark                                                                |
| `riff_player_bleedout`                       |                 |               |                                                                                                |
| `player_bleedout_forceHolster`               |                 |               |                                                                                                |
| `player_bleedout_forceDeathOnTeamBleedout`   |                 |               |                                                                                                |
| `player_bleedout_bleedoutTime`               |                 |               |                                                                                                |
| `player_bleedout_firstAidTime`               |                 |               |                                                                                                |
| `player_bleedout_firstAidTimeSelf`           |                 |               |                                                                                                |
| `player_bleedout_firstAidHealPercent`        |                 |               |                                                                                                |
| `player_bleedout_aiBleedingPlayerMissChance` |                 |               |                                                                                                |

## Convars

Convars are located inside the `R2Northstar\mods\Northstar.CustomServers\mod\cfg\autoexec_ns_server.cfg` file.

They allow the server admin to set server's properties like the name, TCP port, and description.

| Name                                             | Description                                                                                                                                                                                 | Default Value                  | Accepted Values                                    |
| ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------ | -------------------------------------------------- |
| `ns_server_name`                                 | Your server's name on the server browser                                                                                                                                                    | `"Unnamed Northstar Server"`   | `string`                                           |
| `ns_server_desc`                                 | Your server's description on the server browser                                                                                                                                             | `"Default server description"` | `string`                                           |
| `ns_server_password`                             | The password required to join your server, can be bypassed if clients directly connect and you are using insecure auth                                                                      | `""`                           | `string`                                           |
| `ns_report_server_to_masterserver`               | Whether your server should report itself to the masterserver, for use in auth and the serverbrowser                                                                                         | `1`                            | `0-1`                                              |
| `ns_report_sp_server_to_masterserver`            | Whether your server should report itself to the masterserver if started on a singleplayer map, for use in auth and the serverbrowser                                                        | `0`                            | `0-1`                                              |
| `ns_auth_allow_insecure`                         | Allows clients to join your server without authenticating with the masterserver, currently required to allow clients to connect directly to your IP, rather than through the server browser | `0`                            | `0-1`                                              |
| `ns_erase_auth_info`                             | Whether your server should erase authentication information after it is used, this is useful for development but should normally be kept at 1                                               | `1`                            | `0-1`                                              |
| `ns_player_auth_port`                            | The port used for the server's local authentication server, this is the TCP port we forwarded earlier                                                                                       | `8081`                         | `1-65535`                                          |
| `everything_unlocked`                            | Whether all items, weapons, etc should be unlocked on the server                                                                                                                            | `1`                            | `0-1`                                              |
| `ns_should_return_to_lobby`                      | Whether the server should return to private match lobby after completing a game, if 0, this will go to the next map/mode in the playlist                                                    | `1`                            | `0-1`                                              |
| `ns_private_match_only_host_can_change_settings` | If 0 Players can change all match settings. If 1 Players can only change map and gamemode. If 2 Players can change nothing                                                                  | `0`                            | `0-2`                                              |
| `ns_private_match_countdown_length`              | Length is seconds before the match is started after the start button in the lobby                                                                                                           | `15`                           | `int`                                              |
| `ns_private_match_last_mode`                     | Forces the lobby to a specifig Gamemode                                                                                                                                                     | `tdm`                          | Any [Gamemode](./#gamemodes)                       |
| `ns_private_match_last_map`                      | Forces the lobby to a specifig map                                                                                                                                                          | `mp_forwardbase_kodai`         | Any [Map](./#maps)                                 |
| `ns_disallowed_weapons`                          | Blacklists weapons                                                                                                                                                                          |                                | List of [Weapons](./#weapons) separated by a comma |
| `ns_disallowed_weapon_primary_replacement`       | Replaces blacklisted weapons by one weapon                                                                                                                                                  |                                | a [Weapon](./#weapons)                             |
| `ns_should_log_unknown_clientcommands`           | Whether unknown clientcommands should be printed in the console, worth disabling if they get on your nerves                                                                                 | `1`                            | `0-1`                                              |
| `net_chan_limit_mode`                            | If 0, don't limit the netchannel processing time individual clients are allowed. If 1, kick clients that go over the limit. If 2, log clients that go over the limit in console             | `2`                            | `0-2`                                              |
| `net_chan_limit_msec_per_sec`                    | The number of milliseconds of server netchan processing time clients can use per second before triggering the response set in net\_chan\_limit\_mode                                        | `30`                           | `int`                                              |
| `base_tickinterval_mp`                           | The delay between each tick ran on the server, your tickrate will be 1 divided by this value                                                                                                | `0.016666667`                  | `float`                                            |
| `sv_updaterate_mp`                               | The maximum number of times per second your server will send information to connected players, if a player's cl\_updaterate\_mp value is lower than this, their rate will be limited to it  | `20`                           | `int`                                              |
| `sv_max_snapshots_multiplayer`                   | The number of snapshots stored locally for use in replays, this should be set to sv\_updaterate\_mp \* 15                                                                                   | `300`                          | `int`                                              |
| `host_skip_client_dll_crc`                       | Whether the server should allow clients with modified client.dll files to connect, these are used for visor colour edit mods                                                                | `1`                            | `0-1`                                              |

## Gamemodes

Gamemodes can be forced by the server using the [`+mp_gamemode`](./#Startup\_args-mpgamemode) startup arg

If ran on a server with the [`ns_should_return_to_lobby 0`](./#Convars-returntolobby) convar, one should also set gamemodes in [`ns_private_match_last_mode`](./#Convars-lastmode) convar

| Value           | Description                  |
| --------------- | ---------------------------- |
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

## Weapons

Weapon Code|Weapon name
-|-
mp_weapon_car|CAR
mp_weapon_alternator_smg|Alternator
mp_weapon_hemlok_smg|Volt
mp_weapon_r97|R-97
mp_weapon_hemlok|Hemlock rifle
mp_weapon_vinson|Flatline
mp_weapon_g2|G2
mp_weapon_rspn101|R-201
mp_weapon_rspn101_og|R-101
mp_weapon_esaw|Devotion
mp_weapon_lstar|L-STAR
mp_weapon_lmg|Spitfire
mp_weapon_shotgun|EVA-8 Auto
mp_weapon_mastiff|Mastiff
mp_weapon_dmr|DMR
mp_weapon_sniper|Kraber
mp_weapon_doubletake|Double Take
mp_weapon_pulse_lmg|Cold War
mp_weapon_smr|Sidewinder SMR
mp_weapon_softball|Softball
mp_weapon_epg|EPG-1
mp_weapon_shotgun_pistol|Mozambique
mp_weapon_wingman_n|Wingman Elite
mp_weapon_autopistol|RE-45 Auto
mp_weapon_semipistol|P2016
mp_weapon_wingman|Wingman
mp_weapon_mgl|MGL
mp_weapon_arc_launcher|Thunderbolt
mp_weapon_rocket_launcher|Archer
mp_weapon_defender|Charge Rifle

## Maps

Maps can be set on autorotation using [`ns_should_return_to_lobby 0`](./#Convars-returntolobby)

First map of autorotation can be set using [`ns_private_match_last_map`](./#Convars-lastmap)

A way to blacklist maps with autorotation do not exists.

| Value                  | Description        |
| ---------------------- | ------------------ |
| `mp_angel_city`        | Angel City         |
| `mp_black_water_canal` | Black Water Canal  |
| `mp_grave`             | Boomtown           |
| `mp_colony02`          | Colony             |
| `mp_complex3`          | Complex            |
| `mp_crashsite3`        | Crashsite          |
| `mp_drydock`           | DryDock            |
| `mp_eden`              | Eden               |
| `mp_thaw`              | Exoplanet          |
| `mp_forwardbase_kodai` | Forward Base Kodai |
| `mp_glitch`            | Glitch             |
| `mp_homestead`         | Homestead          |
| `mp_relic02`           | Relic              |
| `mp_rise`              | Rise               |
| `mp_wargames`          | Wargames           |
| `mp_lobby`             | Lobby              |
| `mp_lf_deck`           | Deck               |
| `mp_lf_meadow`         | Meadow             |
| `mp_lf_stacks`         | Stacks             |
| `mp_lf_township`       | Township           |
| `mp_lf_traffic`        | Traffic            |
| `mp_lf_uma`            | UMA                |
| `mp_coliseum`          | The Coliseum       |
| `mp_coliseum_column`   | Pillars            |
