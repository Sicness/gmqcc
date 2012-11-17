CC     ?= clang
CFLAGS += -Wall -I. -fomit-frame-pointer -fno-stack-protector -fno-common
#turn on tons of warnings if clang is present
ifeq ($(CC), clang)
	CFLAGS +=                  \
		-Weverything                  \
		-Wno-missing-prototypes       \
		-Wno-unused-parameter         \
		-Wno-sign-compare             \
		-Wno-implicit-fallthrough     \
		-Wno-sign-conversion          \
		-Wno-conversion               \
		-Wno-disabled-macro-expansion \
		-Wno-padded                   \
		-Wno-format-nonliteral

endif
ifeq ($(track), no)
    CFLAGS += -DNOTRACK
endif

OBJ     = \
          util.o      \
          code.o      \
          ast.o       \
          ir.o        \
          con.o
OBJ_C = main.o lexer.o parser.o
OBJ_X = exec-standalone.o util.o con.o

#default is compiler only
default: gmqcc
%.o: %.c
	$(CC) -c $< -o $@ $(CFLAGS)

exec-standalone.o: exec.c
	$(CC) -c $< -o $@ $(CFLAGS) -DQCVM_EXECUTOR=1

qcvm:     $(OBJ_X)
	$(CC) -o $@ $^ $(CFLAGS) -lm

# compiler target
gmqcc: $(OBJ_C) $(OBJ)
	$(CC) -o $@ $^ $(CFLAGS)

all: gmqcc qcvm

clean:
	rm -f *.o gmqcc qcvm
	
$(OBJ) $(OBJ_C) $(OBJ_X): gmqcc.h
main.o: lexer.h
parser.o: ast.h lexer.h
ast.o: ast.h ir.h
ir.o: ir.h
