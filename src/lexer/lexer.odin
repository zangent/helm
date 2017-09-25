import "zext:str.odin";
export "types.odin";
import "../state.odin";

lex_file :: proc(code: string, path: string = "No path given.") -> ^Token_File #no_bounds_check {
	tokens: [dynamic]Token;

	t := new(Tokenizer);
	defer free(t);
	t.file_contents = code;
	t.file_len = len(code);

	t.current_file = state.File{str.split(code, "\n"), path};

	for t.cursor < t.file_len {
		t.cursor+=1;
	}
}

lex_string :: proc(code: string, origin: string) #inline {
	return lex_file(code, str.cat("generated-code-", origin));
}