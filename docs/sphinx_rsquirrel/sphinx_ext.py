from sphinx.application import Sphinx

from .lexer import SquirrelLexer


def setup(app: Sphinx):
    app.add_lexer("squirrel", SquirrelLexer)

    return {
        "version": "0.1",
        "parallel_read_safe": True,
        "parallel_write_safe": True,
    }
