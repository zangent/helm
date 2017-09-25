import "zext:fs.odin";
import "zext:str.odin";
import "state.odin";
import "core:fmt.odin";
import "core:os.odin";
import "lexer/lexer.odin";

VERSION :: "0.1";

_show_version :: proc() {
	fmt.print("Helm v");
	fmt.println(VERSION);
	fmt.println("Copyright (c) 2017 Zachary Pierson, Brendan Pierson, and contributors.");
}

_show_help :: proc() {
	_show_version();
	fmt.println(`
Documentation: http://helmlang.org
Usage:
    helm [<options>] <file>

<options>
    --out | -o path              Set output file path.
    --mode [release/dev/debug]   Specify build constant. Def. dev. See docs for info.
    --build [token_json/ast_json/ast_graph/ir/obj/bin/docs]
                                 Set the final output file type.
    --threads                    Set the number of parser threads used.
    --bounds-check [on/off]      Enable bounds check *by default*.
    --nil-checks [on/off]        Enable nil check *by default*.
    --minimal | -m               Make use of less high-level abstractions. See docs for info.
    --force-debug | -g           Force output of debug symbols.
    --help | -h                  Print help and exit.
    --version | -v               Print compiler version and exit.
    --opt | -O                   Set optimization level.
    --collection | -c name path  Add collection by name 'name' from 'path'.
    --shared | --dll             Generate shared library/dll.
`);
}

_add_collection :: proc(bc: ^state.Build_Context, c: state.Collection) -> bool {
	for _c in bc.collections do if _c.name == c.name {
		fmt.printf_err("Can't redefine collection '%s'.\n", c.name);
		return false;
	}
	append(&bc.collections, c);
	return true;
}

main :: proc() {

	//a := make([]u8, 45); // Runs fine.


	if len(os.args) < 2 {
		//_show_help();
		return;
	}


	//fmt.println("")

	//b := make([]u8, 45); // Segfaults

	out_file := "a";
	//bc : state.Build_Context;
	json_out_include_contents := false;

	args := os.args[1..];
	args_len := len(args);

	{

		binary_path, ok := fs.get_binary_path();
		if !ok {
			fmt.println_err("Couldn't find the path of the current executable.");
			fmt.println_err("Exiting!");
			return;
		}

		stdlib_path := fs.to_absolute(fs.parent_name(binary_path), "stdlib");

		//_add_collection(&bc, state.Collection{"std", stdlib_path});
	}

	src_path := "";

	for i:=0; i < len(args); i += 1 {
		ca := args[i];
		if ca == "--out" || ca == "-o" {
			if args_len <= i + 1 {
				fmt.println_err(ca, "requires one argument.");
				return;
			}
			out_file = args[i+1];
			i+=1;
		} else if ca == "--mode" {
			if args_len <= i + 1 {
				fmt.println_err(ca, "requires one argument.");
				return;
			}
			ca = args[i+1];
			match ca {
				//case release:
			}
		} else {
			if len(src_path) > 0 {
				fmt.println_err("Malformed command!");
			}
			src_path = ca;
		}
	}
}