
enum Workspace_Event {
	PARSED, TYPE_CHECKED, IR, COMPILED
};

struct Workspace;

typedef void (*Workspace_Event_Proc)(Workspace*);

struct Workspace {
	String name;
	String main;
	Parser parser = {0};
	Checker checker = {0};
	Array<Workspace_Event_Proc> event_handlers;
};

Workspace workspace_create() {
	Workspace w;
	array_init(&w.event_handlers, heap_allocator());
	return w;
}

void workspace_compile() {

}

// Necessary so that Odin-level code can interface with the Array class.
void workspace_add_event_handler(Workspace *w, Workspace_Event_Proc wep) {
	w->event_handlers()
}