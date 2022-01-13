# Document is empty
`[error] Failed reading masterserver authentification response: encountered parse error 'The document is empty.'`

The masterserver needs to request your gameserver for it to be authentified and registered.
This error means that masterserver can't access your server's tcp port.

It can come from many reasons, but you can narrow them down using [Port scanning tools](#check-if-a-tcp-port-is-open).

## If a scan on your external IP is successfull

#### Your GameServer is out of date

Check that your server is running on the latest Northstar release as it can sometimes include breaking changes.

#### Mastserver is down

Check Northstar's Discord for annoucements. if https://northstar.tf gives you a HTTP 523 error, that means that the masterserver is offline.

#### Ports are not the same 

Your gameserver is configured to listen to a given TCP port.

Masterserver needs to be able to contact your gameserver though that same port.

#### Another program is using the port

Sometimes another program listens to the same tcp port as Northstar.

You can check if that's the case by running `netstat -a -b` using CMD as admin

As two programs cannot listen to the same port and IP at the same time, changing the TCP listen port can sometimes solve the problem.

## If a scan on your external IP isn't successfull

#### Firewall is blocking tcp ports

In some cases your Firewall or antivirus can prevent your ports to be exposed to your local network.
To fix this issue, make a rule to allow your server to listen on your network.
Disabling the firewall and antivirus can also work, even if it's not reccomended.

#### Router NAT configuration is incorrect

If your port can be accessed from your local IP but not from your public IP, then it's very likely that your NAT rules aren't properly configured.

#### CGNAT

See [CGNAT](https://r2northstar.gitbook.io/r2northstar-wiki/hosting-a-server-with-northstar/prerequisites#cgnat)

## Check if a tcp port is open

To check if a tcp port is open, you can use online services like [canyouseeme](https://www.canyouseeme.org/) or use a command line tool.

On Windows using Powershell the following command can detect if a port is accessible. 

`Test-NetConnection -ComputerName IP -Port PORT` 

If powershell isn't an option for you, multiple CLI and GUI tools are available to download.

Here are some examples :
- (CLI)[nmap](https://nmap.org/download.html)
- (GUI)[PortQryUI](https://docs.microsoft.com/fr-FR/troubleshoot/windows-server/networking/portqry-command-line-port-scanner-v2)

Your server **must** be running while you scan the port.
