
enum Workspace_Event {
	PARSED, TYPE_CHECKED, IR, COMPILED
};

enum Build_Mode {
	BM_BINARY, BM_LIBRARY, BM_SCRIPT_JIT, BM_COMPILE_JIT, BM_RUN_FILE
}

enum Backend {
	#ifdef HELM_ENABLE_LLVM
	Backend_LLVM
	#endif
};

const Backend _BACKEND_DEFAULT = 
	#ifdef HELM_ENABLE_LLVM
		Backend_LLVM;
	#else
		0;
	#endif

struct Workspace;
struct Parser;
struct Checker;
struct Timings;

typedef void (*Workspace_Event_Proc)(Workspace*, Workspace_Event);

struct Build_Constants {

	// Compiler info
	String HELM_OS;      // target operating system
	String HELM_ARCH;    // target architecture
	String HELM_ENDIAN;  // target endian
	String HELM_VENDOR;  // compiler vendor
	String HELM_VERSION; // compiler version
	String HELM_ROOT;    // Helm ROOT

	// In bytes
	i64    word_size; // Size of a pointer, must be >= 4
	i64    max_align; // max alignment, must be >= 1 (and typically >= word_size)
};

struct Binary_Build {
	bool generate_docs;
	i32  optimization_level;
	bool show_timings;
	bool keep_temp_files;

}

struct Library_Collection {
	String name;
	String path;
};

struct Workspace {
	String                       name;
	String                       main;
	Parser                       parser         = {0};
	Checker                      checker        = {0};
	Timings                      timings        = {0};
	Array<Workspace_Event_Proc>  event_handlers;
	Backend                      backend        = _BACKEND_DEFAULT;
	Build_Mode                   build_mode     = BM_BINARY;
	String                       output_file;
	Build_Constants              constants;
	Array<Library_Collection>    library_collections = {0};
	union {
		Binary_Build binary_settings;
		Binary_Build library_settings; // Essentially an alias.

	};
	gbAffinity affinity;
	isize      thread_count;
};

gb_global thread_local Workspace current_workspace = {0};

Workspace workspace_init(String name) {
	Workspace w;
	array_init(&w.event_handlers, heap_allocator());

	// TODO(zachary): @Leak - This string is never freed.
	String timings_name = concatenate_strings(heap_allocator(), str_lit("Total Time - "), name);

	timings_init(&w.timings, timings_name, 128);
	defer (timings_destroy(&w.timings));
	init_string_buffer_memory();
	init_scratch_memory(gb_megabytes(10));
	init_global_error_collector();

	array_init(&library_collections, heap_allocator());
	// NOTE(bill): `core` cannot be (re)defined by the user
	add_library_collection(str_lit("core"), get_fullpath_relative(heap_allocator(), helm_root_dir(), str_lit("core")));

	return w;
}

void workspace_compile() {

}

// Necessary so that Odin-level code can interface with the Array class.
void workspace_add_event_handler(Workspace *w, Workspace_Event_Proc wep) {
	w->event_handlers()
}

#ifdef HELM_ENABLE_LLVM
int llvm_build(Timings *timings, Checker *checker);
#endif

gb_inline void add_library_collection(String name, String path) {
	add_library_collection(current_workspace, name, path);
}

void add_library_collection(Workspace* workspace, String name, String path) {
	// TODO(bill): Check the path is valid and a directory
	Library_Collection lc = {name, string_trim_whitespace(path)};
	array_add(&workspace->library_collections, lc);
}

gb_inline bool find_library_collection_path(String name, String *path) {
	return find_library_collection_path(current_workspace, name, path);
}

bool find_library_collection_path(Workspace* workspace, String name, String *path) {
	for_array(i, workspace->library_collections) {
		if (workspace->library_collections[i].name == name) {
			if (path) *path = workspace->library_collections[i].path;
			return true;
		}
	}
	return false;
}


String const WIN32_SEPARATOR_STRING = {cast(u8 *)"\\", 1};
String const NIX_SEPARATOR_STRING   = {cast(u8 *)"/",  1};

#if defined(GB_SYSTEM_WINDOWS)
String helm_root_dir(void) {
	String path = global_module_path;
	Array<wchar_t> path_buf;
	isize len, i;
	gbTempArenaMemory tmp;
	wchar_t *text;

	if (global_module_path_set) {
		return global_module_path;
	}

	array_init_count(&path_buf, heap_allocator(), 300);

	len = 0;
	for (;;) {
		len = GetModuleFileNameW(nullptr, &path_buf[0], cast(int)path_buf.count);
		if (len == 0) {
			return make_string(nullptr, 0);
		}
		if (len < path_buf.count) {
			break;
		}
		array_resize(&path_buf, 2*path_buf.count + 300);
	}
	len += 1; // NOTE(bill): It needs an extra 1 for some reason

	gb_mutex_lock(&string_buffer_mutex);
	defer (gb_mutex_unlock(&string_buffer_mutex));

	tmp = gb_temp_arena_memory_begin(&string_buffer_arena);
	defer (gb_temp_arena_memory_end(tmp));

	text = gb_alloc_array(string_buffer_allocator, wchar_t, len+1);

	GetModuleFileNameW(nullptr, text, cast(int)len);
	path = string16_to_string(heap_allocator(), make_string16(text, len));

	for (i = path.len-1; i >= 0; i--) {
		u8 c = path[i];
		if (c == '/' || c == '\\') {
			break;
		}
		path.len--;
	}

	global_module_path = path;
	global_module_path_set = true;


	array_free(&path_buf);

	return path;
}

#elif defined(GB_SYSTEM_OSX)

#include <mach-o/dyld.h>

String helm_root_dir(void) {
	String path = global_module_path;
	Array<char> path_buf;
	isize len, i;
	gbTempArenaMemory tmp;
	u8 *text;

	if (global_module_path_set) {
		return global_module_path;
	}

	array_init_count(&path_buf, heap_allocator(), 300);

	len = 0;
	for (;;) {
		u32 sz = path_buf.count;
		int res = _NSGetExecutablePath(&path_buf[0], &sz);
		if(res == 0) {
			len = sz;
			break;
		} else {
			array_resize(&path_buf, sz + 1);
		}
	}

	gb_mutex_lock(&string_buffer_mutex);
	defer (gb_mutex_unlock(&string_buffer_mutex));

	tmp = gb_temp_arena_memory_begin(&string_buffer_arena);
	defer (gb_temp_arena_memory_end(tmp));

	text = gb_alloc_array(string_buffer_allocator, u8, len + 1);
	gb_memmove(text, &path_buf[0], len);

	path = make_string(text, len);
	for (i = path.len-1; i >= 0; i--) {
		u8 c = path[i];
		if (c == '/' || c == '\\') {
			break;
		}
		path.len--;
	}

	global_module_path = path;
	global_module_path_set = true;


	// array_free(&path_buf);

	return path;
}
#else

// NOTE: Linux / Unix is unfinished and not tested very well.
#include <sys/stat.h>
#include <string.h>

const char *linux_exe_path = "/proc/self/exe";

String helm_root_dir(void) {
	String path = global_module_path;
	Array<char> path_buf;
	Array<char> last_path_buf = {0};
	
	// Kind of a hack, but
	// because there's no "capacity" set here,
	// this data won't be freed, so it's safe.
	// Please don't kill me, C compiler! I'm sorry!
	last_path_buf.data = (char *)linux_exe_path;

	isize len, i;
	gbTempArenaMemory tmp;
	u8 *text;

	if (global_module_path_set) {
		return global_module_path;
	}

	defer (array_free(&path_buf));

	len = 0;

	struct stat path_stat;

	do {
		array_init_count(&path_buf, gb_heap_allocator(), 300);
		for (;;) {
			// This is not a 100% reliable system, but for the purposes
			// of this compiler, it should be _good enough_.
			// That said, there's no solid 100% method on Linux to get the program's
			// path without checking this link. Sorry.
			len = readlink(last_path_buf.data, &path_buf[0], path_buf.count);
			if(len == 0) {
				return make_string(nullptr, 0);
			}
			if (len < path_buf.count) {
				break;
			}
			array_resize(&path_buf, 2*path_buf.count + 300);
		}
		if (last_path_buf.capacity != 0) {
			array_free(&last_path_buf);
		}
		last_path_buf = path_buf;
		lstat(&path_buf[0], &path_stat);
	} while(S_ISLNK(path_stat.st_mode));
	
	if (last_path_buf.capacity != 0) array_free(&last_path_buf);

	gb_mutex_lock(&string_buffer_mutex);
	defer (gb_mutex_unlock(&string_buffer_mutex));

	tmp = gb_temp_arena_memory_begin(&string_buffer_arena);
	defer (gb_temp_arena_memory_end(tmp));

	text = gb_alloc_array(string_buffer_allocator, u8, len + 1);

	gb_memmove(text, &path_buf[0], len);

	path = make_string(text, len);
	for (i = path.len-1; i >= 0; i--) {
		u8 c = path[i];
		if (c == '/' || c == '\\') {
			break;
		}
		path.len--;
	}

	global_module_path = path;
	global_module_path_set = true;

	return path;
}
#endif


#if defined(GB_SYSTEM_WINDOWS)
String path_to_fullpath(gbAllocator a, String s) {
	String result = {};
	gb_mutex_lock(&string_buffer_mutex);
	defer (gb_mutex_unlock(&string_buffer_mutex));

	gbTempArenaMemory tmp = gb_temp_arena_memory_begin(&string_buffer_arena);
	String16 string16 = string_to_string16(string_buffer_allocator, s);

	DWORD len = GetFullPathNameW(&string16[0], 0, nullptr, nullptr);
	if (len != 0) {
		wchar_t *text = gb_alloc_array(string_buffer_allocator, wchar_t, len+1);
		GetFullPathNameW(&string16[0], len, text, nullptr);
		text[len] = 0;
		result = string16_to_string(a, make_string16(text, len));
	}
	gb_temp_arena_memory_end(tmp);
	return result;
}
#elif defined(GB_SYSTEM_OSX) || defined(GB_SYSTEM_UNIX)
String path_to_fullpath(gbAllocator a, String s) {
	char *p;
	gb_mutex_lock(&string_buffer_mutex);
	p = realpath(cast(char *)s.text, 0);
	gb_mutex_unlock(&string_buffer_mutex);
	if(p == nullptr) return make_string_c("");
	return make_string_c(p);
}
#else
#error Implement system
#endif


String get_fullpath_relative(gbAllocator a, String base_dir, String path) {
	u8 *str = gb_alloc_array(heap_allocator(), u8, base_dir.len+1+path.len+1);
	defer (gb_free(heap_allocator(), str));

	isize i = 0;
	gb_memmove(str+i, base_dir.text, base_dir.len); i += base_dir.len;
	gb_memmove(str+i, "/", 1);                      i += 1;
	gb_memmove(str+i, path.text,     path.len);     i += path.len;
	str[i] = 0;

	String res = make_string(str, i);
	res = string_trim_whitespace(res);
	return path_to_fullpath(a, res);
}


String get_fullpath_core(gbAllocator a, String path) {
	String module_dir = helm_root_dir();

	String core = str_lit("core/");

	isize str_len = module_dir.len + core.len + path.len;
	u8 *str = gb_alloc_array(heap_allocator(), u8, str_len+1);
	defer (gb_free(heap_allocator(), str));

	isize i = 0;
	gb_memmove(str+i, module_dir.text, module_dir.len); i += module_dir.len;
	gb_memmove(str+i, core.text, core.len);             i += core.len;
	gb_memmove(str+i, path.text, path.len);             i += path.len;
	str[i] = 0;

	String res = make_string(str, i);
	res = string_trim_whitespace(res);
	return path_to_fullpath(a, res);
}


String const HELM_VERSION = str_lit("0.6.2");

void init_build_context(void) {
	BuildContext *bc = &build_context;

	gb_affinity_init(&bc->affinity);
	if (bc->thread_count == 0) {
		bc->thread_count = gb_max(bc->affinity.thread_count, 1);
	}

	bc->HELM_VENDOR  = str_lit("helm");
	bc->HELM_VERSION = HELM_VERSION;
	bc->HELM_ROOT    = helm_root_dir();

#if defined(GB_SYSTEM_WINDOWS)
	bc->HELM_OS      = str_lit("windows");
#elif defined(GB_SYSTEM_OSX)
	bc->HELM_OS      = str_lit("osx");
#else
	bc->HELM_OS      = str_lit("linux");
#endif

#if defined(GB_ARCH_64_BIT)
	bc->HELM_ARCH = str_lit("amd64");
#else
	bc->HELM_ARCH = str_lit("x86");
#endif

	{
		u16 x = 1;
		bool big = !(*cast(u8 *)&x);
		bc->HELM_ENDIAN = big ? str_lit("big") : str_lit("little");
	}


	// NOTE(zangent): The linker flags to set the build architecture are different
	// across OSs. It doesn't make sense to allocate extra data on the heap
	// here, so I just #defined the linker flags to keep things concise.
	#if defined(GB_SYSTEM_WINDOWS)
		#define LINK_FLAG_X64 "/machine:x64"
		#define LINK_FLAG_X86 "/machine:x86"

	#elif defined(GB_SYSTEM_OSX)
		// NOTE(zangent): MacOS systems are x64 only, so ld doesn't have
		// an architecture option. All compilation done on MacOS must be x64.
		GB_ASSERT(bc->HELM_ARCH == "amd64");

		#define LINK_FLAG_X64 ""
		#define LINK_FLAG_X86 ""
	#else
		// Linux, but also BSDs and the like.
		// NOTE(zangent): When clang is swapped out with ld as the linker,
		//   the commented flags here should be used. Until then, we'll have
		//   to use alternative build flags made for clang.
		/*
			#define LINK_FLAG_X64 "-m elf_x86_64"
			#define LINK_FLAG_X86 "-m elf_i386"
		*/
		#define LINK_FLAG_X64 "-arch x86-64"
		#define LINK_FLAG_X86 "-arch x86"
	#endif


	if (bc->HELM_ARCH == "amd64") {
		bc->word_size = 8;
		bc->max_align = 16;

		bc->llc_flags = str_lit("-march=x86-64 ");
		bc->link_flags = str_lit(LINK_FLAG_X64 " ");
	} else if (bc->HELM_ARCH == "x86") {
		bc->word_size = 4;
		bc->max_align = 8;
		bc->llc_flags = str_lit("-march=x86 ");
		bc->link_flags = str_lit(LINK_FLAG_X86 " ");
	} else {
		gb_printf_err("This current architecture is not supported");
		gb_exit(1);
	}


	isize opt_max = 1023;
	char *opt_flags_string = gb_alloc_array(heap_allocator(), char, opt_max+1);
	isize opt_len = 0;
	bc->optimization_level = gb_clamp(bc->optimization_level, 0, 3);
	if (bc->optimization_level != 0) {
		opt_len = gb_snprintf(opt_flags_string, opt_max, "-O%d", bc->optimization_level);
	} else {
		opt_len = gb_snprintf(opt_flags_string, opt_max, "");
	}
	if (opt_len > 0) {
		opt_len--;
	}
	bc->opt_flags = make_string(cast(u8 *)opt_flags_string, opt_len);


	#undef LINK_FLAG_X64
	#undef LINK_FLAG_X86
}