#! /bin/bash

if ! python3 -m poetry &>/dev/null; then
    python3 -m pip install -U poetry
fi
python3 -m poetry install
cd ./docs || exit
python3 -m poetry run sphinx-autobuild source build/html --open-browser --ignore "*build/**"
cd ../
