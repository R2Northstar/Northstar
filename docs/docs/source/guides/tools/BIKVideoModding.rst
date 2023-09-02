BIK Video Modding
=================

Prequisites to Video Modding
============================

- `The RAD Video Tools <http://www.radgametools.com/bnkdown.htm>`__ installed on your PC
.. note::
    The ZIP file containing the installer is password protected, you can find it on the download page
    

Converting the Video
~~~~~~~~~~~~~~~~~~~~

1. Open RAD Video Tools
2. Browse to your Video in the File Browser and select it
3. Press "Bink it!"
4. In the newly opened window press "Bink"
5. Wait for the Conversion to finish, then press done

The Video will now be in the same folder as the original one and converted to a .bik file


Making a Main Menu Video Mod
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. `Convert <#converting-the-video>`__ a Video to .bik
2. Rename the newly converted .bik to ``menu_act01.bik``
3. Make a mod according to `Getting Started </guides/gettingstarted.html>`__
4. Copy the .bik to the following path in your mod folder:
    .. code-block:: text

        author.mod/
        ├─ mod.json
        ├─ media/
        │  ├─ menu_act01.bik
5. Your mod should now load a custom Main Menu Video

