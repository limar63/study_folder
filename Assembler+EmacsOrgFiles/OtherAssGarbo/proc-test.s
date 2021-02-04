
.data
message:
    .ascii "Hello, world!\n"      #ascii is troed on print_fun label memory location
    .set len, . - message         #len is stored in assembler memory

    .text

print_fun:
    #write(1, message, len)
    mov $1, %rax                  #1 in rax calls write during syscall
    mov $1, %rdi                  #1 in rdi calls stdout during syscall
    mov $message, %rsi            #putting message value (because with $) text inside rsi to write it
    mov $len, %rdx                #putting len value to set amount of bytes to print
    syscall
    ret
exit_fun:
    #exit(0)
    mov $60, %rax                 #60 calls exit during syscall
    xor %rdi, %rdi                #puts xor + reg = 0 in reg. We put 0 inside rdi this way
    syscall
    ret

    .global _start
_start:
    call print_fun
    call exit_fun
