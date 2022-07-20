Contributing to ModdingDocs
===========================

All contributions to ModdingDocs are welcome. To add a change simply make a pull request to the `ModdingDocs repo <https://github.com/R2Northstar/ModdingDocs/>`_.

ModdingDocs uses `reStructuredText <https://en.wikipedia.org/wiki/ReStructuredText>`_.

A cheatsheet for reStructuredText syntax can be found here: https://docs.generic-mapping-tools.org/6.2/rst-cheatsheet.html

Setting up the build environment for docs
-----------------------------------------

You don't necessarily need to do this. You could just edit the files in an editor of your choice and then push the changes, wait for a GitHub actions to create a build and then check it out online. However, building the documentation locally allows you to quickly see whether the changes you made were correct or if there were any issues.

To set up a build locally, do the following:

Clone the `ModdingDocs repo <https://github.com/R2Northstar/ModdingDocs/>`_, e.g.


.. code:: bash

    git clone https://github.com/R2Northstar/ModdingDocs/


Opened the clone repo.

Setup a `Python virtual environment <https://docs.python.org/3/tutorial/venv.html>`_
(this is not strictly necessary but can help keep your Python install clean)

.. code:: bash

    # Create virtual environment (the second `venv` is the name of the folder of the virtual environment)
    python3 -m venv venv

    # Activate it
    source venv/bin/activate

Install the Python packages necessary to build the docs

.. code:: bash

    pip install -r docs/requirements.txt

Finally to actually build the docs, go to the ``docs/`` directory and run `make html`, i.e.

.. code:: bash

    cd docs/
    make html

This will create a new folder inside ``docs/`` called ``build/`` where under ``html/`` you can find the rendered HTML files which you can open in the browser of your choice.


Tips and tricks
---------------

If you're using `Visual Studio Code <https://code.visualstudio.com/>`_, the following extensions might be of interest:


- `snekvik.simple-rst <https://marketplace.visualstudio.com/items?itemName=trond-snekvik.simple-rst>`_: for syntax highlighting
- `lextudio.restructuredtext <https://marketplace.visualstudio.com/items?itemName=lextudio.restructuredtext>`_: for previewing the rst files in VS Code
- `ms-vscode.live-server <https://marketplace.visualstudio.com/items?itemName=ms-vscode.live-server>`_: for previewing HTML files in VS Code
