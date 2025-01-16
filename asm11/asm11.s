section .data
    vowels db "aeiouAEIOU", 0
    newline db 10

section .bss
    input resb 256
    output resb 16

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
    jz convert_to_string

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

convert_to_string:
    lea rdi, [output + 15]
    mov byte [rdi], 0
    mov rax, rbx

convert_loop:
    dec rdi
    xor rdx, rdx
    mov rcx, 10
    div rcx
    add dl, '0'
    mov [rdi], dl
    test rax, rax
    jnz convert_loop

print_result:
    mov rax, 1
    mov rdi, 1
    mov rsi, rdi
    lea rdx, [output + 16]
    sub rdx, rdi
    syscall

    mov rax, 1
    mov rdi, 1
    lea rsi, [newline]
    mov rdx, 1
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall
