section .data
    ; Numéros de syscall
    SYS_SOCKET   equ 41
    SYS_BIND     equ 49
    SYS_LISTEN   equ 50
    SYS_ACCEPT   equ 43
    SYS_FORK     equ 57
    SYS_READ     equ 0
    SYS_WRITE    equ 1
    SYS_CLOSE    equ 3
    SYS_EXIT     equ 60

    ; Paramètres pour les sockets
    AF_INET      equ 2
    SOCK_STREAM  equ 1      ; TCP
    IPPROTO_TCP  equ 6

    ; Structure sockaddr_in pour le serveur TCP (16 octets)
    ; sin_family = AF_INET, sin_port = htons(4242) = 0x9210, sin_addr = INADDR_ANY (0)
    sockaddr_in_listen:
        dw AF_INET
        dw 0x9210         ; 4242 en ordre réseau
        dd 0              ; INADDR_ANY
        times 8 db 0

    ; Messages à afficher/renvoyer
    listening_msg: db "⏳ Listening on port 4242", 0xA
    listening_msg_len equ $ - listening_msg

    prompt_str: db "Type a command: ", 0
    prompt_len: equ $ - prompt_str

    pong_str: db "PONG", 0xA
    pong_len: equ $ - pong_str

    goodbye_str: db "Goodbye!", 0xA
    goodbye_len: equ $ - goodbye_str

    unknown_str: db "Unknown command", 0xA
    unknown_len: equ $ - unknown_str

    reverse_prefix: db "REVERSE ", 0
    reverse_prefix_len equ $ - reverse_prefix

    ping_str: db "PING", 0
    ping_str_len equ $ - ping_str

    exit_str: db "EXIT", 0
    exit_str_len equ $ - exit_str

section .bss
    listen_sock   resq 1      ; descripteur de la socket d'écoute
    client_sock   resq 1      ; descripteur de socket client (après accept)
    command_buffer resb 256   ; buffer pour la commande du client
    reverse_buffer resb 256   ; buffer pour stocker le texte inversé

section .text
global _start

_start:
    ; Création de la socket TCP : socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)
    mov rax, SYS_SOCKET
    mov rdi, AF_INET
    mov rsi, SOCK_STREAM
    mov rdx, IPPROTO_TCP
    syscall
    cmp rax, 0
    jl exit_error
    mov [listen_sock], rax

    ; Bind de la socket sur le port 4242
    mov rax, SYS_BIND
    mov rdi, [listen_sock]
    lea rsi, [sockaddr_in_listen]
    mov rdx, 16
    syscall
    cmp rax, 0
    jl close_listen

    ; Passage en mode écoute (backlog = 10)
    mov rax, SYS_LISTEN
    mov rdi, [listen_sock]
    mov rsi, 10
    syscall
    cmp rax, 0
    jl close_listen

    ; Affichage du message de démarrage sur stdout
    mov rax, SYS_WRITE
    mov rdi, 1
    lea rsi, [listening_msg]
    mov rdx, listening_msg_len
    syscall

.accept_loop:
    ; Attente d'une connexion entrante
    mov rax, SYS_ACCEPT
    mov rdi, [listen_sock]
    xor rsi, rsi         ; pas d'adresse client
    xor rdx, rdx
    syscall
    cmp rax, 0
    jl .accept_loop      ; en cas d'erreur, on réessaye
    mov [client_sock], rax

    ; Fork pour gérer le client dans un processus enfant
    mov rax, SYS_FORK
    syscall
    cmp rax, 0
    je .child            ; fork retourne 0 dans l'enfant

    ; Parent : ferme le descripteur client et retourne en accept_loop
    mov rax, SYS_CLOSE
    mov rdi, [client_sock]
    syscall
    jmp .accept_loop

.child:
    ; Dans l'enfant, fermer la socket d'écoute
    mov rax, SYS_CLOSE
    mov rdi, [listen_sock]
    syscall

.client_loop:
    ; Envoi du prompt au client
    mov rax, SYS_WRITE
    mov rdi, [client_sock]
    lea rsi, [prompt_str]
    mov rdx, prompt_len
    syscall

    ; Lecture de la commande du client
    mov rax, SYS_READ
    mov rdi, [client_sock]
    lea rsi, [command_buffer]
    mov rdx, 256
    syscall
    cmp rax, 0
    jle .exit_child     ; si rien lu ou erreur, on quitte le client
    ; RAX contient le nombre d'octets lus (on le sauvegarde dans RCX)
    mov rcx, rax

    ; Comparaison avec "PING"
    lea rdi, [command_buffer]
    lea rsi, [ping_str]
    mov rdx, ping_str_len
    push rcx            ; sauvegarde de la longueur lue
    call strncmp
    pop rcx
    cmp rax, 0
    je .handle_ping

    ; Comparaison avec "REVERSE "
    lea rdi, [command_buffer]
    lea rsi, [reverse_prefix]
    mov rdx, reverse_prefix_len
    push rcx
    call strncmp
    pop rcx
    cmp rax, 0
    je .handle_reverse

    ; Comparaison avec "EXIT"
    lea rdi, [command_buffer]
    lea rsi, [exit_str]
    mov rdx, exit_str_len
    push rcx
    call strncmp
    pop rcx
    cmp rax, 0
    je .handle_exit

    ; Commande inconnue
    mov rax, SYS_WRITE
    mov rdi, [client_sock]
    lea rsi, [unknown_str]
    mov rdx, unknown_len
    syscall
    jmp .client_loop

.handle_ping:
    ; Réponse à PING → "PONG"
    mov rax, SYS_WRITE
    mov rdi, [client_sock]
    lea rsi, [pong_str]
    mov rdx, pong_len
    syscall
    jmp .client_loop

.handle_reverse:
    ; La commande commence par "REVERSE "
    ; Le texte à inverser démarre à command_buffer + reverse_prefix_len
    lea rsi, [command_buffer + reverse_prefix_len]
    ; La longueur du texte est (nombre d'octets lus) - (longueur du préfixe)
    mov rbx, rcx
    sub rbx, reverse_prefix_len
    ; Si le dernier caractère est un saut de ligne (0xA), on le retire
    mov rdx, rbx
    dec rdx
    lea rdi, [command_buffer + reverse_prefix_len]
    add rdi, rdx
    mov al, byte [rdi]
    cmp al, 0xA
    jne .no_newline
    dec rbx
.no_newline:
    ; Rbx contient maintenant la longueur utile du texte
    ; On effectue l'inversion du texte dans reverse_buffer
    ; Calculer le pointeur de fin : (command_buffer + reverse_prefix_len + rbx - 1)
    lea rdi, [command_buffer + reverse_prefix_len]
    add rdi, rbx
    dec rdi           ; rdi pointe sur le dernier caractère à inverser
    ; Initialisation de l'index (r8 = 0) et de la longueur (r9 = rbx)
    xor r8, r8
    mov r9, rbx
    ; R10 pointera vers reverse_buffer
    lea r10, [reverse_buffer]
.reverse_loop:
    cmp r8, r9
    jge .done_reverse
    mov al, byte [rdi]
    mov byte [r10 + r8], al
    inc r8
    dec rdi
    jmp .reverse_loop
.done_reverse:
    ; Envoi du texte inversé au client
    mov rax, SYS_WRITE
    mov rdi, [client_sock]
    lea rsi, [reverse_buffer]
    mov rdx, r9
    syscall
    jmp .client_loop

.handle_exit:
    ; Réponse à EXIT → "Goodbye!"
    mov rax, SYS_WRITE
    mov rdi, [client_sock]
    lea rsi, [goodbye_str]
    mov rdx, goodbye_len
    syscall
    jmp .exit_child

.exit_child:
    ; Fermeture de la socket client et sortie du processus enfant
    mov rax, SYS_CLOSE
    mov rdi, [client_sock]
    syscall
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall

close_listen:
    mov rax, SYS_CLOSE
    mov rdi, [listen_sock]
    syscall
exit_error:
    mov rax, SYS_EXIT
    mov rdi, 1
    syscall

; Fonction strncmp
; Compare en octets deux chaînes pointées par RDI et RSI sur une longueur RDX.
; Retourne 0 si égales, sinon 1.
; Rétablit RBX (sauvegardé en début de fonction).
strncmp:
    push rbx
    mov rcx, rdx
.strncmp_loop:
    cmp rcx, 0
    je .equal
    mov al, byte [rdi]
    mov bl, byte [rsi]
    cmp al, bl
    jne .notequal
    inc rdi
    inc rsi
    dec rcx
    jmp .strncmp_loop
.equal:
    xor rax, rax
    pop rbx
    ret
.notequal:
    mov rax, 1
    pop rbx
    ret
