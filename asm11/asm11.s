global _start

section .bss
    input resb 256
    output resb 12

section .data
    help: db "Return the number of vowels in the word passed as input", 10
    .lenHelp: equ $ - help

section .text
_start:
    mov rax, 0
    mov rdi, 0
    mov rsi, input
    mov rdx, 256
    syscall

    cmp rax, 0
    jle _exit

    xor rdi, rdi
    xor r8, r8

._code:
    mov al, [input + rdi]
    inc rdi
    cmp al, 10
    je ._end

    cmp al, 'a'
    je ._found
    cmp al, 'e'
    je ._found
    cmp al, 'i'
    je ._found
    cmp al, 'o'
    je ._found
    cmp al, 'u'
    je ._found
    cmp al, 'y'
    je ._found
    cmp al, 'A'
    je ._found
    cmp al, 'E'
    je ._found
    cmp al, 'I'
    je ._found
    cmp al, 'O'
    je ._found
    cmp al, 'U'
    je ._found
    cmp al, 'Y'
    je ._found
    jmp ._code

._found:
    inc r8
    jmp ._code

._end:
    mov rax, r8
    mov rsi, output
    call std__to_string

    mov byte [rsi + rdx], 10
    inc rdx

    mov rax, 1
    mov rdi, 1
    mov rsi, output
    syscall

_exit:
    mov rax, 60
    xor rdi, rdi
    syscall

std__to_string:
    push rsi
    push rax

    mov rdi, 1
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
