section .data
    result_msg db "", 0
    result_msg_len equ $ - result_msg
    buffer db 0
    error_msg db "Error: No input provided", 0
    error_msg_len equ $ - error_msg

section .bss
    num1 resq 1
    num2 resq 1
    result resq 1
    temp resb 21  

section .text
    global _start

_start:
    cmp qword [rsp + 16], 0
    je .no_input_error
    cmp qword [rsp + 24], 0
    je .no_input_error

    mov rsi, [rsp + 16]  
    mov rdi, num1
    call string_to_int

    mov rsi, [rsp + 24]  
    mov rdi, num2
    call string_to_int

    mov rax, [num1]
    add rax, [num2]
    mov [result], rax
    
    mov rdi, 1         
    mov rsi, result_msg
    mov rdx, result_msg_len
    mov rax, 1          
    syscall

    mov rax, [result]
    mov rdi, temp        
    call int_to_string
    mov rsi, rdi        
    call print_string

    mov rax, 60          
    xor rdi, rdi        
    syscall

.no_input_error:
    mov rdi, 1
    mov rsi, error_msg
    mov rdx, error_msg_len
    mov rax, 1
    syscall

    mov rax, 60
    mov rdi, 1
    syscall


string_to_int:
    xor rax, rax
    xor rcx, rcx
    xor rbx, rbx
    movzx rdx, byte [rsi]
    cmp rdx, '-'
    jne .loop
    inc rsi
    mov rbx, 1
.loop:
    movzx rdx, byte [rsi + rcx]
    cmp rdx, 0
    je .end
    sub rdx, '0'
    imul rax, rax, 10
    add rax, rdx
    inc rcx
    jmp .loop
.end:
    test rbx, rbx
    jz .positive
    neg rax
.positive:
    mov [rdi], rax
    ret


int_to_string:
    mov rcx, 10
    mov rbx, 0
    add rdi, 20
    mov byte [rdi], 0
    dec rdi
    test rax, rax
    jns .convert_loop
    neg rax
    mov rbx, 1
.convert_loop:
    xor rdx, rdx
    div rcx
    add dl, '0'
    mov [rdi], dl
    dec rdi
    test rax, rax
    jnz .convert_loop
    test rbx, rbx
    jz .no_sign
    mov byte [rdi], '-'
    dec rdi
.no_sign:
    inc rdi
    ret


print_string:
    mov rdx, 0
    .find_end:
        cmp byte [rsi + rdx], 0
        je .found_end
        inc rdx
        jmp .find_end
    .found_end:
    mov rax, 1
    mov rdi, 1        
    syscall
    ret
