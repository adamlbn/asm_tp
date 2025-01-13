global _start

section .bss
    input resb 2

section .data
    msg db "0", 0xA 
    newline db 0xA
    msg_len equ $ - msg
    newline_len equ 1

section .text
_start:

    mov rax, 0          
    mov rdi, 0          
    mov rsi, input      
    mov rdx, 2          
    syscall

    movzx eax, byte [input]  
    cmp al, '0'
    jl _invalid_input         
    cmp al, '9'
    jg _invalid_input         

    sub eax, '0'

    test al, 1               
    jnz _odd                 

_even:
    mov eax, 0
    jmp _exit

_odd:
    mov eax, 1
    jmp _exit

_invalid_input:
    mov eax, 2               

_exit:
    mov rdi, rax       
    mov rax, 60
    syscall
