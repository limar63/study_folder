    .data
premsg:
    .ascii "0x"                                     #to make the number have distinct x16 look when printed, this will be used as a prefix before a number

msg:                                                #placeholder msg label, reserved memory will be used to store parsed number
    .space 16                                       #16 bytes for 32 ascii numbers

nextline:
    .ascii "\n"                                     #switching to the next line after 16 ascii numbers

var1:
    .quad 0x00000000000ef12b                        #number which will be parsed

    .global parse_intro
    .global optimizing
    .global time_to_print

    .text

parse_intro:
                                                    #binary mask for cutting smallest 4 bits (single number) from the 8 byte number
    mov $0b0000000000000000000000000000000000000000000000000000000000001111, %r9
    mov $0x1, %rbx                                  #multiplier that will be used to shift from first 4 bits to proper position in the ascii number
    mov $0x0, %r12                                  #register that will hold first half of the reversed number
    mov $0x0, %r14                                  #register that will hold second half of the reversed number
    jmp parse_start

parse_start:                                        #main body of the parsing number to ascii procedure
    mov %r8, %rax                                   #making a copy of a number before shifting it
    shr $4, %r8                                     #shifting original number to 4 numbers right to go to the next number on the next step
    and %r9, %rax                                   #taking last 4 bits from a number
    cmp $0xa, %rax                                  #checking if a number is smaller than 0xa
    jl zero_to_9                                    #jumping to do +30 procedure if it's not x16 numeric symbol

    add $0x57, %rax                                 #adding 57 because to change a number to ascii number from a to f you need to add x16 57
    mul %rbx
    mul %rbx                                        #we multiplying it twice because we go from 8 bytes to 16 bytes
    add %rax, %r12                                  #adding summed with 30 and increased twice by rbx coefficient piece of initial number to the previous pieces of a number to put it together in ascii
    shl $4, %rbx                                    #shifting rbx 4 bits to the left to increase it by mul 10 without rax shenanigans
    jmp check_for_overflow                          #going to overflow check after adding 8 bytes to %r12


zero_to_9:                                          #function to change from bit number to ascii number
    add $0x30, %rax                                 #adding 30 because to change a number to ascii number from 0 to 9 you need to add x16 30
    mul %rbx
    mul %rbx                                        #we multiplying it twice because we go from 8 bytes to 16 bytes
    add %rax, %r12                                  #adding summed with 30 and increased twice by rbx coefficient piece of initial number to the previous pieces of a number to put it together in ascii
    shl $4, %rbx                                    #shifting rbx 4 bits to the left to increase it by mul 10 without rax shenanigans
    jmp check_for_overflow                          #going to overflow check after adding 8 bytes to %r12

check_for_overflow:                                 #function to store half of the value inside a second register, because it goes from 8 bytes to 16 bytes when parsed to ASCII
    mov $0x1000000000000000, %rax                   #value for overflow check
    cmp %rax, %r12                                  #checking if r12 is overflowed
    jle looping                                     #doing a loop to parse_start with retq if loop ends in case if %r12 is not going to get overflow
    cmp $0x1, %rcx                                  #checking if count is 1 and then
    je finishing                                    #Finishing to avoid moving %r12 to %r14 another time
    mov %r12, %r14                                  #moving %r12 value to store in %r14
    xor %r12, %r12                                  #resetting %r12
    mov $0x1, %rbx                                  #resetting rbx to start from the first position
    jmp looping                                     #doing a loop to parse_start with retq if loop ends


looping:
    loop parse_start
    retq                                            #exiting back to start if loops ends, otherwise back to parse_start and decrementing %rcx

optimizing:
                                                    #binary mask for cutting lower 4 bytes out in optimization routine
    mov $0b1111111111111111111111111111111100000000000000000000000000000000, %rbx

    mov $16, %rcx                                   #the counter
    movq %r8, %rax                                  #moving the initial number value to accumulator register %rax
    andq %rbx, %rax                                 #leaving only first 32 not as 0 to check if biggest part of the number is full of 0 or not
    cmp $0, %rax                                    #checking if number is full of 0
    jne finishing                                   #first (from the left) 32 bits aren't full of 0 so we can't ignore them
    subq $8, %rcx                                   #second half of a number is full of 0, so we can only count from 8 instead of 16
    retq                                            #returning to _start

finishing:
    retq                                            #little function to jump return

time_to_print:
    mov $0b1111111100000000000000000000000000000000000000000000000000000000, %r9
    cmp $0, %r14                                    #checking if we skipped 4 bytes because original had zeroes in the biggest part of the number
    je skipped_bytes                                #jumping to function that will swap r14 and r12, so that lower part is kept in r14 and r12 is full of zeroes (0x30 in ASCII)
    mov $56, %rcx                                   #making a counter which would stop the jump loop which would also work as a shift left value
    call byte_fun                                   #calling the reversing procedure
    mov %r14, %r12                                  #moving second half of the number to r12
    mov %rax, %r14                                  #storing first half of the number from the accumulator having the value after completing byte_fun to %r14
    mov $56, %rcx                                   #we are putting 56 and not 64 because the last step will be made after the loop to avoid additional actions
    call byte_fun                                   #reversing the second half of a number
    mov %rax, %r12                                  #moving stored second half of the number to the different register
    lea msg(%rip), %rax                             #storing the address of the msg inside %rax
    mov %r14, (%rax)                                #Putting on the first half of the reserved memory by msg, linked to %rax through previous instruction, the first half of the number needed to display formatted to ascii saying mov value (rax) makes you move the value to the address stored in the register
    add $8, %rax                                    #adding 8 to address second half of the reserved memeory in msg
    mov %r12, (%rax)                                #putting second half of the reversed number to an address of the last 8 bytes resrved by msg
    mov $1, %rax                                    #putting 1 to %rax for printing syscall
    mov $1, %rdi                                    #puttin 1 to %rdi for printing syscall
    lea msg(%rip), %rsi                             #taking a position independent link to the msg label with numbers related to ascii data and putting it to a printing register %rsi
    mov $16, %rdx                                   #setting length of 16 bits (2 per 1 number) and 1 bit for newline \n char
    syscall                                         #syscalling the print with proper number
    retq                                            #returning to the _start body

byte_fun:                                           #start of the reverse function to save the entry point
    pop %rbp                                        #putting entry point to the %rbp register to succesfully return after few jumping back and forth
    jmp byte_reverse                                #jumping to the main body of the reverse function

byte_reverse:                                       #function which separates highest 2 bits from the reversed number and then shifts the reversed number by 8 bits (2 numbers) to the left and then switches 8 bits to their proper position and pushes them to a stack.
    mov %r12, %rax                                  #putting copy of the currently shifted reversed number to an accumulator register %rax
    shl $8, %r12                                    #shifting reversed number to the left for thenext loop cycle
    and %r9, %rax                                   #applying binary mask which will only leave 8 bytes (or 2 numbers)
    shr %cl, %rax                                   #shifting current 8 bits of a reversed number right, prior to %rcx count, to reverse their position
    push %rax                                       #pushing a shifted piece of a number to a stack
    sub $8, %rcx                                    #substracting 8 from count to represent shifting of the next 8 bits
    jne byte_reverse                                #if sub from %rcx not resulted in zero - we are looping
    push %r12                                       #pushing last 2 numbers of the reversed number, shifted to the left, as final piece of the reversed value, which will be accessed first from stack to start the reverse
    mov $8, %rcx                                    #switching count register to 8 for a future loop inside byte_back
    xor %rax, %rax                                  #cleaning up the accumulator to 0
    jmp byte_back                                   #jumping to a code which put 8 elements inside stack all together and puts them back to stack as a single entity

byte_back:                                          #function which summs elements in the stack to get the reversed version of the number
    pop %rbx                                        #poppint highest stack element to a register
    add %rbx, %rax                                  #adding the highest element to an accumulator
    loop byte_back                                  #decrementing the %rcx counter and starting at byte back again
    push %rbp                                       #we exited the loop and now putting the address of print procedure to top of the stack to get back to a procedure after calling the byte_fun
    retq                                            #returning to print procedure

skipped_bytes:                                      #function to avoid issues with printing when only 4 bytes of the original number were evaluated in parsing
    #I put this print of "0x" to avoid _start code because I want to use this program as a library
    mov $1, %rax                                    #putting 1 to %rax for print syscall
    mov $1, %rdi                                    #putting 1 to %rdi for print syscall
    lea premsg(%rip), %rsi                          #putting a link to "0x" ascii value to %rsi to print it
    mov $2, %rdx                                    #setting 2 bytes to display 2 characters
    syscall                                         #syscall for printing "0x"
    mov %r12, %r14                                  #moving first half of the reversed number to a register that will be pushed to a stack first, so it would be last when we get it back
    mov $0x3030303030303030, %r12                   #changing a second half or reversed number to ascii zeroes
    jmp time_to_print                               #we are ready to start printing procedure
