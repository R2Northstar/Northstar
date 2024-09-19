# Troubleshooting

## Northstar not launching with Steam

If you're encountering issues with Northstar launching on Steam, a very quick fix that usually works is deleting the compatdata for Titanfall2.

You can do this by going to your Steam directory, going to `steamapps/compatdata`, then look for the folder called `1237970` (the App ID for Titanfall2). This folder contains the data used by Steam in order to make games function using Proton (assuming you're using Proton for said game).
This folder, however, sometimes has issues with launching Northstar.

It is recommended you close Steam before this. Deleting this folder then attempting to launch Northstar with NorthstarProton again _should_ fix the issue. Steam will generate another `compatdata` folder for Titanfall2 automatically.

## EA App blank window

If you have already logged in to EA App with Proton Experimental, the blank EA App should not prevent you from playing Northstar. However, if you find that it does or if you simply wish to use the EA App, the following should resolve these issues.

### Steam & SteamDeck

1. Make sure that you have protontricks installed

2. Install `d3dcompiler_43` and `d3dcompiler_47` into your Titanfall 2 Proton compatdata.
    1. **For SteamDeck (and Protontricks Flatpak)**, run `flatpak run com.github.Matoking.protontricks 1237970 d3dcompiler_43 d3dcompiler_47` in a terminal session (Konsole on SteamDeck).
    2. **Otherwise**, run `protontricks 1237970 d3dcompiler_43 d3dcompiler_47` in a terminal session.

### Lutris

Install both `d3dcompiler_43` and `d3dcompiler_47` through Winetricks.

## Crackling sound

* [PulseAudio](https://wiki.archlinux.org/title/PulseAudio/Troubleshooting#Glitches.2C\_skips\_or\_crackling):

Add `tsched=0` to `~/.pulse/default.pa`

<details><summary>PipeWire:</summary>

[Source](https://forum.manjaro.org/t/howto-troubleshoot-crackling-in-pipewire/82442)

This guide is for pipewire-media-session, not wirepluber which has a different location and is formatted in LUA.

Before, copy all the necessary configuration files:

```
mkdir -p ~/.config/pipewire/media-session.d/ && cp /usr/share/pipewire/media-session.d/alsa-monitor.conf ~/.config/pipewire/media-session.d && cp /usr/share/pipewire/pipewire.conf ~/.config/pipewire/
```
Restart PipeWire after each step.

1. Enable sample rate switching.

Change `#default.clock.allowed-rates = [ 48000 ]` to `default.clock.allowed-rates = [ 44100 48000 ]` in `~/.config/pipewire/pipewire.conf`.

2. Disable suspend.

Change `#session.suspend-timeout-seconds = 5` to `session.suspend-timeout-seconds = 0` in `~/.config/pipewire/media-session.d/alsa-monitor.conf`.

If the above doesn't help, you can also try:

3. Setting alsa headroom (`alsa-monitor.conf`).

Change `#api.alsa.headroom      = 0` to `#api.alsa.headroom      = 1024`.

If it doesn't solve the issue try 2048 however if it does try lower values: 512, 256, 128, 64, 32. Use a lowest value that works.

4. Changing the alsa period size (`alsa-monitor.conf`).

`#api.alsa.period-size   = 1024`

`#api.alsa.headroom      = 0`

to

`api.alsa.period-size   = 256`

`api.alsa.headroom      = 1024`

If it doesn't solve the issue try different values: 2048, 512, 256, 128, 64, 32. Use a lowest values that works.
</details>

## Fullscreen issues

Running the game on fullscreen through Linux might lead to a black screen preventing you from launching the game. Edit your `ns_startup_args.txt` to include `-noborder -window` or edit `"setting.fullscreen"` and `"setting.nowindowborder"` at `<wineprefix>/drive_c/users/<username>/Documents/Respawn/Titanfall2/local/videoconfig.txt` to solve this.

For more info and proposed fixes, refer to [this issue thread on Github](https://github.com/R2Northstar/Northstar/issues/1)

## Game crashes on launch with Cause: Access Violation Data Execution Prevention (DEP) at: 0x00000000

**Steam/Steam Deck:** Ensure your installation matches the latest [install guide](installing-on-steamdeck-and-linux.md#steam-and-steam-deck-northstarproton).

**Lutris**: Ensure your installation matches the latest [install guide](installing-on-steamdeck-and-linux.md#lutris-wine). If that fails, you may optionally try the latest release of [Wine-TKG](https://github.com/Frogging-Family/wine-tkg-git/releases/latest).

## Reducing stuttering

### DXVK State Cache Stutter Fix

You may feel that the game stutters frequently during the first hour of play. This is normal, it's just DXVK having to compile shaders at draw time due not having a ready state cache. The more you play, the less stuttering there will be in the future.

However if you don't want to wait you can try precompiled DXVK [_state cache_](https://github.com/doitsujin/dxvk#state-cache): [**Titanfall2.dxvk-cache**](https://github.com/begin-theadventure/dxvk-caches/blob/v10/dxvk-caches/Titanfall/Titanfall%202/Titanfall2.dxvk-cache.md)

Proton: extract and put it in `/path/to/steamapps/shadercache/1237970/DXVK_state_cache` default is `~/.local/share/..` or next to .exe if shader pre-caching is turned off.

Wine: extract and put it next to game's .exe. Also remember to rename it if the .exe has a different name.

### Steam/Steam Deck (dxvk-async)

DXVK-async is automatically installed and enabled if using the NorthstarProton runner.

### Lutris (dxvk-async)

DXVK-[_async_](https://github.com/Sporif/dxvk-async#improvements) can optionally be used on Lutris to prevent stutter during shader compilation by asynchronously compiling and allowing the frame to render with not-yet-compiled shaders simply not drawn.

Download [**dxvk-async**](https://github.com/Sporif/dxvk-async/releases), extract and put it in `~/.local/share/lutris/runtime/dxvk` then type the name of the folder in `▲` -> `Configure` -> `Runner Options` -> `DXVK version`, to enable add `DXVK_ASYNC 1` to `System Options` -> `Environment variables`

_DXVK-async can also be installed for Lutris with_ [_ProtonUp-Qt_](https://davidotek.github.io/protonup-qt/)

### Origin Continual File Writing Fix

[_Preventing_](https://github.com/ValveSoftware/Proton/issues/4001#issuecomment-647014231) _Origin from writing certain files_:

Path:

Proton: `/path/to/steamapps/compatdata/1237970/pfx/drive_c/users/steamuser/Application Data/Origin` default is `~/.local/share/..`

Wine: `/path/to/drive_c/users/<username>/AppData/Roaming/Origin`

Access can be restricted using a file manager or terminal:

`chmod -R 555` -> access only

`chmod -R 755` -> access + save

It's also possible to create command aliases to type something short, such as tfoff/tfon.

## Reshade adding incompatible DXVK version for Northstar

If you ever used ReShade together with Titanfall2 in the past it will have created a bunch of DXVK DLLs that are incompatible with Northstar. If Northstar fails to fully initialize with an exception and you have previously installed ReShade on Windows delete the following files from `Titanfall2/bin/x64_retail/`:

* D3D8.DLL
* D3D9.DLL
* D3D10.DLL
* D3D11.DLL
* OPENGL.DLL
* DXGI.DLL

## Archive

{% hint style="info" %}
The following issues should no longer occur in the latest Northstar releases.
{% endhint %}

### Blank console

This issue has been resolved as of Northstar 1.9.2 and newer.

