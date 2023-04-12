---
description: Frequently asked questions
---

# FAQ

## **If you have any issues please go to [the troubleshooting page.](installing-northstar/troubleshooting.md)**

### Q: Where are all my levels and saved loadouts?

A: Northstar runs separate from official servers and progress does not carry over.

However your progress on official servers is not lost, so running vanilla client after playing on Northstar you should be back to your old level on official servers.

### Q: I get an error message saying "Player Not Found" or "Invalid Master Server Token"

These two errors can commonly be fixed for the average user by following the guide [here](installing-northstar/troubleshooting.md#player-not-found-invalid-master-server-token). "Invalid Master Server Token" can also be caused by the Northstar master server being offline, however this is normally not the cause of the error.

### Q: How do I open the console?

A: Check [_Opening the console_](installing-northstar/using-northstar/commands.md#opening-the-console).

### Q: How can I check if my server is listed on the server browser?

You can use community-made server browsers such as: [https://taskinoz.com/northstar/](https://taskinoz.com/northstar/) or [https://cpdt.dev/northstar/](https://cpdt.dev/northstar/)

### Q: Will there be a console version?

A: No.

### Q: Does AI work? What about custom maps?

A: AI does work! Custom maps however will take time. Possibly a lot of time, don't ask for an ETA.

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

### Q: Can I use Northstar to play the campaign?

A: The campaign can be played using Northstar but for the best experience it is recommended to use vanilla. A [co-op campaign mod is in development](https://github.com/R2Northstar/NorthstarMods/tree/main/Northstar.Coop) and it will be made available when it is finished.

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

### Q: Where is Frontier Defense?

A: Frontier Defense is currently in development and will be available in a release when it's finished.
