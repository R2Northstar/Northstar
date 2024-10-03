# Troubleshooting

### If server is reachable using external IP

**Your GameServer is out of date**

Check that your server is running on the latest Northstar release as it can sometimes include breaking changes.

**MasterServer is down**

Check Northstar's Discord for annoucements.

[https://northstar.tf](https://northstar.tf) giving you a HTTP 523 error means that the masterserver is offline.

**Ports are not the same**

Your gameserver is configured to listen to a given UDP port.

Masterserver needs to be able to contact your gameserver though that same port (i.e., you can't forward a different external port).

**Another Northstar Server is using the port**

Shutdown every other server to narrow down the problem

This won't generally help but will allow you to avoid checking for the wrong server.

### If server is not reachable using external IP

Check if your server is reachable from your internal network's IP (often starts with `192.168.x.x`)

**Firewall is blocking ports**

In some cases your Firewall or antivirus can prevent your ports to be exposed to your local network.
To fix this issue, make a rule to allow your server to listen on your network.
Disabling the firewall and antivirus can also work, even if it's not recommended.

### If server is not reachable using external IP but reachable using internal IP

**Router configuration is incorrect**

If your port can be accessed from your local IP but not from your public IP, then it's very likely that your NAT rules aren't properly configured.

**CGNAT**

See [CGNAT](getting-started.md#cgnat)

### If server is not reachable using external IP nor using internal IP

**Another program is using the port**

Sometimes another program listens to the same port as Northstar.

You can check if that's the case by running `netstat -a -b` using CMD as admin

As two programs cannot listen to the same port and IP at the same time, changing the listen port can sometimes solve the problem.

**Server is using the wrong port**

If you are running multiple instances, the other instances may use a higher port number automatically.

You can use `netstat -a -b` using CMD as admin to check which process listens on which port.

## Cannot join own dedicated server via serverbrowser but others can

If you're hosting the dedicated server on the same network as the PC you're trying to join it from but are unabled to join it, the reason is likely that your router doesn't support [NAT loopback](https://en.wikipedia.org/wiki/Network_address_translation#NAT_loopback).

The TL;DR is that basically when you connect via serverbrowser to your own dedicated gameserver located on the same network, the message goes to your router where it sees that the gameserver IP requested is the same as its IP address. A router that supports NAT loopback will still check forwarding rules, notice that it goes to your server and "turn the packet around" to your server. A router that doesn't support NAT loopback will simply drop the packet, meaning the request to join will never reach your gameserver.

To work around this you can set `ns_auth_allow_insecure 1` on the gameserver in the `autoexec_ns_server.cfg`. This way you can directly connect to your server via `connect <local gameserver ip>:<port>` (e.g. `connect 192.168.123.456:37015`).

Note that this still won't allow you to join your server via serverbrowser. You will always have to use the `connect` command to join it. Also, setting `ns_auth_allow_insecure 1` means that anyone that knows the server IP can join it without authenticating with masterserver, meaning that they can impersonate any player on your server. \
To resolve this you will have to invest into a router that supports NAT loopback or host your gameserver outside your local network.
