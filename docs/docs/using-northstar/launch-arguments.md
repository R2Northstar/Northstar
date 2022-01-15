# Launch arguments

Here's a list of new command line arguments that Northstar introduces, they should be included in `ns_startup_args.txt` or `ns_startup_args_dedi.txt`.

Argument|Description|Value
-|-|-
`-disablelogs`|Disable logging and creation of log files
`-vanilla`|Disables Northstar loading
`-northstar`|Enables Northstar loading
`-dedicated`|Starts a dedicated server without video output
`-waitfordebugger`|Waits for debugger to connect before launching game
`-language`|Forces loading of client localisation|language string ex: `portuguese`
`LFX|Enables the use of [LatencyFleX](playing-on-linux#latencyflex) (Linux-only)|`0` or `1`
