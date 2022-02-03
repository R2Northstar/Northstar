---
description: Frequently asked questions
---

# FAQ

## **If you have any issues please go to [the troubleshooting page.](installing-northstar/troubleshooting.md)**

### Q: Where are all my levels and saved loadouts?

A: Northstar runs separate from official servers and progress does not carry over.

However your progress on official servers is not lost, so running vanilla client after playing on Northstar you should be back to your old level on official servers.

### Q: How do I open the console?

A: Check [_Opening the console_](installing-northstar/using-northstar/commands.md#opening-the-console).

### Q: How can I check if my server is listed on the server browser?

You can use community-made server browsers like: [https://taskinoz.com/northstar/](https://taskinoz.com/northstar/)

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

### Q: Can I use Northstar to play singleplayer?

A: No single player is not supported at the moment, so you'll need to use the vanilla client. A [co-op single player mod is planned](https://github.com/R2Northstar/NorthstarMods/tree/main/Northstar.Coop) but development is currently halted in favour of focussing on multiplayer content.

### Q: I get an error saying "Showing user info for UID 0 on hardware" and can't connect to servers

A: Should be fixed soon.

### Q: Can you host a dedicated server on Linux?

A: It works using wine and llvmpipe, a guide is WIP.

### Q: I get an error message saying "Connection timed out" when trying to connect to my own dedicated server

A: Add `+net_usesocketsforloopback 1` in your `ns_startup_args.txt` and `ns_startup_dedi_args.txt`, restart both client and server.

### Q: What's with the "r2" part in the name of some of the Northstar things?

`r2` refers to the internal development name of Titanfall 2 given to it by Respawn. Titanfall 1 for example is `r1`, Apex Legends is `r5`, etc.\
The reason this wiki for example is called `r2northstar.gitbook.io` is due to the fact that "_Northstar_" is a rather common name and as such often already reserved by other organisations and people. "_R2Northstar_" is both uncommon and therefore still available and ties "_Northstar_" with Titanfall 2, due to the `r2` part of the name.

### Q: Can I use a pirated/cracked copy Titanfall 2 to run Northstar?

A: The answer is obvious, No! Northstar does not support piracy of any kind.\
If you want to use Northstar you'll have to purchase Titanfall 2 either from Steam/Origin/EA Desktop App or use a subscription service like Gamepass PC and EA Play.

### Q: Why are there no Attrition / Frontier Defense servers?

A: AI movement (including grunts, autotitans, etc) currently does not work. Since AI is intrinsic to these modes, they are currently unavailable
