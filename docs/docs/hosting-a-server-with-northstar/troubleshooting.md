# Document is empty

`[error] Failed reading masterserver authentification response: encountered parse error 'The document is empty.'`

Masterserver needs to request your gameserver for it to be authentified and registered.
This error means that masterserver can't access your server's tcp port.

Multiple problems can cause this error, but you can narrow it down by checking if your server is reachable from the outside.

## Check if server is reachable

You can check if the server is reachable using your internet browser.

example : `http://{server_ip}:{server_tcp_port}/verify` should answer you `I am a northstar server!`

Your server **must** be running while you check if the server is reachable.

## If server is reachable using external IP

### Your GameServer is out of date

Check that your server is running on the latest Northstar release as it can sometimes include breaking changes.

### MasterServer is down

Check Northstar's Discord for annoucements.

[https://northstar.tf](https://northstar.tf) giving you a HTTP 523 error means that the masterserver is offline.

### Ports are not the same

Your gameserver is configured to listen to a given TCP port.

Masterserver needs to be able to contact your gameserver though that same port.

### Another Northstar Server is using the port

Shutdown every other server to narrow down the problem

This won't generally help but will allow you to avoid checking for the wrong server.

## If server is not reachable using external IP

Check if your server is reachable from your internal network's IP (often starts with `192.168.x.x`)

### Firewall is blocking tcp ports

In some cases your Firewall or antivirus can prevent your ports to be exposed to your local network.
To fix this issue, make a rule to allow your server to listen on your network.
Disabling the firewall and antivirus can also work, even if it's not reccomended.

## If server is not reachable using external IP but reachable using internal IP

### Router configuration is incorrect

If your port can be accessed from your local IP but not from your public IP, then it's very likely that your NAT rules aren't properly configured.

### CGNAT

See [CGNAT](https://r2northstar.gitbook.io/r2northstar-wiki/hosting-a-server-with-northstar/prerequisites#cgnat)

## If server is not reachable using external IP nor using internal IP

Try checking your loopback network interface `http://127.0.0.1:{server_tcp_port}/verify`

### Another program is using the port

Sometimes another program listens to the same tcp port as Northstar.

You can check if that's the case by running `netstat -a -b` using CMD as admin

As two programs cannot listen to the same port and IP at the same time, changing the TCP listen port can sometimes solve the problem.

### Server is using the wrong port

You can use `netstat -a -b` using CMD as admin to check which process listens on which port
