
enum Workspace_Event {
	PARSED, TYPE_CHECKED, IR, COMPILED
};

struct Workspace {
	String name;
	String main;
	Parser parser = {0};
	Checker checker = {0};

};