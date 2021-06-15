#define NSYMS 100

struct symtab {
	char *name;
	int type;
} symtab[NSYMS];

struct symtab *symlook();

