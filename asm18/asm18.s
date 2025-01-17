section .data
    SYS_SOCKET  equ 41
    SYS_CONNECT equ 42
    SYS_SENDTO  equ 44
    SYS_RECVFROM equ 45
    SYS_CLOSE   equ 3
    SYS_EXIT    equ 60
    SYS_SELECT  equ 23

    AF_INET     equ 2
    SOCK_DGRAM  equ 2
    IPPROTO_UDP equ 17

    server_addr db 0x7F, 0x00, 0x00, 0x01
    server_port dw 0x3905
    family      dw AF_INET

    timeout     dd 1, 0

    request     db "Hello, server!", 0
    request_len equ $ - request

    response    times 256 db 0
    response_len equ 256

    timeout_msg db "Timeout: no response from server", 0xA
    timeout_msg_len equ $ - timeout_msg

section .bss
    sockfd resb 8
    addr_len resb 8
    readfds resb 128

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

    mov word [family], AF_INET
    mov word [server_port], 0x3905
    mov dword [server_addr], 0x0100007F

    mov rax, SYS_SENDTO
    mov rdi, [sockfd]
    lea rsi, [request]
    mov rdx, request_len
    mov r10, 0
    lea r8, [family]
    mov r9, 16
    syscall
    cmp rax, 0
    jl .close_socket

    lea rdi, [readfds]
    mov rcx, 128 / 8
    xor rax, rax
    rep stosq

    mov rax, [sockfd]
    bts [readfds], rax

    mov rax, SYS_SELECT
    mov rdi, [sockfd]
    add rdi, 1
    lea rsi, [readfds]
    mov rdx, 0
    mov r10, 0
    lea r8, [timeout]
    syscall
    cmp rax, 0
    jle .timeout

    mov rax, SYS_RECVFROM
    mov rdi, [sockfd]
    lea rsi, [response]
    mov rdx, response_len
    mov r10, 0
    lea r8, [family]
    lea r9, [addr_len]
    syscall
    cmp rax, 0
    jl .close_socket

    mov rax, 1
    mov rdi, 1
    lea rsi, [response]
    mov rdx, rax
    syscall

    mov rax, SYS_CLOSE
    mov rdi, [sockfd]
    syscall

    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall

.timeout:
    mov rax, 1
    mov rdi, 1
    lea rsi, [timeout_msg]
    mov rdx, timeout_msg_len
    syscall

    mov rax, SYS_CLOSE
    mov rdi, [sockfd]
    syscall

    mov rax, SYS_EXIT
    mov rdi, 1
    syscall

.close_socket:
    mov rax, SYS_CLOSE
    mov rdi, [sockfd]
    syscall

.exit_error:
    mov rax, SYS_EXIT
    mov rdi, 1
    syscall
