all: libmake compile

libmake:
	gcc printing.s -shared -o libprint.so

compile:
	gcc -L/home/lehalinuksoid/Python_rofli/Assembler+EmacsOrgFiles/linkedtest -g -nostdlib -o test linkedlist.s -lprint

