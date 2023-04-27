C++ Interface
================

The Squirrel VMs can be manipulated and controlled by Northstar and Plugins.

All functions and macros documented are defined and used in the Northstar Client. For plugins it's recommended to use F1F7Y's `template
<https://github.com/F1F7Y/R2PluginTemplate>`_ that mirrors the definitions to an extend or `rrplug
<https://github.com/catornot/rrplug>`_ if you prefer Rust.
Note that this documentation only covers the C++ API available in the Launcher.

For more information you can read the official library `documentation
<http://www.squirrel-lang.org/squirreldoc/reference/embedding_squirrel.html>`_.
However be aware that implementations or behaviour might be different and features are missing in Respawn's Squirrel fork.

.. toctree::
    :maxdepth: 2

    /squirrel/cpp_api/stack
    /squirrel/cpp_api/objecthandling
    /squirrel/cpp_api/objectmanipulation
    /squirrel/cpp_api/sq_functions
