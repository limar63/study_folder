    .text
msg:
    .ascii "Hello, owrld!\n"
    .set len, . - msg

    .globl _start

_start:

    # write
    mov  $1,   %rax
    mov  $1,   %rdi

    call next

next:
    pop %rsi
    sub $(next - msg), %rsi

    mov  $len, %rdx
    syscall

    # exit
    mov  $60, %rax
    xor  %rdi, %rdi
    syscall
