import "zext:str.odin";
export "types.odin";
import "../state.odin";

lex_file :: proc(code: string, path: string = "No path given.") -> ^Token_File #no_bounds_check {
	tokens: [dynamic]Token;

	t := new(Tokenizer);
	defer free(t);
	t.file_contents = code;
	t.file_len = cast(size_t)len(code);

	t.current_file = state.File{path, str.split(code, "\n")};

	for t.cursor < t.file_len {
		t.cursor+=1;
	}

	return nil;
}

lex_string :: proc(code: string, origin: string) -> ^Token_File #inline {
	return lex_file(code, str.cat("generated-code-", origin));
}