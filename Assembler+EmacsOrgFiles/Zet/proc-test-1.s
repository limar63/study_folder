
#Privet
    .data
stack:
    .space 0x1000
stack_bottom:

val1:
    .long 10

val2:
    .long 20

val3:
    .long 30

    .text

#plus_fun:
    #movq %rsp, %rax
    #addq 8(%rsp), %rax
    #addq %rax, 16(%rsp)
    #movq -16(%rsp), %rsp
    #ret

    .global _start
_start:
    movq $stack_bottom, %rsp
    pushq $val1
    pushq $val2
    pushq $val3

    #call plus_fun

    mov $35, %rax
    mov  $60, %rax
    xor  %rdi, %rdi
    syscall
