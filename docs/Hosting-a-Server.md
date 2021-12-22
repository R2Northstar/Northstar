**Hosting a Listen Server**  
To host a listen server on Northstar, go to the lobby and press the `Private Match` button to begin a private match.  
While this does allow you to host a server, other people won't be able to join it, so you'll need to port forward 2 ports to allow other people to join.  
The ports you'll need to forward are 37015-37020 UDP, and 8081 TCP by default, if this works as it should, this should result in your server being displayed on the server browser, and other clients being able to connect to it.  
  
**Hosting a Dedicated Server**  
Dedicated servers allow you to host a Northstar server without having to use a full client, making them more lightweight and easier to host for longer periods of time. Dedicated servers are still in development for Northstar, so while they do work, expect some bugs and general jank.  
To start a dedicated server on Northstar, launch NorthstarLauncher.exe with the argument `-dedicated`, this can be done manually, but releases also provide the batch file `r2ds.bat`, which will also do this.  
When using a dedicated server, arguments are read from `ns_startup_args_dedi.txt`, rather than `ns_startup_args.txt`.  
  
**Dedicated Server Caveats**  
At the moment, dedicated servers still require DirectX 11 to work, which typically requires a physical GPU, though they use almost no GPU processing power while in use, this can be an issue especially on GPU-less setups, so the launch argument `-softwared3d11` can be used to force DirectX to run in software mode.  
While this is absolutely not ideal, it's the best solution for headless dedicated servers at the moment, and surprisingly hardly uses any CPU time, though it can use roughly up to 1GB of RAM.  
Regarding RAM usage, dedicated servers also use significant amounts of RAM at the moment, often requiring 1.5-2GB, though I expect this to lower as development continues.  
  
**Server Configuration**  
Whether you're running a listen or dedicated server, you'll generally want to mess with the configuration at least a bit. While I do think the default configuration settings are pretty ok, being able to change your server's name or password, or increasing your server's tickrate is often something you'll want to do. Server configuration can be modified in the file `R2Northstar/mods/Northstar.CustomServers/mod/cfg/autoexec_ns_server.cfg`, which will be executed on server startup.