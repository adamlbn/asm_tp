global _start 

section .data
    help: db "Convert a number to hex (-h) or binary (-b)", 10
    .lenHelp: equ $ - help
    usage: db "USAGE : ./asm09 [-b] NUMBER", 10
    .lenUsage: equ $ - usage

section .bss
    nb resb 32
    string resb 32
    conversion resb 1

section .text
_start:
    mov r13, [rsp]
    cmp r13, 2
    jl _error

    mov byte [conversion], 0

    mov rsi, rsp
    add rsi, 16
    mov rsi, [rsi]
    mov al, [rsi]
    cmp al, '-'
    jne ._getNumberDirect

    mov al, [rsi + 1]
    cmp al, 'b'
    je ._isBinary
    cmp al, 'h'
    je ._isHex
    jmp _error

._isBinary:
    mov byte [conversion], 1
    mov rsi, rsp
    add rsi, 24
    mov rsi, [rsi]
    jmp ._getNumber

._isHex:
    mov byte [conversion], 0
    mov rsi, rsp
    add rsi, 24
    mov rsi, [rsi]
    jmp ._getNumber

._getNumberDirect:
    mov rsi, rsp
    add rsi, 16
    mov rsi, [rsi]

._getNumber:
    mov rdi, nb
    mov rcx, 32
    rep movsb

    xor rdi, rdi
    mov r8, 0

convert:
    mov al, [nb + rdi]
    cmp al, 0
    je doneConvert

    cmp rax, '0'
    jl _error
    cmp rax, '9'
    jg _error

    sub rax, 48
    imul r8, 10
    add r8, rax
    
    inc rdi
    jmp convert

doneConvert:
    mov al, [conversion]
    cmp al, 0
    je ._convertHex
    jne ._convertBin

._convertHex:
    mov rcx, 16
    jmp ._choosen

._convertBin:
    mov rcx, 2

._choosen:
    mov rax, r8

loop:
    xor rdx, rdx
    div rcx
    push rdx
    inc r10
    cmp rax, 0
    je done

    jmp loop

done:
    mov r13, r10
    inc r13
    xor rdi, rdi
    mov rdi, string

addToString:
    pop r11
    cmp r11, 10
    jb ._dec
    jae ._ascii

._dec:
    add r11, '0'
    jmp ._store

._ascii:
    add r11, 55

._store:
    mov [rdi], r11
    inc rdi
    dec r10
    cmp r10, 0
    je _end
    jmp addToString

_end:
    mov byte [rdi], 0
    
    mov rsi, string
    mov rdi, 1
    mov rax, 1
    mov rdx, r13
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
