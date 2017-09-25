module helm.lexer.lexer;

import helm.lexer.tokens;
import helm.types;
import logging = helm.logging;
import uni = std.uni;

private void lexer_err(Tokenizer* t, string msg) {
	logging.error_at(t.current_file, t.line, t.column, msg, CompileFailType.LEXER_FAIL);
}
private void lexer_wrn(Tokenizer* t, string msg) {
	logging.warn_at(t.current_file, t.line, t.column, msg);
}

class TokenFile {
	Token[] tokens;
	File file;
	this(Token[] _tokens, File _file) {
		tokens = _tokens;
		file = _file;
	}
}

/// Represents the position of a specific token.
class TokenPos {
	File file; /// The file a token came from.
	/// The position in the file the token came from.
	u32 line, column;

	///
	this(File file, u32 line, u32 column) {
		this.file = file;
		this.line = line;
		this.column = column;
	}

	string get_text_pos() {
		import std.conv : to;
		return "(" ~ to!string(line) ~ ", " ~ to!string(column) ~ ")";
	}
}

/// A lexed token of Helm source code.
struct Token {
	TokenKind kind; /// The type of token represented by the text.
	string text;    /// The text that `kind` represents.
	TokenPos pos;   /// The place that this token came from.
}

/// Stores the state of the lexer.
struct Tokenizer {
	/// The current position in the file.
	/// Tracked to provide location info for tokens.
	u32 line = 1, column = 1;
	/// The contents of the current file.
	string file_contents;
	/// The current file being lexed;
	File current_file;
	package char* file_start_pos;
	package char* cursor;
}

/// Print a token in a json-like format. Useful for debugging.
void print_tok(Token tok) {
	import std.stdio : writef;
	writef("{file: \"%s\", line: %d, col: %d, type: \"%s\", lit: \"%s\"},\n",
	       tok.pos.file.path, tok.pos.line, tok.pos.column, token_names[tok.kind], tok.text);
}

/// Lex a bit of Helm source code into an array of tokens.
TokenFile tokenize_file(string code, string path = "No path given.") {
	
	import std.string : toStringz, splitLines;
	
	Token[] tokens;
	
	Tokenizer* t = new Tokenizer;
	t.file_contents = code;
	t.file_start_pos = cast(char*)code.toStringz();
	t.cursor = t.file_start_pos;
	t.current_file = new File(code.splitLines(), path);

lexer_main_loop:
	while(*t.cursor != 0) {

		eat_whitespace(t);

		char c = *t.cursor;

		if(c=='\n') {

			Token token;
			token.kind = TokenKind.NewLine;
			token.pos = new TokenPos(t.current_file, t.line, t.column);
			token.text = "\n";

			tokens ~= token;

			t.line++;
			t.column = 1;
			t.cursor++;

			continue;
		}

		if(is_identifier_char(c, 1)) {


			Token token;
			token.kind = TokenKind.Identifier;
			token.pos = new TokenPos(t.current_file, t.line, t.column);

			string identifier_name = "";
			identifier_name ~= c;
			t.cursor++;
			t.column++;

			// Grabbing an identifier.
			while(*t.cursor != 0) {
				c = *t.cursor;
				if(is_identifier_char(c, 0)) {
					identifier_name ~= c;
					t.cursor++;
					t.column++;
				} else break;
			}

			token.text = identifier_name;

			for(int i = TokenKind._KeywordBegin; i < TokenKind._KeywordEnd; i++) {
				if(naive_strcmp(cast(char*)identifier_name.toStringz, cast(char*)token_names[i].toStringz)) {
					token.kind = cast(TokenKind)i;
				}
			}

			tokens ~= token;

			continue;
		}

		if(c == '/' && (*(t.cursor+1) == '*')) {
			tokens ~= eat_block_comment(t);
			continue;
		}

		if(c == '/' && *(t.cursor+1) == '/') {
			string comment;
			Token token;
			token.kind = TokenKind.Comment;
			t.cursor+=2;
			token.pos = new TokenPos(t.current_file, t.line, t.column);
			while(*t.cursor != 0 && *t.cursor != '\n') {
				comment ~= *t.cursor;
				t.cursor++;
			}
			token.text = comment;
			t.cursor++;
			t.column = 0;
			t.line++;
			tokens ~= token;
			continue;
		}


		if((c >= '0' && c <= '9') || (c == '.' && (*(t.cursor+1) >= '0' && *(t.cursor+1) <= '9'))) {

			// NOTE(zachary): We have a numeric literal.
			
			Token token;
			token.kind = TokenKind.Integer; // NOTE(zachary): We'll assume
										//   it's an int until proven otherwise.
			token.pos = new TokenPos(t.current_file, t.line, t.column);

			if(c=='.') token.kind = TokenKind.Float;

			string number_value = "";
			number_value ~= c;

			int i=0;

			const u8 MODE_B10 = 1;
			const u8 MODE_HEX = 2;
			const u8 MODE_BIN = 3;
			u8 mode = MODE_B10;

			while(*t.cursor != 0) {
				i++;
				t.cursor++;
				t.column++;
				c = *t.cursor;
				// TODO(zachary): Is this bulletproof?
				if(mode == MODE_B10) {
					if(c >= '0' && c <= '9') {

						number_value ~= c;
						continue;
					} else if(c == 'b') {
						if(i == 1) {
							if(*(t.cursor - 1) != '0') {
								lexer_err(t, "Can't start a binary literal that doesn't begin with 0 (E.g. 0bXX)");
							}
							mode = MODE_BIN;
							number_value ~= c;
							continue;
						} else {
							lexer_err(t, "Can't start a binary literal with non-0bXX syntax; the 'b' is in the wrong place!");
						}
					} else if(c == 'x' || c == 'X') {
						if(i == 1) {
							if(*(t.cursor - 1) != '0') {
								lexer_err(t, "Can't start a hexidecimal literal that doesn't begin with 0 (E.g. 0xFFFF)");
							}
							mode = MODE_HEX;
							number_value = "";
							continue;
						} else {
							lexer_err(t, "Can't start a binary literal with non-0xFFFF syntax; the 'x' is in the wrong place!");
						}
					}
				} else if(mode == MODE_HEX) {

					//lexer_err(t, "Hexidecimal literals are not implemented yet!\nSee " ~ __FILE__ ~ " L" ~ __LINE__);
					
					// Lowercase the character, to make things easier.
					//if(c >= 'A' && c <= 'Z') c -= 'A' - 'a';
					if((c >= 'A' && c <= 'F') || (c >= 'a' && c <= 'f') || (c >= '0' && c <= '9')) {
						number_value ~= c;
						continue;
					}

				} else if(mode == MODE_BIN) {
					lexer_err(t, "Binary literals are not implemented yet!\nSee " ~ __FILE__ ~ " L" ~ __LINE__ );
				}
				if(c == '.') {
					if(mode != MODE_B10) {
						lexer_err(t, "Can't put a decimal point in a " ~ (mode==MODE_HEX?"hexidecimal":"binary") ~ " literal");
					}
					token.kind = TokenKind.Float;
					number_value ~= c;
					continue;
				}
				break;
			}
			if(mode == MODE_B10) {
				token.text = number_value;
			} else if(mode == MODE_HEX) {
				import std.conv : to, parse;
				token.text = to!string(parse!long(number_value, 16));
			}

			tokens ~= token;

			continue;
		}

		if(c=='"') {

			tokens ~= eat_string(t);
			continue;

		}

		if(c=='\'') {

			Token token;
			token.kind = TokenKind.Char;
			token.pos = new TokenPos(t.current_file, t.line, t.column);

			t.cursor++;
			t.column++;
			c = eat_char(t);
			if(*(t.cursor+1)!='\'') {
				lexer_err(t, "Expected a single qoute to end a char literal");
			}
			t.cursor+=2;
			t.column+=2;
			// NOTE(zachary): We'll want chars to be bytes in the language,
			// so it's better to start storing them as numbers sooner
			// rather than later.
			import std.conv : to;
			token.text = to!string(to!short(c));
			tokens ~= token;
		}

		// NOTE(zachary): Now, we map the symbols.
		for(int i = TokenKind._AbsoluteCapture; i < TokenKind._KeywordBegin; i++) {
			if(naive_strcmp(t.cursor, cast(char*)token_names[i].toStringz, false)) {
				const ulong skip = token_names[i].length;
				Token token;
				token.kind = cast(TokenKind)i;
				token.text = code[(t.cursor - t.file_start_pos) .. (t.cursor - t.file_start_pos + skip)];
				token.pos = new TokenPos(t.current_file, t.line, t.column);
				tokens ~= token;
				t.cursor += skip;
				t.column += skip;
				// Using goto as a 'continue' that breaks out of both loops.
				goto lexer_main_loop;
			}
		}

		lexer_err(t, "Failed to parse the token!");
		t.cursor++;

	}

	Token EOF_token;
	EOF_token.kind = TokenKind.EOF;
	EOF_token.text = "";
	EOF_token.pos = new TokenPos(t.current_file, t.line, t.column);

	tokens ~= EOF_token;

	return new TokenFile(tokens, t.current_file);
}


private void eat_whitespace(Tokenizer* t) {
	while(1) {
		if(uni.isWhite(*t.cursor)) {
			t.column++;
			t.cursor++;
			continue;
		}
		return;
	}
}

private Token eat_block_comment(Tokenizer* t) {
	
	Token token;
	token.kind = TokenKind.Comment;
	token.pos = new TokenPos(t.current_file, t.line, t.column);
	const char* start = t.cursor;
	u8 depth = 0;
	while(1) {
		const char c = *t.cursor;
		if(c=='\n') {
			t.line ++;
			t.column = 1;
			t.cursor ++;
			continue;
		} else if(c=='/' && (*(t.cursor+1) == '*')) {
			depth ++;
			t.column ++;
			t.cursor ++;
		} else if(c=='*' && (*(t.cursor+1) == '/')) {
			depth --;
			t.column ++;
			t.cursor ++;
		}
		if(depth == 0) {
			break;
		} else {
			t.column ++;
			t.cursor ++;
		}
	}
	// TODO(zachary): Test this!

	// NOTE(Brendan): This crashes if there's a /* with no matching */ by the end of the file.
	// (This includes a situation where you have two /* and only one */ at the end of the file.)
	
	t.column ++;
	t.cursor ++;
	token.text = t.file_contents[(start - t.file_start_pos) .. (t.cursor - start)];
	return token;
}

private bool naive_strcmp(char* a, char* b, bool identifier = true) {
	if(*b==0) return false;
	for(;*b!=0;b++,a++) {
		if(*b!=*a) return false;
	}
	if(identifier) {
		return !is_identifier_char(*a, false);
	}
	return true;
}


private char eat_char(Tokenizer* t) {

	char c = *t.cursor;

	if(c=='\n') {
		t.line++;
		t.column = 0;
		return c;
	}

	string gen_escape_seq(string trigger, string response) {
		/* NOTE(zachary): I'm purposefully advancing twice,
			to account for the backslash _and_ the 'n' */
		return `if(c=='\\' && *(t.cursor+1) == '`~trigger~`') {
			t.column++;
			t.cursor++;
			return '`~response~`';
		}`;
	}


	// NOTE(zachary): Here's some instructions for implementing escape sequences.
	//   http://en.cppreference.com/w/cpp/language/escape

	mixin(gen_escape_seq(`n`, `\n`));
	mixin(gen_escape_seq(`r`, `\r`));
	mixin(gen_escape_seq(`\\`, `\\`));
	mixin(gen_escape_seq(`\'`, `\'`));
	mixin(gen_escape_seq(`\"`, `\"`));
	mixin(gen_escape_seq(`?`, `?`));
	mixin(gen_escape_seq(`a`, `\a`));
	mixin(gen_escape_seq(`f`, `\f`));
	mixin(gen_escape_seq(`t`, `\t`));
	mixin(gen_escape_seq(`v`, `\v`));

	// TODO(zachary): Add more escape sequences.
	//   I'm only doing octal for now because that's
	//   what the majority of escape codes I encounter are.

	// Octal Sequence
	if(c=='\\' && (*(t.cursor+1) >= '0' && *(t.cursor+1) <= '7')) {
		// TODO(zachary): There has to be a better way to do this!
		string num;
		num ~= *(t.cursor+1);
		t.column++;
		t.cursor++;
		if(*(t.cursor+1) >= '0' && *(t.cursor+1) <= '7') {
			num ~= *(t.cursor+1);
			t.column++;
			t.cursor++;
			if(*(t.cursor+1) >= '0' && *(t.cursor+1) <= '7') {
				num ~= *(t.cursor+1);
				t.column++;
				t.cursor++;
			}
		}
		import std.conv : parse;
		return cast(char)parse!short(num, 8);
	}

	if(c=='\\') {
		lexer_wrn(t, "Unrecognized escape code");
	}

	return c;
}

private Token eat_string(Tokenizer* t) {

	// TODO(zachary): Make sure parsing escaped characters is a good idea!
	// NOTE(zachary): The strings in this language are multi-line strings.
	string contents;

	Token token;
	token.kind = TokenKind.String;
	token.pos = new TokenPos(t.current_file, t.line, t.column);

	while(*t.cursor != 0) {
		t.cursor++;
		t.column++;

		if(*t.cursor=='"') {

			t.column++;
			t.cursor++;
			break;
		}

		contents ~= eat_char(t);
	}

	token.text = contents;

	return token;
}

/// `first` determines whether numbers are allowed.
private bool is_identifier_char(char test, bool first) {
	return ((test >= 'a' && test <= 'z') || (test >= 'A' && test <= 'Z') ||
		   (test == '_') || (first && (test <= '0' && test >= '9')) || !first) &&
		   !(uni.isWhite(test) || test == '\'' || test == '\"' || test == '%' ||
			 test == '^' || test == '&' || test == '*' || test == '(' || test == ')' ||
			 test == '[' || test == ']' || test == ',' || test == '.' || test == '/' ||
			 test == '<' || test == '>' || test == '?' || test == '+' || test == '`' ||
			 test == ':' || test == ';' || test == '\n' || test == '-');
}