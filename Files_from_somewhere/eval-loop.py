from collections import namedtuple                                                                          #for that stack 'clink' register
from functools import reduce                                                                                #for the arithmetics
import pprint                                                                                               #for fancy display of the dictionary 
 
#**EXP** - The expression is currently being evaluated
 
#**ENV** - A pointer to the environment, in which to evaluate EXP
 
#**Clink** - a pointer to the frame for the computation of which the current one is a subcomputation.
#It holds all active registers
 
#**PC** - the “program counter”. As each “instruction” is executed, it updates **PC** to point to the next instruction to be executed.
#Values for our interpreter: Function name NAME, competing function DONE
 
#**VAL** - The returned value of a subcomputation. This register is not saved and restored in **CLINK** frames; in fact, it’s sole purpose is to pass values back safely across the restoration of a frame.
 
#**UNEVLIS** **EVLIS** - These are utility registers which are part of the state of the interpreter (they are saved in **CLINK** frames).
#They are used primarily for evaluation of components of combinations, but may be used for other purposes also
 
 
#**PC** functions
StackFrame = namedtuple('StackFrame', ['exp',  'unevlis', 'global_d', 'local_d', 'evlis',  'pc', 'clink'])  #Static tuple for saving/loading stack
 
class Closures:                                                                                             #Closures for lexic scope in lambdas
    def __init__(self, expression, dictionary):
        self.expression = expression                                                                        #expression of the lambda
        self.dictionary = dictionary                                                                        #local scope from the moment when lambda is created
 
def plus_func():                                                                                            #(+ arg ...)
    global pc, val
    #print('plus')                                                                                           #tracing plus func
    if not all(isinstance(x, int) for x in evlis):                                                          #check if all arguments are int
        pc = 'DONE'                                                                                         #instant exit from the eval loop
        val = "Exception: you can only use 'Summ' with int elements. If you need help - type help"          #Exception text
    else:
        val = reduce(lambda x,y: x + y, evlis, 0)                                                           #summing 0 with all elements in the evlis
        reg_load()                                                                                          #loading the stack lvl below with current val
 
def minus_func():                                                                                           #(- arg ...)
    global pc, val
    #print('minus')                                                                                          #tracing minus func
    if not all(isinstance(x, int) for x in evlis):
        pc = 'DONE'                                                                                         #instant exit from the eval loop
        val = "Exception: you can only use 'Minus' with int elements. If you need help - type help"         #Exception text
    elif len(evlis) == 1:                                                                                   #Lisp returns -x if it's (- x)
        val = evlis[0] * -1
        reg_load()                                                                                          #loading the stack lvl below with current val
    else:
        val = reduce(lambda x,y: x - y, evlis)                                                              #substracting from first element all other elements in the evlis
        reg_load()                                                                                          #loading the stack lvl below with current val
 
def multiply_func():                                                                                        #(* arg ...)
    global pc, val
    #print('multiply')                                                                                       #tracing multiply func
    if not all(isinstance(x, int) for x in evlis):
        pc = 'DONE'                                                                                         #instant exit from the eval loop
        val = "Exception: you can only use 'Multiply' with int elements. If you need help - type help"      #Exception text
    else:
        val = reduce(lambda x,y: x * y, evlis, 1)                                                           #multiplying 1 with all elements in the evlis
        reg_load()                                                                                          #loading the stack lvl below with current val
 
def divide_func():                                                                                          #(/ arg arg ...)
    global val, pc
    #print('dividing')                                                                                       #tracing divide func
    if not all(isinstance(x, int) for x in evlis):
        pc = 'DONE'                                                                                         #instant exit from the eval loop
        val = "Exception: you can only use 'Divide' with int elements. If you need help - type help"        #Exception text
    elif len(evlis) == 1:
        pc = 'DONE'                                                                                         #instant exit from the eval loop
        val = "Error: You can't call eval for the empty division symbol"                                    #Exception text
    else:
        val = int(reduce(lambda x,y: x / y, evlis))                                                         #dividing first elements with all others in the evlis
        reg_load()                                                                                          #loading the stack lvl below with current val
 
def null_func():                                                                                            #returns #t if argument is empty list (null (quote ())), otherwise #f (null arg)
    global val, pc
    #print('null')                                                                                           #tracing null func
    if not len(evlis) == 1:
        pc = 'DONE'                                                                                         #instant exit from the eval loop
        val = 'Exception: you can only use "Null" with single argument. If you need help - type help'       #Exception text
    else:
        if type(evlis[0]) == list and not evlis[0]:
            val = '#t'                                                                                      #returning #t as value
            reg_load()                                                                                      #loading the stack lvl below with current val
        else:
            val = '#f'                                                                                      #returning #f as value
            reg_load()                                                                                      #loading the stack lvl below with current val
 
def equal_func():                                                                                           #returns #t if all arguments are equal, otherwise #f (= arg ...)
    global val, pc
    #print('equal')                                                                                          #tracing equal func
    if not all(isinstance(x, int) for x in evlis):
        pc = 'DONE'                                                                                         #instant exit from the eval loop
        val = "Exception: you can only use 'Equal' with int elements. If you need help - type help"         #Exception text
    elif not evlis:
        pc = 'DONE'                                                                                         #instant exit from the eval loop
        val = "Exception: you can't use 'Equal' with no elements. If you need help - type help"             #Exception text
    else:
        val = '#t'                                                                                          #Val is equal by default unless we find unequal element        
        for i in range(0, len(evlis) - 1):                                                                  #we check current and the next element in each 'for', so, we need len - 1
            if not evlis[i] == evlis[i + 1]:                                                                #checking if current and the next element are not equal
                val = '#f'                                                                                  #if it's not equal - set val to #f and break the 'for' cycle
                break
        reg_load()                                                                                          #loading the stack lvl below with current val
 
def not_equal_func():                                                                                       #(\= arg ...)
    global val, pc
    #print('not equal')                                                                                      #tracing not_equal func
    if not all(isinstance(x, int) for x in evlis):
        pc = 'DONE'                                                                                         #instant exit from the eval loop
        val = "Exception: you can only use 'not Equal' with int elements. If you need help - type help"     #Exception text
    elif not evlis:
        pc = 'DONE'                                                                                         #instant exit from the eval loop
        val = "Exception: you can use 'Equal' with no elements. If you need help - type help"               #Exception text
    else:
        val = '#t'                                                                                          #Val is equal by default unless we find equal element        
        for i in range(0, len(evlis) - 1):                                                                  #we check current and the next element in each 'for', so, we need len - 1
            if not evlis[i] != evlis[i + 1]:                                                                #checking if current and the next element are equal
                val = '#f'                                                                                  #if it's equal - set val to #f and break the 'for' cycle
                break
        reg_load()                                                                                          #loading the stack lvl below with current val
 
def more_than_func():                                                                                       #(> arg ...)
    global val, pc
    #print('more than')                                                                                      #tracing more_than func
    if not all(isinstance(x, int) for x in evlis):
        pc = 'DONE'                                                                                         #instant exit from the eval loop
        val = "Exception: not int value in 'More than' function. If you need help - type help"              #Exception text
    elif not evlis:
        pc = 'DONE'                                                                                         #instant exit from the eval loop
        val = "Exception: you can use 'More than' with no elements. If you need help - type help"           #Exception text
    else:
        val = '#t'                                                                                          #val is #t by default unless we find element equal or bigger than the first one
        for i in range(1, len(evlis)):                                                                      #range starts from 1 because we take first element by default
            if not evlis[0] > evlis[i]:                                                                     #checking if the first element is not bigger than the current one
                val = '#f'                                                                                  #returning #f as val and breaking 'for' cycle
                break
        reg_load()                                                                                          #loading the stack lvl below with current val
 
def less_than_func():                                                                                       #(< arg ...)
    global pc, val
    #print('less than')                                                                                      #tracing less_than func
    if not all(isinstance(x, int) for x in evlis):
        pc = 'DONE'                                                                                         #instant exit from the eval loop
        val = "Exception: not int value in 'Less than than' function. If you need help - type help"         #Exception text
    elif not evlis:
        pc = 'DONE'                                                                                         #instant exit from the eval loop
        val = "Exception: you can use 'Less than' with no elements. If you need help - type help"           #Exception text
    else:
        val = '#t'                                                                                          #val is #t by default unless we find element equal or smaller than the first one
        for i in range(1, len(evlis)):                                                                      #range starts from 1 because we take first element by default
            if not evlis[0] < evlis[i]:                                                                     #checking if the first element is not smaller than the current one
                val = '#f'                                                                                  #returning #f as val and breaking 'for' cycle
                break
        reg_load()                                                                                          #loading the stack lvl below with current val
 
def more_or_equal_func():                                                                                   #(>= arg ...)
    global pc, val
    #print('more or equal than')                                                                             #tracing more_or_equal func
    if not all(isinstance(x, int) for x in evlis):
        pc = 'DONE'                                                                                         #instant exit from the eval loop
        val = "Exception: not int value in 'More or equal than' function. If you need help - type help"     #Exception text
    elif not evlis:
        pc = 'DONE'                                                                                         #instant exit from the eval loop
        val = "Exception: you can use 'More or equal than' with no elements. If you need help - type help"  #Exception text
    else:
        val = '#t'                                                                                          #val is #t by default unless we find element bigger than the first one
        for i in range(1, len(evlis)):                                                                      #range starts from 1 because we take first element by default
            if not evlis[0] >= evlis[i]:                                                                    #checking if the first element is not smaller than the current one
                val = '#f'                                                                                  #returning #f as val and breaking 'for' cycle
                break
        reg_load()                                                                                          #loading the stack lvl below with current val
 
def less_or_equal_func():                                                                                   #(<= arg ...)
    global pc, val
    #print('less or equal than')                                                                             #tracing less_or_equal func
    if not all(isinstance(x, int) for x in evlis):
        pc = 'DONE'                                                                                         #instant exit from the eval loop
        val = "Exception: not int value in 'Less or equal than' function. If you need help - type help"     #Exception text
    elif not evlis:
        pc = 'DONE'                                                                                         #instant exit from the eval loop
        val = "Exception: you can use 'Less or equal than' with no elements. If you need help - type help"  #Exception text
    else:
        val = '#t'                                                                                          #val is #t by default unless we find element smaller than the first one
        for i in range(1, len(evlis)):                                                                      #range starts from 1 because we take first element by default
            if not evlis[0] <= evlis[i]:                                                                    #checking if the first element is not bigger than the current one
                val = '#f'                                                                                  #returning #f as val and breaking 'for' cycle
                break
        reg_load()                                                                                          #loading the stack lvl below with current val
 
def cons_func():                                                                                            #(cons arg arg) making first argument into head of the second argument list (car + cdr)
    global pc, val
    #print('consing')                                                                                        #tracing cons func
    if len(evlis) != 2:                                                                                     #check if it's exactly 2 arguments
        pc = 'DONE'                                                                                         #instant exit from the eval loop
        val = "Exception: wrong amount of arguments in 'cons' function. If you need help - type help"       #Exception text
    else:  
        a = evlis[0]                                                                                        #first arg
        b = evlis[1]                                                                                        #second arg
        if type(b) != list:                                                                                 #check if second argument is not a list
            pc = 'DONE'                                                                                     #instant exit from the eval loop
            val = "Exception: this intepreter can't handle pairs. If you need help - type help"             #Exception text
        else:
            val = [a] + b                                                                                   #making a list with first arg as a head of the second arg
            reg_load()                                                                                      #loading the stack lvl below with current val
 
def car_func():                                                                                             #(car arg) - get first element of the arg
    global val
    #print('carring')                                                                                        #tracing car func
    if len(evlis) != 1:                                                                                     #check if it's exactly 1 argument
        pc = 'DONE'                                                                                         #instant exit from the eval loop
        val = "Exception: wrong amount of arguments in 'cons' function. If you need help - type help"       #Exception text
    else:
        val = evlis[0][0]                                                                                   #getting first element of the argument
        reg_load()                                                                                          #loading the stack lvl below with current val
   
def cdr_func():                                                                                             #(cdr arg) - get an arg without it's head element
    global val
    #print('cdrring')                                                                                        #tracing cdr func
    if len(evlis) != 1:                                                                                     #check if it's exactly 1 argument
        pc = 'DONE'                                                                                         #instant exit from the eval loop
        val = "Exception: wrong amount of arguments in 'cons' function. If you need help - type help"       #Exception text
    else:
        val = evlis[0][1:]                                                                                  #getting an argument without it's first element (head)
        reg_load()                                                                                          #loading the stack lvl below with current val
 
def list_func():                                                                                            #(list arg ...) - makes a list out of args
    global val
    #print('listing')                                                                                        #tracing list func
    val = evlis                                                                                             #getting evlis list as a result
    reg_load()                                                                                              #loading the stack lvl below with current val

def print_func():
    global val
    #print('printing')                                                                                       #tracing print
    print(evlis[0])
    val = 'nil'
    reg_load()

exp = None                                                                                                  #expression global variable
unevlis = []                                                                                                #unevaled arguments global variable
evlis = []                                                                                                  #evaled arguments global varaible
pc = None                                                                                                   #global variable that holds a link to the function, which should start on the next tick of the interpreter cycle
clink = None                                                                                                #because no higher frame available
val = None                                                                                                  #global variable, that is not getting saved in clink, holds value that will be returned by the end of interpreting
#global_pseudo_dict = 'Global scope is empty' #list for tracing arguments without embedded functions
block_d = {}
local_d = {}                                                                                                #dictionary for local variable
#dictionary that displays example of all embedded functions and special constructs
example_dictionary = {
    '+' : '(+ arg ...)',
    '-' : '(- arg ...)',
    '*' : '(* arg ...)',
    '/' : '(/ arg arg ...)',
    'null' : '#t if arg is empty list (null (quote ())), otherwise #f (null arg)',
    '=' : '(= arg ...) #t if all arg are equal, otherwise #f ',
    '/=' : '(\= arg ...) #t if all arg are not equal, otherwise #f ',
    '>' : '(> arg ...)',
    '<' : '(< arg ...)',
    '>=' : '(>= arg ...)',
    '<=' : '(<= arg ...)',
    'cons' : '(cons arg arg) making first arg into head of the second arg list, can also be explained as (car + cdr)',
    'car' : '(car arg) - get first element of the arg',
    'cdr' : '(cdr arg) - get an arg without it\'s head element',
    'list' : '(list arg ...) - makes a list out of evalled args',
    'quote' : '(quote arg) like list, but leaving arg as it is',
    'if' : '(if (predicate) (body_if_true) (body_if_false))',
    'cond' : '(cond (predicate arg) (predicate arg) ...) if no predicate is #t - return #f',
    'define' : '(define variable_name arg) or (define (function_name arg ...) body) both defining and redefining',
    'let' : "(let ((variable_name arg) ...) body) Local scope, which starts and ends inside (let) construct.  difference from let* is that all variables evalled in parallel (you can't have (let ((x 10)(y x)) body)",
    'let*' : "(let* ((variable_name arg) ...) body) Local scope, which starts and ends inside (let*) construct.  difference from let is that all variables evalled in order one by one (you can have (let ((x 10)(y x)) body)",
    'lambda' : '(lambda (variable_name ...) body) Returns closure object, which contains lambda expression and current local dictionary. If lambda is returned as final result - displays only expression of the closure without local dictionary.',
    'exit' : 'close the program, if you don\'t want to use cntrl+c',
    'global' : 'print what global dictionary contains right now',
    'global-clear' : 'clears global dictionary from custom variables and functions',
    'clear-input' : 'clears repl input screen',
    'help' : 'shows this dictionary again'} 
#dictionary with embedded functions
embedded_functions = {
    '+' : plus_func,
    '-' : minus_func,
    '*' : multiply_func,
    '/' : divide_func,
    'null' : null_func,
    '=' : equal_func,
    '/=' : not_equal_func,
    '>' : more_than_func,
    '<' : less_than_func,
    '>=' : more_or_equal_func,
    '<=' : less_or_equal_func,
    'cons' : cons_func,
    'car' : car_func,
    'cdr' : cdr_func,
    'list' : list_func,
    'print' : print_func
    } 
global_d = {}                                                                                               #global dictionary, that by default is equal to the embedded_functions dict
embedded_list = ['+', '-', '*', '/', 'null', '=', '/=', '<', '>', '<=', '>=', 'cons', 'list', 'car', 'cdr', 'print', '#t', '#f', 'nil'] #list of self-evalling expressions
def to_str(final_list, count, result):                                                                      #making result look like lisp code
    if count == 0:
        if isinstance(final_list, Closures):                                                                #if it's Closure - splitting it to expression only
            final_list = final_list.expression
        if not final_list:                                                                                  #displaying empty list
            return '())'
    if count == len(final_list):                                                                            #if it's an end of the list  - return the result with closing parentheses. Exiting case of the recursion
        return result[:-1] + ') '
    else:                                                                                                   #recursive case
        if final_list[count] == '\'' or final_list[count] == ',':                                           #getting rid of commas and quotes
            return to_str(final_list, count + 1, result)
        elif type(final_list[count]) == list:                                                               #If it's list - add new layer of the recursion
            return to_str(final_list, count + 1, result + to_str(final_list[count], 0, '('))
        elif type(final_list[count]) == int:                                                                #if it's int - change it to str and add to the result list
            return to_str(final_list, count + 1, result + str(final_list[count]) + ' ')
        else:                                                                                               #it's str, which means we need to add it to the result
            return to_str(final_list, count + 1, result + final_list[count] + ' ')
 
def tokenize(line):                                                                                         #tokenizing expression to separated elements
    word_holder = ''                                                                                        #used to differ between 1 element formed by many letters and elements formed by 1 letter. After adding word_hodler to the list, it's set to '' value again
    tokens = []                                                                                             #resulting list
    for i in line:
        if i == '(' or i == ')':
            if word_holder == '':                                                                           #if none in word_holder we can just add parentheses to the resulting list
                tokens.append(i)
            else:                                                                                           #if word_holder not empty, we first add word_hodler to the list, then parentheses
                tokens.append(word_holder)
                word_holder = ''
                tokens.append(i)
        elif i == ' ':                                                                                      #if current element is empty space
             if word_holder != '':                                                                          #if word_holder is not empty we just add word_holder
                tokens.append(word_holder)
                word_holder = ''
        else:
            word_holder += i                                                                                #adding another letter to the word holder, because other If's didn't work
    if word_holder != '':
        tokens.append(word_holder)
    return tokens
 
def parse(array):                                                                                           #via stack
    global pc, val
    stack = [] 
    count_open = 0
    count_closed = 0                                                                                        # for comparing amount of opened parentheses to closed ones
    for i in array:
        if i != ')':
            if i == '(':
                count_open = count_open + 1
            if i.isdigit():                                                                                 #adding int element to stack
                stack.append(int(i))
            else:                                                                                           #adding non int element as it is
                stack.append(i)
        else:
            count_closed = count_closed + 1
            resulting_list = []                                                                             #cleaning resulting list every time ')' is got
            while stack and stack[-1] != '(':                                                               #making a list out of elements in reversed order (because it's a stack) until opened parentheses
                resulting_list.append(stack.pop())
            if stack:                                                                                       #getting rid of potential opened parentheses
                stack.pop()
            stack.append(resulting_list[::-1])                                                              #adding proper python list to a stack instead of lisp expression
    if count_open != count_closed:
        pc = 'DONE'                                                                                         #instant exit from the eval loop
        val = "Exception: your parentheses are messed up. If you need help - type help"                     #Expression text
    else:
        return stack.pop()                                                                                  #Returning final result and at the same time cleaning stack

def my_eval():                                                                                              #Eval function
    #print('my_evalling')                                                                                    #tracing eval_function
    global val, pc, unevlis, evlis, exp, local_d, global_d, clink
    if type(exp) == int:                                                                                    #self-evalling int
        #print('selfevaling int')                                                                            #tracing int
        val = exp                                                                                           #giving exp as val for self-evalling
        reg_load()                                                                                          #loading the stack lvl below with current val
   
    elif exp == 'exit':                                                                                     #exit command
        exit('Exiting interpretator')                                                                       #exits the interpreter

    elif exp == 'help':                                                                                     #exit command
        val = example_dictionary                                                                            #dictionary explaining all the embedded functions
        pc = 'DONE'                                                                                         #instant exit from the eval loop
 
    elif exp == 'global':                                                                                   #displaying global dict
        val = global_d                                                                                      #val set to global dictionary, which contains all the embedded functions, global variables and custom functions
        pc = 'DONE'                                                                                         #instant exit from the eval loop

    elif exp == 'clear-input':                                                                              #clearing global dictionary via setting it's value to the copy of the embedded_functions dictionary
        for i in range(50):
            print('')
        val = 'cleared'
        pc = 'DONE'                                                                                         #instant exit from the eval loop

    elif exp == 'global-clear':                                                                             #clearing global dictionary via setting it's value to the copy of the embedded_functions dictionary
        global_d = {}
        val = 'global dictionary is cleared'                                                                #message after completing it's action
        pc = 'DONE'                                                                                         #instant exit from the eval loop
   
    elif type(exp) == str:                                                                                  #if it's string value (variable/embedded funcs)
        if exp in embedded_list:                                                                            #check if it's in embedded list and needs to be self-evaled
            #print('selfevaling embedded func')                                                              #tracing selfeval func
            val = exp                                                                                       #giving exp as val for self-evalling
            reg_load()                                                                                      #loading the stack lvl below with current val
        elif exp in local_d:
            #print('from local dict')                                                                        #tracing getting variable from local dictionary
            val = local_d[exp]
            reg_load()                                                                                      #loading the stack lvl below with current val
        elif exp in global_d:
            val = global_d[exp]
            reg_load()                                                                                      #loading the stack lvl below with current val
        else:
            val = "Exception: this string element doesn't exist in dictionaries. If you need help - type help" #message after completing it's action
            pc = 'DONE'                                                                                     #instant exit from the eval loop
 
    elif type(exp) == list or exp in global_d or exp in embedded_functions:
        if exp[0] == 'quote':                                                                               #(quote arg) like list, but without evalling arg
            #print('quoting')                                                                                #tracing quote function
            if len(exp) != 2:                                                                               #check if quote has only 1 argument + quote construct
                pc = 'DONE'                                                                                 #instant exit from the eval loop
                val = 'Exception: "quote" function can only work with 1 argument. If you need help - type help' #exception text
            else:
                val = exp[1]                                                                                #getting argument as a result
                reg_load()                                                                                  #loading the stack lvl below with current val
 
        elif exp[0] == 'define':                                                                            #define function #(define variable arg) or (define (function_name arg ...) body)
            #print('defining')                                                                               #tracing define
            if type(exp[1]) == str:                                                                         #checking if argument is a string element, so you are defining a variable
                #print('defining variable')                                                                  #tracing that it's a string element
                reg_save('define_var')                                                                      #saving before evalling needed element to return to a proper order
                exp = exp[2]                                                                                #evalling the value, that is to be defined to a value
                pc = 'my_eval'                                                                              #sending link to evaling new expression
            elif type(exp[1]) == list:                                                                      #defining a function
                if not all(isinstance(n, str) for n in exp[1]) or len(exp) != 3:                            #checking
                    val = 'Exception: your define is wrong. If you need help - type help'                   #exception text
                    pc = 'DONE'                                                                             #instant exit from the eval loop
                else:
                    #print('defining function')                                                              #defining function
                    closure = Closures(['lambda', exp[1][1:], exp[2]], local_d)                             #saving function as a lambda construction in closure. Lambda in expression field, local dictionary in dictionary field
                    global_d[exp[1][0]] = closure                                                           #adding function to a global dictionary
                    val = 'function defined!'                                                               #return message about defining a function
                    pc = 'DONE'                                                                             #instant exit from the eval loop
            else:
                val = 'Exception: define construction is incorrect. If you need help - type help'           #exception text
                pc = 'DONE'                                                                                 #instant exit from the eval loop
 
        elif exp[0] == 'if':                                                                                #if func (if (predicate)(body_if_true)(body_if_false))
            #print('iffing')                                                                                 #tracing if func
            if len(exp) != 4:
                val = 'Exception: your if construction is wrong. If you need help - type help'              #exception text
                pc = 'DONE'                                                                                 #instant exit from the eval loop
            else:
                reg_save('if_construction')                                                                 #saving with link to if construction func to eval expression before going for it
                exp = exp[1]                                                                                #eval the #t/#f element of if
                pc = 'my_eval'                                                                              #link to eval
   
        elif exp[0] == 'cond':                                                                              #cond func (cond (predicate arg) (predicate arg) ...)
            #print('conding')                                                                                #tracing cond function
            unevlis = exp[1:]                                                                               #putting everything except word 'cond' in list of unevalled arguments for further evalling
            pc = 'cond_construction'                                                                        #link to function that will interpreter cond construction
 
        elif exp[0] == 'let':                                                                               #let func (let ((id arg) ...) body) difference from let is that all variables evalled in parallel (you can't have (let ((x 10)(y x)) body)
            #print('letting')                                                                                #tracing let
            if len(exp) != 3:
                val = 'Exception: your let construction is wrong. If you need help - type help'             #exception text
                pc = 'DONE'                                                                                 #instant exit from the eval loop
            else:
                unevlis = exp[1]                                                                            #putting variable in unevalled list to eval later
                pc = 'let_construction'                                                                     #moving link to let construction function
 
        elif exp[0] == 'let*':                                                                              #let func (let* ((id arg) ...) body) difference from let is that all variables evalled one by one (you can have (let* ((x 10)(y x)) body)
            #print('letting asterix')                                                                        #tracing let with *
            if len(exp) != 3:
                val = 'Exception: your let* construction is wrong. If you need help - type help'            #exception text
                pc = 'DONE'                                                                                 #instant exit from the eval loop
            else:
                unevlis = exp[1]                                                                            #putting variable in unevalled list to eval later
                pc = 'let_asterix_construction'                                                             #moving link to let* construction function
 
        elif exp[0] == 'lambda':                                                                            #lambda func (lambda (arg) x)
            #print('lambding')                                                                               #tracing lambda
            closure = Closures(exp, local_d)                                                                 #creating closure object with expression and local dictionary element
            val = closure                                                                                   #making val as a closure to return closure vlaue
            reg_load()                                                                                      #loading the stack lvl below with current val

        elif exp[0] == 'begin':                                                                            
            #print('beginning')                                                                              
            unevlis = exp[1:]
            pc = 'begin_construct'

        elif exp[0] == 'block':                                                                                                                                                          
            block_d[exp[1]] = clink
            unevlis = exp[2:]
            pc = 'begin_construct' 

        elif exp[0] == 'return-from':                                                                                                                                                        
            #print('doing return', exp, unevlis, evlis)
            unevlis = exp[2]
            if block_d[exp[1]] in clink:                                                                            #checking if we didn't trying to exit from the block that doesn't exist
                clink = block_d[exp[1]]
                reg_save('reg_load')
                exp = exp[2]
                pc = 'my_eval'
            else:
                pc = 'DONE'                                                                                         #instant exit from the eval loop
                val = 'Exception: return-from doesn\'t exist inside block'                                              

        else:
            #print('smth else')                                                                              #tracing non special construction function
            pc = 'eval_arguments'                                                                           #link to evaling function
            unevlis = exp                                                                                   #putting full exp to determine which function it is and eval it
            evlis = []                                                                                      #clearing evlis before going to eval elements

    else:
        pc = 'DONE'                                                                                         #instant exit from the eval loop
        val = 'Exception: wrong expression element \"' + str(exp) + '\". If you need help - type help'      #exception text
 
def applying_procedure():                                                                                   #applying the procedure from the first element of evlis on the arguments (all other elements of evlis except first element)
    global evlis, pc, val, local_d, exp
    print('applying evlis:', evlis)
    if evlis:                                                                                               #check if evlis not empty
        first_element, evlis = evlis[0], evlis[1:]                                                          #getting first element to determine which function it and getting rid of first element
        if isinstance(first_element, Closures):                                                             #check if it's closure
            if not evlis:
                pc = 'DONE'                                                                                 #instant exit from the eval loop
                val = 'Exception: evlis is empty! If you need help - type help'                             #exception text
            else:
                local_d = first_element.dictionary                                                          #change local dictionary to the one, imported with closure to avoid dynamic scope issue
                for i, j in enumerate(first_element.expression[1]):                                         #making an eval list (pairs with number and element, number works to go index by index in evlis list from 0)
                    local_d[j] = evlis[i]                                                                   #adding element j (expression arguments) as key and evlis arguments as value for that key
                exp = first_element.expression[2]                                                           #getting body of the lambda as the expression to eval it up with current local dictionary values
                pc = 'my_eval'                                                                              #link to start evalling the lambda body
 
        elif first_element in embedded_functions:                                                                     #in case if first element is an key from global dictionary
            result = embedded_functions[first_element]                                                                #get result as value of an object from dictionary with first_element key
            if type(result) == int:                                                                         #returning int value
                val = result                                                                                #returning val as a result
                reg_load()                                                                                  #loading the stack lvl below with current val
            else:
                result()                                                                                    #since else means it's function without '()' - putting parentheses makes the function call
        else:
            pc = 'DONE'                                                                                     #instant exit from the eval loop
            val = "Exception: interpreter can't handle " + str(unevlis) + ' in evlis. If you need help - type help' #exception text
    else:                                                                                                   #evlis is empty
        pc = 'DONE'                                                                                         #instant exit from the eval loop
        val = 'Exception: evlis is empty! If you need help - type help'                                     #exception text
   
def eval_arguments():                                                                                       #going through evalling elements in unevlis
    #print('eval_arging')                                                                                    #tracing eval_args
    global pc, exp
    if not unevlis:                                                                                         #unevlis is empty aka everything that wasn't evalled now in evlis
        pc = 'applying_procedure'                                                                           #link to applying function in evlis
    else:                                                                                                   #still elements in unevlis
        reg_save('eval_arguments_continue')                                                                 #link to eval_arguments_continue function after reg_loading in my_eval, which adds evalled element from unevlis to evlis 
        exp = unevlis[0]                                                                                    #getting first element in unevlis to eval it up
        pc = 'my_eval'                                                                                      #link to start evalling current argument
   
#putting the result of evaluation on the list of evaluated expressions
def eval_arguments_continue():
    #print('eval_arg_conting')                                                                               #tracing eval_arg_continue
    global evlis, unevlis, pc
    evlis.append(val)                                                                                       #adding evalled argument to evlis
    unevlis = unevlis[1:]                                                                                   #changing unevlis to unevlis without head element (which already got evalled and added to evlis) without changing unevlis lists in memory, but creating new one
    pc = 'eval_arguments'                                                                                   #going back to eval_arguments to continue evalling arguments
 
 
def if_construction():                                                                                      #chooses which body should be evalled, depends on the result of the predicate
    #print('if_constructing')                                                                                #tracing of if_construction function 
    global exp, pc, val
    if val == '#t':                                                                                         #check if predicate result (after evaling it in my_eval section) is true
        exp = exp[2]                                                                                        #change exp to positive part of the if construction
        pc = 'my_eval'                                                                                      #evaling it up
    elif val == '#f':
        exp = exp[3]                                                                                        #change exp to negative part of the if construction
        pc = 'my_eval'                                                                                      #evaling it up
    else:
        val = 'Exception: predicate part of the if construction is wrong. If you need help - type help'     #exception text
        pc = 'DONE'                                                                                         #instant exit from the eval loop
 
def cond_construction():                                                                                    #checking if cond ran out of cond cases or goes for the next one to find out if it's #t
    #print('cond_construction')                                                                              #tracing cond construction
    global exp, pc, val
    if not unevlis:                                                                                         #if none cond actually worked #f should be returned
        val = '#f'                                                                                          #returning #f as a result
        reg_load()                                                                                          #loading the stack lvl below with current val
    else:
        reg_save('cond_continue')                                                                           #saving link to cond continue before evalling predicate of the current unevlis element
        exp = unevlis[0][0]                                                                                 #predicate is unevlis[0][0], argument is unevlis[0][1], exp is set to predicate to eval it up
        pc = 'my_eval'                                                                                      #link to eval
 
def cond_continue():                                                                                        #check if latest evalled predicate in cond was true
    #print('cond_continue')                                                                                  #tracing cond continue
    global exp, pc, unevlis
    if val == '#t':                                                                                         #if predicate got #t result
        exp = unevlis[0][1]                                                                                 #exp is set to predicate argument
        pc = 'my_eval'                                                                                      #link to eval to eval the predicate argument
    else:
        unevlis = unevlis[1:]                                                                               #changing unevlis to unevlis without head element (which already got checked, got false and no longer needed to be considered) without changing unevlis lists in memory, but creating new one
        pc = 'cond_construction'                                                                            #link to function to continue checking for a predicate

def begin_construct():
    #print('begin construct')
    global exp, pc, evlis, unevlis
    if len(unevlis) == 1:
        exp = unevlis[0]
        pc = 'my_eval'
    else:
        reg_save('begin_continue')
        exp = unevlis[0]
        pc = 'my_eval'

def begin_continue():
    global unevlis, pc
    print('begin continue')
    unevlis = unevlis[1:]
    pc = 'begin_construct'

def let_construction():                                                                                     #function that either continues evalling let variables or adds them all to local_d from evlis list and starts evalling let body, if all variables finished evalling process
    global exp, pc, local_d, evlis
    print('let construct')
    if not unevlis:                                                                                         #if all arguments got evalled
        local_d = local_d.copy()                                                                            #separating a link from previous local dictionary while saving it's value to change it without changing other local dicts
        while evlis:                                                                                        #going through evlis to add evalled elements to dictionary
            local_d[evlis[0][0]] = evlis[0][1]                                                              #adding variable name as key and argument as value
            evlis = evlis[1:]                                                                               #changing evlis to evlis without head element (which already got added to dictionary) without changing evlis lists in memory, but creating new one
        exp = exp[2]                                                                                        #set exp to let body to eval it up with added variable
        pc = 'my_eval'                                                                                      #link to eval the let body
    else:                                                                                                   #if there are still arguments to eval
        reg_save('let_continue')                                                                            #link to next step after evalling argument for a current variable
        exp = unevlis[0][1]                                                                                 #changing exp to current variable argument to eval it up
        pc = 'my_eval'                                                                                      #link to start evalling argument
 
def let_continue():                                                                                         #function that adds variable names and it's evalled value to the evlis list
    global unevlis, pc, evlis
    #print('let continue')
    evlis.append([unevlis[0][0], val])                                                                      #adding to evlis element, which contains variable name in unevlis[0][0] for a future key and val of the evalled argument as a value of this future key
    unevlis = unevlis[1:]                                                                                   #changing unevlis to unevlis without head element (which already got evalled and added to evlis) without changing unevlis lists in memory, but creating new one
    pc = 'let_construction'                                                                                 #link to return back to check if all variables are added to the evlis or there are still more
 
def let_asterix_construction():                                                                             #evals the body of the let* with available local dictionary if all variable were added to local_d, or goes for the next variable if there are still more
    #print('let_asterix_constructing')                                                                       #tracing let function which adds elements to local dictionary
    global exp, pc
    if not unevlis:                                                                                         #if all arguments got evalled
        exp = exp[2]                                                                                        #set exp to let body to eval it up with added variable
        pc = 'my_eval'                                                                                      #link to eval the let body
    else:                                                                                                   #if there are still arguments to eval
        reg_save('let_asterix_continue')                                                                    #link to next step after evalling argument for a current variable
        exp = unevlis[0][1]                                                                                 #changing exp to current variable argument to eval it up
        pc = 'my_eval'                                                                                      #link to start evalling argument
 
def let_asterix_continue():                                                                                 #adding variable name as a key and it's evalled value as key value to the local dictionary of the let*
    #print('lend_asterix_continue')                                                                          #tracing let* function which adds elements to local dictionary and updates local_d for the next variable in let*
    global local_d, unevlis, pc
    local_d = local_d.copy()                                                                                #separating a link from previous local dictionary while saving it's value to change it without changing other local dicts
    local_d[unevlis[0][0]] = val                                                                            #adding new variable to the list
    unevlis = unevlis[1:]                                                                                   #changing unevlis to unevlis without head element (which already got evalled and added to the dictionary) without changing unevlis lists in memory, but creating new one
    pc = 'let_asterix_construction'                                                                         #link to return back to check if all variable are added to the dictionary or there are still more
 
 
def define_var():                                                                                           #saving a variable to a global dictionary
    global global_d, val, pc
    print('defining_var')                                                                                   #tacing function for variable defining
    global_d[exp[1]] = val                                                                                  #adding variable with name in exp[1] as a key and value as val
    val = 'Variable ' + exp[1] + ' defined!'                                                                #message about adding a varaible to a global dictionary
    pc = 'DONE'                                                                                             #instant exit from the eval loop
 
#**CLINK** register saving
def reg_save(retag):                                                                                        #function to save current registers
    global clink, exp, unevlis, global_d, local_d, evlis 
    #print('reg_saving exp is', exp, unevlis, local_d, evlis, retag, clink)                                  #tracing save function
    clink = StackFrame(exp, unevlis, global_d, local_d, evlis, retag, clink)                                #saving named tuple clink (inside other clinks)

def return_load(label):                                                                                             
    global exp, unevlis, global_d, local_d, evlis, pc, clink
    #print('reg_loading pc', exp, unevlis, local_d, evlis, pc, clink)
    exp = block_d[label].exp
    unevlis = block_d[label].unevlis
    global_d = block_d[label].global_d
    local_d = block_d[label].local_d
    evlis = block_d[label].evlis
    pc = block_d[label].pc
    clink = block_d[label].clink

#**CLINK** register unpack
def reg_load():                                                                                             #function to load registers from previous save
    global exp, unevlis, global_d, local_d, evlis, pc, clink
    #print('reg_loading pc', exp, unevlis, local_d, evlis, pc, clink)                                                                                #tracing loading function
    exp = clink.exp                                                                                         #loading value of exp register from exp stored in clink
    unevlis = clink.unevlis                                                                                 #loading value of unevlis register from unevlis stored in clink
    global_d = clink.global_d                                                                               #loading value of global_d register from global_d stored in clink
    local_d = clink.local_d                                                                                 #loading value of local_d register from local_d stored in clink
    evlis = clink.evlis                                                                                     #loading value of evlis register from evlis stored in clink
    pc = clink.pc                                                                                           #loading value of pc register from pc stored in clink
    clink = clink.clink                                                                                     #loading value of clink register from clink stored in clink (if current layer is layer 0, the one that is getting loaded is layer 1 and this stored clink is layer 2)
 
def repl():                                                                                                 #Read eval print loop function
    global pc, exp, val#, global_pseudo_dict
    while True:                                                                                             #loop that is permanent untill exit is given or cntrl+c
        reg_save('DONE')                                                                                    #saving deepest layer of stack
        pc = 'my_eval'                                                                                      #link to start evalling expression, that is given by user and parsed to a value, recognizable by interpreter
        exp = parse(tokenize(input("MICRO-LOOPED-LISP: ")))                                                 #getting input from user with name marker, then tokenizing it to bits and prasing it to a python list
        #print('exp', exp, 'unevlis', unevlis, 'global_d', global_pseudo_dict,'local_d', local_d, 'evlis', evlis, 'pc', pc, 'val', val)
        while pc != 'DONE':                                                                                 #internal cycle is working until it gets PC value equal to 'DONE' by the next turn of the cycle
            globals()[pc]() #globals() is the function, that returns a dictionary with all built-in and created in this program available functions. 
                            #[pc] works as a key to return the name of the function by the register value and parentheses call the function of that name
            #global_key_list = list(global_d.keys())
            #if len(global_key_list) > 15:
                #global_pseudo_dict = {i : (global_d[i].expression if isinstance(global_d[i], Closures) else global_d[i]) for i in global_key_list[15:]}
            #print('exp', exp, 'unevlis', unevlis, 'global_d', global_pseudo_dict,'local_d', local_d, 'evlis', evlis, 'pc', pc, 'val', val)
        if type(val) == int or type(val) == str or type(val) == dict:                                       #check if it's self-evalled value that doesn't need to be processed with to_str function
            pprint.pprint(val)                                                                              #pprint to display global dictionary in a more readable version
        else:
            pprint.pprint(to_str(val, 0, '(')[:-1])                                                         #not really a big difference if it's print or pprint
        val = None                                                                                          #clearing val after completing the internal cycle
       
repl()
