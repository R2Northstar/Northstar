# BIK Video Modding

# Prequisites to Video Modding

- [The RAD Video Tools](http://www.radgametools.com/bnkdown.htm)
installed on your PC

!!! note
    The ZIP file containing the installer is password protected, you can find it on the download page


## Converting the Video

1. Open RAD Video Tools
2. Browse to your Video in the File Browser and select it
3. Press "Bink it!"
4. In the newly opened window press "Bink"
5. Wait for the Conversion to finish, then press done

The Video will now be in the same folder as the original one and converted to a .bik file


## Making a Main Menu Video Mod

1. [Convert](#converting-the-video) a Video to .bik
2. Rename the newly converted .bik to `menu_act01.bik`
3. Make a mod according to [Getting Started](../gettingstarted.md)
4. Copy the .bik to the following path in your mod folder:
    ```text
        author.mod/
        ├─ mod.json
        ├─ media/
        │  ├─ menu_act01.bik
    ```
5. Your mod should now load a custom Main Menu Video


## Playing a Custom BIK Video

Not only can you replace the pre-existing BIK files Respawn uses, you can also make your own custom ones and play them whenever you like with console commands.

`playvideo [video name] [horizontal resolution] [vertical resolution]` will play the named BIK file within the specified resolution.

**EX.** `playvideo mycoolvideo 100 100` will play the BIK file named "mycoolvideo" within a 100x100 resolution square in the top-left corner.

The `stopvideos` command will end any currently playing BIK videos.

With these commands, BIK files can be used as a substitute for custom audio outside of audio overrides, though they of course can only be played directly on the client and have no directional audio. Videos running in a 1x1 resolution in the top-left corner will be nearly unnoticeable outside of whatever audio they're playing.

Some things to note while using custom BIK videos:

* BIKs will always play anchored to the top-left corner of the screen.
* BIK sound is only affected by the Master volume slider.
* If a resolution within the playvideo command is not entered or is invalid, it will be auto-filled by whatever the current window's resolution is. Any number from 1 to 32767 is valid. Anything higher will cause the video to not play.
* Videos will **NOT** stretch based on resolution, any extra space is just black.
* You can also convert files like .mp3 and .wav into .bik. However, the audio quality in-game diminishes considerably.
* While BIKs are allowed to have transparency, Titanfall 2 does not process it appropriately.
* BIK videos will layer on top of each other based on when their command is run. There is no way to change how they are layered.
* When a BIK video ends, if there are any other videos currently running above it, they will be forced to disappear for a single frame right before that video ends. This causes a noticeable flicker for any BIKs that are being used for actual video rather than just sound.
* While the resolution used in the playvideo command does not affect performance, the actual video's resolution can. It's recommended your actual video's resolution is lowered only to what is needed. In the case of only using BIKs for sound, it's recommended you lower resolution and framerate as much as possible with whatever video editor you use.
