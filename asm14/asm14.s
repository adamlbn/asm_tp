section .data
    SYS_OPEN  equ 2
    SYS_WRITE equ 1
    SYS_CLOSE equ 3
    SYS_EXIT  equ 60

    msg db 'Hello Universe!', 0xa
    len equ $ - msg

    usage db 'Usage: ./asm14 <filename>', 0xa
    usage_len equ $ - usage

    fd dq 0

section .bss
    buffer resb 256

section .text
global _start

_start:
    mov rcx, [rsp]
    cmp rcx, 2
    jl .error

    mov rsi, [rsp + 16]

    mov rdi, rsi
    mov rsi, 0102o
    mov rdx, 0666o
    mov rax, SYS_OPEN
    syscall

    cmp rax, 0
    jl .exit

    mov [fd], rax

    mov rdx, len
    mov rsi, msg
    mov rdi, [fd]
    mov rax, SYS_WRITE
    syscall

    mov rdi, [fd]
    mov rax, SYS_CLOSE
    syscall

    mov rax, SYS_EXIT
    xor rdi, rdi
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

.exit:
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall
