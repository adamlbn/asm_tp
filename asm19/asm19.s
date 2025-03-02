section .data
    SYS_SOCKET   equ 41
    SYS_BIND     equ 49
    SYS_RECVFROM equ 45
    SYS_OPENAT   equ 257
    SYS_WRITE    equ 1
    SYS_CLOSE    equ 3
    SYS_EXIT     equ 60

    AF_INET     equ 2
    SOCK_DGRAM  equ 2
    IPPROTO_UDP equ 17

    listening_msg     db "⏳ Listening on port 1337", 0xA
    listening_msg_len equ $ - listening_msg

    filename    db "messages", 0

    sockaddr_in:
        dw AF_INET
        dw 0x3905
        dd 0
        times 8 db 0

    newline     db 0xA

    recv_buffer times 256 db 0

section .bss
    sockfd   resq 1    
    filefd   resq 1   
    addr_len resq 1   

section .text
global _start

_start:
    mov rax, SYS_SOCKET
    mov rdi, AF_INET
    mov rsi, SOCK_DGRAM
    mov rdx, IPPROTO_UDP
    syscall
    cmp rax, 0
    jl .exit_error
    mov [sockfd], rax

    mov rax, SYS_BIND
    mov rdi, [sockfd]
    lea rsi, [sockaddr_in]
    mov rdx, 16             
    syscall
    cmp rax, 0
    jl .close_socket


    mov rax, SYS_OPENAT
    mov rdi, -100          
    lea rsi, [filename]
    mov rdx, 1089          
    mov r10, 0x1A4         
    syscall
    cmp rax, 0
    jl .close_socket
    mov [filefd], rax

    mov rax, SYS_WRITE
    mov rdi, 1              ; fd 1 = stdout
    lea rsi, [listening_msg]
    mov rdx, listening_msg_len
    syscall

.loop:
    mov qword [addr_len], 16

    mov rax, SYS_RECVFROM
    mov rdi, [sockfd]
    lea rsi, [recv_buffer]
    mov rdx, 256          
    mov r10, 0            
    lea r8, [sockaddr_in] 
    lea r9, [addr_len]
    syscall

    cmp rax, 1
    jl .loop

    mov rbx, rax

    mov rax, SYS_WRITE
    mov rdi, [filefd]
    lea rsi, [recv_buffer]
    mov rdx, rbx
    syscall

    mov rax, SYS_WRITE
    mov rdi, [filefd]
    lea rsi, [newline]
    mov rdx, 1
    syscall

    jmp .loop

.close_socket:
    mov rax, SYS_CLOSE
    mov rdi, [sockfd]
    syscall

.exit_error:
    mov rax, SYS_EXIT
    mov rdi, 1
    syscall
