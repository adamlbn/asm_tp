section .data
    usage_msg db "Usage: ./asm10 number1 number2 number3", 10
    .lenUsage: equ $ - usage_msg
    invalid_input_msg db "Invalid input", 10
    .lenInvalidInput: equ $ - invalid_input_msg
    newline db 10

section .bss
    result resb 32

section .text
    global _start

_start:
    mov r13, [rsp]
    cmp r13, 4
    jne _usage_error

    mov rsi, rsp
    add rsi, 16
    call _atoi
    mov r8, rax

    mov rsi, rsp
    add rsi, 24
    call _atoi
    mov r9, rax

    mov rsi, rsp
    add rsi, 32
    call _atoi
    mov r10, rax

    mov rax, r8
    cmp rax, r9
    jge ._compare_third
    mov rax, r9

._compare_third:
    cmp rax, r10
    jge ._print_result
    mov rax, r10

._print_result:
    lea rdi, [result + 31]
    mov byte [rdi], 0
    dec rdi

    mov rcx, 10

convert_loop:
    xor rdx, rdx
    div rcx
    add dl, '0'
    mov [rdi], dl
    dec rdi
    cmp rax, 0
    jne convert_loop

    mov rax, 1
    mov rdi, 1
    lea rsi, [rdi + 1]
    lea rdx, [result + 32]
    sub rdx, rsi
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall

_usage_error:
    mov rax, 1
    mov rdi, 2
    lea rsi, [usage_msg]
    mov rdx, usage_msg.lenUsage
    syscall

    mov rax, 60
    mov rdi, 1
    syscall

_atoi:
    xor rax, rax
    xor rcx, rcx

.atoi_loop:
    movzx rbx, byte [rsi + rcx]
    test rbx, rbx
    je .atoi_done

    cmp rbx, '0'
    jl _invalid_input
    cmp rbx, '9'
    jg _invalid_input

    sub rbx, '0'
    imul rax, 10
    add rax, rbx
    inc rcx
    jmp .atoi_loop

.atoi_done:
    ret

_invalid_input:
    mov rax, 1
    mov rdi, 2
    lea rsi, [invalid_input_msg]
    mov rdx, invalid_input_msg.lenInvalidInput
    syscall

    mov rax, 60
    mov rdi, 1
    syscall
