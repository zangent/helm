module helm.main;

import std.stdio;
import std.getopt;
import std.file;
import types = helm.types;
import std.string : strip;
import helm.lexer;
import helm.parser;
import to_json = helm.json;

private string out_file = "a";
/// A global error flag
shared types.CompileFailType fail_type = types.CompileFailType.NO_FAIL;

enum CompliationMode {
	tokens, ast, ast_graph, ir, bin
}

void main(string[] args) {

	CompliationMode compile_to = CompliationMode.bin;
	bool include_lines = false;

	auto help_info = getopt(args,
		"output|o", "Output path for the generated file", &out_file,
		"out-type|t", "What stage to output [tokens, ast, ast_graph, ir, bin (default)]", &compile_to,
		"include-lines|l", "Should JSON output formats include each file's contents (default false)", &include_lines
	);

	auto input_files = args[1..$];
	if(help_info.helpWanted || input_files.length == 0) {
		defaultGetoptPrinter("
The Helm compiler.
-----------------".strip(), help_info.options);
		return;
	}

	version(Windows) {
		if(out_file.length>4 && out_file[$-4..$] == ".exe") {
			out_file = out_file[0..$-4];
		}
	}

	foreach(string input; input_files) {
		if(!input.exists()) {
			writeln("Failed to find input file `" ~ input ~ "`.\nExiting.");
			return;
		}
	}
	TokenFile[] token_files;
	foreach(string input; input_files) {
		string contents;
		try {
			contents = input.readText();
		} catch(Exception e) {
			writeln("Failed to read input file `" ~ input ~ "`.\nExiting.");
			return;
		}
		token_files ~= tokenize_file(contents, input);
	}

	if(compile_to == CompliationMode.tokens) {
		import std.json;
		const(JSONValue) json = to_json.token_lists_to_json(token_files, include_lines);
		std.file.write(out_file~".tokens.json", json.toJSON(true));
	}
}
