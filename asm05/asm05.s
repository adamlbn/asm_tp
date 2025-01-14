section .data
    no_param_msg db "No param !", 0xA
    no_param_msg_len equ $ - no_param_msg

section .text
    global _start

_start:
    mov rdi, [rsp]
    cmp rdi, 1
    je no_param

    mov rsi, [rsp + 16]
    call print_string

    mov rax, 60
    xor rdi, rdi
    syscall

no_param:
    mov rdi, 1
    mov rsi, no_param_msg
    mov rdx, no_param_msg_len
    mov rax, 1
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall

print_string:
    xor rdx, rdx
.find_length:
    cmp byte [rsi + rdx], 0
    je .write_string
    inc rdx
    jmp .find_length

.write_string:
    mov rax, 1
    mov rdi, 1
    syscall
    ret
