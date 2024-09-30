---
description: >-
  Instructions regarding testing new features, directed at both developers and
  maintainers
---

# Testing

{% hint style="info" %}
This section is very much still WIP. Feel free to help expand it.
{% endhint %}

## Developers & Contributors

This section applies to you if you're opening a pull request to any of the Northstar repos.

Whatever your change includes, whether a bug fix or a new feature make sure to test it appropriately.

This means if your change is a bug fix, it's recommend you first make sure you can reproduce the bug. Then after making the necessary changes to fix it, test it using the same method you used to originally confirm the bug.\
When you're opening a pull request, make sure to mention how to reproduce the bug, so that reviewers can confirm that your chance indeed fixed the issue.

If your change is a new feature, make sure to test both that the newly added functionality performs as expected, as well as ensuring that it doesn't introduce any form of regression bugs. This means, testing anything that might be affected by your new feature.

## Maintainers

This section applies to you if you're someone who's able to merge PRs in any of the repos of the Northstar GitHub org as well as when simplying performing reviews, even without being able to actually merge a PR.

When reviewing pull requests on GitHub, make sure to checkout the changes made by a PR locally and test it there. In particular, test the parts of the code that are touched by a PR.

After testing, make sure to mention the steps tested in your review.

## Acquiring necessary files

### FlightCore developer tools

You can use FlightCore to essentially 1-click install any pull request to [NorthstarMods](https://github.com/R2Northstar/NorthstarMods/) and [NorthstarLauncher](https://github.com/R2Northstar/NorthstarLauncher/).

The tool is still being improved upon but already more than usable. Check its README for instructions:

{% embed url="https://github.com/R2NorthstarTools/FlightCore/blob/main/docs/DEV-TOOLS.md" %}


### Manually

#### NorthstarLauncher

Before starting, make sure you have a **working and up-to-date Northstar install** and you're **logged into GitHub with your GitHub account** (downloading files from CI only works while logged into any GitHub account)!

1. Head to the bottom of the page of the PR and click on "_Show all checks_"\
   &#x20;![rcon1](https://user-images.githubusercontent.com/40122905/179726100-48945eb6-3ebe-467f-acef-1c7d56f3e4bd.png)
2. For "_CI / build (pull\_request)_" click on "_Details_"\
   &#x20;![rcon2](https://user-images.githubusercontent.com/40122905/179726993-d1cb7849-a2fc-4d0d-9379-cf4e279469a1.png)
3. From here click on "_Summary_"\
   &#x20;![rcon3](https://user-images.githubusercontent.com/40122905/179727326-5e6d64c7-6ff0-472a-ac7d-7e4f04d6bac9.png)
4. And then click on "_NorthstarLauncher-XXXXXXX_"\
   &#x20;![rcon4](https://user-images.githubusercontent.com/40122905/179727511-877641f8-e5fc-4a34-bcf1-29bafefc1ad2.png)
5. Once downloaded, open the zip and copy `Northstar.dll` and `NorthstarLauncher.exe` to your Titanfall2 folder, overwriting the existing DLL and EXE in there.

Alternatively, compiling the PR'd code from source is also an option. For this, refer to [northstarlauncher.md](repositories/northstarlauncher.md)

#### NorthstarMods

Click on the source branch of the PR

![](../.gitbook/assets/download-mods-pr1.png)

Click on _"Code"_ and then on _"Download ZIP"_

![](../.gitbook/assets/download-mods-pr2.png)

From there copy over all the `Northstar.XXXXX` folders into your mods folder in your Titanfall2 install the same way you would manually install mods.

## Tips and toolkits

(might require `sv_cheats 1`)

**Spawn titan/grunt:**

* For titan: `ent_create npc_titan; ent_fire !picker setteam 2`
* For grunt: `ent_create npc_soldier; ent_fire !picker setteam 2`

**Give free kill / build up titan/core meter**

`script AddPlayerScore(GetPlayerArray()[0], "KillPilot")`

where `GetPlayerArray()[0]` should point to the player you want to give kill/meter.

**Add fake lag for network testing**

`net_fakelag 200` -> 200ms network lag

```
] find net_fake
[info] "net_fakelag" = "0" ( CHEAT ) - Lag all incoming network data (including loopback) by this many milliseconds.
[info] "net_fakeloss" = "0" - Simulate packet loss as a percentage (negative means drop 1/n packets)
[info] "net_fakelag_clientOnly" = "1" ( CHEAT ) - Fakelag won't affect the server, only clients
[info] "net_fakelagjitter" = "0" - Jitter net_fakelag packet time
```

**Joining same server multiple times with same accounts**

By default duplicate accounts are blocked by server. Use `-allowdupeaccounts` when starting server to allow duplicate accounts. From there you can launch multiple clients on the same account and connect them to the server.

**Quickly switch map**

Use `map <map name>` to quickly switch map.\
Example: `map mp_glitch`

List of maps can be found [here](../hosting-a-server-with-northstar/server-settings/file-names.md#maps)

**Speed-up/slow-down game**

Use `host_timescale <factor>` to speed-up or slow-down the game.\
For example `host_timescale 10` speeds up game by factor of `10`. Set to `1` to go back to default.

**Viewing Navmeshes**

Requires `sv_cheats 1` and `enable_debug_overlays 1`.

Use `navmesh_debug_hull 1` to view navmeshes.
