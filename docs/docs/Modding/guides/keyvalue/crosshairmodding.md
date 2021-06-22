# Crosshair Modding

Example Mod:
[Custom.Crosshairs](https://github.com/MysteriousRSA/Custom.Crosshairs)

## How To Modify Crosshairs:

1: Create the following file
`~/Your.Mod/keyvalues/scripts/weapons/mp_weapon_[desired weapon].txt`

2: Put the following into the newly created .txt file:

```
WeaponData
{
    RUI_CrosshairData
    {
        Crosshair_1
        {
            "ui"                        "ui/crosshair_alternator"
        }
    }
}
```

3: Change `"ui/crosshair_alternator"` to your desired crosshair.

## Overlapping Crosshairs

It is possible to combine crosshairs by modifying the `mp_weapon_[Desired
Weapons].txt` file.

**Below is an example of combining the Alternator and R201 crosshairs
into one.**

```
WeaponData
{
    "active_crosshair_count"            "2" //Amount of crosshairs you want to use

    RUI_CrosshairData
    {
        Crosshair_1
        {
            "ui"                        "ui/crosshair_alternator"
        }
        Crosshair_2
        {
            "ui"                        "ui/crosshair_tri"
        }
    }
}
```

**To add more crosshairs add another Crosshair\_X following the
formating in the script above.**

!!! note
    The limit for this seems to be 4 Crosshairs on-screen at once.

## How the script above appears:

![triandaltCH](https://user-images.githubusercontent.com/45333346/149623038-64937ab7-bb0f-450c-ba92-97c625e715bf.png)

## Adjust Crosshair Spread?

Simply add the following line below the "ui" line: `"base_spread"               "3.0"`

```
WeaponData
{
    RUI_CrosshairData
    {
        Crosshair_1
        {
            "ui"                        "ui/crosshair_alternator" //This is the Croshair
            "base_spread"               "3.0"   //This is a spread Multiplier, line doesn't exist by default
        }
    }
}
```

* This only affects the visual spread of the crosshair, not the actual bullet spread. Positive values increase the spread while negative values decrease it. By default, it is based on the weapon's own stats.

## No Crosshair?

```
WeaponData
{
    RUI_CrosshairData
    {
        Crosshair_1
        {
            "ui"                        "ui/crosshair_sniper_amped" //This means NO crosshair, unless your weapon is amped
        }
    }
}
```

## Crosshair Index:

These are the available crosshairs in-game, along with their in-game
reference:

### Titan Crosshairs:

| Picture | Value | Special Properties |
| ------- | ----- | ------- ---------- |
| ![](../../../_static/crosshairmodding/crosshair_40mm.png)| `ui/crosshair_40mm` | `NOADS` |
| ![](../../../_static/crosshairmodding/crosshair_40mm_burst.png)| `ui/crosshair_40mm_burst` | `NOADS`, `TRACKER` |
| ![](../../../_static/crosshairmodding/crosshair_flight_core.png)| `ui/crosshair_flight_core` | `NOADS`, `NOSPREAD` |
| ![](../../../_static/crosshairmodding/crosshair_heat_shield.png)| `ui/crosshair_heat_shield` / `ui/crosshair_vortex` | `NOADS`, `NOSPREAD`, `TRACKER` |
| ![](../../../_static/crosshairmodding/crosshair_ion.png)| `ui/crosshair_ion` | `NOADS` |
| ![](../../../_static/crosshairmodding/crosshair_leadwall.png)| `ui/crosshair_leadwall` | `NOADS`,` NOSPREAD` |
| ![](../../../_static/crosshairmodding/crosshair_quad_rocket.png)| `ui/crosshair_quad_rocket` | `NOADS`,` NOSPREAD` |
| ![](../../../_static/crosshairmodding/crosshair_scorch.png)| `ui/crosshair_scorch` ||
| ![](../../../_static/crosshairmodding/crosshair_shotgun.png)| `ui/crosshair_titan_predator_close_range`/ `ui/crosshair_titan_predator_power_shot_close` | `NOADS` |
| ![](../../../_static/crosshairmodding/crosshair_titan_predator_power_shot_long.png)| `ui/crosshair_titan_predator_power_shot_long` | `NOADS` |
| ![](../../../_static/crosshairmodding/crosshair_titan_sniper.png)| `ui/crosshair_titan_sniper` | `NOADS`, `NOSPREAD`, `TRACKER` |
| ![](../../../_static/crosshairmodding/crosshair_tracker_rockets.png)| `ui/crosshair_tracker_rockets` | `NOADS`, `NOSPREAD` |

### Pilot Crosshairs:
| Picture | Value | Special Properties |
| ------- | ----- | ------- ---------- |
| ![](../../../_static/crosshairmodding/crosshair_alternator.png)| `ui/crosshair_alternator` ||
| ![](../../../_static/crosshairmodding/crosshair_arc.png)| `ui/crosshair_arc` | `NOADS`, `NOSPREAD` |
| ![](../../../_static/crosshairmodding/crosshair_circle2.png)| `ui/crosshair_circle` / `ui/crosshair_circle2` / `ui/crosshair_circle2_small` | `NOADS`, `NOSPREAD` |
| ![](../../../_static/crosshairmodding/crosshair_charge_rifle.png)| `ui/crosshair_charge_rifle` | `NOADS`, `NOSPREAD, TRACKER` |
| ![](../../../_static/crosshairmodding/crosshair_wingman_n.png)| `ui/crosshair_dot` / `ui/crosshair_wingman_n` ||
| ![](../../../_static/crosshairmodding/crosshair_esmoke.png)| `ui/crosshair_esmoke` | `NOADS`, `NOSPREAD` |
| ![](../../../_static/crosshairmodding/crosshair_firestar.png)| `ui/crosshair_firestar` | `NOADS`, `NOSPREAD` |
| ![](../../../_static/crosshairmodding/crosshair_frag.png)| `ui/crosshair_frag` / `ui/crosshair_frag2` | `NOADS`, `NOSPREAD` |
| ![](../../../_static/crosshairmodding/crosshair_grapple.png)| `ui/crosshair_grapple` | `NOADS`, `NOSPREAD`, `TRACKER` |
| ![](../../../_static/crosshairmodding/crosshair_grapple_charge.png)| `ui/crosshair_grapple_charge` / `ui/crosshair_phase_charge` | `NOADS`, `NOSPREAD`, `TRACKER` |
| ![](../../../_static/crosshairmodding/crosshair_gravstar.png)| `ui/crosshair_gravstar` | `NOADS`, `NOSPREAD` |
| ![](../../../_static/crosshairmodding/crosshair_grenade_launcher.png)| `ui/crosshair_grenade_launcher` / `ui/crosshair_grenade_launcher2` | `NOADS` |
| ![](../../../_static/crosshairmodding/crosshair_ladder.png)| `ui/crosshair_ladder` | `NOADS`, `NOSPREAD` |
| ![](../../../_static/crosshairmodding/crosshair_shotgun.png)| `ui/crosshair_lstar` / `ui/crosshair_shotgun` ||
| ![](../../../_static/crosshairmodding/crosshair_mastiff.png)| `ui/crosshair_mastiff` | `NOSPREAD` |
| ![](../../../_static/crosshairmodding/crosshair_mine.png)| `ui/crosshair_mine` | `NOADS`, `NOSPREAD` |
| ![](../../../_static/crosshairmodding/crosshair_mozambique.png)| `ui/crosshair_mozambique` | `NOSPREAD` |
| ![](../../../_static/crosshairmodding/crosshair_plus.png)| `ui/crosshair_plus` ||
| ![](../../../_static/crosshairmodding/crosshair_pulse_blade.png)| `ui/crosshair_pulse_blade` | `NOADS`, `NOSPREAD` |
| ![](../../../_static/crosshairmodding/crosshair_satchel.png)| `ui/crosshair_satchel` | `NOADS`, `NOSPREAD` |
| ![](../../../_static/crosshairmodding/crosshair_smart_pistol.png)| `ui/crosshair_smart_pistol` | `NOADS`, `NOSPREAD`, `TRACKER` |
| ![](../../../_static/crosshairmodding/crosshair_smr.png)| `ui/crosshair_smr` | `NOADS`, `NOSPREAD` |
| ![](../../../_static/crosshairmodding/crosshair_sniper_amped.png)| `ui/crosshair_sniper_amped` | `AMPED`, `NOSPREAD` |
| ![](../../../_static/crosshairmodding/crosshair_square.png)| `ui/crosshair_square` ||
| ![](../../../_static/crosshairmodding/crosshair_test.png)| `ui/crosshair_test` ||
| ![](../../../_static/crosshairmodding/crosshair_tri.png)| `ui/crosshair_tri` ||
| ![](../../../_static/crosshairmodding/crosshair_turret.png)| `ui/crosshair_turret` | `NOADS`, `TRACKER` |
| ![](../../../_static/crosshairmodding/crosshair_wingman.png)| `ui/crosshair_wingman` ||

!!! note
    ``ui/crosshair_test`` has a rapidly flashing dot in its center.

!!! note
    Some of the crosshairs shown above were recreated from scratch, and may not be entirely accurate to their in-game look.

* `AMPED` means the crosshair is invisible, unless your weapon is amped.
* `NOADS` means the crosshair doesn't fully disappear when aiming down sights.
* `NOSPREAD` means the crosshair completely ignores the `"base_spread"` setting, and will always use a specific spread.
* `TRACKER` means the crosshair can track a specific value of your weapon (charge amount, clip size...).

## Examples

![CH1](https://user-images.githubusercontent.com/45333346/149503054-45eb1fa5-5e89-4bf1-bf58-b58c1bfab94b.png)

![CH2](https://user-images.githubusercontent.com/45333346/149503085-154c05b8-4a76-4d03-80aa-fe67fba1bcb1.png)


### Extra Info


* As with any mod, it is recommended to test this out in a private match first. Save any changes you made to the desired weapon's file and type `sv_cheats 1; reload_mods; weapon_reparse; sv_cheats 0` in your console.


* Keep in mind that some weapons have animated or dynamic crosshairs. Weapons like the Charge Rifle, Cold War, Frag Grenade, etc... have custom animations for their crosshairs. Which can cause weirdness or jank when used on other weapons or when using other crosshairs on them.
   * Animated weapons like the Charge Rifle will work with animated crosshairs like `ui/crosshair_titan_sniper`

Thank you to `Cpone#0001` and `Nixie#8251` from the [Northstar
Discord](https://northstar.tf/discord) for helping me figure this out.
