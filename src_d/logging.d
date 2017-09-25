module helm.logging;

import helm.main;
import helm.types;
import std.stdio : write, writeln, writef;

/// The function to be called when the compiler needs to print an error.
/// The host process can change this, otherwise Helm will use its own pretty-printing logging.
void function(File file, u32 line, u32 col, string msg, CompileFailType ft) print_err = &default_error_at;
/// The function to be called when the compiler needs to print a warning.
/// The host process can change this, otherwise Helm will use its own pretty-printing logging.
void function(File file, u32 line, u32 col, string msg) print_warn = &default_warn_at;

alias warn_at = print_warn;
alias error_at = print_err;

package u8 digits(int n) {
	return ((n<10?1:n<100?2:n<1000?3:4) + 1);
}

package void line_num(int line, bool last_line) {
	//writef("\033[100m%*d \033[m ", digits(last_line?line:(line+1)), line);
	writef("\033[100m%*d \033[m ", digits(line), line);
}
package __gshared {
	const string ANSI_RED = "\033[1;31m";
	const string ANSI_ORN = "\033[1;33m";
	const string ANSI_CLR = "\033[m";
}

package void show_context(File file, u32 line, u32 col) {
	if(line > 1) {
		line_num(line-1, false);
		write(file.lines[line-2], "\n");
	}
	line_num(line, true);
	write(file.lines[line-1], "\n");
	writef(ANSI_ORN ~ "%*c\n" ~ ANSI_CLR, digits(line)+2+col, '^');
}
void default_error_at(File file, u32 line, u32 col, string msg, CompileFailType ft) {
	write("\033[1m", file.path, ":", line, ":", col, ": ");
	write(ANSI_RED ~ "error: " ~ ANSI_CLR);
	write(msg, "\033[21m\n");
	show_context(file, line, col);
	fail_type = ft;
}
void default_warn_at(File file, u32 line, u32 col, string msg) {
	write("\033[1m", file.path, ":", line, ":", col, ": ");
	write(ANSI_ORN ~ "warning: " ~ ANSI_CLR);
	write(msg, "\033[21m\n");
	show_context(file, line, col);
}