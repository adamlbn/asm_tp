section .data
    SYS_SOCKET   equ 41
    SYS_CONNECT  equ 42
    SYS_SENDTO   equ 44
    SYS_RECVFROM equ 45
    SYS_CLOSE    equ 3
    SYS_EXIT     equ 60
    SYS_SELECT   equ 23

    AF_INET      equ 2
    SOCK_DGRAM   equ 2
    IPPROTO_UDP  equ 17

    ; Définition d'une structure sockaddr_in (16 octets)
    sockaddr_in:
        dw AF_INET          ; sin_family (2 octets)
        dw 0x3905           ; sin_port en ordre réseau (en mémoire : 05 39 = 1337)
        dd 0x0100007F      ; sin_addr (127.0.0.1 en ordre réseau)
        times 8 db 0        ; sin_zero (8 octets)

    ; Timeout de 1 seconde (tv_sec=1, tv_usec=0)
    timeout:
        dd 1
        dd 0

    request     db "Hello, server!", 0
    request_len equ $ - request

    response    times 256 db 0

    timeout_msg db "Timeout: no response from server", 0xA
    timeout_msg_len equ $ - timeout_msg

section .bss
    sockfd resq 1      ; un quadword pour la socket
    addr_len resq 1
    readfds resb 128   ; espace pour le fd_set

section .text
global _start

_start:
    ; Création de la socket UDP : socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)
    mov rax, SYS_SOCKET
    mov rdi, AF_INET
    mov rsi, SOCK_DGRAM
    mov rdx, IPPROTO_UDP
    syscall
    cmp rax, 0
    jl .exit_error
    mov [sockfd], rax

    ; Envoi de la requête au serveur
    mov rax, SYS_SENDTO
    mov rdi, [sockfd]
    lea rsi, [request]
    mov rdx, request_len
    mov r10, 0               ; flags = 0
    lea r8, [sockaddr_in]    ; adresse du serveur
    mov r9, 16               ; taille de sockaddr_in
    syscall
    cmp rax, 0
    jl .close_socket

    ; Préparation du fd_set pour select
    lea rdi, [readfds]
    mov rcx, 128/8
    xor rax, rax
    rep stosq
    ; On place le bit correspondant à la socket dans readfds
    mov eax, dword [sockfd]
    bts dword [readfds], eax

    ; Appel de SYS_SELECT pour attendre la réponse avec timeout
    mov rax, SYS_SELECT
    mov rdi, [sockfd]
    add rdi, 1               ; nfds = sockfd + 1
    lea rsi, [readfds]
    mov rdx, 0               ; writefds = NULL
    mov r10, 0               ; exceptfds = NULL
    lea r8, [timeout]        ; délai d'attente
    syscall
    cmp rax, 0
    jle .timeout             ; en cas d'erreur ou de timeout

    ; Réception de la réponse
    mov rax, SYS_RECVFROM
    mov rdi, [sockfd]
    lea rsi, [response]
    mov rdx, 256
    mov r10, 0               ; flags = 0
    lea r8, [sockaddr_in]    ; (on peut réutiliser sockaddr_in pour récupérer l'adresse d'envoi)
    lea r9, [addr_len]
    syscall
    cmp rax, 0
    jl .close_socket
    ; Sauvegarder le nombre d’octets reçus (dans rax) pour l'écrire
    mov rbx, rax

    ; Affichage de la réponse sur la sortie standard
    mov rax, 1               ; SYS_WRITE
    mov rdi, 1               ; fd = stdout
    lea rsi, [response]
    mov rdx, rbx             ; nombre d'octets reçus
    syscall

    ; Fermeture de la socket et sortie avec code 0
    mov rax, SYS_CLOSE
    mov rdi, [sockfd]
    syscall

    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall

.timeout:
    ; Message en cas de timeout et sortie avec code 1
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
