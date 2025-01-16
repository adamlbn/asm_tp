section .bss
    input resb 256

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

    lea rsi, [input]
    lea rdi, [input + rcx - 1]

check_palindrome:
    cmp rsi, rdi
    jge is_palindrome

    mov al, [rsi]
    mov bl, [rdi]
    cmp al, bl
    jne not_palindrome

    inc rsi
    dec rdi
    jmp check_palindrome

is_palindrome:
    mov rax, 60
    xor rdi, rdi
    syscall

not_palindrome:
    mov rax, 60
    mov rdi, 1
    syscall

_exit:
    mov rax, 60
    mov rdi, 1
    syscall
