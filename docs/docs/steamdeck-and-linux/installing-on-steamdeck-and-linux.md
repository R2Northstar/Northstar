# Installing on SteamDeck and Linux

## Steam & Steam Deck (NorthstarProton)

{% hint style="warning" %}
EA App currently displays a blank screen when using NorthstarProton, however Northstar will still launch assuming you have logged in to EA App at least once.
{% endhint %}

{% hint style="warning" %}
NorthstarProton has some problems and may stop working at any point, if this happens you can try [deleting the compatibility directory](linux-troubleshooting.md#northstar-not-launching-with-steam) or visit the Northstar Discord for help.
{% endhint %}

> **Check your GLIBC version.** NorthstarProton currently only supports version 2.33 and higher. Verify your installed version with `ldd --version`. **Ubuntu 20.04 LTS** and **Debian 11** are known to have outdated GLIBC packages, meaning you will have to experiment with finding a Proton version that works for you, or use Lutris. It is therefore strongly recommended to use an up-to-date Linux distro to be able to make use of NorthstarProton. This check does not need to be completed on Steam Deck or Steam OS.

On Steam Deck, complete the following in desktop mode. You may return to game mode once completed _(A mouse + keyboard plugged into the Deck are recommended for easier navigation of menus)_

1. Make sure you ran the vanilla version of Titanfall2 at least once on Linux!
   * If Titanfall 2 fails to launch, you may have to delete the game's Proton prefix and reinstall using another version of Proton.
   1. To do this, head to `~/.local/share/Steam/steamapps/compatdata` if you installed Steam via a native package, or the Flatpak equivalent.
   2. Delete the folder named `1237970`
   3. Set Titanfall 2 to launch with `Proton 6.3-8` or `Proton 7.0-6` in the _Properties_ -> _Compatibility_ section.
   4. Launch the game and allow the install to completely finish.
   5. Set Titanfall 2 to launch with a more current version of Proton, NorthstarProton, or Proton GE.
   6. If Titanfall 2 still fails to launch, delete the prefix again and try installing with the other version of Proton.
2. Install the latest version of Northstar using [FlightCore](../installing-northstar/northstar-installers#geckoeidechse-flightcore), [Viper](../installing-northstar/northstar-installers#0negal-viper), or do it manually
   1. For manual install download the latest version of Northstar from the [releases](https://github.com/R2Northstar/Northstar/releases) page
   2. Then extract all contents of the file to your Titanfall 2 folder ( Right click _Titanfall 2_ > Open _Properties_ > Click _Local Files_ > Click _Browse_ )
3. Install NorthstarProton or a current version of Proton GE.
   * In some user cases, NorthstarProton may not work. You may instead try Proton GE, which is also available through the following methods.
   1. **Protonup-QT**: Click _About_, then tick the box to enable _advanced mode_. You should be able to select and install NorthstarProton from the _Add version_ menu.
   2. **ProtonPlus**: NorthstarProton can also be installed via ProtonPlus.
   3. **Manual**: Download the latest release of [NorthstarProton](https://github.com/cyrv6737/NorthstarProton/releases/), extract it, and place the folder in one of the following directories:
      * **Steam (Native Package) & Steam Deck:** `~/.local/share/Steam/compatibilitytools.d`
      * **Steam (Flatpak):** `~/.var/app/com.valvesoftware.Steam/data/Steam/compatibilitytools.d/`
4. Restart Steam. Head to `Properties -> Compatibility` under Titanfall2. Check `Force the use of a specific Steam Play compatibility tool` checkbox, then set the Steam Play compatibility tool to NorthstarProton.
5. Add `%command% -northstar` as a [launch option](../installing-northstar/troubleshooting.md#launch-opts) to Titanfall2
6. Launch Titanfall2, it should now launch Northstar

Note that removing the `%command% -northstar` will cause Steam to launch the vanilla game again.

{% hint style="info" %}
This guide assumes you're *up to date with NorthstarProton*, as the method used to launch Northstar changed in NorthstarProton-8.1-1 which was released on 2023-02-22.\
If you're using an older version of NorthstarProton, replace the information about launch options with a text file called `run_northstar.txt` in your Titanfall2 directory. This text file should have a single character `1` inside.
{% endhint %}

## Lutris (Wine)

1. If you don't already have the game downloaded, install the game [from here.](https://lutris.net/games/titanfall-2/)
2. Download the latest version of Northstar from the [releases](https://github.com/R2Northstar/Northstar/releases) page
3. Extract all contents of the file to your Titanfall 2 folder
4. **If you have the game installed on Lutris:** right click _Titanfall 2_ > _Configure_ > _Game Options_ > Set _Executable path_ to _NorthstarLauncher.exe_
5. **Otherwise:** click the `+` button in the top left > set the name to whatever and _Runner_ to _Wine_ > click on _Game options_ > set _Executable path_ to _NorthstarLauncher.exe_ then save.

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
