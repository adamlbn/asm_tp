section .bss
    input resb 256  ; Buffer pour stocker l'entrée

section .text
    global _start

_start:
    ; Lire l'entrée standard
    mov rax, 0                 ; sys_read
    mov rdi, 0                 ; stdin
    mov rsi, input             ; Buffer pour l'entrée
    mov rdx, 256               ; Taille maximale
    syscall

    ; Vérifier si la lecture a réussi
    cmp rax, 0                 ; Si aucun octet n'a été lu, quitter
    jle _exit

    ; Trouver la longueur de la chaîne (en ignorant le saut de ligne)
    mov rcx, rax               ; RCX = nombre de caractères lus
    dec rcx                    ; Ignorer le saut de ligne

    ; Initialiser les pointeurs pour vérifier le palindrome
    lea rsi, [input]           ; RSI pointe vers le début de la chaîne
    lea rdi, [input + rcx - 1] ; RDI pointe vers la fin de la chaîne

check_palindrome:
    cmp rsi, rdi               ; Comparer les pointeurs
    jge is_palindrome          ; Si RSI >= RDI, la chaîne est un palindrome

    ; Comparer les caractères
    mov al, [rsi]              ; Charger le caractère de gauche
    mov bl, [rdi]              ; Charger le caractère de droite
    cmp al, bl                 ; Comparer les caractères
    jne not_palindrome         ; Si les caractères diffèrent, ce n'est pas un palindrome

    ; Déplacer les pointeurs
    inc rsi                    ; Déplacer RSI vers la droite
    dec rdi                    ; Déplacer RDI vers la gauche
    jmp check_palindrome       ; Répéter

is_palindrome:
    ; Retourner 0 (c'est un palindrome)
    mov rax, 60                ; sys_exit
    xor rdi, rdi               ; Code de retour 0
    syscall

not_palindrome:
    ; Retourner 1 (ce n'est pas un palindrome)
    mov rax, 60                ; sys_exit
    mov rdi, 1                 ; Code de retour 1
    syscall

_exit:
    ; Quitter le programme (cas d'erreur)
    mov rax, 60                ; sys_exit
    mov rdi, 1                 ; Code de retour 1
    syscall
