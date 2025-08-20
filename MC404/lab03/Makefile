proj.s: proj.c
	clang --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax proj.c -S -o proj.s

proj.o: proj.s
	clang --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax proj.s -c -o proj.o

proj.x: proj.o
	ld.lld proj.o -o proj.x