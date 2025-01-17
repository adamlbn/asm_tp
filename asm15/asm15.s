section .data
    SYS_OPEN  equ 2
    SYS_READ  equ 0
    SYS_CLOSE equ 3
    SYS_EXIT  equ 60
    SYS_WRITE equ 1

    ELF_MAGIC db 0x7F, 'E', 'L', 'F'
    ELF_CLASS_64 db 2

    usage db 'Usage: ./asm15 <filename>', 0xa
    usage_len equ $ - usage

section .bss
    fd resb 8
    buffer resb 5

section .text
global _start

_start:
    mov rcx, [rsp]
    cmp rcx, 2
    jl .error

    mov rsi, [rsp + 16]

    mov rdi, rsi
    mov rsi, 0
    mov rdx, 0
    mov rax, SYS_OPEN
    syscall

    cmp rax, 0
    jl .file_error

    mov [fd], rax

    mov rdi, [fd]
    mov rsi, buffer
    mov rdx, 5
    mov rax, SYS_READ
    syscall

    mov rdi, [fd]
    mov rax, SYS_CLOSE
    syscall

    mov rcx, 4
    lea rsi, [buffer]
    lea rdi, [ELF_MAGIC]
    repe cmpsb
    jne .not_elf

    mov al, [buffer + 4]
    cmp al, [ELF_CLASS_64]
    jne .not_elf

    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall

.not_elf:
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

.file_error:
    mov rax, SYS_EXIT
    mov rdi, 1
    syscall
