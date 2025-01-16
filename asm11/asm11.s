section .data
    vowels db "aeiouAEIOU", 0

section .bss
    input resb 256

section .text
    global _start

_start:
    mov rax, 0
    mov rdi, 0
    lea rsi, [input]
    mov rdx, 256
    syscall

    xor rbx, rbx

    lea rsi, [input]
    mov rcx, rax

count_vowels:
    lodsb
    test al, al
    jz print_result

    lea rdi, [vowels]
    mov rdx, 10
check_vowel:
    scasb
    je increment_count
    dec rdx
    jnz check_vowel

    jmp count_vowels

increment_count:
    inc rbx
    jmp count_vowels

print_result:
    add rbx, '0'
    mov [input], bl

    mov rax, 1
    mov rdi, 1
    lea rsi, [input]
    mov rdx, 1
    syscall

    mov rax, 1
    mov rdi, 1
    lea rsi, [newline]
    mov rdx, 1
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall

section .data
    newline db 10
