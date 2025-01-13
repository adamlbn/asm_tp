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
    sub eax, '0'             
    test al, 1               
    jnz _odd                  

    
    mov eax, 0
    jmp _exit

_odd:
    mov eax, 1

_exit:
    mov rdi, rax       
    mov rax, 60
    syscall
