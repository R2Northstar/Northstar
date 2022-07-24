# Playing on Linux

Northstar is officially supported on Linux, it uses compatibility layers like Proton or Wine to launch the game on POSIX systems.

## Installing

### Steam & Steam Deck (NorthstarProton)

On Steam Deck, complete the following in desktop mode. You may return to game mode once completed *(A mouse + keyboard plugged into the Deck are recommended for easier navigation of menus)*

1. Make sure you ran the vanilla version of Titanfall2 at least once on Linux!
2. Install the latest version of Northstar using [Viper](../northstar-installers.md#0negal-viper) or do it manually
   1. For manual install download the latest version of Northstar from the [releases](https://github.com/R2Northstar/Northstar/releases) page
   2. Then extract all contents of the file to your Titanfall 2 folder ( Right click _Titanfall 2_ > Open _Properties_ > Click _Local Files_ > Click _Browse_ )
3. In your Titanfall2 folder create a file called `run_northstar.txt` and write a single `1` to it, i.e. `echo 1 > run_northstar.txt`&#x20;
4. Download the latest release of [NorthstarProton](https://github.com/cyrv6737/NorthstarProton/releases/), extract it, and place the folder in one of the following directories:
> **Steam (Native Package) & Steam Deck:** `~/.local/share/Steam/compatibilitytools.d`

> **Steam (Flatpak):** `~/.var/app/com.valvesoftware.Steam/data/Steam/compatibilitytools.d/`
5. Restart Steam. Head to `Properties -> Compatibility` under Titanfall2. Check `Force the use of a specific Steam Play compatibility tool` checkbox, then set the Steam Play compatibility tool to NorthstarProton.
6. Launch Titanfall2, it should now launch Northstar

Note that removing the `run_northstar.txt` file or editing it and changing `1` to be a `0` will cause Steam to launch the vanilla game again.

### Lutris (Wine)

1. If you don't already have the game downloaded, install the game [from here.](https://lutris.net/games/titanfall-2/)
2. Download the latest version of Northstar from the [releases](https://github.com/R2Northstar/Northstar/releases) page
3. Extract all contents of the file to your Titanfall 2 folder
4. **If you have the game installed on Lutris:** right click _Titanfall 2_ > _Configure_ > _Game Options_ > Set _Executable path_ to _NorthstarLauncher.exe_
5. **Otherwise:** click the `+` button in the top left > set the name to whatever and _Runner_ to _Wine_ > click on _Game options_ > set _Executable path_ to _NorthstarLauncher.exe_ then save.

> **If you're migrating from Steam:** Set _Wine prefix_ to `(your Steam directory)/steamapps/compatdata/1237970/pfx/`. This will save you the hassle of having to re-download Origin.

Now just launch the game through Lutris and you should be greeted with a Northstar welcome message upon entering the main menu.

> **Note:** Origin might prompt you to log in and "set an installation folder for future downloads" on first launch. Just do those, close Origin, then launch the game again.

## LatencyFleX

LatencyFleX is a Linux-only input latency reduction alternative to Nvidia Reflex that is supported by Northstar.

LatencyFleX's Vulkan layer can be installed with your package manager on supported distributions. On Arch it's available in [AUR](https://aur.archlinux.org/packages/latencyflex-git), and on Fedora/openSUSE Tumbleweed it can be acquired from [Copr](https://copr.fedorainfracloud.org/coprs/kylegospo/LatencyFleX/).

If you're using another distro you will need to install LatencyFleX manually. A full install guide and current releases [can be found on their GitHub](https://github.com/ishitatsuyuki/LatencyFleX). Northstar only requires the [Vulkan layer](https://github.com/ishitatsuyuki/LatencyFleX#latencyflex-vulkan-layer-essential) and [Wine extensions](https://github.com/ishitatsuyuki/LatencyFleX#latencyflex-wine-extensions-required-for-proton-reflex-integration) steps to be completed. **If you are using NorthstarProton, the Wine extensions are automatically installed and only the Vulkan layer is required.**

Once installed, LatencyFleX can be enabled by doing either of the following:

* **Steam:** Add the following to your Titanfall 2 launch options: `"LFX=1 %command%"`
* **Lutris:** Right click on Titanfall 2, click 'Configure', navigate to 'System Preferences' / 'System Options' / 'Environmental Variables', and use the following:

> Key: LFX Value: 1

Once in-game, LatencyFleX can be toggled off and on using the `"r_latencyflex"` console variable.

While playing with LatencyFleX, **VSync and Adaptive Super Sampling must be disabled**. If you wish to prevent tearing while using LatencyFleX, the following may be added to the end of `ns_startup_args.txt` in the root of your Titanfall 2 install:

> \+fps\_max\_use\_refresh 1

## Troubleshooting

> Read Lutris troubleshooting of [common issues with Origin](https://github.com/lutris/docs/blob/master/Origin.md) first.

### Blank console

This issue has been resolved as of [Northstar 1.9.2 and newer.](https://github.com/R2Northstar/Northstar/releases/latest)

For older builds of Northstar, please update or see the [legacy guide](installing-northstar/using-northstar/playing-on-linux-legacy-guide.md#blank-console) if the use of an older build is desired.

### Crackling sound

Can be fixed by adding [`tsched=0`](https://wiki.archlinux.org/title/PulseAudio/Troubleshooting#Glitches.2C\_skips\_or\_crackling) to `/etc/pulse/default.pa`

### Fullscreen issues

Running the game on fullscreen through Linux might lead to a black screen preventing you from launching the game. Edit your `ns_startup_args.txt` to include `-noborder -window` or edit `"setting.fullscreen"` and `"setting.nowindowborder"` at `<wineprefix>/drive_c/users/<username>/Documents/Respawn/Titanfall2/local/videoconfig.txt` to solve this.

For more info and proposed fixes, refer to [this issue thread on Github](https://github.com/R2Northstar/Northstar/issues/1)

### Game crashes on launch with Cause: Access Violation Data Execution Prevention (DEP) at: 0x00000000

**Steam/Steam Deck:** Ensure your installation matches the latest [install guide](#steam-and-steam-deck-northstarproton).

**Lutris**: Ensure your installation matches the latest [install guide](#lutris-wine). If that fails, you may optionally try the latest release of [Wine-TKG](https://github.com/Frogging-Family/wine-tkg-git/releases/latest).

### Reducing stuttering

#### DXVK State Cache Stutter Fix

You may feel that the game stutters frequently during the first hour of play. This is normal, it's just DXVK having to compile shaders at draw time due not having a ready state cache. The more you play, the less stuttering there will be in the future.

However if you don't want to wait you can try precompiled DXVK [_state cache_](https://github.com/doitsujin/dxvk#state-cache): [**Titanfall2.dxvk-cache**](https://github.com/begin-theadventure/dxvk-caches/blob/main/dxvk-caches/Titanfall/Titanfall%202/Titanfall2.dxvk-cache.md)

Proton: extract and put it in `/path/to/steamapps/shadercache/1237970/DXVK_state_cache` default is `~/.local/share/..` or next to .exe if shader pre-caching is turned off.

Wine: extract and put it next to game's .exe. Also remember to rename it if the .exe has a different name.

#### Steam/Steam Deck (dxvk-async)
DXVK-async is automatically installed and enabled if using the NorthstarProton runner.

#### Lutris (dxvk-async)

DXVK-[_async_](https://github.com/Sporif/dxvk-async#improvements) can optionally be used on Lutris to prevent stutter during shader compilation by asynchronously compiling and allowing the frame to render with not-yet-compiled shaders simply not drawn.

Download [**dxvk-async**](https://github.com/Sporif/dxvk-async/releases), extract and put it in `~/.local/share/lutris/runtime/dxvk` then type the name of the folder in `▲` -> `Configure` -> `Runner Options` -> `DXVK version`, to enable add `DXVK_ASYNC 1` to `System Options` -> `Environment variables`

*DXVK-async can also be installed for Lutris with [ProtonUp-Qt](https://davidotek.github.io/protonup-qt/)*

#### Origin Continual File Writing Fix

[_Preventing_](https://github.com/ValveSoftware/Proton/issues/4001#issuecomment-647014231) _Origin from writing certain files_:

Path:

Proton: `/path/to/steamapps/compatdata/1237970/pfx/drive_c/users/steamuser/Application Data/Origin` default is `~/.local/share/..`

Wine: `/path/to/drive_c/users/<username>/AppData/Roaming/Origin`

Access can be restricted using a file manager or terminal:

`chmod -R 555` -> access only

`chmod -R 755` -> access + save

It's also possible to create command aliases to type something short, such as tfoff/tfon.

### Reshade adding incompatible DXVK version for Northstar

If you ever used ReShade together with Titanfall2 in the past it will have created a bunch of DXVK DLLs that are incompatible with Northstar. If Northstar fails to fully initialize with an exeption and you have previously installed ReShade on Windows delete the following files from `Titanfall2/bin/x64_retail/`:

* D3D8.DLL
* D3D9.DLL
* D3D10.DLL
* D3D11.DLL
* OPENGL.DLL
* DXGI.DLL

### Northstar 1.9.1 and prior

For older builds of Northstar, please see the [legacy guide](installing-northstar/using-northstar/playing-on-linux-legacy-guide.md).
