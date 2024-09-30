# FlightCore Guide

FlightCore is a Northstar installer and mod manager which allows for installing, updating, and managing mods for the Northstar client made for Titanfall 2.

Something to note is that FlightCore works on both Windows and Linux. The setup process is similar for both, except for the installation folder, and how you install FlightCore. 

## Windows Installation

![The Windows download button on FlightCore's GitHub page](../../images/flightcore-windows-download.png)

Install the FlightCore file directly from the [Northstar website](https://northstar.tf), from [FlightCore's GitHub releases page](https://github.com/R2NorthstarTools/FlightCore/releases) (You want to download `FlightCore_X.Y.Z_x64_en-US.msi`, X Y Z being the version numbers of FlightCore), or by clicking the Windows download button on [FlightCore's GitHub page](https://github.com/R2NorthstarTools/FlightCore)

Then, run the `.msi` file this downloads, and it will automatically install FlightCore for you.

## Linux Installation 

For Linux, you want to download `flight-core_X.Y.Z_amd64.AppImage` (X Y Z being the version numbers of FlightCore) from [FlightCore's GitHub releases page](https://github.com/R2NorthstarTools/FlightCore/releases), put it in a place you prefer, then make sure to right click on it, click on properties, and tick `Executable as Program` (as shown below), then you can just double click it to open FlightCore.

![Make sure to tick this setting to be ON](../../images/flightcore-executable-as-program.png)

## Main Menu

![FlightCore Main Window](../../images/flightcore-main-window.png)

This is the _Main Menu_ of FlightCore. It includes the _Play_, _Changelog_, _Mods_, and _Settings_ tabs, all of which will be covered in the guide.

## Play 

![Play tab's information](../../images/flightcore-main-window-information.png)

The _Play_ tab is actually the main window that FlightCore opens to. It includes some useful information in the bottom left, such as the version of Northstar you have installed, how many players are online, how many servers are online, and a button to launch Northstar.

## Changelog

![FlightCore's Changelog tab](../../images/flightcore-changelog.png)

The _Changelog_ tab displays information from Northstar's [GitHub page for releases](https://github.com/R2Northstar/Northstar/releases), detailing what a new update to Northstar brings.

## Mods

![FlightCore's Mods browser](../../images/flightcore-mod-browser-window.png)

The _Mods_ tab of Flightcore can display either mods installed locally, or a browser for installing mods from [Northstar's Thunderstore page](https://northstar.thunderstore.io/). The default option it opens to when clicking the tab is displaying the mods you have installed.

`Local` displays mods you have installed currently, with options to toggle them on or off or delete them.

`Online` displays the Mod browser, which sorts by newest uploads by default. Hitting install on a mod will automatically install it, and hitting the *i* next to it will open the mod's information page on ThunderStore in your browser.

## Settings 

![FlightCore's Settings tab](../../images/flightcore-settings.png)

The _Settings_ tab is the fourth and final tab of FlightCore. This tab allows you to view and choose your Titanfall2 directory (default directories can be found in the [Default Directories](../troubleshooting.md#game-location) section), select how many mods you want to see per page on the online browser in FlightCore, the version of FlightCore you're running, a toggle to enable testing release channels, and an option to see a tab for quick access to options designed to help you troubleshoot NorthStar, labeled _Repair_.

![FlightCore's Repair tab](../../images/flightcore-repair.png)

This tab is very useful to both you and anyone that might be trying to help you, with both general Northstar options and FlightCore specific options. The _"Disable all but core mods"_ button allows you to quickly disable all mods that are installed after installing Northstar, allowing you to quickly see if a mod you have installed is causing issues. _"Force reinstall Northstar"_ does what the name implies, completely reinstalling Northstar in the event of something going wrong with your Northstar files.

The FlightCore specific options include _"Force delete temp download folder"_, which will forcibly delete a folder that FlightCore creates to place a mod before it finishes fully installing. This process is normally automatically done, but the option is there in the event of the automatic feature failing, and as a way to clean things up manually. The last option of the Repair screen is the _"Delete FlightCore persistent store"_ button. This button may sound complicated, but it essentially just resets FlightCore settings such as install path, in case you ever want to/need to "reset" FlightCore.
