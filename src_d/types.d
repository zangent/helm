module helm.types;
import std.stdint;

alias i8   = int8_t;
alias u8  = uint8_t;
alias i16  = int16_t;
alias u16 = uint16_t;
alias i32  = int32_t;
alias u32 = uint32_t;
alias i64  = int64_t;
alias u64 = uint64_t;

/// The reason that a compile failed.
/// Passed to `helm.logging.print_err`
enum CompileFailType {
	NO_FAIL, LEXER_FAIL, PARSER_FAIL, TYPE_CHECK_FAIL, EMIT_FAIL
}


/**
  * Represents a source file.
  * Used to pretty-print errors.
  */
class File {
	/// Source of the file, split by newlines.
	string[] lines;
	/// The path of the file.
	string path;
	///
	this(string[] lines, string path) {
		this.lines = lines;
		this.path = path;
	}
}