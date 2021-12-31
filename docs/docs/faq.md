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

### Q: I get an error saying "Showing user info for UID 0 on hardware" and can't connect to servers!

A: Should be fixed soon.

### Q: I get an error regarding "File Corruption" and can't launch Northstar.

A: Check the Engine Error File Corruption Detected thread.

### Q: Can you host a dedicated server on Linux?

A: It works using wine and llvmpipe, a guide is WIP.

### Q: I get an error message saying "Connection timed out" when trying to connect to my own dedicated server.

A: Add `+net_usesocketsforloopback 1` in your `ns_startup_args.txt` and `ns_startup_dedi_args.txt`, restart both client and server.
