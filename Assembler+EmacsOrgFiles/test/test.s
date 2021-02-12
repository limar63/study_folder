

    .data

message:
    .ascii "Hola, mundo\n"            # asciz puts a 0 byte at the end

    .global main
    .text
main:                                   # This is called by C library's startup code
    mov     $message, %rdi          # First integer (or pointer) parameter in %rdi

    call printingf
    call    puts                    # puts(message)
    ret                             # Return to C library code

printingf:
    pop %rdi
    push %rdi
    sub $(printingf - message), %rdi
    ret
