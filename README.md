# Northstar

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/R2Northstar/Northstar)](https://github.com/R2Northstar/Northstar/releases)
![GitHub release downloads (latest by date)](https://img.shields.io/github/downloads/R2Northstar/Northstar/latest/total)
[![Join the chat at Discord](https://img.shields.io/badge/chat-on%20discord-7289DA.svg)](https://northstar.tf/discord)
[![Read the wiki](https://img.shields.io/badge/wiki-GitBook-important)](https://r2northstar.gitbook.io)

Northstar is a modding framework client that allows users to host their own Titanfall 2 servers using custom scripts and assets to create custom content, as well as being able to host vanilla content.

<p align="center"><strong>
<a href="https://r2northstar.gitbook.io/r2northstar-wiki/installing-northstar/basic-setup">Installation</a> | <a href="https://r2northstar.gitbook.io/r2northstar-wiki/installing-northstar/troubleshooting">Troubleshooting</a> | <a href="https://r2northstar.gitbook.io/">Wiki</a>
</strong></p>

## Development

Northstar's development is split into 5 repositories:

1. [NorthstarLauncher](https://github.com/R2Northstar/NorthstarLauncher) (Code for the C++ hook DLL)
1. [NorthstarMods](https://github.com/R2Northstar/NorthstarMods) (Code for the squirrel mods responsible for server gamelogic recreation and custom content)
1. [NorthstarMasterServer](https://github.com/R2Northstar/NorthstarMasterServer) (Responsible for server browser, authentication and persistence)
1. [NorthstarStubs](https://github.com/R2Northstar/NorthstarStubs) (D3D11 and GFSDK stubs for the Northstar dedicated server)
1. [NorthstarNavs](https://github.com/R2Northstar/NorthstarNavs) (Custom navmesh files used for AI navigation)

The documentation is split into two repositories:
1. [NorthstarWiki](https://github.com/R2Northstar/NorthstarWiki) (Wiki covering installation, hosting and configuration of Northstar)
1. [ModdingDocs](https://github.com/R2Northstar/ModdingDocs) (Guides and tutorials on how to mod using Northstar)

## Special Thanks
  
Thanks to everyone that's put up with me and helped out with this project, it's been a fun passion project I've had throughout 2021 so releasing it is pretty cathartic. Specifically: 

- Thanks to the Icepick developers for making the Icepick, I initially forked it for earlier versions of Northstar and it was a great base to experiment with stuff on before moving to the custom launcher.
- Thanks to everyone on R5R team for giving me advice on some later parts of development.  
- Thanks to everyone in the testing server for putting up with me and helping find bugs.  
- Thanks to everyone else that's helped, gave advice, all that.
