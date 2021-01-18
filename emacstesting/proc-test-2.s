    .data
stack:
    .space 0x1001
stack_bottom:

msg:
    .space 16
    .ascii "\n"

var1:
    .quad 0xad24a45056ef1da8

message:
    .ascii "Privet\n"

len:
    .long . - message


    .global _start

    .text

parse_start:
    mov %r8, %rax
    and %rbx, %rax
    push %rax

    push %rax
    push %rdx
    mov $0xa, %rax

    mul %rdx
    mov %rax, %r15
    pop %rdx
    pop %rax
    cmp %r15, %rax
    #0-9
    jl zero_to_9
    #a-f
    mov $0x57, %rax
    push %rdx
    push %rdx
    mul %rdx
    pop %rdx
    mul %rdx
    pop %rdx
    mov %rax, %r11
    pop %rax
    push %rdx
    mul %rdx
    pop %rdx
    add %r11, %rax
    add %rax, %r12
    mov %rdx, %rax
    mul %r13
    mov %rax, %rdx
    dec %cl
    mov %rbx, %rax
    push %rdx #не пойму почему мне надо пришлось добавить, иначе %rdx затирается
    mul %r10
    pop %rdx
    mov %rax, %rbx
    inc %r9
    jne check_for_overflow
    jmp time_to_print



zero_to_9:
    mov $0x30, %rax
    push %rdx
    push %rdx
    mul %rdx
    pop %rdx
    mul %rdx
    pop %rdx
    mov %rax, %r11
    pop %rax
    push %rdx
    mul %rdx
    pop %rdx
    add %r11, %rax
    add %rax, %r12
    mov %rdx, %rax
    mul %r13
    mov %rax, %rdx
    dec %cl
    mov %rbx, %rax
    #push %r10
    push %rdx #не пойму почему мне надо пришлось добавить, иначе %rdx затирается
    mul %r10
    pop %rdx
    #pop %r10
    mov %rax, %rbx
    inc %r9
    jne check_for_overflow
    jmp time_to_print

check_for_overflow:
    mov $0x1000000000000000, %rax
    cmp %rax, %r12
    jle parse_start
    cmp $0x0, %cl
    je time_to_print
    mov %r12, %r14
    xor %r12, %r12
    shrq $32, %r8
    mov $0b1111, %rbx
    mov $0x1, %rdx
    jmp parse_start


optimizing:
    movq %r8, %rdx
    andq %rbx, %rdx
    cmp $0, %rdx
    #true
    jne finishing
    movb $8, %cl
    movl %r8d, %edx
    movl $0b11111111111111110000000000000000, %ebx
    andl %ebx, %edx
    cmp $0, %edx
    #true
    jne finishing
    movb $4, %cl
    movb %r8b, %dl
    cmp $0, %dl
    #true
    jne finishing
    movb $2, %cl
    cmp $0, %r8b
    jne finishing
    dec %cl
    ret
finishing:
    retq

time_to_print:
    lea msg(%rip), %rax
    mov %r14, (%rax)
    add $8, %rax
    mov %r12, (%rax)
    mov $1, %rax
    mov $1, %rdi
    lea msg(%rip), %rsi
    mov %r9, %rdx
    syscall
    retq

#byte_reverse:

    #retq


_start:
    mov $0b1111111111111111111111111111111100000000000000000000000000000000, %rbx #binary mask for cutting numbers out
    mov var1(%rip), %r8 #the number
    #andq %rbx, %rax
    mov $16, %cl #the counter
    mov $0b10000, %r10

    call optimizing
    mov $0b0000000000000000000000000000000000000000000000000000000000001111, %rbx
    mov $0x0, %r9
    mov $0x10, %r13
    mov $0x1, %rdx
    mov $0x0, %r12
    call parse_start
    mov $60, %rax
    xor %rdi, %rdi
    syscall
