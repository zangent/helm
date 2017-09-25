
Output_Mode :: enum {
	tokens_json, ast_json, ast_graph, ir, obj, bin, docs
}

Build_Type :: enum {
	release, dev, debug
}

File :: struct {
	path: string,
	source_lines: [dynamic]string,
}

Build_Context :: struct {

	os,               // Target OS           E.g. ("macos", "linux", "windows", "android")
	os_family,        // OS Vendor/family    E.g. ("apple", "microsoft", "bsd", "linux")
	arch,             // Target architecture E.g. ("x86", "amd64", "arm", "arm64")
	endian,           // Target endianness   E.g. ("little", "big")
	vendor,           // Compiler vendor     E.g. ("sidethink")
	version: string,  // Compiler version    E.g. ("0.1") NOTE: This is a string

	ptr_size: i64,    // Size of a pointer on the target system, in bytes.
	max_align: i64,   // Max alignment. Must be >=1 (and typically >= ptr_size)

	is_lib: bool = false,
	minimal_abst: bool = false,
	output_mode: Output_Mode = Output_Mode.bin,
	opt_level: i8 = 0,
	keep_temp_files: bool = false,
	build_type: Build_Type = Build_Type.dev,
	bounds_checks: bool = true,
	nil_checks: bool = false,

	thread_count: i32 = 1,

	collections: []Collection,
}

Collection :: struct {
	name, path: string
}