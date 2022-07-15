VTF Modding
===========

VTF Overview
------------

VTF, short for "Valve Texture Format", is a texture type used by valve in the source engine and is semi-used in titanfall. it is used for some fx and other textures. Most things use .dds, but we can change this. The tool used to edit vtfs is `VTFEdit <https://nemstools.github.io/pages/VTFLib-Download.html>`__.

VMT Overview
------------

VMT, short for "Valve Material Type", is a text `material <https://developer.valvesoftware.com/wiki/Material>`__ system that dictates how the game percieves a vtf outside of how it looks. It uses `parameters <https://developer.valvesoftware.com/wiki/Category:List_of_Shader_Parameters>`__ and `proxies <https://developer.valvesoftware.com/wiki/Material_proxies>`__ to dictate how `shaders <https://developer.valvesoftware.com/wiki/Shader>`__ will show the game. We will go into greater detail later.

Editing FX that use VTFs
------------------------

A lot of fx in titanfall use vtfs as textures. Therefore, if the corresponding vtf can be found, we can do almost anything with the fx's appearence.
Example Mod: `Exrill's Blue L-Star <https://northstar.thunderstore.io/package/EXRILL/Exrills_Blue_Lstar/>`__
Since the L-Star has a physical bullet that is counted as fx, we can edit how it looks.

VTF Skins
---------

Though it is more a skins thing, making vtf skins is somewhat complicated, and to do any vtf editing you need to understand it. To get started, extract the .mdl of what you want with the `Titanfall VPK Tool <https://github.com/Wanty5883/Titanfall2/blob/master/tools/Titanfall_VPKTool3.4_Portable.zip>`__. Open `englishclient_mp_common.bsp.pak000_dir.vpk` in the vpk folder. Go to `models\weapons` and find the weapon you want. Not all guns are named the same in files as they are in game. Here is `list of weapon names <https://noskill.gitbook.io/titanfall2/documentation/file-location/weapon/weapon-model>`__ to help you out. Once you've found your gun, extract both the ptpov and w versions. ptpov is the viewmodel and w is the normal model. then extract it anywhere. To change the path to the texture we will need a hex editor. I will use `HxD <https://mh-nexus.de/en/hxd/>`__, but you can also use `ida <https://hex-rays.com/ida-free/>`__ or anything else, its just personal preference. Once you've got that, open your .mdl with it and search (ctrl+f) for skin_31. If that dosent bring anything up, try skn_31 or skin31 or something like that until you find it. The string of text around it should look something like `.models\Weapons_R2\weaponname\weaponname_skin_31`. Near it, there should be the same text, but without the `_skin_31`. This is the path to the default textures. Now, before you edit, you have to realize hex editors are just built different (cant help it). You cant add or delete text with a hex editor, only replace. Go to the start of the path for the default textures, and change the path to anything else, as long as it starts with `.models\weapons_r2`. For this example i will make a kraber skin, so i will change my path to `.models\weapons_r2\vtfkraber\vtfkraber`.once youve done that, save and do the same thing on the ptpov_ or w_ model. now in the same folder you extracted your mdls too, make a `materials` folder. inside that create the path you hex edited, but the last part is a .vmt file not a folder. the path i would make would be `models\weapons_r2\vtfkraber\vtfkraber.vmt`. once you have made your .vmt, open it and paste this in::

	"UnlitTwoTexture"
	{

		"$surfaceprop" "metal"
		"$basetexture" ""
		"$texture2" ""
		"$bumpmap" ""	
		"$allowoverbright" "1"
		"$vertexcolor" 1
		"$vertexalpha" 1	
		"$decal" "1"
		"$model" 1
		"$nocull" "1"
	}

When we use vtf textures, we can only use the albedo and normal `maps <https://titanfall-skin-group.gitbook.io/titanfall-2-skin-creation/ms/genral-information/texture-maps>`__. Fire up `VTFEdit <https://nemstools.github.io/pages/VTFLib-Download.html>`__ and hit file, import, and grab your texture. then file, save as, and save it in the same folder as your .vmt. In your vmt, put the path to your texture in the parentheces after `"$basetexture"`, treating models as root. So i would put, `models\weapons_r2\vtfkraber\kraber_col`. Then do the same for your normal map, but when you import it, pick volume texture instead of animated texture. In `"$bumpmap"` put the path to your normal texture. Now create another vtf with literally any image. Put its path in `"$texture2"`. As far as i know, this is neccesary even though the texture isnt used. Your root folder should look somewhat like this::

	root
	├─ materials
	│  └─ models
	│     └─ weapons_r2
	│        └─ vtfkraber
	│           └─ vtfkraber.vmt
	└─ models
	   └─ weapons
	      └─at_rifle (name of kraber)
	        ├─ ptpov_at_rifle.mdl
	        └─ w_at_rifle.mdl

And you're done! You just need to pack it into a vpk with the vpk tool and put it in a mod.

Making your Skin Animated
-------------------------

To make an animated skin, all we need to do is add a proxie and change our albedo vtf. Once you've made the frames of your skin, import them all at once with ctrl+a and save your vtf. Put it as `"$basecolor"`. At the bottom of your vmt but before the }, add this:
::
	"Proxies"
	{
			AnimatedTexture
			{
				animatedTextureVar $basetexture
				animatedTextureFrameNumVar $frame
				animatedTextureFrameRate 
			}
	}

Put the fps you want your skin to play at in afet animatedTextureFrameRate, and you're done!
