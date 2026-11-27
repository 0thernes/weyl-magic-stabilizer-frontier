; SPDX-License-Identifier: Apache-2.0
; Copyright (c) 2026 Alexander Stephen Donahue
;
; Dual-ABI (Windows x64 + System V AMD64) NASM x86-64 bare-metal GF(p) inner kernel
; for Singer projective-geometry stabilizer code elimination (`Q(5,2)`, `Q(7,2)`, `Q(11,2)`).
;
; Exports:
;   void gf_sub_mul_asm(uint8_t *dst, const uint8_t *src, size_t len, uint8_t factor, uint8_t p)
;     Computes: for i in 0..len: dst[i] = (dst[i] + p - (factor * src[i]) % p) % p
;   uint32_t gf_dot_mod_asm(const uint8_t *a, const uint8_t *b, size_t len, uint8_t p)
;     Computes: (sum_{i=0}^{len-1} a[i] * b[i]) % p
;
; Assemble:
;   Windows x64: nasm -f win64 -DWIN64 asm/gf7_singer_kernel.asm -o build/gf7_singer_kernel.obj
;   Linux ELF64: nasm -f elf64 asm/gf7_singer_kernel.asm -o build/gf7_singer_kernel.o

default rel
section .text

global gf_sub_mul_asm
global gf_dot_mod_asm

; ---------------------------------------------------------------------------
; void gf_sub_mul_asm(uint8_t *dst, const uint8_t *src, size_t len, uint8_t factor, uint8_t p)
;   WIN64: rcx=dst, rdx=src, r8=len, r9b=factor, [rsp+40]=p
;   SYSV:  rdi=dst, rsi=src, rdx=len, cl=factor, r8b=p
; ---------------------------------------------------------------------------
gf_sub_mul_asm:
    push rbx
    push r12
    push r13
    push r14
    push r15

%ifdef WIN64
    mov r10, rcx            ; dst
    mov r11, rdx            ; src
    mov r12, r8             ; len
    movzx r13d, r9b         ; factor
    ; 5 pushes = 40 bytes + 8 return addr + 32 shadow space = offset 80!
    movzx r14d, byte [rsp + 80] ; p
%else
    mov r10, rdi            ; dst
    mov r11, rsi            ; src
    mov r12, rdx            ; len
    movzx r13d, cl          ; factor
    movzx r14d, r8b         ; p
%endif

    test r12, r12
    jz .sub_done
    test r13d, r13d
    jz .sub_done
    cmp r14d, 2
    jb .sub_done

    xor r15, r15            ; i = 0
.sub_loop:
    movzx eax, byte [r11 + r15] ; src[i]
    imul eax, r13d          ; eax = factor * src[i]
    xor edx, edx
    div r14d                ; edx = (factor * src[i]) % p
    movzx eax, byte [r10 + r15] ; dst[i]
    add eax, r14d           ; dst[i] + p
    sub eax, edx            ; dst[i] + p - rem
    cmp eax, r14d
    jb .sub_store
    sub eax, r14d
.sub_store:
    mov byte [r10 + r15], al
    inc r15
    cmp r15, r12
    jb .sub_loop

.sub_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

; ---------------------------------------------------------------------------
; uint32_t gf_dot_mod_asm(const uint8_t *a, const uint8_t *b, size_t len, uint8_t p)
;   WIN64: rcx=a, rdx=b, r8=len, r9b=p
;   SYSV:  rdi=a, rsi=b, rdx=len, cl=p
; ---------------------------------------------------------------------------
gf_dot_mod_asm:
    push r12
    push r13
    push r14

%ifdef WIN64
    mov r10, rcx            ; a
    mov r11, rdx            ; b
    mov r12, r8             ; len
    movzx r13d, r9b         ; p
%else
    mov r10, rdi            ; a
    mov r11, rsi            ; b
    mov r12, rdx            ; len
    movzx r13d, cl          ; p
%endif

    xor eax, eax            ; acc = 0
    xor r14, r14            ; i = 0
    test r12, r12
    jz .dot_done
    cmp r13d, 2
    jb .dot_done

.dot_loop:
    movzx ecx, byte [r10 + r14]
    movzx edx, byte [r11 + r14]
    imul ecx, edx
    add eax, ecx
    inc r14
    cmp r14, r12
    jb .dot_loop

    xor edx, edx
    div r13d                ; edx = acc % p
    mov eax, edx

.dot_done:
    pop r14
    pop r13
    pop r12
    ret
