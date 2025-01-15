global _start

section .bss
    nb1 resb 32
    nb2 resb 32
    nb3 resb 32
    signNb1 resb 1 
    signNb2 resb 1
    signNb3 resb 1
    finalSign resb 1
    result resb 32

section .data
    help: db "Return the biggest of 3 numbers passed as parameters", 10
    .lenHelp: equ $ - help
    usage: db "USAGE : ./asm10 NUMBER1 NUMBER2 NUMBER3", 10
    .lenUsage: equ $ - usage

section .text
_start:
    mov r13, [rsp]
    cmp r13, 4
    jne _error

    mov rsi, rsp
    add rsi, 16
    mov rsi, [rsi]
    mov rdi, nb1
    mov rcx, 4
    rep movsb

    mov rsi, rsp
    add rsi, 24
    mov rsi, [rsi]
    mov rdi, nb2
    mov rcx, 4
    rep movsb

    mov rsi, rsp
    add rsi, 32
    mov rsi, [rsi]
    mov rdi, nb3
    mov rcx, 4
    rep movsb

    mov byte [signNb1], 0
    mov byte [signNb2], 0
    mov byte [signNb3], 0

    xor rdi, rdi
    mov r8, 0

sign1:
    mov al, [nb1 + rdi]
    cmp al, '-'
    je ._negative
    jne convert1
    ._negative:
        mov byte [signNb1], 1
        inc rdi
        jmp convert1
    
convert1:
    mov al, [nb1 + rdi]
    cmp al, 0
    je done1
    cmp rax, '0'
    jl _error
    cmp rax, '9'
    jg _error
    sub rax, 48
    imul r8, 10
    add r8, rax
    inc rdi
    jmp convert1

done1:
    xor rdi, rdi
    mov r9, 0

sign2:
    mov al, [nb2]
    cmp al, '-'
    je ._negative
    jne convert2
    ._negative:
        inc rdi
        mov byte [signNb2], 1
        jmp convert2
 
convert2:
    mov al, [nb2 + rdi]
    cmp rax, 0
    je done2
    cmp rax, '0'
    jl _error
    cmp rax, '9'
    jg _error
    sub rax, 48
    imul r9, 10
    add r9, rax
    inc rdi
    jmp convert2

done2:
    xor rdi, rdi
    mov r10, 0

sign3:
    mov al, [nb3]
    cmp al, '-'
    je ._negative
    jne convert3
    ._negative:
        inc rdi
        mov byte [signNb3], 1
        jmp convert3
convert3:
    mov al, [nb3 + rdi]
    cmp rax, 0
    je done3
    cmp rax, '0'
    jl _error
    cmp rax, '9'
    jg _error
    sub rax, 48
    imul r10, 10
    add r10, rax
    inc rdi
    jmp convert3

done3:
    mov r11, 0
    
._nb1:
    mov al, [signNb1]
    cmp al, 1
    je ._nb1IsNeg
    jne ._nb2
    ._nb1IsNeg:
        inc r11

._nb2:
    mov al, [signNb2]
    cmp al, 1
    je ._nb2IsNeg
    jne ._nb3
    ._nb2IsNeg:
        inc r11

._nb3:
    mov al, [signNb2]
    cmp al, 1
    je ._nb3IsNeg
    jmp ._diffPosNeg
    ._nb3IsNeg:
        inc r11

._diffPosNeg:
    cmp r11, 3
    je ._negatives
    cmp r11, 0
    je ._positives
    ._check1:
        mov al, [signNb1]
        cmp al, 1
        je ._nb1Neg
        jne ._check2
        ._nb1Neg:
            mov r8, 0
        ._check2:
            mov bl, [signNb2]
            cmp bl, 1
            je ._nb2Neg
            jne ._check3
            ._nb2Neg:
                mov r9, 0
        ._check3:
            mov cl, [signNb3]
            cmp cl, 1
            je ._nb3Neg
            jne ._positives
            ._nb3Neg:
                mov r10, 0

._positives:
    cmp r8, r9
    ja ._nb1GreaterPos
    jb ._nb2GreaterPos
    ._nb1GreaterPos:
        cmp r8, r10
        jb ._nb3GreaterPos
        mov rax, r8
        mov rcx, 0
        call std__to_string
        jmp _exit
    ._nb2GreaterPos:
        cmp r9, r10
        jb ._nb3GreaterPos
        mov rax, r9
        mov rcx, 0
        call std__to_string
        jmp _exit
    ._nb3GreaterPos:
        mov rax, r10
        mov rcx, 0
        call std__to_string
        jmp _exit
    
._negatives:
    cmp r8, r9
    jb ._nb1GreaterNeg
    ja ._nb2GreaterNeg
    ._nb1GreaterNeg:
        cmp r8, r10
        ja ._nb3GreaterNeg
        mov rax, r8
        mov rcx, 1
        call std__to_string
        jmp _exit
    ._nb2GreaterNeg:
        cmp r9, r10
        ja ._nb3GreaterNeg
        mov rax, r9
        mov rcx, 1
        call std__to_string
        jmp _exit
    ._nb3GreaterNeg:
        mov rax, r10
        mov rcx, 1
        call std__to_string
        jmp _exit

_exit:
    mov rax, 1
    mov rdi, 1
    syscall
    mov rax, 60
    mov rdi, 0
    syscall

_error:
    mov rax, 1
    mov rdi, 1
    mov rsi, help
    mov rdx, help.lenHelp
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, usage
    mov rdx, usage.lenUsage
    syscall
    mov rax, 60
    mov rdi, 1 
    syscall

std__to_string:
    push rsi
    push rax
    cmp rcx, 1
    jne .no_sign
    mov byte [rsi], '-'
    inc rsi
    mov rdi, 2
    jmp .continue
.no_sign:
    mov rdi, 1
.continue:
    mov rcx, 1
    mov rbx, 10
    .get_divisor:
        xor rdx, rdx
        div rbx
        cmp rax, 0
        je ._after
        imul rcx, 10
        inc rdi
        jmp .get_divisor
    ._after:
        pop rax
        push rdi
    .to_string:
        xor rdx, rdx
        div rcx
        add al, '0'
        mov [rsi], al
        inc rsi
        push rdx
        xor rdx, rdx
        mov rax, rcx
        mov rbx, 10
        div rbx
        mov rcx, rax
        pop rax
        cmp rcx, 0
        jg .to_string
    mov byte [rsi + rdx], 0
    pop rdx
    pop rsi
    ret
