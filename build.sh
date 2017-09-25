#!/bin/bash

mkdir build 2>/dev/null

# Temporary evil!
(gcc -E -traditional-cpp - < src/lexer/tokens.pp.odin 2> /dev/null) | grep -v '^# [0-9]' > src/lexer/tokens.odin
(gcc -E -traditional-cpp - < src/parser/ast.pp.odin 2> /dev/null) | grep -v '^# [0-9]' > src/parser/ast.odin

../Odin/odin build src/main.odin -collection=zext=../zext/lib

#rm src/lexer/tokens.odin src/parser/ast.odin

if [ "$(expr substr $(uname -s) 1 5)" == "MINGW" ]; then
	mv src/main.exe build/main.exe
else
	mv src/main build/main
fi