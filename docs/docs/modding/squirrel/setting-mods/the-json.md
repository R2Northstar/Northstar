The mod.json
============

The mod.json is responsible for governing when, and where your mod is loaded, and follows a layout that is fairly complicated at first glance, but ultimately simple

```json
{
	"Name" : "SimpleRandomiser",
	"Description" : "SimpleRandomiser",
	"Version": "0.1.0",
	"LoadPriority": 1,
```
The script above defines the pubic and listed details of the mod
```json
	"Scripts": [
		{
			"Path": "sh_SimpleRandomiser.gnut",
			"RunOn": "MP",
			"ClientCallback": {
				"After": "simplerandomiser_init"
			},

			"ServerCallback": {
				"After": "simplerandomiser_init"
			}
		}
	],
```
The scirpt above defines both what functions to run, when to run them and WHERE to run them, in this case it runs your simplerandomiser_init, when on multiplayer and for both the server and the client
```json
	"Localisation": [
		"resource/simplerandomiser_localisation_%language%.txt"
	]
}
```
this defines the path to the language file

name this file mod.json, and it should go in the mods root folder
