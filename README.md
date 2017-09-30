<img src="misc/logo.png" alt="Helm logo" height="74">

# The Helm Programming Language

Helm is an opinionated programming language made to emphasize a couple of core ideas
	* Metaprogramming is invaluable to large projects
	* Code should be simple to read and self-documenting
	* It *shouldn't* be hard to write fast and legible code
	* Modern template-based, feature-abusing programming is a mess
	* The language should trust the programmer to use features well, but that trust shouldn't be abused.

Website: [https://helmlang.org/](https://helmlang.org/)

#### Odin

Helm's compiler is a fork of [the Odin programming language.](https://github.com/gingerBill/Odin/). This language would *not* be where it is without GingerBill's work he put into Odin. If you feel like this language is too bloated, or if you just feel like it's not gone in a direction you like, I implore you to check out Odin.

## Requirements to build and run

- Windows
	* x86-64
	* MSVC installed (C++11 support)
	* [LLVM binaries](https://github.com/gingerBill/Odin/releases/tag/llvm-4.0-windows) for `opt.exe` and `llc.exe`
	* Requires MSVC's link.exe as the linker
		* run `vcvarsall.bat` (or `misc/shell.bat` for VS2017) to put the `link` binary in your path

- MacOS
	* x86-64
	* LLVM explicitly installed (`brew install llvm`)
	* XCode installed (for the linker)

- GNU/Linux
	* x86-64
	* Build tools (ld)
	* LLVM installed
	* Clang installed (temporary - this is Calling the linker for now)

## Warnings

* _Very_ in development!