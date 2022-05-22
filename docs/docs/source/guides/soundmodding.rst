Sound Modding
==============

Getting Sounds Played
----------------------

To have sounds be played in-game, you need the audio event name. To get this, go into a private match and enter in the console:``sv_cheats 1`` and then:``ns_print_played_sounds 1``. Then do whatever plays the audio you want to replace and find the event name in the console's output.
After that, go to your mod's folder (the one with your ``mod.json``), and make a new folder called audio. For each sound you want to replace, make a folder named the same as the event, and also a ``.json`` file called the same as the event. In the folder put the audio files which should play.

In your ``name_of_audio_event.json``, put the following:

.. code-block:: json

    {
        "EventId": [ "name_of_audio_event" ],
        "AudioSelectionStrategy": "random"
    }

In ``EventId`` put the event name, and in ``AudioSelectionStrategy`` enter ``random`` or ``sequential``. If you choose random, the game will pick a random sound from the folder and play it. If you pick sequential, the sounds will be looped over in alphebetically order.

Creating Your Sound
--------------------
Recommended tool: `Audacity <https://www.audacityteam.org/>`_ 

Open/Add your audio as a track to Audacity and set your sample rate to either ``48000hz`` or ``44100hz``.
In Audacity, select your entire track, open the effects dropdown menu, then click ``Change Speed``. In the dialog set either ``Speed Multiplier`` to ``0.918`` or ``Percent Change`` to ``-8,200``. After that, export your track as ``.wav`` and make sure you don't add any metadata.
