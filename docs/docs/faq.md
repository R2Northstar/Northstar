---
description: Frequently asked questions
---

# FAQ

### Q: Where are all my levels and saved loadouts?

A: Northstar runs separate from official servers and progress does not carry over.

However your progress on official servers is not lost, so running vanilla client after playing on Northstar you should be back to your old level on official servers.

### Q: How do I open the console?

A: Check [_Opening the console_](using-northstar/commands.md#opening-the-console).

### Q: How can I check if my server is listed on the server browser?
You can use community-made server browsers like: https://taskinoz.com/northstar/

### Q: Will there be a console version?

A: No.

### Q: Does AI work? What about custom maps?

A: Not right now, they're being looked into. Give it time. Possibly a lot of time, don't ask for an ETA.

### Q: I'm trying to invite a friend via Steam/Origin but they cannot join me?

A: Due to the way Northstar works, you sadly cannot just create a private match and invite a friend via Steam/Origin. Instead you'll have to host a server.

Check the prerequisites:

{% content-ref url="hosting-a-server-with-northstar/prerequisites.md" %}
[prerequisites.md](hosting-a-server-with-northstar/prerequisites.md)
{% endcontent-ref %}

and instructions to host a _listen server_:

{% content-ref url="hosting-a-server-with-northstar/basic-listen-server.md" %}
[basic-listen-server.md](hosting-a-server-with-northstar/basic-listen-server.md)
{% endcontent-ref %}

### Q: My main menu screen is blank or only cinematics show up!

A: Please remove conflicting mods such as `better.serverbrowser` and reinstall _Northstar core mods_ (those that start with `Northstar.`, are in the [NorthstarMods repository](https://github.com/R2Northstar/NorthstarMods), and included in the release zip).\
Try deleting `enabledmods.json` as well. Otherwise pay attention in console for your errors if you know what you're doing.

### Q: Can I use Northstar to play singleplayer?

A: No single player is not supported at the moment, so you'll need to use the vanilla client. A [co-op single player mod is planned](https://github.com/R2Northstar/NorthstarMods/tree/main/Northstar.Coop) but development is currently halted in favour of focussing on multiplayer content.

### Q: I get an error saying "Showing user info for UID 0 on hardware" and can't connect to servers!

A: Should be fixed soon.

### Q: I get an error regarding "File Corruption" and can't launch Northstar.

A: Check the Engine Error File Corruption Detected thread.

### Q: Can you host a dedicated server on Linux?

A: It works using wine and llvmpipe, a guide is WIP.

### Q: I get an error message saying "Connection timed out" when trying to connect to my own dedicated server.

A: Add `+net_usesocketsforloopback 1` in your `ns_startup_args.txt` and `ns_startup_dedi_args.txt`, restart both client and server.
