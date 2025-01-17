section .text
global _start

_start:
    ; Vérifier le nombre d'arguments
    mov rax, 1                  
    mov rdi, 0                   
    cmp rdi, 2                 
    je continue                  
    jmp no_param                 

continue:
    ; Ouvrir le fichier
    mov rax, 2                 
    lea rdi, [rel filename]      
    mov rsi, 2                 
    mov rdx, 0                   
    syscall
    test rax, rax
    js fail_open                 
    mov r12, rax                 

    ; Déplacer le curseur à l'offset 0x2000
    mov rax, 8                   
    mov rdi, r12                 
    mov rsi, 0x2000              
    mov rdx, 0                  
    syscall
    test rax, rax
    js fail_lseek               

    ; Écrire "H4CK"
    mov rax, 1                  
    mov rdi, r12                 
    lea rsi, [rel new_message]   
    mov rdx, 5                   
    syscall
    test rax, rax
    js fail_write                

    ; Fermer le fichier
    mov rax, 3                   
    mov rdi, r12                 
    syscall

    ; Sortie réussie
    mov rax, 60                  
    xor rdi, rdi                 
    syscall

no_param:
    ; Afficher un message d'erreur
    mov rax, 1                  
    mov rdi, 1                  
    lea rsi, [rel error_message] 
    mov rdx, error_len           
    syscall

    ; Quitter avec code de sortie 1
    mov rax, 60                 
    mov rdi, 1                   
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
filename db 'asm01', 0
error_message db 'Erreur: Aucun parametre fourni.', 0xA, 0
error_len equ $ - error_message
open_error db 'Erreur: impossible d ouvrir le fichier.', 0xA, 0
open_error_len equ $ - open_error
lseek_error db 'Erreur: impossible de deplacer le curseur.', 0xA, 0
lseek_error_len equ $ - lseek_error
write_error db 'Erreur: impossible d ecrire dans le fichier.', 0xA, 0
write_error_len equ $ - write_error
new_message db 'H4CK', 0xA
