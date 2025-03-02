section .data
    ; Numéros de syscall
    SYS_SOCKET   equ 41
    SYS_BIND     equ 49
    SYS_RECVFROM equ 45
    SYS_OPENAT   equ 257
    SYS_WRITE    equ 1
    SYS_CLOSE    equ 3
    SYS_EXIT     equ 60

    ; Paramètres pour les sockets
    AF_INET     equ 2
    SOCK_DGRAM  equ 2
    IPPROTO_UDP equ 17

    ; Message de lancement affiché sur stdout
    listening_msg     db "⏳ Listening on port 1337", 0xA
    listening_msg_len equ $ - listening_msg

    ; Nom du fichier de log (sera créé dans le répertoire courant)
    filename    db "messages", 0

    ; Structure sockaddr_in (16 octets) pour le bind
    ; sin_family : AF_INET (2)
    ; sin_port   : 0x3905 (en ordre réseau, correspond à 1337)
    ; sin_addr   : INADDR_ANY (0)
    ; sin_zero   : 8 octets à 0
    sockaddr_in:
        dw AF_INET
        dw 0x3905
        dd 0
        times 8 db 0

    ; Caractère de saut de ligne (sera utilisé après chaque message)
    newline     db 0xA

    ; Buffer de réception (256 octets)
    recv_buffer times 256 db 0

section .bss
    sockfd   resq 1    ; Descripteur de la socket UDP
    filefd   resq 1    ; Descripteur du fichier "messages"
    addr_len resq 1    ; Taille de la structure d'adresse pour recvfrom

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

    ; Bind de la socket sur le port 1337 (adresse locale INADDR_ANY)
    mov rax, SYS_BIND
    mov rdi, [sockfd]
    lea rsi, [sockaddr_in]
    mov rdx, 16             ; taille de la structure sockaddr_in
    syscall
    cmp rax, 0
    jl .close_socket

    ; Ouverture (ou création) du fichier "messages" en mode écriture et append.
    ; openat(AT_FDCWD, filename, O_WRONLY | O_CREAT | O_APPEND, 0644)
    ; AT_FDCWD vaut -100.
    ; Les flags sont : O_WRONLY (1) + O_CREAT (64) + O_APPEND (1024) = 1089.
    mov rax, SYS_OPENAT
    mov rdi, -100           ; AT_FDCWD
    lea rsi, [filename]
    mov rdx, 1089           ; flags
    mov r10, 0x1A4          ; mode 0644 (octal 0644 = décimal 420 = 0x1A4)
    syscall
    cmp rax, 0
    jl .close_socket
    mov [filefd], rax

    ; Affichage du message "Listening on port 1337" sur stdout
    mov rax, SYS_WRITE
    mov rdi, 1              ; fd 1 = stdout
    lea rsi, [listening_msg]
    mov rdx, listening_msg_len
    syscall

.loop:
    ; Initialisation de la taille de l'adresse pour recvfrom (16 octets)
    mov qword [addr_len], 16

    ; Attente de réception d'un message sur la socket UDP
    mov rax, SYS_RECVFROM
    mov rdi, [sockfd]
    lea rsi, [recv_buffer]
    mov rdx, 256          ; taille max du message
    mov r10, 0            ; flags = 0
    lea r8, [sockaddr_in] ; adresse source (non utilisée ici)
    lea r9, [addr_len]
    syscall
    ; Si aucune donnée n'est reçue ou en cas d'erreur, on retourne en début de boucle
    cmp rax, 1
    jl .loop

    ; Le nombre d'octets reçus est dans rax
    mov rbx, rax

    ; Écriture du message reçu dans le fichier "messages"
    mov rax, SYS_WRITE
    mov rdi, [filefd]
    lea rsi, [recv_buffer]
    mov rdx, rbx
    syscall

    ; Ajout d'un saut de ligne après le message
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
