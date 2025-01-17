section .data
    SYS_OPEN  equ 2
    SYS_READ  equ 0
    SYS_WRITE equ 1
    SYS_CLOSE equ 3
    SYS_EXIT  equ 60

    target_str db "1337", 0xA
    patch_str db "H4CK", 0xA
    target_len equ $ - target_str
    patch_len equ $ - patch_str

    usage db 'Usage: ./asm16 <filename>', 0xa
    usage_len equ $ - usage

section .bss
    fd resb 8
    buffer resb 1024

section .text
global _start

_start:
    mov rcx, [rsp]
    cmp rcx, 2
    jl .error

    mov rsi, [rsp + 16]

    mov rdi, rsi
    mov rsi, 2
    mov rdx, 0
    mov rax, SYS_OPEN
    syscall

    cmp rax, 0
    jl .file_error

    mov [fd], rax

    mov rdi, [fd]
    mov rsi, buffer
    mov rdx, 1024
    mov rax, SYS_READ
    syscall

    mov rdi, [fd]
    mov rax, SYS_CLOSE
    syscall

    mov rcx, rax
    lea rdi, [buffer]
    lea rsi, [target_str]
    mov rdx, target_len

.search_loop:
    cmp rcx, rdx
    jl .not_found

    push rdi
    push rsi
    push rcx
    repe cmpsb
    pop rcx
    pop rsi
    pop rdi
    je .patch

    inc rdi
    dec rcx
    jmp .search_loop

.patch:
    lea rsi, [patch_str]
    mov rcx, patch_len
    rep movsb

    mov rdi, [rsp + 16]
    mov rsi, 0x241
    mov rdx, 0644o
    mov rax, SYS_OPEN
    syscall

    cmp rax, 0
    jl .file_error

    mov [fd], rax

    mov rdi, [fd]
    mov rsi, buffer
    mov rdx, 1024
    mov rax, SYS_WRITE
    syscall

    mov rdi, [fd]
    mov rax, SYS_CLOSE
    syscall

    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall

.not_found:
    mov rax, SYS_EXIT
    mov rdi, 1
    syscall

.file_error:
    mov rax, SYS_EXIT
    mov rdi, 1
    syscall

.error:
    mov rdx, usage_len
    mov rsi, usage
    mov rdi, 2
    mov rax, SYS_WRITE
    syscall

    mov rax, SYS_EXIT
    mov rdi, 1
    syscall
