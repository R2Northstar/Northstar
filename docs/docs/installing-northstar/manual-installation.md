# Manual installation

## Installing Northstar:

{% embed url="https://www.youtube.com/watch?v=bK4pV-AHOHM" %}

Firstly, note that the Northstar client is only available on PC and requires you to **both own the game and have it installed**.

1. Download the latest version of Northstar from the [releases](https://github.com/R2Northstar/Northstar/releases) page
2. Copy all the files in the newly downloaded zip folder to your `Titanfall2` folder.\
   ![Drag and drop the contents of the zip into your Titanfall2 folder](../images/manual-install-drag-drop-files.png)\
   The location of the `Titanfall2` folder can vary depending on whether you purchased the game off Steam or Origin, and if you set a custom folder for game installs.
   * **For Steam** - Right click _Titanfall 2_ > Open _Properties_ > Click _Local Files_ > Click _Browse_\
     Usually: `C:\Program Files (x86)\Steam\steamapps\common\Titanfall2`
   * **For Origin** - To find the location of your Origin library go to _Origin_ -> _Application Settings_ -> _Installs & Saves_ -> _On your Computer_ -> _Game Library Location_\
     Go to the directory mentioned there using File Explorer and open the `Titanfall2` folder.\
     Usually: `C:\Program Files (x86)\Origin Games\Titanfall2`
   * **For EA App** - To find the location of your EA library go to _Settings_ -> _Download_\
     Go to the directory under "Install location" using File Explorer and open the `Titanfall2` folder.\
     ⚠️ The default location `C:\Program Files\EA Games\Titanfall2` is not writeable by non-admin processes. If you installed Titanfall2 in the default location using EA App, please move the install to a different location.
3. Launch `NorthstarLauncher.exe` to start Northstar
   * After launching for the first time, you'll be greeted with a popup requesting to authenticate to the master server. Click _Yes_ (This can be changed in the mods menu later if desired)\
     ![Authentication Agreement](../images/titleagreement.png)
4. Select _Launch Northstar_\
   ![Launch Northstar](../images/titlelaunchnorthstar.png)
5. From the multiplayer menu, you can use the server browser to select and join any of the public community hosted servers.\
   ![Server Browser](../images/lobbyserverbrowser.png)

Should you notice any issues/warnings/errors while running Northstar, check the troubleshooting page.

{% content-ref url="troubleshooting.md" %}
[troubleshooting.md](troubleshooting.md)
{% endcontent-ref %}

## Updating Northstar

To update, simply follow the same process you used to install Northstar using the newest zipped release of Northstar. When copying the new files make sure to select "_Overwrite_".\
Note that if you modified some files like `ns_startup_args.txt`, these will also be overwritten. If you want to keep the changes you made make sure to make a copy of these files beforehand and change them back after applying the update.
