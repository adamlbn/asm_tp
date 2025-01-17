section .data
    SYS_READ  equ 0
    SYS_WRITE equ 1
    SYS_EXIT  equ 60

    usage db 'Usage: ./asm17 <shift>', 0xA
    usage_len equ $ - usage

section .bss
    input resb 256
    output resb 256

section .text
global _start

_start:
    mov rcx, [rsp]
    cmp rcx, 2
    jl .error

    mov rsi, [rsp + 16]
    call atoi
    mov r12, rax

    mov rax, SYS_READ
    mov rdi, 0
    mov rsi, input
    mov rdx, 256
    syscall

    lea rsi, [input]
    lea rdi, [output]
    mov rcx, rax

.caesar_loop:
    lodsb
    test al, al
    jz .done

    ; Gestion des lettres minuscules
    cmp al, 'a'
    jb .check_upper
    cmp al, 'z'
    ja .check_upper

    add al, r12b
    cmp al, 'z'
    jbe .store_char
    sub al, 26
    jmp .store_char

.check_upper:
    ; Gestion des lettres majuscules
    cmp al, 'A'
    jb .store_char
    cmp al, 'Z'
    ja .store_char

    add al, r12b
    cmp al, 'Z'
    jbe .store_char
    sub al, 26

.store_char:
    stosb
    loop .caesar_loop

.done:
    sub rdi, output
    mov rdx, rdi

    mov rax, SYS_WRITE
    mov rdi, 1
    mov rsi, output
    syscall

    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall

.error:
    mov rax, SYS_WRITE
    mov rdi, 1
    mov rsi, usage
    mov rdx, usage_len
    syscall

    mov rax, SYS_EXIT
    mov rdi, 1
    syscall

atoi:
    xor rax, rax
    xor rcx, rcx

.convert_loop:
    movzx rdx, byte [rsi + rcx]
    test rdx, rdx
    jz .done_convert

    cmp rdx, '0'
    jb .done_convert
    cmp rdx, '9'
    ja .done_convert

    sub rdx, '0'
    imul rax, rax, 10
    add rax, rdx
    inc rcx
    jmp .convert_loop

.done_convert:
    ret
