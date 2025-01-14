section .data
    error_msg db "No param !", 0xA
    error_msg_len equ $ - error_msg

section .bss
    buffer resb 256

section .text
    global _start

_start:
    mov rdi, [rsp + 8]
    cmp rdi, 1
    jle no_input_error

    mov rsi, [rsp + 16]
    mov rdi, 1
    call print_string

    mov rax, 60
    xor rdi, rdi
    syscall

no_input_error:
    mov rdi, 1
    mov rsi, error_msg
    mov rdx, error_msg_len
    mov rax, 1
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall

print_string:
    xor rdx, rdx
.find_end:
    cmp byte [rsi + rdx], 0
    je .found_end
    inc rdx
    jmp .find_end
.found_end:
    mov rax, 1
    syscall
    ret
