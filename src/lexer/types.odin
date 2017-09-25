using import "zext:TEMP.odin";
import "../state.odin";
export "tokens.odin";


Token_File :: struct {
	tokens: [dynamic]Token,
	file: ^state.File,
};

Token_Pos :: struct {
	file: ^state.File,
	line, column: u32,
};

Token :: struct {
	kind: Token_Kind,
	text: string,
	pos: Token_Pos,
}

Tokenizer :: struct {
	line, column: u32,
	file_contents: string,
	file_len: size_t,
	current_file: state.File,
	cursor: size_t,
}

import "core:fmt.odin";
print_tok :: proc(t: Token) #inline {
	fmt.printf("{file: \"%s\", line: %d, col: %d, type: \"%s\", lit: \"%s\"},\n",
	           t.pos.file.path, t.pos.line, t.pos.column, TOKEN_NAMES[t.kind], t.text);
}