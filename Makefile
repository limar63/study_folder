all:
	as --64 hello-ass.s -o hello-ass.o
	ld -melf_x86_64 -s hello-ass.o -o hello-ass
