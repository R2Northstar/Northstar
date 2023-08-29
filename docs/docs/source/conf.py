# Configuration file for the Sphinx documentation builder.

# -- Project information

project = "Northstar Modding"
copyright = "2022, Northstar Developer Team"
author = "Northstar Developer Team"

# -- General configuration

extensions = [
    "sphinx.ext.duration",
    "sphinx.ext.doctest",
    "sphinx.ext.autodoc",
    "sphinx.ext.autosummary",
    "sphinx.ext.intersphinx",
    "sphinx_design",
    "sphinxcontrib.youtube",
    "sphinx_copybutton",
    "sphinx_rsquirrel",
]

intersphinx_mapping = {
    "python": ("https://docs.python.org/3/", None),
    "sphinx": ("https://www.sphinx-doc.org/en/master/", None),
}
intersphinx_disabled_domains = ["std"]

templates_path = ["_templates"]

exclude_patterns = ["_build"]

# -- Options for HTML output

html_theme = "furo"

html_static_path = ["_static"]
html_css_files = [
    "styles/main.css",
]


html_theme_options = {
    "light_css_variables": {
        "color-brand-primary": "#7C4DFF",
        "color-brand-content": "#7C4DFF",
    },
    "dark_css_variables": {
        "color-background-primary": "#14141E",
        "color-background-secondary": "#20202F",
        "color-background-hover": "#10101F",
        "color-highlight-on-target": "#10101F",
    },
}

# -- Options for EPUB output
epub_show_urls = "footnote"

highlight_language = "squirrel"

# furo theme specific
pygments_dark_style = "one-dark"

