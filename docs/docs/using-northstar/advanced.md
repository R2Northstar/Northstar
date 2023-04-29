# Advanced Options

{% hint style="warning" %}
This is a section detailing the more advanced parts of using Northstar, with some of them having a chance to potentially mess with your game. Setting your level too high, for example, will lock you out of Northstar's multiplayer until you reset your entire player stats, progress, and loadouts.
{% endhint %}

## Mod profiles <a href="#profiles" id="profiles"></a>

Profiles are a way to launch a version of Northstar with specific mods enabled, differing per profile. These profiles are separated by folders that you create yourself, and add your own mods to. This is especially useful if you want to [play vanilla using Northstar](advanced.md#vanilla-on-northstar).\
Currently, the only mod managers supporting profiles are [VTOL](https://github.com/BigSpice/VTOL) and [r2modman](https://thunderstore.io/package/ebkr/r2modman/).

### Regular Profile

The first thing you want to do while creating a new profile is to have a Northstar release version downloaded and ready to be used. You will only need the `R2Northstar` folder from this second version, as the rest of the `NorthstarRelease.vX.Y.Z.zip` doesn't matter to creating additional profiles.

You'll want to rename the `R2Northstar` folder to whatever you prefer it to be called, such as `R2NorthstarNoMods` if you'd like to have a normal Northstar installation without using additional mods. These profiles act entirely independently from the other folders, meaning you can use a mod in a folder without it affecting any others. The only downside to this, however, is that they must all be updated independently when a Northstar update is released. You can install any mods that you would like to `YourProfileName/mods`, and they will load when launching it, though, just like core mods, additional mods will all also need to be updated independently. 

In order to create the `.bat` to launch this profile, you'll need to first create a `.txt` file inside of your Titanfall2 directory, and name it whatever you would like. Inside of this `.txt` file, you'll want to put in `NorthstarLauncher.exe -profile=PROFILE FOLDER NAME HERE`, replacing all of `PROFILE FOLDER NAME HERE` with the name that you gave the folder you installed your mods to. After this, rename the file to `yourFileName.bat`. Double clicking or right clicking on the `.bat` file then hitting `open` will launch Northstar with the assigned profile.

You can set up profiles in an even more advanced way by setting up a way to use Steam to launch multiple different profiles from their newer launch menu that appears when you can launch a game in more ways than one. This is also covered [here](installing-northstar/basic-setup.mdbasic-setup#adding-alternate-launch-option-for-steam), and can be set up for profiles by simply adding the `-profile=PROFILE FOLDER NAME HERE` to the arguments of the new option for NorthstarLauncher, as seen below

![SteamEdit using Northstar Profiles](../images/steamedit-profiles.png)

### Vanilla Profile

A simple "vanilla" profile can be created using a `.bat` file, without needing to fully make an additional mods folder. You can do this simply by creating a `.txt` file inside of your Titanfall2 directory (you can name it whatever you want), and putting in `NorthstarLauncher.exe -norestrictservercommands -profile=R2Vanilla`.
After doing this, you'll want to rename it to `yourFileName.bat`.
This tells the NorthstarLauncher to not restrict server commands, a feature which is needed to allow the server to tell the client which server to join (but is disabled on Northstar for security reasons), and tells it to use the `R2Vanilla` profile, which, as it doesn't normally exist, will launch Northstar with no core mods enabled, allowing you to easily play on Vanilla using most of Northstar's security fixes.

Double clicking the `.bat` or right clicking on it and hitting `open` will launch the vanilla profile.

## Setting levels using console commands <a href="#set-level" id="set-level"></a>

{% hint style="warning" %}
This section here can cause you to mess up your persistence (multiplayer user data) on Northstar if you set your levels too high! Make sure to read carefully!
{% endhint %}

With everything unlocked, there is no need to set your level to a higher level, but some users may still want to do so. In order to this, you'll need to open the in-game console with the `~` button on your keyboard and type in/copy and paste the relevant commands. Both of these require `sv_cheats 1` to be enabled on the server you're playing on, easily done by using `sv_cheats 1` in the console in a private match. 

`script GetPlayerArray()[0].SetPersistentVar("gen", INSERT_GEN_COUNT)` this command sets the Generation level of the player. You want to replace `INSERT_GEN_COUNT` with the number you want. Setting this number too high should work for levling up, however it will display `g103` on your kill card.

`script GetPlayerArray()[0].SetPersistentVar("xp", INSERT_XP_COUNT)` this command sets the xp count of the player (meaning, the amount of kills required per level in order to level up). You want to replace `INSERT_XP_COUNT` with the number you want. Setting this number lower than 472 is recommended, as to not encounter issues.

If you experience strange issues after using these, you probably set something too high, and should follow the [resetting levels wiki section](installing-northstar/troubleshooting.md#i-used-a-command-to-set-my-playergun-xp-level-and-i-set-it-too-high-so-now-my-game-crashes-when-trying-to-join-multiplayer).

## Playing Vanilla via NorthstarLauncher <a href="#vanilla-on-northstar" id="vanilla-on-northstar"></a>

It is recommended that you [set up a vanilla profile](advanced.md#profiles) instead of disabling all of your mods and using `-norestrictservercommands` as a launch option, however if you wish to only play vanilla using this method and would rather not set up a profile, you can do the following.

The reason behind doing this is that Northstar has several security fixes that Vanilla does not have, however these are not *necessary*. The odds you get hacked playing vanilla are close to zero, and there are no reports of people being genuinely hacked by playing Vanilla.\
This method assumes you're launching Northstar via Titanfall 2 on EA or Steam using launch options.

1. Go to the main menu of Northstar 
2. Click `"Mods"` on the bottom of the menu
3. Disable **ALL** of your mods
4. Close Northstar
5. Add `-norestrictservercommands` and `-northstar` as a [launch option](installing-northstar/troubleshooting.md#launch-opts)
6. Launch Titanfall 2 and you should be able to play on vanilla servers using Northstar's security fixes

**TO PLAY ON NORTHSTAR AGAIN**

1. Go to your [Titanfall2 directory](installing-northstar/troubleshooting.md#game-location)
2. Open your `R2Northstar` folder
3. Delete `enabledmods.json`
4. Launch Northstar
