// Until there's metaprogramming, I have to do this.

#define TOKEN_LIST \
	TOK(EOF,              "EOF")                               \
	/* Comments. Mostly ignored                                \
	unless metaprogramming scripts                             \
	touch them. */                                             \
	TOK(Comment,          "Comment")                           \
	/* Simple things like  names, etc. */                      \
	TOK(_LiteralBegin,    "")                                  \
	TOK(Identifier,       "Identifier")                        \
	/* Literal types */                                        \
	TOK(Integer,          "Integer")                           \
	TOK(Float,            "Float")                             \
	TOK(Char,             "Char")                              \
	TOK(String,           "String")                            \
	TOK(_LiteralEnd,      "")                                  \
	/* From here on out, the tokens should be                  \
	literal repreesentations of what they're                   \
	supposed to be. */                                         \
	TOK(_AbsoluteCapture,   "")                                \
	TOK(_OperatorBegin,   "")                                  \
	/* Assignment operators */                                 \
	TOK(_AssignOpBegin,   "")                                  \
	TOK(AddEq,            "+=")                                \
	TOK(SubEq,            "-=")                                \
	TOK(MulEq,            "*=")                                \
	TOK(DivEq,            "/=")                                \
	TOK(ModEq,            "%=") /* Is this even useful?  */    \
	TOK(AndEq,            "&=")                                \
	TOK(OrEq,             "|=")                                \
	TOK(XorEq,            "~=")                                \
	TOK(AndNotEq,         "&~=")                               \
	TOK(ShiftLeftEq,      "<<=")                               \
	TOK(ShiftRightEq,     ">>=")                               \
	TOK(Increment,        "++")                                \
	TOK(Decrement,        "--")                                \
	TOK(_AssignOpEnd,     "")                                  \
	/* These have to be here so that they're                   \
	over the Lt and Gt operators */                            \
	TOK(ShiftLeft,        "<<")                                \
	TOK(ShiftRight,       ">>")                                \
	/* Comparison operators */                                 \
	TOK(_ComparisonBegin,   "")                                \
	TOK(CmpAnd,           "&&")                                \
	TOK(CmpOr,            "||")                                \
	TOK(CmpEq,            "==")                                \
	TOK(CmpNotEq,         "!=")                                \
	TOK(CmpLtEq,          "<=")                                \
	TOK(CmpLt,            "<")                                 \
	TOK(CmpGtEq,          ">=")                                \
	TOK(CmpGt,            ">")                                 \
	TOK(_ComparisonEnd,   "")                                  \
	/* Other Operators */                                      \
	TOK(Eq,               "=")                                 \
	TOK(Not,              "!")                                 \
	TOK(Hash,             "#")                                 \
	TOK(Ampersand,        "@")                                 \
	TOK(Arrow,            "->")                                \
	TOK(AndNot,           "&~")                                \
	TOK(And,              "&")                                 \
	TOK(Or,               "|")                                 \
	TOK(Xor,              "~")                                 \
	TOK(Caret,            "^")                                 \
	TOK(Question,         "?")                                 \
	/* Arithmetic operators */                                 \
	TOK(_ArithmeticBegin,   "")                                \
	TOK(Sub,              "-")                                 \
	TOK(Add,              "+")                                 \
	TOK(Mul,              "*")                                 \
	TOK(Div,              "/")                                 \
	TOK(Mod,              "%")                                 \
	TOK(_ArithmeticEnd,   "")                                  \
	/* Simple symbols */                                       \
	TOK(OpenParen,        "(")                                 \
	TOK(CloseParen,       ")")                                 \
	TOK(OpenBracket,      "[")                                 \
	TOK(CloseBracket,     "]")                                 \
	TOK(OpenBrace,        "{")                                 \
	TOK(CloseBrace,       "}")                                 \
	TOK(Colon,            ":")                                 \
	TOK(Semicolon,        ";")                                 \
	TOK(Period,           ".")                                 \
	TOK(Comma,            ",")                                 \
	TOK(Ellipsis,         "...")                               \
	TOK(NewLine,          "\n")                                \
	TOK(_OperatorEnd,     "")                                  \
	/* Keywords */                                             \
	                                                           \
	/* A word of caution: Be careful to place                  \
	any variations on a token at the top.                      \
	For example, "foreach" comes before "for" */               \
	                                                           \
	TOK(_KeywordBegin,    "")                                  \
	TOK(Alias,            "alias")                             \
	TOK(When,             "when")                              \
	TOK(If,               "if")                                \
	TOK(Else,             "else")                              \
	TOK(For,              "for")                               \
	TOK(In,               "in")                                \
	TOK(Switch,           "switch")                            \
	TOK(Case,             "case")                              \
	TOK(Default,          "default")                           \
	TOK(Break,            "break")                             \
	TOK(Continue,         "continue")                          \
	TOK(Fallthrough,      "fallthrough")                       \
	TOK(Defer,            "defer")                             \
	TOK(Return,           "return")                            \
	TOK(Func,             "func")                              \
	TOK(Struct,           "struct")                            \
	TOK(Class,            "class")                             \
	TOK(Union,            "union")                             \
	TOK(Enum,             "enum")                              \
	TOK(Cast,             "cast")                              \
	TOK(Load,             "load")                              \
	TOK(Import,           "import")                            \
	TOK(Static,           "static")                            \
	TOK(_KeywordEnd,      "")                                  \
	TOK(Count,            "")                                  \

Token_Kind :: enum {
	Invalid
	#define TOK(a, b) ,a
	TOKEN_LIST
	#undef TOK
};

TOKEN_NAMES := []string{
	"Invalid"
	#define TOK(a, b) ,b
	TOKEN_LIST
	#undef TOK
};

/*
_alloc_token_names :: proc() -> []string {

	arr := make([]string, 1
		#define TOK(a, b) + 1
		TOKEN_LIST
		#undef TOK
	);

*/