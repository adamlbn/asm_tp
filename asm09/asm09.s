global _start

section .bss
    nb resb 32
    string resb 32

section .text
_start:
    mov r13, [rsp]
    cmp r13, 0x2
    jne error

    mov rsi, rsp
    add rsi, 16
    mov rsi, [rsi]
    mov rdi, nb
    mov rcx, 4
    rep movsb

    xor rdi, rdi
    mov r8, 0

convertToHexa:
    mov al, [nb + rdi]
    cmp al, 0
    je finishConvert

    cmp rax, '0'
    jl error

    cmp rax, '9'
    jg error

    sub rax, 48
    imul r8, 10
    add r8, rax

    inc rdi
    jmp convertToHexa

finishConvert:
    mov rax, r8
    mov rcx, 16
    xor rdi, rdi
    mov rdi, string

loop:
    xor rdx, rdx
    div rcx
    push rdx
    inc r10
    cmp rax, 0
    je finish

    jmp loop

finish:
    xor rdi, rdi
    mov rdi, string

addString:
    pop r11
    cmp r11, 10
    jb ._decimal
    jae ._ascii

    ._decimal:
        add r11, '0'
        jmp ._store
    ._ascii:
        add r11, 87
        jmp ._store
    ._store:
      mov [rdi], r11
      inc rdi
      dec r10
      cmp r10, 0
      je _end
      jmp addString

_end:
    mov byte [rdi], 10

    mov rsi, string
    mov rax, 1
    mov rdi, 1
    syscall

    mov rax, 60
    mov rdi, 0
    syscall

error:
    mov rax, 60
    mov rdi, 1
    syscall
