---
description: A new Northstar master server written in Go
---

# Atlas

TODO

## Main menu promos

For defining main menu promos shown to players, Atlas sends a JSON that defines them.

The endpoint for this is `/client/mainmenupromos`

```json
{
    "newInfo": {
        "Title1": "%$rui\/bullet_point%`2Northstar vX.Y`0 is now live!",
        "Title2": "%$rui\/bullet_point%`2Highlighted`0 defailt",
        "Title3": "%$rui\/bullet_point%Make sure to `2update`0 your game!"
    },
    "largeButton": {
        "Title": "Blog Title",
        "Text": "Short Summary",
        "Url": "https://northstar.tf/blog/REPLACE-ME/",
        "ImageIndex": 0
    },
    "smallButton1": {
        "Title": "Join the Discord!",
        "Url": "https://northstar.tf/discord",
        "ImageIndex": 22
    },
    "smallButton2": {
        "Title": "Check out the Northstar Wiki!",
        "Url": "https://northstar.tf/wiki",
        "ImageIndex": 12
    }
}
```

`ImageIndex` corresponds to the index of the corresponding spotlight + 1

### Spotlights

The spotlights are:

| Name           | Image                                                                |
| -------------- | -------------------------------------------------------------------- |
| `spotlight_01` | ![spotlight_01](../../../_static/images/spotlights/spotlight_01.png) |
| `spotlight_02` | ![spotlight_02](../../../_static/images/spotlights/spotlight_02.png) |
| `spotlight_03` | ![spotlight_03](../../../_static/images/spotlights/spotlight_03.png) |
| `spotlight_04` | ![spotlight_04](../../../_static/images/spotlights/spotlight_04.png) |
| `spotlight_05` | ![spotlight_05](../../../_static/images/spotlights/spotlight_05.png) |
| `spotlight_06` | ![spotlight_06](../../../_static/images/spotlights/spotlight_06.png) |
| `spotlight_07` | ![spotlight_07](../../../_static/images/spotlights/spotlight_07.png) |
| `spotlight_08` | ![spotlight_08](../../../_static/images/spotlights/spotlight_08.png) |
| `spotlight_09` | ![spotlight_09](../../../_static/images/spotlights/spotlight_09.png) |
| `spotlight_10` | ![spotlight_10](../../../_static/images/spotlights/spotlight_10.png) |
| `spotlight_11` | ![spotlight_11](../../../_static/images/spotlights/spotlight_11.png) |
| `spotlight_12` | ![spotlight_12](../../../_static/images/spotlights/spotlight_12.png) |
| `spotlight_13` | ![spotlight_13](../../../_static/images/spotlights/spotlight_13.png) |
| `spotlight_14` | ![spotlight_14](../../../_static/images/spotlights/spotlight_14.png) |
| `spotlight_15` | ![spotlight_15](../../../_static/images/spotlights/spotlight_15.png) |
| `spotlight_16` | ![spotlight_16](../../../_static/images/spotlights/spotlight_16.png) |
| `spotlight_17` | ![spotlight_17](../../../_static/images/spotlights/spotlight_17.png) |
| `spotlight_18` | ![spotlight_18](../../../_static/images/spotlights/spotlight_18.png) |
| `spotlight_19` | ![spotlight_19](../../../_static/images/spotlights/spotlight_19.png) |
| `spotlight_21` | ![spotlight_21](../../../_static/images/spotlights/spotlight_21.png) |
| `spotlight_22` | ![spotlight_22](../../../_static/images/spotlights/spotlight_22.png) |
| `spotlight_23` | ![spotlight_23](../../../_static/images/spotlights/spotlight_23.png) |
| `spotlight_24` | ![spotlight_24](../../../_static/images/spotlights/spotlight_24.png) |
| `spotlight_25` | ![spotlight_25](../../../_static/images/spotlights/spotlight_25.png) |
| `spotlight_26` | ![spotlight_26](../../../_static/images/spotlights/spotlight_26.png) |

!!! note
    These images are lower scaled version of the originals.
    For the high quality original images, check the game files.

!!! note
    `spotlight_20` does not seem to exist