from pygments.lexer import RegexLexer, bygroups, default, include, this, using, words
from pygments.token import (
    Comment,
    Generic,
    Keyword,
    Name,
    Number,
    Operator,
    Punctuation,
    String,
    Text,
    Token,
    Whitespace,
)

# test: hwatch -t -N --no-help-banner -c py -m pygments -x -O"full,debug_token_types" -l .\sphinx_rsquirrel\lexer.py:SquirrelLexer test.gnut
# py -m pygments -v -f html -x -O"full,debug_token_types" -l .\sphinx_rsquirrel\lexer.py:SquirrelLexer test.gnut


class SquirrelLexer(RegexLexer):
    name = "Squirrel"
    aliases = ["squirrel"]
    filenames = ["*.nut", "*.gnut"]

    _keyword_types = [
        "void",
        "bool",
        "int",
        "float",
        "entity",
        "string",
        "vector",
        "asset",
        "var",
    ]
    _builtin_names = [
        "TitanLoadoutDef",
        "PilotLoadoutDef",
    ]
    _declarations = [
        "global",
        "const",
        "static",
        "local",
        "typedef",
    ]
    tokens = {
        "values": [
            (r"[^\S\n]+", Whitespace),
            (r"(\$?\"(\\.|.)*?[\"\n])", String),
            (r"-?([0-9]+(([.]([0-9]+)?)(e[-]?[0-9]+)?))", Number.Float),
            (r"(0x[0-9a-fA-F]+|0[0-7]+|-?[0-9]+|'[a-f]')", Number.Integer),
            include("constants"),
        ],
        "value": [include("values"), default("#pop")],
        "root": [
            (r"(\"(\\.|.)*?[\"\n])", String),
            include("comments"),
            include("keywords"),
            include("operators"),
            include("statement"),
            # include("generic"),
        ],
        "statement": [
            (r"#.*", Comment.Preproc),
            (r"(function)(\s+)", bygroups(Keyword, Whitespace), "funcname"),
            (
                r"(class)(\s+)([a-zA-Z_]\w*)",
                bygroups(Keyword, Whitespace, Name.Class),
            ),
            (r"(struct|enum)( ?)(\{)", bygroups(Name.Class, Whitespace, Punctuation)),
            include("declarations"),
            (
                r"(\.?)([a-zA-Z_]\w*)(\s*?)(\()",
                bygroups(Punctuation, Name.Function, Whitespace, Punctuation),
                "arguments",
            ),
            include("type"),
            (r"(?<=\w)(\.)(\w+)", bygroups(Punctuation, Name.Attribute)),
            (
                r"(?<=\w)(\.)(\w+)(=)",
                bygroups(Punctuation, Name.Attribute, Punctuation),
            ),
            (
                r"([a-zA-Z_]\w*)(\s*)(=)",
                bygroups(Name.Variable, Whitespace, Punctuation),
            ),
            include("values"),
            include("tableaccess"),
            (r"[a-zA-Z_.]\w*", Name.Variable),
            (r"[\{\}\(\)\[\]]", Punctuation),
        ],
        "funcname": [
            (r"[a-zA-Z_]\w*", Name.Function),
            (r"[(]", Punctuation, "sig"),
            default("#pop"),
        ],
        "sig": [
            (
                r"([a-zA-Z_]\w*)(\s*?)(?=[,)])",
                bygroups(Name.Variable, Whitespace),
            ),
            (r"[\[<]", Generic.Error, "array"),
            (r",", Punctuation),
            (r"=", Punctuation, "value"),
            (r"\.\.\.", Keyword.Pseudo),
            include("operators"),
            (r"[)]", Punctuation, "#pop"),
            include("typed_name"),
        ],
        "itype": [
            (r"[>]", Punctuation, "#pop"),
            include("tableaccess"),
            include("typed_name"),
        ],
        "typeb": [
            include("typed_name"),
            default("#pop"),
        ],
        "typed_name": [
            include("type"),
            (r"[a-zA-Z_]\w*", Name.Variable),
        ],
        "type": [
            (
                r"(array|table)(\s*?)(<)",
                bygroups(Keyword.Type, Whitespace, Punctuation),
                "itype",
            ),
            (words(_keyword_types, suffix=r"\b"), Keyword.Type),
            (words(_builtin_names, suffix=r"\b"), Name.Builtin),
            include("constants"),
            (r"ornull", Keyword.Type),
            (
                r"(\s*?)(functionref)(\()",
                bygroups(Whitespace, Name.Builtin.Type, Punctuation),
                "sig",
            ),
            (",", Punctuation),
            include("whitespace"),
        ],
        "whitespace": [
            (r"\n", Whitespace),
            (r"[^\S\n]+", Whitespace),
        ],
        "arguments": [
            (r"\)", Punctuation, "#pop"),  # end of arguments
            (r"(,)", Punctuation),  # end of argument
            include("tableaccess"),
            (r"[\[<]", Punctuation, "array"),
            (r"{", Punctuation, "structure"),
            (r"[a-zA-Z_]\w*", Name.Variable),
            include("funcname"),
            include("operators"),
            include("values"),
            include("namedargs"),
        ],
        "namedargs": [(r"(\w+?)(=)", bygroups(Name.Variable, Punctuation))],
        "structure": [
            (r"}", Punctuation, "#pop"),  # end of structure
            (r"(,)( )", bygroups(Punctuation, Whitespace)),  # end of member
            (r"[\[<]", Punctuation, "array"),
            include("constants"),
            include("namedargs"),
        ],
        "tableaccess": [
            (r"(\w+)(\[)", bygroups(Name.Variable, Punctuation), "tablekey"),
        ],
        "tablekey": [
            (r"\]", Punctuation, "#pop"),  # end of structure
            include("values"),
            (r"[a-zA-Z_]\w*", Name.Variable),
        ],
        "array": [
            (r"[\]>]", Punctuation, "#pop"),
            include("tableaccess"),
            (r"(,)( ?)", bygroups(Punctuation, Whitespace)),  # end of member
            (r" ", Whitespace),  # end of member
            (r"/\*.+?\*/", Comment),
            include("values"),
        ],
        "comments": [
            (r"(//.*?$)", Comment.Single),
            (r"/\*", Comment.Multiline, "comment_multiline"),
        ],
        "comment_multiline": [
            (r"[^*/]", Comment.Multiline),
            (r"/\*", Comment.Multiline),
            (r"\*/", Comment.Multiline, "#pop"),
            (r"[*/]", Comment.Multiline),
        ],
        "operators": [
            (words(("in", "and", "or", "not"), suffix=r"\b"), Operator.Word),
            (
                words(
                    (
                        "=",
                        ";",
                        ":",
                        "?",
                        "!",
                        "!=",
                        "||",
                        "==",
                        "&&",
                        "<=",
                        "=>",
                        ">",
                        "<",
                        "+",
                        "+=",
                        "-",
                        "-=",
                        "/",
                        "/=",
                        "*",
                        "*=",
                        "%",
                        "%=",
                        "++",
                        "--",
                        "<-",
                        "&",
                        "^",
                        "|",
                        "~",
                        ">>",
                        "<<",
                        ">>>",
                        "!",
                    ),
                ),
                Operator,
            ),
        ],
        "declarations": [
            (words(_declarations, suffix=r"\b"), Keyword.Declaration),
        ],
        "constants": [
            (
                words(
                    (
                        "true",
                        "false",
                        "null",
                    ),
                    suffix=r"\b",
                ),
                Keyword.Constant,
            ),
        ],
        "keywords": [
            (
                words(
                    (
                        "break",
                        "case",
                        "catch",
                        "clone",
                        "continue",
                        "default",
                        "delegate",
                        "delete",
                        "else",
                        "extends",
                        "for",
                        "foreach",
                        "if",
                        "local",
                        "resume",
                        "return",
                        "switch",
                        "this",
                        "throw",
                        "try",
                        "typeof",
                        "while",
                        "parent",
                        "yield",
                        "vargc",
                        "vargv",
                        "instanceof",
                        "static",
                        "untyped",
                        "globalize_all_functions",
                        "wait",
                        "thread",
                        "unreachable",
                        "expect",
                        "waitthread",
                        "waitthreadsolo",
                        "delaythread",
                        "typedef",
                    ),
                    suffix=r"\b",
                ),
                Keyword,
            ),
            include("declarations"),
            include("constants"),
        ],
    }
