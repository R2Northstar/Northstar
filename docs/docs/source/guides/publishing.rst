Publishing your mod
===================

Best practices
--------------

Make sure to name your mod in the form ``<your name>.<mod name>``, similar to the existing default mods, like ``Northstar.Client``, ``Northstar.CusomServer``,
Note that the Northstar name (``Northstar.Xyz``) is reserved for mods that come with the Northstar install and should therefore **not** be used.

It is recommended to upload the source code of your mod to a public repository like `Github <https://github.com/>`_ to give your users a place to suggest changes and leave feedback in an organised manner.

Thunderstore
------------

The best place to publish your mod is `Thunderstore <https://northstar.thunderstore.io/>`_. To do so, you need to package your mod as a zip with a specific folder structure. You can either set the structure up manually or use `this GitHub template <https://github.com/laundmo/northstar-mod-template>`_

Package structure
^^^^^^^^^^^^^^^^^

The Thunderstore package zip structure is as follows:

.. code-block::

    mods/<your name>.<mod name>/
    icon.png
    manifest.json
    README.md


- ``icon.png``: 256x256px icon for your mod.
- ``README.md``: the description page for your mod
- ``manifest.json`` outlined `here <https://northstar.thunderstore.io/package/create/docs/>`_

You can put multiple mods in the ``mods/`` folder, but only do this if neccessary.

``manifest.json`` checker: `https://northstar.thunderstore.io/tools/manifest-v1-validator/ <https://northstar.thunderstore.io/tools/manifest-v1-validator/>`_

Uploading
^^^^^^^^^

After you have set up the folder structure, head to `https://northstar.thunderstore.io <https://northstar.thunderstore.io>`_ and log in with either Discord or Github. Then you can use the `Upload` button at the top of the page to upload your zip.

When uploading, it will verify your package structure and you can publish after it's successfully checked.

To update a mod, change the version in ``mod.json`` and ``manifest.json``, and upload again. If the mod name is the same, it will update the previous version.