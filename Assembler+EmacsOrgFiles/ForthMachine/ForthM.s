    .macro NEXT
    lodsq                                               #lodsq reads from memory, pointed by address inside %rsi and puts it in %rax, after which %rsi is incremented by 8
    jmp *(%rax)
    .endm

    .macro PUSHRSP reg
    lea -8(%rbp), %rbp                                  #Decrement of %rbp by 8
    movq \reg, (%rbp)                                   #Push "reg" to a stack of return
    .endm

    .macro POPRSP reg
    movq (%rbp), \reg                                   #popping the highest stack element to reg
    lea 8(%rbp), %rbp                                   #incrementing %rbp by 8
    .endm

    .data

    .set link, (%rip)

    .macro  defword name, namelen, flags=0, label       #macro for forth words
    .section .rodata
    .align 8
    .global name_\label
    name_\label :
    .quad link(%rip)
    .set link, name_\label(%rip)
    .byte \flags+\namelen
    .ascii "\name"
    .align 8
    .global \label
    \label :
    .quad DOCOL(%rip)                                   #codeword
    #next will be put previously defined words to make a new word. They should be added when macro is called
    .endm

    .macro defcode name, namelen, flags=0, label        #macro for forth words written on assembly
    .section .rodata
    .align 8
    .global name_\label
    name_\label :
    .quad link(%rip)
    .set link, name_\label(%rip)
    .byte \flags+\namelen
    .ascii "\name"
    .align 8
    .global \label
    \label :
    .quad code_\label                                   #codeword
    .text
    .global code_\label
    code_\label :
    #assembly code should be written here for the embedded forth word will be here when macro is called
    .endm


return_stack:
    .space 3000

return_stack_tail:

    .global _start

    .text

DOCOL:
    PUSHRSP %rsi                                        #saving %rsi, which pointed to the next action before going into deeper function call, in the return stack to return to it when we are done
    leaq 8(%rax), %rsi                                  #%rax points to a codeword and we are doing %rax + 8 to point the the first argument in param list of the called function and put it in new %rsi
    NEXT                                                #Functions move around by %rsi/%rax registers, so, we don't need a retq

_start:
    lea return_stack_tail(%rip), %rbp
    mov $0x0, %rax
    PUSHRSP %rax
    mov $0x1, %rax
    PUSHRSP %rax
    mov $0x2, %rax
    PUSHRSP %rax
    mov $0x0, %rax
    POPRSP %rax
    POPRSP %rax
    POPRSP %rax


    mov $60, %rax                                       #Exiting from a program
    xor %rdi, %rdi
    syscall
