section .text
global _start

_start:
    mov rcx, [rsp]
    cmp rcx, 2
    jl no_param

    mov rax, 2
    mov rdi, [rsp + 16]
    mov rsi, 2
    mov rdx, 0
    syscall
    test rax, rax
    js fail_open
    mov r12, rax

    mov rax, 8
    mov rdi, r12
    mov rsi, 0x2000
    mov rdx, 0
    syscall
    test rax, rax
    js fail_lseek

    mov rax, 1
    mov rdi, r12
    lea rsi, [rel new_message]
    mov rdx, 5
    syscall
    test rax, rax
    js fail_write

    mov rax, 3
    mov rdi, r12
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall

no_param:
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel usage_msg]
    mov rdx, usage_msg_len
    syscall

    mov rax, 60
    mov rdi, 1
    syscall

fail_open:
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel open_error]
    mov rdx, open_error_len
    syscall
    jmp exit

fail_lseek:
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel lseek_error]
    mov rdx, lseek_error_len
    syscall
    jmp exit

fail_write:
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel write_error]
    mov rdx, write_error_len
    syscall
    jmp exit

exit:
    mov rax, 60
    mov rdi, 1
    syscall

section .data
usage_msg db 'Usage: ./asm16 <filename>', 0xA, 0
usage_msg_len equ $ - usage_msg
open_error db 'Erreur: impossible d\'ouvrir le fichier.', 0xA, 0
open_error_len equ $ - open_error
lseek_error db 'Erreur: impossible de déplacer le curseur.', 0xA, 0
lseek_error_len equ $ - lseek_error
write_error db 'Erreur: impossible d\'écrire dans le fichier.', 0xA, 0
write_error_len equ $ - write_error
new_message db 'H4CK', 0xA
