---
description: Frequently asked questions
---

# FAQ

## **If you have any issues please go to [the troubleshooting page.](installing-northstar/troubleshooting.md)**

### Q: Where are all my levels and saved loadouts? <a href="#faq-loadouts" id="faq-loadouts"></a>

A: Northstar runs separate from official servers and progress does not carry over.

However your progress on official servers is not lost, so running vanilla client after playing on Northstar you should be back to your old level on official servers.

### Q: I get an error message saying "Couldn't find player account" or "Invalid Master Server Token" <a href="#INVALID_MASTERSERVER_TOKEN" id="INVALID_MASTERSERVER_TOKEN"></a>

These two errors can commonly be fixed for the average user by following the guide [here](installing-northstar/troubleshooting.md#PLAYER_NOT_FOUND). "Invalid Master Server Token" can also be caused by the Northstar master server being offline, however this is normally not the cause of the error.

### Q: I get an error message saying "Failed creating log file! Make sure the profile directory is writable."/ Why won't my mod manager install mods? <a href="#faq-failed-log" id="faq-failed-log"></a>

Most of the time, this is due to the fact that EA App's default install location is read-only, which does not allow for Northstar to write logs in that location, and commonly doesn't allow mod managers to properly install mods. You can fix it by following the [default EA location section](installing-northstar/troubleshooting.md#cannot-write-log-file-when-using-northstar-on-ea-app)

### Q: How do I open the console? <a href="#faq-devconsole" id="faq-devconsole"></a>

A: Check [_Opening the console_](using-northstar/commands.md#opening-the-console).

### Q: How can I check if my server is listed on the server browser? <a href="#faq-is-my-server-listed" id="faq-is-my-server-listed"></a>
You can use the official server browser on [https://northstar.tf/servers/](https://northstar.tf/servers/)\
Alternatively, you can use a community-made server browser such as: [https://taskinoz.com/northstar/](https://taskinoz.com/northstar/)

### Q: Will there be a console version? <a href="#faq-console" id="faq-console"></a>

A: No.

### Q: Does AI work? What about custom maps? <a href="#faq-ai" id="faq-ai"></a>

A: AI does work! Custom maps however will take time. Possibly a lot of time, don't ask for an ETA.

### Q: I'm trying to invite a friend via Steam/Origin but they cannot join me? <a href="#faq-invite-friends" id="faq-invite-friends"></a>

A: Due to the way Northstar works, you sadly cannot just create a private match and invite a friend via Steam/Origin. Instead you'll have to host a server.

Check the [prerequisites](hosting-a-server-with-northstar/getting-started.md) and [instructions to host a _listen server_](hosting-a-server-with-northstar/basic-listen-server.md):

### Q: Can I use Northstar to play the campaign? <a href="#faq-campaign" id="faq-campaign"></a>

A: The campaign can be played using Northstar but for the best experience it is recommended to use vanilla. A [co-op campaign mod is in development](https://github.com/R2Northstar/NorthstarMods/tree/main/Northstar.Coop) and it will be made available when it is finished.

### Q: I get an error saying "Showing user info for UID 0 on hardware" and can't connect to servers <a href="#faq-UID-0" id="faq-UID-0"></a>

A: Should be fixed soon.

### Q: Can you host a dedicated server on Linux? <a href="#faq-dedicated-linux" id="faq-dedicated-linux"></a>

A: Check the [Linux dedicated server hosting section](hosting-a-server-with-northstar/dedicated-server/hosting-on-linux.md)

### Q: I get an error message saying "Connection timed out" when trying to connect to my own dedicated server <a href="#faq-connected-timed-out" id="faq-connection-timed-out"></a>

A: Add `+net_usesocketsforloopback 1` in your `ns_startup_args.txt` and `ns_startup_dedi_args.txt`, restart both client and server.

### Q: What's with the "r2" part in the name of some of the Northstar things? <a href="#faq-r2" id="faq-r2"></a>

`r2` refers to the internal development name of Titanfall 2 given to it by Respawn. Titanfall 1 for example is `r1`, Apex Legends is `r5`, etc.\
The reason this wiki for example is called `r2northstar.gitbook.io` is due to the fact that "_Northstar_" is a rather common name and as such often already reserved by other organisations and people. "_R2Northstar_" is both uncommon and therefore still available and ties "_Northstar_" with Titanfall 2, due to the `r2` part of the name.

### Q: Can I use a pirated/cracked copy Titanfall 2 to run Northstar? <a href="#faq-piracy" id="faq-piracy"></a>

A: The answer is obvious, No! Northstar does not support piracy of any kind.\
If you want to use Northstar you'll have to purchase Titanfall 2 either from Steam/Origin/EA Desktop App or use a subscription service like Gamepass PC and EA Play.

### Q: Where is Frontier Defense? <a href="#faq-frontier-defense" id="faq-frontier-defense"></a>

A: Frontier Defense is currently in development and will be available in a release when it's finished.

### Q: I get an error message saying something along the lines of "SSL connect error" <a href="#faq-ssl" id="faq-ssl"></a>

A: We are unsure of what causes this, and are trying to figure out a solution for it. If you experience this, please reach out to us via a ticket on the Northstar Discord server to allow us to get more information on the issue

### Q: Why is my game running so bad? <a href="#faq-performance" id="faq-performance"></a>

A: This usually lies behind your computer's specs not being high enough in order to run the game, but can also be affected by EA App's overlay. You can disable this by going to and following the [disable EA overlay section](installing-northstar/troubleshooting.md#ea-overlay).

### Q: Why does my game tell me there's an issue with Origin when I don't have Origin? <a href="#ea-replaced-origin" id="faq-ea-replaced-origin"></a>

A: Titanfall2 (and other EA games) used to use a program called [Origin](<https://en.wikipedia.org/wiki/Origin_(service)>) to play games, however this has since been replaced by the EA App.
This change, however, did not update the game's error messages to say "EA App" instead of "Origin", so any time you see that there's an issue with Origin, you can replace mention of "Origin" with the "EA App".

### Q: When I launch Northstar, a small command prompt appears for a few seconds then closes as nothing else happens!

A: Delete `R2Northstar/plugins`, which disables any currently installed plugins, the only default plugin being Northstar's Discord Rich Presence. Alternatively, you could insert `-noplugins` in your `ns_startup_args.txt` in the [titanfall2 directory](installing-northstar/troubleshooting.md#game-location), which would simply disable plugins instead of deleting them.

### Q: Does Northstar work via EA Play or Xbox Gamepass (PC)? <a href="#faq-eaplay" id="faq-eaplay"></a>

A: Yes, it does! It works by these because EA Play just installs the game on the EA App, and installing Titanfall 2 via Xbox Gamepass (PC) is done via EA Play. Simply install Titanfall 2, and install Northstar. Note that you'll need to do [this fix to move the game location](installing-northstar/troubleshooting.md#cannot-write-log-file-when-using-northstar-on-ea-app) (make sure you carefully read and follow the ENTIRE section) as the default EA install causes issues with Northstar, notably with the log writing process and mod manager installing Northstar and mods properly.
