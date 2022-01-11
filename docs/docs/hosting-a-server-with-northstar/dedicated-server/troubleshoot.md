# Document is empty
`[error] Failed reading masterserver authentification response: encountered parse error 'The document is empty.'`

The masterserver needs to request your gameserver for it to be authentified and registered.
This error means that masterserver can't access your server's tcp port.

It can come from many reasons

#### Your GameServer is out of date

Check that your server is running on the latest Northstar release as it can sometimes include breaking changes.

#### Ports are not the same 

Your gameserver is configured to listen to a given TCP port.

Masterserver needs to be able to contact your gameserver though that same port.

#### Windows Firewall is blocking tcp ports

In some cases Windows Firewall can prevent your ports to be exposed to your local network.
To fix this issue, make a rule to allow your server to listen on your network.
Disabling the firewall can also work, even if it's not reccomended.

#### Router NAT configuration is incorrect

If your port can be accessed from your local IP but not from your public IP, then it's very likely that your NAT rules aren't properly configured.

#### CGNAT

See [CGNAT](https://r2northstar.gitbook.io/r2northstar-wiki/hosting-a-server-with-northstar/prerequisites#cgnat)

#### Mastserver is down

Check Northstar's Discord for annoucements. if https://northstar.tf gives you a HTTP 523 error, that means that the masterserver is offline.

## Check if a tcp port is open

To check if a tcp port is open, you can use online services like [canyouseeme](https://www.canyouseeme.org/) or use a command line tool.

On Windows using Powershell the following command can detect if a port is accessible. 

`Test-NetConnection -ComputerName IP -Port PORT` 
