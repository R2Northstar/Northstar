Contributing to ModdingDocs
===========================

All contributions to ModdingDocs are welcome. To add a change simply make a pull request to the `ModdingDocs repo <https://github.com/R2Northstar/ModdingDocs/>`_.

ModdingDocs uses `reStructuredText <https://en.wikipedia.org/wiki/ReStructuredText>`_.

A cheatsheet for reStructuredText syntax can be found here: https://docs.generic-mapping-tools.org/6.2/rst-cheatsheet.html

The ``.rst`` files can be found in the ``docs/source`` directory. If you're adding a new file, make sure to link it in ``index.rst``

Contributing without a local build
----------------------------------
You don't necessarily need to set up a local build environment.

To contribute without doing so, you can just edit the files in an editor of your choice and create a GitHub pull request from them.

There will be a test-build done for each PR, which you can find on your PR as a "Check" by clicking ``show all checks`` and ``details``.

This should take you to a online version of the docs with your PRs changes. 


Building locally
----------------

First, you need to have a relatively recent version of Python installed - 3.8 or higher. `Download here <https://www.python.org/downloads/>`_

tl:dr;
^^^^^^

.. tabs::

    .. code-tab:: powershell Windows

        git clone https://github.com/R2Northstar/ModdingDocs/
        cd ModdingDocs
        py -m pip install poetry
        py -m poetry install
        py -m poetry run build
    
    .. code-tab:: bash Linux

        git clone https://github.com/R2Northstar/ModdingDocs/
        cd ModdingDocs
        python3 -m pip install poetry
        python3 -m poetry install
        python3 -m poetry run build



Explanation
^^^^^^^^^^^

Open a terminal wherever you want the files to end up and clone the `ModdingDocs repo <https://github.com/R2Northstar/ModdingDocs/>`_, e.g.


.. code:: bash

    git clone https://github.com/R2Northstar/ModdingDocs/
    cd ModdingDocs

Your terminal should now be open in the ModdingDocs folder.

Next, you need to install `Poetry <https://python-poetry.org/docs/cli/>`_, the dependency management and build tool used:

.. tabs::

    .. code-tab:: powershell Windows
        
        py -m pip install poetry
        
    .. code-tab:: bash Linux

        python3 -m pip install poetry

Now, tell poetry to install this project and its dependencies.

.. tabs::

    .. code-tab:: powershell Windows
        
        py -m poetry install
        
    .. code-tab:: bash Linux

        python3 -m poetry install


After this is done downloading and setting up all the dependencies, you can build it with:


.. tabs::

    .. code-tab:: powershell Windows
        
        py -m poetry run build
        
    .. code-tab:: bash Linux

        python3 -m poetry run build


This should rebuild the docs on changes and open them in your default browser with live reloading.


VSCode
---------------

If you're using `Visual Studio Code <https://code.visualstudio.com/>`_, the following extensions might be of interest:


- `snekvik.simple-rst <https://marketplace.visualstudio.com/items?itemName=trond-snekvik.simple-rst>`_: for syntax highlighting
- `lextudio.restructuredtext <https://marketplace.visualstudio.com/items?itemName=lextudio.restructuredtext>`_: for autocompletion and syntax checks.

.. note::
    To get the ReStructuredText support working, you will likely need to tell VSCode to use the Poetry environment.

    To do so, open one of the .py files, which should make the python version appear in the bottom right of VSCode.

    Click on it, and select the version with ``(moddingdocs`` after it.

    Then, when looking at a ReStructuredText file there should be ``esbonio:`` in the bottom right.

    Click that to restart the ReStructuredText support. This allows it to see all the dependencies Poetry installed.

