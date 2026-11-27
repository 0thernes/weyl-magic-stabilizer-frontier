# SPDX-License-Identifier: Apache-2.0
CC ?= gcc
NASM ?= nasm
CFLAGS_STRICT = -std=c11 -O3 -Wall -Wextra -Wpedantic -Werror -Wshadow -Wconversion
CFLAGS_SAN = -std=c11 -O1 -g -Wall -Wextra -Wpedantic -Werror -fsanitize=address,undefined -fno-omit-frame-pointer

.PHONY: all test test-nasm sanitize fuzz clean

all: build/weyl_verify_pure

build:
	mkdir -p build

build/weyl_verify_pure: src/weyl_verify.c | build
	$(CC) $(CFLAGS_STRICT) src/weyl_verify.c -o build/weyl_verify_pure

build/gf7_singer_kernel.o: ../asm/gf7_singer_kernel.asm | build
	$(NASM) -f elf64 ../asm/gf7_singer_kernel.asm -o build/gf7_singer_kernel.o

build/weyl_verify_nasm: src/weyl_verify.c build/gf7_singer_kernel.o | build
	$(CC) $(CFLAGS_STRICT) -DUSE_NASM_KERNEL src/weyl_verify.c build/gf7_singer_kernel.o -o build/weyl_verify_nasm

build/weyl_verify_san: src/weyl_verify.c | build
	$(CC) $(CFLAGS_SAN) src/weyl_verify.c -o build/weyl_verify_san

build/fuzz_singer: src/fuzz_singer.c | build
	$(CC) $(CFLAGS_STRICT) src/fuzz_singer.c -o build/fuzz_singer

test: build/weyl_verify_pure
	./build/weyl_verify_pure --fast

test-nasm: build/weyl_verify_nasm
	./build/weyl_verify_nasm

sanitize: build/weyl_verify_san
	./build/weyl_verify_san --fast

fuzz: build/fuzz_singer
	./build/fuzz_singer 100000

clean:
	rm -rf build
