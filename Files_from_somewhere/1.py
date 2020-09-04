from functools import reduce
#'(+ 1 2 (+ 2 3))'  -> ['+', 1, 2, ['+', 2, 3]]
#              parsing
             
             
 
#'(car (quote       (+ 42 13)))' -> ['(','car','(','quote','(','+','42','13',')',')',')']

#Exception class for custom exceptions 
class LispInterException(ValueError):pass 

#Closures - construction, that contain dictionary on the moment of creating a function and a function lambda expression, needed to avoid dynamic scope issues 
class Closures:
    def __init__(self, expression, dictionary):
        self.expression = expression
        self.dictionary = dictionary
 
#tokenizing an expression, making every single
def tokenize(line):
    #used to differ between 1 element formed by many letters and elements formed by 1 letter. After adding word_hodler to the list, it's set to '' value again
    word_holder = ''
    #resulting list
    tokens = []
    #going through the expression line
    for i in line:
        #check if it's a non spacebar separator
        if i == '(' or i == ')':
            #if none in word_holder we can just add parentheses to the resulting list
            if word_holder == '':
                tokens.append(i)
            #else we need to add word holder characters before adding the separator
            else:
                #adding what word_holder contains
                tokens.append(word_holder)
                #clearing word_holder
                word_holder = ''
                #adding parentheses to a token list
                tokens.append(i)
        #if we get a spacebar as a current character
        elif i == ' ':
            #if word_holder is not empty we need to add word_holder to the stack, since we got to the separator
            if word_holder != '':
                #adding what word_holder contains
                tokens.append(word_holder)
                #clearing word_holder
                word_holder = ''
        #not a separator so we just fill the word_holder
        else:
            #adding another character to word_holder list
            word_holder += i
    #we check that after getting to the end of the expression line word_holder is empty. If not - it should be added to the resulting list
    if word_holder != '':
        #adding what word_holder contains
        tokens.append(word_holder)
    #returning resulting list
    return tokens
 
 
#tokens: '(','42','(','13',')','666',')'
#stack: '(','42',['13']
 
#parsing the list of tokenized elements via stack method. Elements, closed by parentheses, will become nested lists
def parse(tokenized_array):
    #creating the resulting stack      
    stack = []
    #going through tokenized array that we got from previous function
    for i in tokenized_array:
        #if we get an element that is not closing parentheses
        if i != ')':
            #if it's a digit character
            if i.isdigit():
                #we append it to a stack as a digit, not a string, by parsing it to int
                stack.append(int(i))
            else:
                #we append it to stack, either it's a '(' or other characters, that is not a ')'
                stack.append(i)
        #we got the ')'
        else:
            #used to form a nested stack inside a stack, but we need to reverse it, because we make a stack by popping old one, and as a result, reversing elements
            placeholder_stack=[]
            #until we get to the closest opening '(', which means, that we got properly formed '(something)' construction, or until we run off the elements without getting to '(', which means, expression is wrong. Maybe, checking if stack is not empty isn't neccesary, but too lazy to check it right now
            while stack and stack[-1] != '(':
                #appending top element from stack and putting it in a placeholder
                placeholder_stack.append(stack.pop())
            #we check to avoid popping the empty list, which will result in crash
            if stack:
                #popping top element
                stack.pop()
            else:
                raise LispInterException("Exception: Missing opening skobochka")
            stack.append(placeholder_stack[::-1])
    return stack.pop()
 
 
def to_str(final_list, count, result): #making result look like lisp code
    if isinstance(final_list, Closures):
        final_list = final_list.expression
    if count == len(final_list):
        return result[:-1] + ') '
    else:
        if final_list[count] == '\'' or final_list[count] == ',':
            return to_str(final_list, count + 1, result)
        elif type(final_list[count]) == list:
            return to_str(final_list, count + 1, result + to_str(final_list[count], 0, '('))
        elif type(final_list[count]) == int:
            return to_str(final_list, count + 1, result + str(final_list[count]) + ' ')
        else:
            return to_str(final_list, count + 1, result + final_list[count] + ' ')
 
 
#embedded functions:
def plus_func(args):
    if not all(isinstance(x, int) for x in args):
            raise LispInterException("Exception: you can only use 'Summ' with int elements")
    else:
        return reduce(lambda x,y: x + y, args, 0)
 
def minus_func(args):
    if not all(isinstance(x, int) for x in args):
            raise LispInterException("Exception: you can only use 'Minus' with int elements")
    else:
        if len(args) == 1: #Lisp returns -x if it's (- x)
            return args[0] * -1
        else:
            return reduce(lambda x,y: x - y, args)
 
def multiply_func(args):
    if not all(isinstance(x, int) for x in args):
            raise LispInterException("Exception: you can only use 'Multiply' with int elements")
    else:
        return reduce(lambda x,y: x * y, args, 1)
 
def divide_func(args):
    if not all(isinstance(x, int) for x in args):
            raise LispInterException("Exception: you can only use 'Divide' with int elements")
    else:
        if len(procedure) == 1:
            return 'Error: You can\'t call eval for the empty division symbol'
        else:
            return reduce(lambda x,y: x / y, args)
 
def null_func(args):
    if not len(args) == 1:
            raise LispInterException("Exception: you can only use 'Null' with single argument")
    else:
        if type(args) == list and not args:
            return '#t'
        else:
            return '#f'
 
def equal_func(args):
    if not all(isinstance(x, int) for x in args):
            raise LispInterException("Exception: you can only use 'Equal' with int elements")
    else:
        for i in range(len(args) - 1):
            if args[i] != args[i + 1]:
                return '#f'
        return '#t'
 
def not_equal_func(args):
    if not all(isinstance(x, int) for x in args):
            raise LispInterException("Exception: you can only use 'Not equal' with int elements")
    else:
        for i in range(len(args) - 1):
            if args[i] == args[i + 1]:
                return '#f'
        return '#t'
 
def more_than_func(args):
    if not all(isinstance(x, int) for x in args):
            raise LispInterException("Exception: you can only use 'More than' with int elements")
    else:
        if not all(isinstance(x, int) for x in args):
            raise LispInterException("Exception: not int value in 'More than' function")
        for i in range(len(args) - 1):
            if not args[i] > args[i + 1]:
                return '#f'
        return '#t'
 
def less_than_func(args):
    if not all(isinstance(x, int) for x in args):
            raise LispInterException("Exception: you can only use 'Less than' with int elements")
    else:
        if not all(isinstance(x, int) for x in args):
            raise LispInterException("Exception: not int value in 'Less than' function")
        for i in range(len(args) - 1):
            if not args[i] < args[i + 1]:
                return '#f'
        return '#t'
 
def more_or_equal_func(args):
    if not all(isinstance(x, int) for x in args):
            raise LispInterException("Exception: you can only use 'More or equal than' with int elements")
    else:
        if not all(isinstance(x, int) for x in args):
            raise LispInterException("Exception: not int value in 'Equal or more than' function")
        if args[0] >= args[1]:
            return '#t'
        else:
            return '#f'
 
def less_or_equal_func(args):
    if not all(isinstance(x, int) for x in args):
            raise LispInterException("Exception: you can only use 'Less or equal than' with int elements")
    else:
        if not all(isinstance(x, int) for x in args):
            raise LispInterException("Exception: not int value in 'Equal or less than' function")
        if args[0] <= args[1]:
            return '#t'
        else:
            return '#f'
 
def cons_func(args):
    if len(args) != 2:
            raise LispInterException("Exception: wrong amount of args in 'cons' function")
    else:
        a = args[0]
        b = args[1]
        if type(b) != list:
            raise LispInterException("Exception: this intepreter can't handle pairs")
        else:
            return [a] + b
 
def car_func(args):
    return args[0][0]
   
def cdr_func(args):
    return args[0][1:]    
 
def list_func(args):
    return args
 
#namespaces
local_d = {}
 
#list of embedded functions added to the dictionary
basic_global = {
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
    'list' : list_func
    }
 
#global will do this trick every time we need to clear it
global_d = basic_global.copy()
 
#tracing for debugging
def tracing(function):
    def traced_function(*arguments):
        print(function.__name__, ' '.join(str(i) for i in arguments))
        result = function(*arguments)
        print('result for function ', function.__name__, ' '.join(str(i) for i in arguments), ' is ', result)
        return result
    return traced_function
       
def my_apply(procedure, arguments, global_d):
    print('ARGUMENTS ARE: ', arguments)
    print('PROCEDURE IS: ', procedure)
    if procedure in global_d:
        return global_d[procedure](arguments)
    elif isinstance(procedure, Closures): #making lambda expression ((lambda (params) (body)) params-value)
        #print('lambda func')
        print('closures is', procedure)
        local_d = procedure.dictionary
        actuals = [i for i in arguments]
        for i,j in enumerate(procedure.expression[1]):
            local_d[j] = actuals[i]
        return (my_eval(procedure.expression[2], global_d, local_d))
    else:
        raise LispInterException('Exception: you gave some bullshit to the interperter')
 
inbuilt_functions = ['+', '-', '*', '/', 'null', '=', '/=', '>', '<', '>=', '<=', 'cons', 'list', 'car', 'cdr', 'lambda']
 
                 
def my_eval(expr, global_d, local_d):
    if type(expr) == int: #displaying int number
        #print('displaying int')
        return expr
 
    elif expr == 'pseudoclear': #kinda clearing the terminal
        for i in range(50):
            print()
        return ''
 
    elif expr == '#t' or expr == '#f': #displaying true/false
        #print('displaying bool')
        return expr
   
    elif expr == 'global': #displaying global dict
        return global_d
 
    elif expr == 'clear-global': #Clearing global dict
        global_d = basic_global.copy()
        return 'global dictionary is cleared'
 
    elif expr == 'exit': #exit key
        exit('Exiting terminal')
 
    elif type(expr) == str: #Calling variable
        #print('looking for variable')
        if expr in basic_global:
            return expr
        if expr in local_d:
            return local_d[expr]
        elif expr in global_d:
            print('globald-expr is', global_d[expr])
            return global_d[expr]
        else:
            raise LispInterException('Exception: variable not defined')
 
    elif type(expr) == list and expr[0] == 'if': #if function
        #print('if func')
        if my_eval(expr[1], global_d, local_d) == '#t':
            return my_eval(expr[2], global_d, local_d)
        else:
            return my_eval(expr[3], global_d, local_d)
 
    elif type(expr) == list and expr[0] == 'quote': #quoting expression into list
        #print('quote  func')
        if len(expr) != 2:
            raise LispInterException('Exception: \'quote\' function can only work with 1 argument')
        return expr[1]
 
    elif type(expr) == list and expr[0] == 'let': #local namespace parallel (let ((var1 value1) (var2 value2)) body)
        #print('let func')
        local_d_new = local_d.copy() #переносим все предыдущие значения в новый дикт, так как надо изолировать дикт в параметрах подаваемый на данный шаг рекурсии и подаваемый на следующий шаг рекурсии
        for i in expr[1]: #Заполнение словаря новыми переменными из текущей итерации рекурсии
            local_d_new[i[0]] = my_eval(i[1], global_d, local_d)
        return my_eval(expr[2], global_d, local_d_new)
   
    elif type(expr) == list and expr[0] == 'let*': #local namespace one after another (let* ((var1 value1) (var2 value2)) body)
        #print('*let func')
        for i in expr[1]: #Создание новой копии словаря после каждого добавления переменной, чтобы в последующих шагах, если использовалась перезаданная переменная из прошлого шага, было использовано новое значение
            local_d = local_d.copy()
            local_d[i[0]] = my_eval(i[1], global_d, local_d)
        return my_eval(expr[2], global_d, local_d)

    elif type(expr) == list and expr[0] == 'letrec': #local namespace parallel (letrec ((var1 value1) (var2 value2)) body)
        #print('letrec func')
        local_d_new = local_d.copy() #переносим все предыдущие значения в новый дикт, так как надо изолировать дикт в параметрах подаваемый на данный шаг рекурсии и подаваемый на следующий шаг рекурсии
        for i in expr[1]: #Заполнение словаря новыми переменными из текущей итерации рекурсии
            local_d_new[i[0]] = my_eval(i[1], global_d, local_d)
        return my_eval(expr[2], global_d, local_d_new)
   
    elif type(expr) == list and expr[0] == 'lambda': #если подается (lambda (x) x)
        #print('single lambda func')
        closure = Closures(expr, local_d)
        print('creating class')
        return closure
 
    elif type(expr) == list and expr[0] == 'define':
        #print('define func')
        if type(expr[1]) == str: #для присваивания атому
            global_d[expr[1]] = my_eval(expr[2], global_d, local_d)
            return 'defined a variable'
        else: #Для присваивания функции
            if not all(isinstance(n, str) for n in expr[1]):
                raise LispInterException('Exception: define - not an identifier, identifier with default, or keyword for procedure argument')
            else:
                closure = Closures(['lambda', expr[1][1:], expr[2]], local_d)
                global_d[expr[1][0]] = closure
                return 'defined a function'
 
    else:
        return my_apply(my_eval(expr[0], global_d, local_d), [my_eval(i, global_d, local_d) for i in expr[1:]], global_d)
#        
 
 
#Прогнать парсинг с отладочной печатью
#Написать функцию самостоятельно перегона из стринга в инт, из инта в стринг
#Доделать всю арифметику, а также car cdr quote cons if
 
# REPL = Read Eval Print Loop
 
def repl():
    #global_d = {}
    while True:
        expr = input("MICRO-LISP: ")
        try:
            result = (my_eval(parse(tokenize(expr)), global_d, {}))
            if type(result) == int or type(result) == str or type(result) == dict:
                print(result)
            else:
                print(to_str(result, 0, '(')[:-1])
        except LispInterException as e:
            print (e)
       
repl()
 
#Добавить в необходимые места ексепшены (например, не хватает открывающейся скобки)
#Сделать Define
#Реализовать специальную конструкцию If, чтобы експрешион ((if (= 1 1) (lambda (x) (+ 1 x)) (lambda (y) (+ 2 y))) 42)   выполнялся (прописать myeval...)
#Реализовать интерпретатор без рекурсии