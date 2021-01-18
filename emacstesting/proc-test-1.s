
#Privet
    .data
#stack:
    #.space 0x1000
#stack_bottom:
    #.text
val1:
    .quad 0x000000000000000a

val2:
    .quad 0x000000000000000b

val3:
    .quad 0x000000000000000c

    .text

#plus_fun:
    #movq %rsp, %rax
    #addq 8(%rsp), %rax
    #addq %rax, 16(%rsp)
    #movq -16(%rsp), %rsp
    #ret

    .global _start
_start:
    #lea stack_bottom(%rip), %rsp

    #call plus_fun

    call my_func
    mov  $60, %rax
    xor  %rdi, %rdi
    syscall
my_func:
    lea val1(%rip), %rax
    movq (%rax), %rax
    pushq %rax
    movq (%rsp), %rdx
    lea val2(%rip), %rax
    movq (%rax), %rax
    pushq %rax
    movq (%rsp), %rdx
    lea val3(%rip), %rax
    movq (%rax), %rax
    pushq %rax
    movq (%rsp), %rdx
    xor %rax, %rax
    movq (%rsp), %rax
    addq 8(%rsp), %rax
    addq 16(%rsp), %rax
    movq %rax, %rsi
    popq %rbx
    popq %rbx
    popq %rbx
    retq
