Textures
^^^^^^^^

Textures are the foundation of some RPak asset types.
They cannot be used directly by the game, but are instead referenced by other asset types which the game can use by itself.

The image used by a texture must be in the .dds format and must be in one of the following compression types:

- BC1 SRGB
- BC2 SRGB
- BC3 SRGB
- BC7
- BC7 SRGB
- DXT1
- DXT3
- DXT5
- BC4U
- BC5U UNORM

.. warning::
    SRGB DDS compression types are preferred, as they can prevent the texture's colour from looking "washed out"

Examples:
=========

1. Basic Texture Asset
----------------------

.. code-block:: json

    {
        "$type": "txtr",
        "path": "textures/models/humans/test_texture",
        "disableStreaming": true
    }

.. note::
    The image file in this texture asset will be called ``test_texture.dds`` and will be at ``<ASSETSDIR>/textures/models/humans/test_texture.dds``

.. note::
    This texture will not be stored in a .starpak file, and all mip levels will be stored in the .rpak file

Asset Structure:
================

``$type``
---------

For an asset to be a texture asset, the ``$type`` field must be ``"txtr"``.

``path``
--------

The ``path`` field of a texture asset is used to determine the location in the RPak's ``assetsDir`` that the image file is in.

It is also used as the asset's unique identifier, allowing other assets to reference and use it.

The ``path`` field must start with ``textures/`` and must not end with a file extension.

.. error::
    If RePak is unable to locate a file at the given ``path``, it will output the following error to the console:

    ``Failed to find texture source file %s. Exiting...``
    where ``%s`` is the ``path`` field of the texture.

.. error::
    If the file at the given ``path`` is not a .dds file, RePak will output the following error to the console:

    ``Attempted to add txtr asset '%s' that was not a valid DDS file (invalid magic).``
    where ``%s`` is the ``path`` field of the texture.

.. error::
    If an unsupported .dds compression type is used, RePak will output the following error to the console:

    ``Attempted to add txtr asset '%s' that was not using a supported DDS type. Exiting...``
    where ``%s`` is the ``path`` field of the texture.

``disableStreaming``
--------------------

The ``disableStreaming`` field of a texture asset determines if the texture should use a starpak to store the higher resolution mip levels.

It should be a boolean value, with ``true`` disabling the use of a starpak,

``disableStreaming`` defaults to ``false`` if it is not present.