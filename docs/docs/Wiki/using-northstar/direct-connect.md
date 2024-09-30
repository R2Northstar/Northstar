# Direct Connect

If a server is set to private and doesn't show up in the server browser, you can directly connect to it from the console by:

1. [Opening the console](commands.md#opening-the-console).
2. Typing in `connect <ip address>:<port number>`. The default port is `37015`.

If you are using a normal Titanfall 2 client (Note this will only work on servers with `ns_auth_allow_insecure 1`):

1. Open Origin, click on Titanfall 2 and Click on the settings icon.
2. Click `Game Properties` and select `Advanced Launch Options`.
3. Add `+bind "KEY" "connect <ip address>:<port>"`
4. Open the game and select a single player level e.g The Gauntlet
5. Press the `KEY` you specified in step 3
