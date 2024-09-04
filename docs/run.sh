#!/bin/bash

if ! python3 -m poetry &>/dev/null; then
    python3 -m pip install -U poetry
fi
python3 -m poetry install
python3 -m poetry run mkdocs serve
