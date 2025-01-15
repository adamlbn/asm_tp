section .data
    usage_msg db "Usage: ./asm10 number1 number2 number3", 10
    .lenUsage: equ $ - usage_msg
    invalid_input_msg db "Invalid input", 10
    .lenInvalidInput: equ $ - invalid_input_msg
    newline db 10

section .bss
    result resb 32  ; Buffer pour stocker le résultat en chaîne de caractères

section .text
    global _start

_start:
    ; Vérifier le nombre d'arguments
    mov r13, [rsp]        ; r13 = argc
    cmp r13, 4            ; 4 arguments (./asm10 + 3 nombres)
    jne _usage_error

    ; Extraire les arguments
    mov rsi, [rsp + 16]   ; rsi = argv[1] (premier nombre)
    call _atoi
    mov r8, rax           ; r8 = premier nombre

    mov rsi, [rsp + 24]   ; rsi = argv[2] (deuxième nombre)
    call _atoi
    mov r9, rax           ; r9 = deuxième nombre

    mov rsi, [rsp + 32]   ; rsi = argv[3] (troisième nombre)
    call _atoi
    mov r10, rax          ; r10 = troisième nombre

    ; Trouver le plus grand nombre
    mov rax, r8           ; rax = premier nombre
    cmp rax, r9
    jge ._compare_third
    mov rax, r9           ; rax = deuxième nombre

._compare_third:
    cmp rax, r10
    jge ._print_result
    mov rax, r10          ; rax = troisième nombre

._print_result:
    ; Convertir le résultat en chaîne de caractères
    lea rdi, [result + 31] ; Pointeur vers la fin du buffer
    mov byte [rdi], 0      ; Null-terminate la chaîne
    dec rdi

    mov rcx, 10            ; Base 10 pour la conversion

convert_loop:
    xor rdx, rdx           ; Clear rdx pour la division
    div rcx                ; Diviser rax par 10
    add dl, '0'            ; Convertir le reste en ASCII
    mov [rdi], dl          ; Stocker le caractère
    dec rdi
    cmp rax, 0             ; Si le quotient est 0, on a fini
    jne convert_loop

    ; Afficher le résultat
    mov rax, 1             ; sys_write
    mov rdi, 1             ; stdout
    lea rsi, [rdi +
