# Have to make this a python script since Poetry doesn't support commandline yet.
from pathlib import Path
import subprocess

DOCS = Path(__file__).parent / "docs"


def build():
    subprocess.run(
        [
            "sphinx-autobuild",
            "source",
            "build/html",
            "--open-browser",
            "--ignore",
            "*build/**",
        ],
        cwd=DOCS,
    )
