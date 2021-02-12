    .data
linked_space:                                                                           #space reserved for linked list nodes
    .space 0x3000

list_head:                                                                              #default list_head value
    .quad 0x0
    .quad 0x0

opening_bracket:                                                                        #part of printing function construct
    .ascii "["

straight_line:                                                                          #part of printing function construct
    .ascii "|"

closing_part:                                                                           #part of printing function construct
    .ascii "] -> "

last_part:                                                                              #part of printing function construct, representing empty "first" node
    .ascii "[empty|node]\n"

cut_error_text:
    .ascii "Error: can't cut a core node\n"

    .global _start

    .text





add_head:                                                                               #function which adds new element as head and makes a link to a previous head element
    mov list_head(%rip), %rax                                                           #moving contents of a label (link to a head node) to a register
    add $16, %rax                                                                       #Moving the link to a point where a new node will start (1 node is 16 bytes)
    mov %rbx, (%rax)                                                                    #Putting a value which we want to hold in new node inside the value address of a new head node
    add $8, %rax                                                                        #Moving address inside register by 8 to put a link to a previous head
    mov list_head(%rip), %rdx                                                           #Moving old head address to an %rdx to put it then inside new head
    mov %rdx, (%rax)                                                                    #Putting link of the old head inside a node of a new head
    add $16, list_head(%rip)                                                            #Changing label which points to the head element to the new node we created
    retq

cut_head:                                                                               #Function which cuts the head by shifting the label 16 bytes back, with exception check to avoid touching core node
    mov list_head(%rip), %rax                                                           #Putting link of the current head element which we will cut away
    add $8, %rax                                                                        #Getting a link to a previous element to check if it's 0x0, which means it's a core node
    cmp $0, (%rax)                                                                      #Comparing it to 0
    je cut_error                                                                        #Jumping to error version of the cut if it's equal
    sub $24, %rax                                                                       #Moving to the beginning of the previous element, 16 bytes + 8 after previous add 8
    mov %rax, list_head(%rip)                                                           #Moving new link to a head label
    retq

cut_error:                                                                              #Function which prints error text and avoid cutting the core element
    mov $1, %rax                                                                        #Printing error text
    mov $1, %rdi
    lea cut_error_text(%rip), %rsi
    mov $29, %rdx
    syscall
    retq

pre_print:                                                                              #Intro for print to put first head element, to avoid issues with loop shenanigans
    push list_head(%rip)
    jmp print_node                                                                      #Moving to main print function

print_node:                                                                             #Function which takes functions from printing code and prints linked list visually
    pop %rbx                                                                            #Putting stored link to node value into %rbx
    push %rbx                                                                           #Pushing back to a stack a link to avoid mutations of a link after working with %rbx
    add $8, %rbx                                                                        #Moving link to the address part of the node with address to a previous list
    mov (%rbx), %rax                                                                    #Putting actual address to the previous node to check if it's 0x0, which means, it's a first empty node
    cmp $0, %rax                                                                        #Comparing link inside %rax to 0
    je return_printing                                                                  #If it's zero - moving to final part of the print, where first empty node is printed with \n char
    mov $1, %rax                                                                        #Printing opening bracket
    mov $1, %rdi
    lea opening_bracket(%rip), %rsi
    mov $1, %rdx
    syscall
    pop %rbx                                                                            #Getting link to the value field of the current node
    mov (%rbx), %r8                                                                     #Moving it to %r8, which is register which will contain numeric value for future printing
    push %rbx                                                                           #Saving link stored inside %rbx because %rbx will be used in printing functions
    call optimizing                                                                     #Printing routine consists of 3 functions which need to be called from printing part of the program
    call parse_intro
    call time_to_print
    mov $1, %rax                                                                        #Printing straight line to separate value from link
    mov $1, %rdi
    lea straight_line(%rip), %rsi
    mov $1, %rdx
    syscall
    pop %rbx                                                                            #Putting link back from stack again in rbx
    push %rbx                                                                           #Storing the link before mutating it again
    add $8, %rbx                                                                        #Changing link to the address which has link to the previous element
    mov (%rbx), %r8                                                                     #Moving link to %r8 to print it
    call optimizing                                                                     #Launching a print routine
    call parse_intro
    call time_to_print
    mov $1, %rax                                                                        #Printing closing part of the node "construct"
    mov $1, %rdi
    lea closing_part(%rip), %rsi
    mov $5, %rdx
    syscall
    pop %rbx                                                                            #Popping link of the printed node to shift it 16 bytes back to move to the previous node
    sub $16, %rbx                                                                       #Moving to the previous node
    push %rbx                                                                           #Putting link to the previous node inside stack to use it later
    jmp print_node                                                                      #Looping back to print_node

return_printing:                                                                        #Finalizing function which will print the first empty node and \n char
    mov $1, %rax
    mov $1, %rdi
    lea last_part(%rip), %rsi
    mov $13, %rdx
    syscall
    pop %rbx                                                                            #Since we didn't pop the stored value in loop body, we need to get rid of it from stack to jump back to _start
    retq

list_initialization:
    lea linked_space(%rip), %rax                                                        #initializing first node, it already has 0x0 as value and it's needed to put on the space for the linked list
    mov %rax, list_head(%rip)                                                           #Putting link to the list_head, which currently containts the first node value/link 0x0, on the linked_space
    retq

_start:
    call list_initialization


    #call pre_print                                                                      #Function which prints the linked list
    #mov $1, %rbx                                                                        #%rbx will hold value which will be put inside new linked list node
    #call add_head                                                                       #Function which adds new node as head element
    #call pre_print
    #mov $2, %rbx
    #call add_head
    #call pre_print
    #mov $3, %rbx
    #call add_head
    #call pre_print
    #call cut_head                                                                       #Function which cuts head element and moves link to a previous element
    #call pre_print
    #call cut_head
    #call pre_print
    #call cut_head
    #call pre_print
    #call cut_head
    #call pre_print

    mov $60, %rax                                                                       #Exiting from a program
    xor %rdi, %rdi
    syscall
