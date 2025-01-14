section .data
    error_msg db "Error: No input provided", 0xA
    error_msg_len equ $ - error_msg

section .text
    global _start

_start:
    mov rdi, [rsp]       
    cmp rdi, 1           
    jle no_input_error

    mov rsi, [rsp + 8]   
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
    mov rdi, 1           
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
