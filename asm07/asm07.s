section .data
    error_msg db "Error: Invalid input", 0xA
    error_msg_len equ $ - error_msg

section .bss
    num resq 1
    buffer resb 32

section .text
    global _start

_start:
    mov rax, 0
    mov rdi, 0
    mov rsi, buffer
    mov rdx, 32
    syscall

    mov rsi, buffer
    call string_to_int
    cmp rax, -1
    je .invalid_input
    mov [num], rax

    call is_prime
    test rax, rax
    jz .prime

    mov rax, 60
    mov rdi, 1
    syscall

.prime:
    mov rax, 60
    xor rdi, rdi
    syscall

.invalid_input:
    mov rax, 1
    mov rdi, 1
    mov rsi, error_msg
    mov rdx, error_msg_len
    syscall

    mov rax, 60
    mov rdi, 2
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
    cmp rdx, 0xA
    je .end
    cmp rdx, '0'
    jb .invalid
    cmp rdx, '9'
    ja .invalid
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
    ret
.invalid:
    mov rax, -1
    ret


is_prime:
    mov rax, [num]
    cmp rax, 1
    jle .not_prime
    cmp rax, 2
    je .prime
    test rax, 1
    jz .not_prime

    mov rcx, 3
.check_loop:
    mov rdx, rcx
    imul rdx, rdx
    cmp rdx, rax
    ja .prime
    xor rdx, rdx
    div rcx
    test rdx, rdx
    jz .not_prime
    add rcx, 2
    jmp .check_loop

.prime:
    xor rax, rax
    ret
.not_prime:
    mov rax, 1
    ret
