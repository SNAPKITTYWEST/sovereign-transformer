# Build the plasma gate x86-64 object + shared lib
# Requirements: nasm, gcc

ASM   = plasma_gate.asm
OBJ   = plasma_gate.o
LIB   = libplasma_gate.so

all: $(LIB)

$(OBJ): $(ASM)
	nasm -f elf64 -o $(OBJ) $(ASM)

$(LIB): $(OBJ)
	gcc -shared -o $(LIB) $(OBJ)

test: $(LIB)
	gcc -o plasma_test plasma_test.c -L. -lplasma_gate -Wl,-rpath,.
	./plasma_test

clean:
	rm -f $(OBJ) $(LIB) plasma_test
