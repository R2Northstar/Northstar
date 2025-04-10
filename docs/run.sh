#!/bin/bash

if ! python3 -m uv &>/dev/null; then
    python3 -m pip install -U uv
fi
python3 -m uv run mkdocs serve
