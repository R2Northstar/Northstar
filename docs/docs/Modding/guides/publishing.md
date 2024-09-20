# Publishing your mod

## Best practices

Make sure to name your mod in the form `<your name>.<mod name>`, similar to the existing default mods, like `Northstar.Client`, `Northstar.CusomServer`,
Note that the Northstar name (`Northstar.Xyz`) is reserved for mods that come with the Northstar install and should therefore **not** be used.

It is recommended to upload the source code of your mod to a public repository like [Github](https://github.com/) to give your users a place to suggest changes and leave feedback in an organised manner.

If the changes your mod makes can be represented in screenshots, gameplay recordings, or GIFs, consider adding those to your README. This way anyone coming across your mod can tell which aspects of the game it changes even before installing it.

To do so, simply upload the image or gif to a host of your choice (Imgur, GitHub, and even Discord all work). To display the image directly on your page in Thunderstore, add the following line to your README:

```markdown
![alt text, this text shows up when image cannot be loaded](https://example.com/image/to/link/to.gif)
```


## Thunderstore

The best place to publish your mod is [Thunderstore](https://northstar.thunderstore.io/). To do so, you need to package your mod as a zip with a specific folder structure. You can either set the structure up manually or use [this GitHub template](https://github.com/laundmo/northstar-mod-template)

### Package structure

The Thunderstore package zip structure is as follows:

```
mods/<your name>.<mod name>/
icon.png
manifest.json
README.md
```


- `icon.png`: 256x256px icon for your mod.
- `README.md`: the description page for your mod
- `manifest.json` outlined [here](https://northstar.thunderstore.io/package/create/docs/)

You can put multiple mods in the `mods/` folder, but only do this if neccessary.

`manifest.json` checker:
[https://northstar.thunderstore.io/tools/manifest-v1-validator/](https://northstar.thunderstore.io/tools/manifest-v1-validator/)

### Uploading

After you have set up the folder structure, head to [https://northstar.thunderstore.io](https://northstar.thunderstore.io) and log in with either Discord or Github. Then you can use the `Upload` button at the top of the page to upload your zip.

When uploading, it will verify your package structure and you can publish after it's successfully checked.

To update a mod, change the version in `mod.json` and `manifest.json`, and upload again. If the mod name is the same, it will update the previous version.

## Github Workflows

If you want to create a Github repository for your mod, you can use a [template](https://github.com/GreenTF/NSModTemplate) that automatically packages and uploads your mod to Thunderstore when you create a Github release of your mod.

Github only supports files smaller than 100mb without using [git-lfs](https://git-lfs.github.com/). Using git-lfs isn't recommended. Instead you should use scripts that split your assets like in this [template](https://github.com/uniboi/NSModTemplate)
