# Playing on Linux

Linux is not officially supported currently. However, you can get it working through Proton or Wine by following this guide.

## Installing Northstar on Steam (Proton)

1. Download the latest version of Northstar from the [releases](https://github.com/R2Northstar/Northstar/releases) page
2. Extract all contents of the file to your Titanfall 2 folder ( Right click _Titanfall 2_ > Open _Properties_ > Click _Local Files_ > Click _Browse_ )
3. Rename _Titanfall2.exe_ to anything else ( for example _Titanfall2old.exe_ ), and rename _NorthstarLauncher.exe_ to _Titanfall2.exe_

Now Steam will automatically launch Northstar when you hit play. Just launch the game through Steam and you should be greeted with a Northstar welcome message upon entering the main menu.

> **Note:** There is a current bug where the game would sometimes launch vanilla Titanfall 2 instead of Northstar. There is no universal fix for this, but people have reported changing Proton versions to _Proton 5.13_ or _Proton Experimental_ and deleting the Proton prefix folder (`Steam/steamapps/compatdata/1237970/`) could help resolve this issue

> If you are still suffering from this bug, try running the game through Lutris. The bug doesn't seem to happen there

## Installing Northstar on Lutris (Wine)

1. If you don't already have the game downloaded, install the game [from here.](https://lutris.net/games/titanfall-2/) 
2. Download the latest version of Northstar from the [releases](https://github.com/R2Northstar/Northstar/releases) page
3. Extract all contents of the file to your Titanfall 2 folder

4. **If you have the game installed on Lutris:** right click _Titanfall 2_ > _Configure_ > _Game Options_ > Set _Executable path_ to _NorthstarLauncher.exe_
5. **Otherwise:** click the `+` button in the top left > set the name to whatever and _Runner_ to _Wine_ > click on _Game options_ > set _Executable path_ to _NorthstarLauncher.exe_ then save. 

> **If you're migrating from Steam:** Set _Wine prefix_ to `(your Steam directory)/steamapps/compatdata/1237970/pfx/`. This will save you the hassle of having to re-download Origin. 

Now just launch the game through Lutris and you should be greeted with a Northstar welcome message upon entering the main menu.

> **Note:** Origin might prompt you to log in and "set an installation folder for future downloads" on first launch. Just do those, close Origin, then launch the game again.

> You might feel the game is stuttering a lot in the first hour of playing. This is normal, it's just DXVK is compiling shaders. The more you play, the less you will stutter in the future. Someone on discord wrote [an in-depth guide](https://i.imgur.com/xzop1lQ.png) on good settings to help the shader cache **and a general performance boost by stopping Origin from writing unnecessary files**.\
> [Link to cache](https://github.com/Cervoxx/DXVKCACHE/raw/master/Titanfall2-cache.tar.xz)\
> [Link to Origin being slow discussion](https://github.com/ValveSoftware/Proton/issues/4001#issuecomment-647014231)

---

For more info and proposed fixes, refer to [this issue thread on Github](https://github.com/R2Northstar/Northstar/issues/1)
