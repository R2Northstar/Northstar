### Playlist overrides

!!! warning
    Playlist overrides determines the behaviour of the server. PlaylistOverrides can be added using the `+setplaylistvaroverrides` argument in the `ns_startup_args_dedi.txt` file.

The list of playlist overrides needs to be quoted and separated by spaces.\
Example: `+setplaylistvaroverrides "run_epilogue 0 featured_mode_amped_tacticals 1"`


| PlaylistOverrides                            | Accepted Values | Default Value | Description                                                                                                         |
| -------------------------------------------- | --------------- | ------------- | ------------------------------------------------------------------------------------------------------------------- |
| `max_players`                                | `int`           |               | Needs to be in combination with the [`-maxplayersplaylist`](./#Startup\_flags-maxplrplst) flag                      |
| `custom_air_accel_pilot`                     |                 |               |                                                                                                                     |
| `pilot_health_multiplier`                    |                 |               |                                                                                                                     |
| `run_epilogue`                               | `0-1`           | `1`           | Enables escape dropship                                                                                             |
| `respawn_delay`                              |                 |               | Delay before respawn                                                                                                |
| `boosts_enabled`                             | `0-1`           | `0`           | Disable boosts. Doesn't disable Titanmeter. Note that unlike the name suggests `1` disables boosts                  |
| `earn_meter_pilot_overdrive`                 | `0-1`           |               |                                                                                                                     |
| `earn_meter_pilot_multiplier`                |                 |               |                                                                                                                     |
| `earn_meter_titan_multiplier`                |                 |               |                                                                                                                     |
| `aegis_upgrades`                             | `0-1`           | `0`           | Enable titan aegis upgrades                                                                                         |
| `infinite_doomed_state`                      | `0-1`           |               |                                                                                                                     |
| `titan_shield_regen`                         | `0-1`           | `0`           | Enable regenerating titan shields                                                                                   |
| `scorelimit`                                 |                 |               |                                                                                                                     |
| `roundscorelimit`                            |                 |               |                                                                                                                     |
| `timelimit`                                  |                 |               |                                                                                                                     |
| `oob_timer_enabled`                          | `0-1`           |               | Out of bounds timer enable                                                                                          |
| `roundtimelimit`                             |                 |               |                                                                                                                     |
| `classic_rodeo`                              | `0-1`           |               |                                                                                                                     |
| `classic_mp`                                 | `0-1`           | `1`           | Enables intro dropship                                                                                              |
| `fp_embark_enabled`                          |                 |               | First person embark and terminations                                                                                |
| `player_force_respawn`                       | `int`           | `5`           | Forces players to respawn after the respawn button has been shown for x seconds. `-1` to disable forced respawning. |
| `promode_enable`                             | `0-1`           | `0`           |                                                                                                                     |
| `riff_floorislava`                           | `0-1`           | `0`           | Covers the whole map with deadly electric smoke                                                                     |
| `featured_mode_all_holopilot`                | `0-1`           | `0`           |                                                                                                                     |
| `featured_mode_all_grapple`                  | `0-1`           | `0`           |                                                                                                                     |
| `featured_mode_all_phase`                    | `0-1`           | `0`           |                                                                                                                     |
| `featured_mode_all_ticks`                    | `0-1`           | `0`           |                                                                                                                     |
| `featured_mode_tactikill`                    | `0-1`           | `0`           |                                                                                                                     |
| `featured_mode_amped_tacticals`              | `0-1`           | `0`           |                                                                                                                     |
| `featured_mode_rocket_arena`                 | `0-1`           | `0`           |                                                                                                                     |
| `featured_mode_shotguns_snipers`             | `0-1`           | `0`           |                                                                                                                     |
| `iron_rules`                                 | `0-1`           | `0`           | Disables ejection and disembark                                                                                     |
| `riff_player_bleedout`                       |                 |               |                                                                                                                     |
| `player_bleedout_forceHolster`               |                 |               |                                                                                                                     |
| `player_bleedout_forceDeathOnTeamBleedout`   |                 |               |                                                                                                                     |
| `player_bleedout_bleedoutTime`               |                 |               |                                                                                                                     |
| `player_bleedout_firstAidTime`               |                 |               |                                                                                                                     |
| `player_bleedout_firstAidTimeSelf`           |                 |               |                                                                                                                     |
| `player_bleedout_firstAidHealPercent`        |                 |               |                                                                                                                     |
| `player_bleedout_aiBleedingPlayerMissChance` |                 |               |                                                                                                                     |

### Sticks and Stones playlist overrides

| PlaylistOverrides for SNS                          | Accepted Values | Default Value | Description                                                                                    |
| -------------------------------------------------- | --------------- | ------------- | ---------------------------------------------------------------------------------------------- |
| sns_softball_enabled                               | 0-1             | 0             | Enables Softball usage                                                                         |
| sns_softball_kill_value                            | int             | 10            |                                                                                                |
| sns_wme_kill_value                                 | int             | 10            |                                                                                                |
| sns_offhand_kill_value                             | int             | 10            |                                                                                                |
| sns_reset_kill_value                               | int             | 5             |                                                                                                |
| sns_melee_kill_value                               | int             | 5             |                                                                                                |
| sns_reset_pulse_blade_cooldown_on_pulse_blade_kill | 0-1             | 1             | Enables getting Pulse Blade back after a Pulse Blade kill                                      |

### Gun game playlist overrides

| PlaylistOverrides for GG                   | Accepted Values | Default Value | Description                                                                                    |
| ------------------------------------------ | --------------- | ------------- | ---------------------------------------------------------------------------------------------- |
| gg_kill_reward                             | float           | 1.0           | Amount of points you get for killing a player                                                  |
| gg_execution_reward                        | float           | 1.0           | Amount of points you get for executing a player                                                |
| gg_assist_reward                           | float           | 0.0           | Amount of points you get for getting an assist on a player                                     |
| gg_weapon_                                 | string          |               | Allows you to override the guns with the formatting `+setplaylistvaroverrides scorelimit <weaponCount> gg_weapon_<index> <offhandSlotOr-1>|<weaponClassName>|<weaponMods>`. Syncs with client   |