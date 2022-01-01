# Basic Setup

## Installing Northstar

{% embed url="https://www.youtube.com/watch?v=bK4pV-AHOHM" %}

Firstly, note that the Northstar client is only available on PC and requires you to **both own the game and have it installed**.

1. Download the latest version of Northstar from the [releases](https://github.com/R2Northstar/Northstar/releases) page
2. Copy all the files in the newly downloaded zip folder to your Titanfall2 folder. This can vary depending on whether you purchased the game off Steam or Origin, and if you set a custom folder for game installs.
   ```
   examples:
      C:\Program Files (x86)\Origin Games\Titanfall2
      C:\Program Files (x86)\Steam\steamapps\common\Titanfall2
      D:\MyCustomGameFolder\Titanfall2
   ```
   {% hint style="info" %}
   For those on Steam, you don't have to go folder hunting! In your Steam library, right click _Titanfall 2_ > Open _Properties_ > Click _Local Files_ > Click _Browse_
   {% endhint %}
3. Launch NorthstarLauncher.exe to start Northstar\
   After launching, you should be greeted with something like this:\
   ![](https://raw.githubusercontent.com/R2Northstar/Northstar/main/wiki/titleagreement.png)
4. Next select Launch Northstar\
   ![](https://raw.githubusercontent.com/R2Northstar/Northstar/main/wiki/titlelaunchnorthstar.png)
5. From the multiplayer menu, you can use the server browser to select and join any of the public community hosted servers.\
   ![](https://raw.githubusercontent.com/R2Northstar/Northstar/main/wiki/lobbyserverbrowser.png)

Should you notice any issues/warnings/errors while running Northstar, check the troubleshooting page.

{% content-ref url="troubleshooting.md" %}
[troubleshooting.md](troubleshooting.md)
{% endcontent-ref %}

## Additional Stuff

Since Northstar doesn't launch directly through Origin, any startup arguments provided in origin won't transfer over, you'll need to add them to the file `ns_startup_args.txt`, which should be in the same folder as you extracted the Northstar files to.

If Northstar doesn't appear to be installed, or you have issues entering the lobby, try running vanilla files. I can't personally say what VPK mods could cause issues with Northstar at the moment, so it'd probably be easiest just to try running unmodded.
