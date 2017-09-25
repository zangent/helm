module helm.parser.parser;

import helm.parser.ast;
import helm.lexer;
import helm.types;
import logging = helm.logging;

private void lexer_err(Token t, string msg) {
	logging.error_at(t.pos.file, t.pos.line, t.pos.column, msg, CompileFailType.PARSER_FAIL);
}
private void lexer_wrn(Token t, string msg) {
	logging.warn_at(t.pos.file, t.pos.line, t.pos.column, msg);
}

struct Parser {
	File file;
}