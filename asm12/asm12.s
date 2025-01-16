section .bss
    input resb 256
    len resb 1

section .text
    global _start

_start:
    mov rax, 0
    mov rdi, 0
    mov rsi, input
    mov rdx, 256
    syscall

    cmp rax, 0
    jle _exit

    mov rcx, rax
    dec rcx
    mov [len], rcx

    lea rsi, [input]
    lea rdi, [input + rcx - 1]

reverse_loop:
    cmp rsi, rdi
    jge print_reversed

    mov al, [rsi]
    mov bl, [rdi]
    mov [rsi], bl
    mov [rdi], al

    inc rsi
    dec rdi
    jmp reverse_loop

print_reversed:
    mov rax, 1
    mov rdi, 1
    mov rsi, input
    mov rdx, [len]
    syscall

    mov rax, 1
    mov rdi, 1
    lea rsi, [newline]
    mov rdx, 1
    syscall

_exit:
    mov rax, 60
    xor rdi, rdi
    syscall

section .data
    newline db 10
