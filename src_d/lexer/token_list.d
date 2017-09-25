module helm.lexer.tokens;

private struct _TokenType {
	string name, value;
}

mixin(({
	auto types = [
		new _TokenType("EOF",            "EOF"),
		/* Comments. Mostly ignored,
		unless metaprogramming scripts
		touch them. */
		new _TokenType("Comment",        "Comment"),
		/* Simple things like  names, etc. */
		new _TokenType("_LiteralBegin",  ""),
		new _TokenType("Identifier",     "Identifier"),
		/* Literal types */
		new _TokenType("Integer",        "Integer"),
		new _TokenType("Float",          "Float"),
		new _TokenType("Char",           "Char"),
		new _TokenType("String",         "String"),
		new _TokenType("_LiteralEnd",    ""),
		/* From here on out, the tokens should be
		literal repreesentations of what they're
		supposed to be. */
		new _TokenType("_AbsoluteCapture", ""),
		new _TokenType("_OperatorBegin", ""),
		/* Assignment operators */
		new _TokenType("_AssignOpBegin", ""),
		new _TokenType("AddEq",          "+="),
		new _TokenType("SubEq",          "-="),
		new _TokenType("MulEq",          "*="),
		new _TokenType("DivEq",          "/="),
		new _TokenType("ModEq",          "%="),/* Is this even useful?  */
		new _TokenType("AndEq",          "&="),
		new _TokenType("OrEq",           "|="),
		new _TokenType("XorEq",          "~="),
		new _TokenType("AndNotEq",       "&~="),
		new _TokenType("ShiftLeftEq",    "<<="),
		new _TokenType("ShiftRightEq",   ">>="),
		new _TokenType("Increment",      "++"),
		new _TokenType("Decrement",      "--"),
		new _TokenType("_AssignOpEnd",   ""),
		/* These have to be here so that they're
		over the Lt and Gt operators */
		new _TokenType("ShiftLeft",      "<<"),
		new _TokenType("ShiftRight",     ">>"),
		/* Comparison operators */
		new _TokenType("_ComparisonBegin", ""),
		new _TokenType("CmpAnd",         "&&"),
		new _TokenType("CmpOr",          "||"),
		new _TokenType("CmpEq",          "=="),
		new _TokenType("CmpNotEq",       "!="),
		new _TokenType("CmpLtEq",        "<="),
		new _TokenType("CmpLt",          "<"),
		new _TokenType("CmpGtEq",        ">="),
		new _TokenType("CmpGt",          ">"),
		new _TokenType("_ComparisonEnd", ""),
		/* Other Operators */
		new _TokenType("Eq",             "="),
		new _TokenType("Not",            "!"),
		new _TokenType("Hash",           "#"),
		new _TokenType("Ampersand",      "@"),
		new _TokenType("Arrow",          "->"),
		new _TokenType("AndNot",         "&~"),
		new _TokenType("And",            "&"),
		new _TokenType("Or",             "|"),
		new _TokenType("Xor",            "~"),
		new _TokenType("Caret",          "^"),
		new _TokenType("Question",       "?"),
		/* Arithmetic operators */
		new _TokenType("_ArithmeticBegin", ""),
		new _TokenType("Sub",            "-"),
		new _TokenType("Add",            "+"),
		new _TokenType("Mul",            "*"),
		new _TokenType("Div",            "/"),
		new _TokenType("Mod",            "%"),
		new _TokenType("_ArithmeticEnd", ""),
		/* Simple symbols */
		new _TokenType("OpenParen",      "("),
		new _TokenType("CloseParen",     ")"),
		new _TokenType("OpenBracket",    "["),
		new _TokenType("CloseBracket",   "]"),
		new _TokenType("OpenBrace",      "{"),
		new _TokenType("CloseBrace",     "}"),
		new _TokenType("Colon",          ":"),
		new _TokenType("Semicolon",      ";"),
		new _TokenType("Period",         "."),
		new _TokenType("Comma",          ","),
		new _TokenType("Ellipsis",       "..."),
		new _TokenType("NewLine",        "\n"),
		new _TokenType("_OperatorEnd",   ""),
		/* Keywords */

		/* A word of caution: Be careful to place
		any variations on a token at the top.
		For example, "foreach" comes before "for" */

		new _TokenType("_KeywordBegin",  ""),
		new _TokenType("Alias",          "alias"),
		new _TokenType("When",           "when"),
		new _TokenType("If",             "if"),
		new _TokenType("Else",           "else"),
		new _TokenType("For",            "for"),
		new _TokenType("In",             "in"),
		new _TokenType("Switch",         "switch"),
		new _TokenType("Case",           "case"),
		new _TokenType("Default",        "default"),
		new _TokenType("Break",          "break"),
		new _TokenType("Continue",       "continue"),
		new _TokenType("Fallthrough",    "fallthrough"),
		new _TokenType("Defer",          "defer"),
		new _TokenType("Return",         "return"),
		new _TokenType("Func",           "func"),
		new _TokenType("Struct",         "struct"),
		new _TokenType("Class",          "class"),
		new _TokenType("Union",          "union"),
		new _TokenType("Enum",           "enum"),
		new _TokenType("Cast",           "cast"),
		new _TokenType("Load",           "load"),
		new _TokenType("Import",         "import"),
		new _TokenType("Static",         "static"),
		new _TokenType("_KeywordEnd",    ""),
		new _TokenType("Count",          "")
	];
	string enum_str = "enum TokenKind {\n";
	string names_str = "const string[] token_names = [";
	foreach(_TokenType* tt; types) {
		enum_str ~= tt.name ~ ", ";
		names_str ~= '`' ~ tt.value ~ "`,";
	}
	enum_str ~= "}";
	names_str ~= "];";
	return enum_str ~ names_str;
})());