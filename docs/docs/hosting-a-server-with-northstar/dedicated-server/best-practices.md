---
description: Tweaks and tricks to improve both your experience in hosting and others' in playing on your server
---

# Best practices

{% hint style="info" %}
TODO: If you have experience in hosting Northstar servers and want to share your knowledge, please open a [pull request](https://github.com/R2Northstar/NorthstarWiki/pulls).
{% endhint %}

## Minimum requirements

The current minimum requirements are as follows:

**Requirements per server:**

- 5GB free disk space (+3 GB if you're on windows due to origin and deps)
- 3+ cores (2 might work, though)
- 3GB+ total memory (RAM or swap will do)
- Windows 8.1 (and built-in WARP [use `-softwared3d11`] or a graphics card) + or wine 6.0.0+ (and dxvk+lavapipe+x11, wined3d+llvmpipe+x11, or a working graphics setup with dxvk or llvmpipe) (see [this](https://github.com/pg9182/northstar-dedicated) for more)

**Per instance:**

- 2GB RAM (this is what's actually used; it does drop to ~1.2GB after a bit)
- 15 Mbps network upload, but 10 is workable, 25 if you want to avoid players getting disconnected when going back to the lobby after a match

**Note:** It is recommended to surpass the listed requirements. Currently the number of available servers covers the daily playerbase more than enough. If you're planning to host public servers for the community it is therefore recommended to either fill a niche (like a gamemode that is so popular that all existing servers are full) or provide a better service than existing hosts (less lag, more stable, etc.).

## Optimization Commands (Optional)

| Command                          | Description                                                                                                                    |
| -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| `net_compresspackets 1`          | Enable compress packets                                                                                                        |
| `net_compresspackets_minsize 64` | Decrease usage from ~12-16 mbps to ~6-8 mbps on 20 player PVP server and ~9-12mbps to ~5-7 mbps on 12 player gun game server   |
| `sv_maxrate 127000`              | Sets the maximum bandwidth rate allowed (both incoming/outcoming) per second (in bytes)                                        |

**Note:** The effect is dependent on your network, system, etc. Therefore, you should really add the command one by one and test it to see if there is any benefit for your server.
