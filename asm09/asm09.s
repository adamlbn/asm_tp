section .data
    hex_digits db "0123456789ABCDEF", 0
    bin_digits db "01", 0
    error_msg db "Error: Invalid input or arguments", 0xA
    error_msg_len equ $ - error_msg

section .bss
    num resq 1
    buffer resb 32

section .text
    global _start

_start:
    mov r13, [rsp]
    cmp r13, 2
    je .default_hex
    cmp r13, 3
    je .check_binary
    jmp .error

.check_binary:
    mov rsi, [rsp + 16]
    cmp byte [rsi], '-'
    jne .error
    cmp byte [rsi + 1], 'b'
    jne .error
    cmp byte [rsi + 2], 0
    jne .error

    mov rsi, [rsp + 24]
    call string_to_int
    cmp rax, -1
    je .error
    mov [num], rax

    mov rax, [num]
    mov rdi, buffer
    mov rcx, 2
    call int_to_string
    jmp .print_result

.default_hex:
    mov rsi, [rsp + 16]
    call string_to_int
    cmp rax, -1
    je .error
    mov [num], rax

    mov rax, [num]
    mov rdi, buffer
    mov rcx, 16
    call int_to_string

.print_result:
    mov rsi, buffer
    call print_string

    mov rax, 60
    xor rdi, rdi
    syscall

.error:
    mov rdi, 1
    mov rsi, error_msg
    mov rdx, error_msg_len
    mov rax, 1
    syscall

    mov rax, 60
    mov rdi, 1
    syscall


string_to_int:
    xor rax, rax
    xor rcx, rcx
    xor rbx, rbx
    movzx rdx, byte [rsi]
    cmp rdx, '-'
    jne .loop
    inc rsi
    mov rbx, 1
.loop:
    movzx rdx, byte [rsi + rcx]
    cmp rdx, 0
    je .end
    cmp rdx, '0'
    jl .invalid
    cmp rdx, '9'
    jg .invalid
    sub rdx, '0'
    imul rax, rax, 10
    add rax, rdx
    inc rcx
    jmp .loop
.end:
    test rbx, rbx
    jz .positive
    neg rax
.positive:
    ret
.invalid:
    mov rax, -1
    ret


int_to_string:
    mov rbx, rdi
    add rdi, 31
    mov byte [rdi], 0
    dec rdi
.convert_loop:
    xor rdx, rdx
    div rcx
    cmp rcx, 16
    je .hex_digit
    cmp rcx, 2
    je .bin_digit
.hex_digit:
    mov dl, [hex_digits + rdx]
    jmp .store_digit
.bin_digit:
    mov dl, [bin_digits + rdx]
.store_digit:
    mov [rdi], dl
    dec rdi
    test rax, rax
    jnz .convert_loop
    inc rdi
    ret


print_string:
    mov rdx, 0
.find_end:
    cmp byte [rsi + rdx], 0
    je .found_end
    inc rdx
    jmp .find_end
.found_end:
    mov rax, 1
    mov rdi, 1
    syscall
    ret
