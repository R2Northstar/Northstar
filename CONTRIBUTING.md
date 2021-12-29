# Welcome to Northstar contribution guide

Thank you for investing your time in contributing to our project!

## Repositories architecture

Northstar software is split into several repositories:

* [Northstar](https://github.com/R2Northstar/Northstar) is the main repository; it only contains downloadable 
versions of the client and wiki documentation (it does not contain source code).
* [NorthstarMasterServer](https://github.com/R2Northstar/NorthstarMasterServer)
holds source code of the master server, which is responsible for authentication, persistence, custom servers
listing.
* [NorthstarLauncher](https://github.com/R2Northstar/NorthstarLauncher) holds source code responsible for 
injecting custom content (mods) into original game files.
* [NorthstarMods](https://github.com/R2Northstar/NorthstarMods) contains mods recreating server gamelogic,
enabling custom server hosting.

## Issues

### Create a new issue 

If you find a bug while using Northstar, before posting it, please ensure that a corresponding issue does not 
already exists.

Also, please double-check that you're opening an issue in the correct repository (read carefully `Repositories architecture`
of this document if you're not sure).

