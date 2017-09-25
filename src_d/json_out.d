module helm.json;

import std.json;
import std.path;
import std.file;
import helm.lexer;
import helm.types;
import std.conv : to;

private string localize(string original) {
	import std.array : array;
	return cast(string)original.asRelativePath(getcwd()).array;
}

alias JSONObj = JSONValue[string];

JSONValue init_file_with_lines(File f, bool include_lines) {

	JSONValue file = JSONValue((JSONValue[string]).init);
	if(include_lines) {
		JSONValue lines = JSONValue(f.lines);
		file.object["lines"] = lines;
	}
	return file;
}

JSONValue token_to_json(Token t) {
	
	JSONValue tv = JSONValue((JSONValue[string]).init);
	tv.object["kind"] = JSONValue(to!string(t.kind));
	tv.object["kind_id"] = JSONValue(cast(uint)t.kind);
	tv.object["text"] = JSONValue(t.text);
	JSONValue pos = JSONValue(["x": t.pos.line, "y": t.pos.column]);
	tv.object["pos"] = pos;
	return tv;
}

JSONValue token_lists_to_json(TokenFile[] tf, bool include_lines) {
	JSONValue json = JSONValue((JSONValue[string]).init);
	foreach(c; tf) {

		JSONValue file = init_file_with_lines(c.file, include_lines);
		JSONValue tokens = JSONValue((JSONValue[]).init);

		foreach(i, t; c.tokens) {
			tokens.array ~= token_to_json(t);
		}

		file.object["tokens"] = tokens;

		json.object[c.file.path.localize] = file;
	}
	return json;
}