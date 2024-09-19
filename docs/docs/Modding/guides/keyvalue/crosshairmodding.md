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

3: change "ui/crosshair_alternator" to your desired crosshair

## Overlapping Crosshairs

It is possible to combine crosshairs by modifying the mp_weapon_[Desired
Weapons].txt

**Below is an example of combining the Alternator and R201 crosshairs
into one**

```

   WeaponData
   {
       active_crosshair_count              "2" //Amount of crosshairs you want to use

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

**To add more crosshairs add another Crosshair\_\ X following the
formating in the script above.**

!!! note
    The limit for this seems to be 4 Crosshairs onscreen at once

## How the script above appears:

![triandaltCH](https://user-images.githubusercontent.com/45333346/149623038-64937ab7-bb0f-450c-ba92-97c625e715bf.png)

## Adjust Crosshair Spread?

Simply add the following line below the  "ui" line
`"base_spread"               "3.0"`
Below the "ui" line, Like this:

```

    {
       RUI_CrosshairData
       {
           Crosshair_1
           {
               "ui"                        "ui/crosshair_alternator" //THis is the Croshair
               "base_spread"               "3.0"   //This is a spread Multiplier, Line doesn't exist by default
           }
       }
   }
```

* This only affects the visual spread of the crosshair, not the actual bullet spread. Positive Values increase spread while negative decrease it. By default it is based on the weapon's own stats.

## No Crosshair?

```

   WeaponData
   {
       RUI_CrosshairData
       {
           Crosshair_1
           {
               "ui"                        "ui/crosshair_sniper_amped" //This means NO crosshair
           }
       }
   }
```

## Crosshair Index:

These are the available crosshairs in-game, along with their in-game
reference:

![Crosshair examples](https://github.com/Riccorbypro/Custom.Crosshairs/raw/main/assets/crosshairs.png)

Crosshair images are taken from the modding guide on
https://noskill.gitbook.io/titanfall2/

## Examples

![CH1](https://user-images.githubusercontent.com/45333346/149503054-45eb1fa5-5e89-4bf1-bf58-b58c1bfab94b.png)

![CH2](https://user-images.githubusercontent.com/45333346/149503085-154c05b8-4a76-4d03-80aa-fe67fba1bcb1.png)


### Extra Info


* As with any mod, it is recommended to test this out in a private match first. Save any changes you made to the desired weapon's file and type `reload` in your console


* Keep in mind that some weapons have animated or dynamic crosshairs. Weapons like the Charge Rifle, Cold War, Frag Grenade, etc... have custom animations for their crosshairs. which can cause weirdness or jank when used on other weapons or when using other crosshairs on them.
   * Animated weapons like the Charge rifle will work with animated crosshairs like `ui/crosshair_titan_sniper`

Thank you to `Cpone#0001` and `Nixie#8251` from the [Northstar
Discord](https://northstar.tf/discord) for helping me figure this out
