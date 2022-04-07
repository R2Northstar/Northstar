# Playing on Linux 🐧

Northstar is officially supported on Linux, it uses compatibility layers like Proton or Wine to launch the game on POSIX systems.

## Installing

### Steam (Proton)

1. Download the latest version of Northstar from the [releases](https://github.com/R2Northstar/Northstar/releases) page
2. Extract all contents of the file to your Titanfall 2 folder ( Right click _Titanfall 2_ > Open _Properties_ > Click _Local Files_ > Click _Browse_ )
3. Rename _Titanfall2.exe_ to anything else ( for example _Titanfall2old.exe_ ), and rename _NorthstarLauncher.exe_ to _Titanfall2.exe_. Alternatively to renaming _NorthstarLauncher.exe_, you can create a symlink to make future Northstar updates easier. This can be done by executing the following in the Titanfall 2 directory:

`ln NorthstarLauncher.exe Titanfall2.exe`

Now Steam will automatically launch Northstar when you hit play. Just launch the game through Steam and you should be greeted with a Northstar welcome message upon entering the main menu.

> **Note:** There is a current bug where the game would sometimes launch vanilla Titanfall 2 instead of Northstar. There is no universal fix for this, but people have reported changing Proton versions to _Proton 5.13_ or _Proton Experimental_ and deleting the Proton prefix folder (`Steam/steamapps/compatdata/1237970/`) could help resolve this issue. Using [Proton GE](https://github.com/GloriousEggroll/proton-ge-custom) has also been reported to resolve the issue.
>
> If you are still suffering from this bug, try running the game through Lutris. The bug doesn't seem to happen there

### Lutris (Wine)

1. If you don't already have the game downloaded, install the game [from here.](https://lutris.net/games/titanfall-2/)
2. Download the latest version of Northstar from the [releases](https://github.com/R2Northstar/Northstar/releases) page
3. Extract all contents of the file to your Titanfall 2 folder

4. **If you have the game installed on Lutris:** right click _Titanfall 2_ > _Configure_ > _Game Options_ > Set _Executable path_ to _NorthstarLauncher.exe_
5. **Otherwise:** click the `+` button in the top left > set the name to whatever and _Runner_ to _Wine_ > click on _Game options_ > set _Executable path_ to _NorthstarLauncher.exe_ then save.

> **If you're migrating from Steam:** Set _Wine prefix_ to `(your Steam directory)/steamapps/compatdata/1237970/pfx/`. This will save you the hassle of having to re-download Origin.

Now just launch the game through Lutris and you should be greeted with a Northstar welcome message upon entering the main menu.

> **Note:** Origin might prompt you to log in and "set an installation folder for future downloads" on first launch. Just do those, close Origin, then launch the game again.

## SteamDeck

{% hint style="info" %}
This guide is really basic and needs fleshing out to make it more accessible. It also assumes you own Titanfall2 on Steam and run it from there.
{% endhint %}

- Install Titanfall2 via the Steam store on the SteamDeck and run the vanilla game at least once
- Switch to desktop mode  
  (A mouse + keyboard plugged into the Deck are recommended for the next few steps)
- Install Northstar like you would in the Linux+Steam guide.  
  If you installed Titanfall2 on the Deck's internal storage, it will be located at `/home/deck/.local/share/Steam/steamapps/common/Titanfall2`
- Like with the Linux guide, rename `Titanfall2.exe` to something else (like `Titanfall2.original.exe`) and rename or link `NorthstarLauncher.exe` to `Titanfall2.exe`.

We now need to configure Steam to use the right Proton version for Northstar due to current incompatibilities on Northstar's side.

- Install [_ProtonUp-Qt_](https://flathub.org/apps/details/net.davidotek.pupgui2) via the _Discover Store_ on the SteamDeck. We'll use it to easily add special Proton versions.
- Launch ProtonUp-Qt and click on "_Add version_". Wait a bit for it to load. Then for "_Compatibility tool_" select `Proton-GE`, for "_Version_" choose `7.3-GE-1`, and click on "_Install_".
- Wait a bit for it to install, then go to "_Show game list_", go to _Titanfall2_ and select `7.3-GE-1` as the compatibility tool. Afterwards close the pop-up and ProtonUp-Qt.

At this point we can go back to Deck UI. The mouse and keyboard are also no longer needed.

- In Steam go to Titanfall2 -> settings -> _Properties_ -> _Compatibility_ and make sure "Force the use of a specific Steam Play compatibility tools" is checked and `Proton-7.3-GE-1` is selected. If not, do so.
- Now go back to the main page of TItanfall2 and hit "_Play_".
- On the first launch, Titanfall2+Northstar will take a long time to boot (like 5+ minutes, seriously). Do not close the game, just wait until you see the main menu screeen. Subsequent launches should be faster.
- If you get "Northstar has crashed!" error close out of the game and try again. Make sure you followed the above instructions.

Should you at any point want to play vanilla Titanfall2 again, go back to Desktop mode and change the previously renamed `Titanfall2.exe` (now `Titanfall2.original.exe` if you followed the steps above) back to `Titanfall2.exe`. Additionally you stop forcing the different Proton version in the Deck UI game settings.

## LatencyFleX

LatencyFleX is a Linux-only input latency reduction alternative to Nvidia Reflex that is supported by Northstar. Currently, LatencyFleX requires manual installation. A full install guide and current releases [can be found on their GitHub](https://github.com/ishitatsuyuki/LatencyFleX).

Northstar only requires the [Vulkan layer](https://github.com/ishitatsuyuki/LatencyFleX#latencyflex-vulkan-layer-essential) and [Wine extensions](https://github.com/ishitatsuyuki/LatencyFleX#latencyflex-wine-extensions-required-for-proton-reflex-integration) steps to be completed.

Once installed, LatencyFleX can be enabled by doing either of the following:

- **Steam:** Add the following to your Titanfall 2 launch options: `"LFX=1 %command%"`
- **Lutris:** Right click on Titanfall 2, click 'Configure', navigate to 'System Preferences' / 'System Options' / 'Environmental Variables', and use the following:

> Key: LFX
Value: 1

Once in-game, LatencyFleX can be toggled off and on using the `"r_latencyflex"` console variable.

While playing with LatencyFleX, **VSync and Adaptive Super Sampling must be disabled**. If you wish to prevent tearing while using LatencyFleX, the following may be added to the end of `ns_startup_args.txt` in the root of your Titanfall 2 install:

> +fps_max_use_refresh 1

## Troubleshooting

> Read Lutris troubleshooting of [common issues with Origin](https://github.com/lutris/docs/blob/master/Origin.md) first.

### Blank console

This problem is caused due to missing fonts on your Titanfall 2 wine prefix, you will need [winetricks](https://github.com/Winetricks/winetricks) or [protontricks](https://github.com/Matoking/protontricks) depending on your installation. Follow these steps to install:

1. Close all Titanfall/Origin processes.
2. If you are using Lutris select your Titanfall 2 installation and click '▲' -> Winetricks. On Proton you can use `protontricks 1237970 --gui`
3. 'Select the default wineprefix' -> 'Install a font' -> Check the packages `lucida` and `arial`.
4. Click OK and wait for everything to install, if done correctly winetricks will popup again.
5. You can now close it and launch the game.

### Crackling sound
Can be fixed by adding [`tsched=0`](https://wiki.archlinux.org/title/PulseAudio/Troubleshooting#Glitches.2C_skips_or_crackling) to `/etc/pulse/default.pa`

### Fullscreen issues

Running the game on fullscreen through Linux might lead to a black screen preventing you from launching the game. Edit your `ns_startup_args.txt` to include `-noborder -window` or edit `"setting.fullscreen"` and `"setting.nowindowborder"` at `<wineprefix>/drive_c/users/<username>/Documents/Respawn/Titanfall2/local/videoconfig.txt` to solve this.

For more info and proposed fixes, refer to [this issue thread on Github](https://github.com/R2Northstar/Northstar/issues/1)

### LatencyFleX issues

Some users have reported issues with enabling LatencyFleX. If you see `"Unable to load LatencyFleX library, LatencyFleX disabled."` in your logs, try adding `latencyflex_wine.dll` to your `bin/x64_retail` folder.

### Game crashes on launch with Cause: Access Violation Data Execution Prevention (DEP) at: 0x00000000

Try running with [ProtonGE](https://github.com/GloriousEggroll/proton-ge-custom/). In particular, `Proton-7.3-GE-1` (not `GE-Proton7-3`) has so far been found to be reliable in this case. Check this [Github issue comment for a guide](https://github.com/R2Northstar/Northstar/issues/1#issuecomment-1062483190).

### Reducing stuttering (Steam/Proton and Lutris/Wine)

You may feel that the game stutters frequently during the first hour of play. This is normal, it's just DXVK having to compile shaders at draw time due not having a ready state cache. The more you play, the less stuttering there will be in the future.

However if you don't want to wait you can try precompiled DXVK [_state cache_](https://github.com/doitsujin/dxvk#state-cache): [**Titanfall2.dxvk-cache**](https://github.com/begin-theadventure/dxvk-caches/blob/main/dxvk-caches/Titanfall/Titanfall%202/Titanfall2.dxvk-cache.md)

Proton: extract and put it in `/path/to/steamapps/shadercache/1237970/DXVK_state_cache` default is `~/.local/share/..` or next to .exe if shader pre-caching is turned off.

Wine: extract and put it next to game's .exe. Also remember to rename it if the .exe has a different name.

There are also other (not necessary) tweaks as:

_DXVK-_[_async_](https://github.com/Sporif/dxvk-async#improvements):

Wine: download [**dxvk-async**](https://github.com/Sporif/dxvk-async/releases), extract and put it in `~/.local/share/lutris/runtime/dxvk` then type the name of the folder in `▲` ->  `Configure` -> `Runner Options` -> `DXVK version`, to enable add `DXVK_ASYNC 1` to `System Options` -> `Environment variables`

Proton: can be used with [**Proton-GE**](https://github.com/GloriousEggroll/proton-ge-custom). Type `DXVK_ASYNC 1 %command%` under `Properties..` -> `LAUNCH OPTIONS`

[_Preventing_](https://github.com/ValveSoftware/Proton/issues/4001#issuecomment-647014231) _Origin from writing certain files_:

Path:

Proton: `/path/to/steamapps/compatdata/1237970/pfx/drive_c/users/steamuser/Application Data/Origin` default is `~/.local/share/..`

Wine: `/path/to/drive_c/users/<username>/AppData/Roaming/Origin`

Access can be restricted using a file manager or terminal:

`chmod -R 555` -> access only

`chmod -R 755`  -> access + save

It's also possible to create command aliases to type something short, such as tfoff/tfon.
