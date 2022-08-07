---
description: >-
  pg9182 has provided a complete docker image to run on Linux servers. This
  provides some server management tools and offers better performance. No
  physical GPU is needed.
---

# Docker Install

The aim of this guide is to show the steps to build a docker-compose container that starts on boot and to show basic configuration. Docker image can be found in this GitHub repo: [https://github.com/pg9182/northstar-dedicated](https://github.com/pg9182/northstar-dedicated)

### Prerequisites

| Requirement | Description                                             |
| ----------- | ------------------------------------------------------- |
| Kernel      | Linux 5.3+, but 4.9+ should work                        |
| CPU         | x86\_64, at least 3 cores minimum                       |
| RAM         | 2GB (Typically peaks at 1.6GB)                          |
| Disk        | 5GB                                                     |
| Network     | Recommended at least 7-20Mbps up                        |
| Docker      | Have Docker and Docker-compose installed on the machine |

### Installation

#### Prep Titanfall Server files

You will need to copy over your Titanfall installation folder and place it on the Linux machine. Most of these files are for SP and therefore we can delete from the installation folder and prune the file size down to \~5GB.

Easiest way to do this is copy the entire Titanfall2 folder to your desktop and delete the [following files](https://github.com/pg9182/northstar-dedicated#reducing-the-size-).

#### Copy Titanfall Folder over to the Linux Machine

1. Access the files on your Linux machine using tools like [Filezilla](https://filezilla-project.org/) or [WinSCP](https://winscp.net/eng/download.php)
2. Navigate to the folder where you want to store the files. You can put them into `~/Titanfall2` for example.
3. Copy the newly pruned Titanfall folder to the server.

![Game files copied to `/mnt/Titanfall` as an example](https://i.postimg.cc/15HbbzFr/image.png)

#### Copy mods to server

If you have configured some mods,these can be placed at a similar location, like `~/mods` for example(https://i.postimg.cc/tRD5jnrJ/image.png)

#### Create docker-compose file

We are going to be using Docker-Compose to set up our container, this gives us much more flexibility and allows us to make changes to the start up args much cleaner. Create a compose file in the same location you've put your `Titanfall2` and `mods` folder for example.

```
nano docker-compose.yml
```

Example docker-compose.yml

```yaml
version: '3'
services:
 northstar1: 
   image: ghcr.io/pg9182/northstar-dedicated:1-tf2.0.11.0 
   pull_policy: always 
   environment:
     - NS_PORT=37015
     - NS_PORT_AUTH=8081
     - 'NS_SERVER_NAME=[Region]Enter Server Name here'
     - 'NS_SERVER_DESC=Enter your description here'
     - |
       NS_EXTRA_ARGUMENTS=
       +setplaylist aitdm 
       +mp_gamemode aitdm 
       +map mp_angel_city
       +ns_private_match_countdown_length 0
       +ns_should_return_to_lobby 0
       +net_compresspackets_minsize 64
       +net_compresspackets 1
       +spewlog_enable 0
       +sv_maxrate 127000
   volumes:
     - ./Titanfall2:/mnt/Titanfall:ro
     - ./mods:/mnt/mods:ro
   ports:
     - '37015:37015/udp'
     - '8081:8081/tcp'
   restart: always
```

**Note:** `./<foldername>` in volumes means that the location is relative to your compose file. The general syntax for adding volumes is `<location on host>:<location in container>[:<modifier like read-only>]` (the part in `[...]` is optional).


A list of all the CONVARs are [here](../../basic-listen-server/#server-configuration)

### Starting

#### Run the following command

To run this container go to the folder you saved the `docker-compose.yaml` in and type

```
docker-compose up
```
