section .text
global _start

_start:
    ; Vérifier si un argument a été passé
    mov rcx, [rsp]               ; rsp contient le nombre d'arguments (argc)
    cmp rcx, 2                   ; Vérifier si argc == 2 (nom du programme + 1 argument)
    jl no_param                  ; Si argc < 2, aller à no_param

    ; Ouvrir le fichier
    mov rax, 2                   ; Appel système open
    mov rdi, [rsp + 16]          ; Récupérer le nom du fichier (argv[1])
    mov rsi, 2                   ; O_RDWR
    mov rdx, 0                   ; Pas de mode nécessaire
    syscall
    test rax, rax
    js fail_open                 ; Si erreur, aller à fail_open
    mov r12, rax                 ; Stocker le descripteur de fichier (fd)

    ; Déplacer le curseur à l'offset 0x2000
    mov rax, 8                   ; Appel système lseek
    mov rdi, r12                 ; Descripteur de fichier
    mov rsi, 0x2000              ; Offset
    mov rdx, 0                   ; SEEK_SET
    syscall
    test rax, rax
    js fail_lseek                ; Si erreur, aller à fail_lseek

    ; Écrire "H4CK"
    mov rax, 1                   ; Appel système write
    mov rdi, r12                 ; Descripteur de fichier
    lea rsi, [rel new_message]   ; Nouveau message
    mov rdx, 5                   ; Taille du message (4 caractères + saut de ligne)
    syscall
    test rax, rax
    js fail_write                ; Si erreur, aller à fail_write

    ; Fermer le fichier
    mov rax, 3                   ; Appel système close
    mov rdi, r12                 ; Descripteur de fichier
    syscall

    ; Sortie réussie
    mov rax, 60                  ; Appel système exit
    xor rdi, rdi                 ; Code de sortie 0
    syscall

no_param:
    ; Afficher un message d'usage
    mov rax, 1                   ; Appel système write
    mov rdi, 1                   ; stdout
    lea rsi, [rel usage_msg]     ; Message d'usage
    mov rdx, usage_msg_len       ; Longueur du message
    syscall

    ; Quitter avec un code d'erreur
    mov rax, 60                  ; Appel système exit
    mov rdi, 1                   ; Code de sortie 1
    syscall

fail_open:
    ; Afficher une erreur d'ouverture
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel open_error]
    mov rdx, open_error_len
    syscall
    jmp exit

fail_lseek:
    ; Afficher une erreur de déplacement
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel lseek_error]
    mov rdx, lseek_error_len
    syscall
    jmp exit

fail_write:
    ; Afficher une erreur d'écriture
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel write_error]
    mov rdx, write_error_len
    syscall
    jmp exit

exit:
    ; Quitter avec un code d'erreur
    mov rax, 60
    mov rdi, 1
    syscall

section .data
usage_msg db 'Usage: ./asm16 <filename>', 0xA, 0
usage_msg_len equ $ - usage_msg
open_error db 'Erreur: impossible d ouvrir le fichier.', 0xA, 0
open_error_len equ $ - open_error
lseek_error db 'Erreur: impossible de deplacer le curseur.', 0xA, 0
lseek_error_len equ $ - lseek_error
write_error db 'Erreur: impossible d ecrire dans le fichier.', 0xA, 0
write_error_len equ $ - write_error
new_message db 'H4CK', 0xA
