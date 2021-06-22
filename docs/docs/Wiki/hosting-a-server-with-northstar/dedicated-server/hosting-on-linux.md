# Hosting on Linux

!!! info
    This page is currently work-in-progress.


Linux users can launch the server executable using a Docker image or by using Wine.
If you do not have a DirectX 11 capable GPU in your system (for example if you are using a hosting service), you will want to host a **Headless server.**

# <a name="Headless_Servers">Headless Servers</a>

## Using Docker

The preferred method for running a Northstar server in Docker is using pg9182's image which can be found in this GitHub repo: [https://github.com/pg9182/northstar-dedicated](https://github.com/pg9182/northstar-dedicated)

### Prerequisites

| Requirement | Description                                             |
| ----------- | ------------------------------------------------------- |
| Kernel      | Linux 5.3+, but 4.9+ should work                        |
| CPU         | x86\_64, at least 3 cores minimum                       |
| RAM         | 2GB (Typically peaks at 1.6GB)                          |
| Disk        | 5GB                                                     |
| Network     | Recommended at least 7-20Mbps up                        |
| Docker      | Have Docker and Docker-Compose installed on the machine |

### Installation

#### Install Docker and Docker-Compose

If you don't already have Docker and Docker-Compose installed, you can learn how to install them for your distro [from this guide](https://docs.docker.com/engine/install/). Once you have them installed, you can move on to the next section.

### Prepare Titanfall2 Server files

You will need obtain Titanfall2's game files, typically by copying over your Titanfall2 installation folder and placing it on the Linux machine. Most of these files are for singleplayer and therefore we can delete them from the installation folder and prune the file size down to \~5GB.

Easiest way to do this is to copy the entire Titanfall2 folder to the server and delete the [following files](https://github.com/pg9182/northstar-dedicated#reducing-the-size-) \
Alternatively download and run [this shell script](https://gist.github.com/pg9182/9a962adbfc27e93237cd14e4523c9da8) to download only the game files necessary to run a server.

#### Copy Titanfall2 folder over to the Linux machine

1. Access the files on your Linux machine using tools like [WinSCP](https://winscp.net/eng/download.php) or any tool that allows for SSH file transfer, or transfer files via USB drive if you can physically access your server.
2. Navigate to the folder where you want to store the files. You can put them into `home/YOUR-USERNAME/Titanfall2` for example.
3. Copy the newly pruned Titanfall2 folder to the server.

#### Copy mods to server

If you have configured some mods, these can be placed at a similar location, like `home/YOUR-USERNAME/mods` for example.

Note that Northstar itself is already installed in the Docker image. Therefore unless you are testing a development version you should NOT copy over the `Northstar.XYZ` mods.

#### Create docker-compose file

We are going to be using Docker-Compose to set up our container. This gives us much more flexibility and allows us to make changes to the start up arguments much cleaner. This example will let you start your servers without needing to have your compose file in the same folder and directory as Titanfall2 and your mods folder. Create a compose file in your home directory, or wherever is most convenient.

```
nano docker-compose.yml
```

Example `docker-compose.yml` \
(Note that you will have to adjust some lines to make it work on your machine)

```yaml
version: "3"
services:
  northstar-attrition:
    image: ghcr.io/pg9182/northstar-dedicated:1-tf2.0.11.0
    pull_policy: always
    environment:
      NS_PORT: 37015
      # uncomment for Northstar v1.12 and older
      #NS_PORT_AUTH: 8081
      NS_SERVER_NAME: "Enter Server Name here"
      NS_SERVER_DESC: "Enter your description here"
      NS_EXTRA_ARGUMENTS: |
        +setplaylist aitdm # Attrition
        +mp_gamemode aitdm # Attrition
        +map mp_angel_city
        +ns_private_match_countdown_length 0
        +ns_should_return_to_lobby 0
        +net_compresspackets_minsize 64
        +net_compresspackets 1
        +spewlog_enable 0
        +sv_maxrate 127000
    volumes:
      - /home/YOUR_USERNAME_HERE/Titanfall2:/mnt/titanfall:ro
      - /home/YOUR_USERNAME_HERE/Titanfall2/mods:/mnt/mods:ro
    ports:
      - "37015:37015/udp"
    restart: always
```

A list of all the CONVARs are [here](../../hosting-a-server-with-northstar/server-settings/convars.md)

A more complex docker-compose example for hosting a server can be found [here](https://github.com/pg9182/northstar-dedicated#container), along with some extra information.

### Starting

#### Run the following command

To run this container go to the folder where you saved the `docker-compose.yml` in and type

```
docker-compose up
```

Your server should be up and running now. Check the in-game server browser or the [online server list](https://northstar.tf/servers) to see if it's online.

Should your server not show up or should you encounter any other issues, check the [server troubleshooting section](../../hosting-a-server-with-northstar/troubleshooting.md) of the wiki.

## Without using Docker

> Hosting on a headless Linux server without Docker on Linux is not recommended, as you'll be forced to build packages yourself.

You can find instructions for running a dedicated server using Wine on [pg9182's repository.](https://github.com/pg9182/northstar-dedicated#running-with-wine)

[This comment on GitHub](https://github.com/R2Northstar/Northstar/issues/49#issuecomment-1001094694) also contains some information for hosting a dedicated server on Linux.
