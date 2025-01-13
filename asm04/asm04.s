global _start

section .bss
    input resb 10

section .text
_start:
    mov rax, 0
    mov rdi, 0
    mov rsi, input
    mov rdx, 10
    syscall

    movzx eax, byte [input]
    cmp al, '0'
    jl _bad_input
    cmp al, '9'
    jg _bad_input

    movzx eax, byte [input + 1]
    cmp al, 0xA
    je _process_number
    cmp al, 0
    je _process_number

_bad_input:
    mov eax, 2
    jmp _exit

_process_number:
    movzx eax, byte [input]
    sub eax, '0'
    test al, 1
    jnz _odd

_even:
    mov eax, 0
    jmp _exit

_odd:
    mov eax, 1

_exit:
    mov rdi, rax
    mov rax, 60
    syscall
