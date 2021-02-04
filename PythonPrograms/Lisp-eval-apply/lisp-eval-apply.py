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
            #until we get to the closest opening '(', which means, that we got properly formed '(something)' construction, or until we run off the elements without getting to '(', which means, expression is wrong.
            while stack and stack[-1] != '(':
                #appending top element from stack and putting it in a placeholder
                x = stack.pop()
                placeholder_stack.append(x)
            #we check to avoid popping the empty list, which will result in crash
            if stack:
                #popping top element to get rid of '('
                stack.pop()
            #stack is empty and '(' was not found
            else:
                #raising a custom exception
                raise LispInterException("Exception: Missing opening skobochka")
            #appending a placeholder stack as a nested stack, while reversing it
            stack.append(placeholder_stack[::-1])
    #since in the end, we will get a resulting list inside a list/selfevalling element (because we get a list as an element because parentheses surround it, or self-evalling element which needs to be returned without list), so we need to pull the only element outside the list
    print(stack)
    return stack.pop()

#better idea will be to make this function a recursion, like I made it in Lua, but I am lazy to remake it right now
#changing a result of the interpreter into the proper string, using recursion
def to_str(final_list, count, result): #making result look like lisp code. Final list is a list that needs to be changed to a lisp-like line, count is used as index to go through list, result is a final list
    #Check if it's closure, if it is - we need only to care about expression part, not dictionary
    if isinstance(final_list, Closures):
        final_list = final_list.expression
    #check if we got to the end of the array
    if count == len(final_list):
        #we need to add ')' at the end to make it look like lisp list
        return result[:-1] + ') '
    #we didn't get to the end of list
    else:
        #check if we got to comma or quote to get rid of it
        if final_list[count] == '\'' or final_list[count] == ',':
            return to_str(final_list, count + 1, result)
        #If it's list - add new layer of the recursion
        elif type(final_list[count]) == list:
            return to_str(final_list, count + 1, result + to_str(final_list[count], 0, '('))
        #if it's int - change it to str and add to the result list
        elif type(final_list[count]) == int:
            return to_str(final_list, count + 1, result + str(final_list[count]) + ' ')
        #it's str, which means we need to add it to the result
        else:
            return to_str(final_list, count + 1, result + final_list[count] + ' ')
 
 
#embedded functions:

#(+ arg ...)
def plus_func(args):
    #check if all arguments are int
    if not all(isinstance(x, int) for x in args):
            #Raising exception because not every element is int text
            raise LispInterException("Exception: you can only use 'Summ' with int elements")
    #everything is int
    else:
        #summing 0 with all expression arguments
        return reduce(lambda x,y: x + y, args, 0)

#(- arg ...)
def minus_func(args):
    #check if all arguments are int
    if not all(isinstance(x, int) for x in args):
            #Raising exception because not every element is int text
            raise LispInterException("Exception: you can only use 'Minus' with int elements")
    #everything is int
    else:
        #check if it's only one argument
        if len(args) == 1: 
            #return negative version of the argument
            return args[0] * -1
        #more than 1 arguments
        else:
            #substracting from first element all other elements
            return reduce(lambda x,y: x - y, args)

#(* arg ...)
def multiply_func(args):
    #check if all arguments are int
    if not all(isinstance(x, int) for x in args):
            #Raising exception because not every element is int text
            raise LispInterException("Exception: you can only use 'Multiply' with int elements")
    #everything is int
    else:
        #multiplying 1 with all elements in the argument list
        return reduce(lambda x,y: x * y, args, 1)

#(/ argument arg ...)
def divide_func(args):
    #check if all arguments are int
    if not all(isinstance(x, int) for x in args):
            #Raising exception because not every element is int text
            raise LispInterException("Exception: you can only use 'Divide' with int elements")
    #everything is int
    else:
        #check if it's only one argument
        if len(args) == 1:
            #Raising exception because you can't use divide on single argument
            return 'Error: You can\'t call eval for the empty division symbol'
        else:
            #dividing first elements with all others in the argument list
            return int(reduce(lambda x,y: x / y, args))

#returns #t if argument is empty list (null (list)), otherwise #f (null arg) 
def null_func(args):
    #check if it's not only one argument
    if not len(args) == 1:
            #Raising exception because you can't use null on any amount of arguments that isn't 1
            raise LispInterException("Exception: you can only use 'Null' with single argument")
    #there is single argument
    else:
        #if it's empty list
        if not args[0]:
            return '#t'
        #anything else that is not empty list
        else:
            return '#f'

#returns #t if all arguments are equal, otherwise #f (= arg ...)
def equal_func(args):
    #we check that all arguments is int. If not:
    if not all(isinstance(x, int) for x in args):
            #rasing exception
            raise LispInterException("Exception: you can only use 'Equal' with int elements")
    #all arguments are int
    else:
        #we are going through arguments length except last element (because we check current element and next element)
        for i in range(len(args) - 1):
            #we check current element and the next element if they are not equal
            if args[i] != args[i + 1]:
                #the moment we get an element that is not equal to the next one - we return false
                return '#f'
        #check for not equal element didn't work, so we return true after going through whole argument list
        return '#t'

#(\= arg ...) returns #t if all arguments are unequal, otherwise #f
def not_equal_func(args):
    #we check that all arguments is int. If not:
    if not all(isinstance(x, int) for x in args):
            #rasing exception
            raise LispInterException("Exception: you can only use 'Not equal' with int elements")
    #all arguments are int
    else:
        #we are going through arguments length except last element (because we check current element and next element)
        for i in range(len(args) - 1):
            #we check current element and the next element if they are equal
            if args[i] == args[i + 1]:
                #the moment we get an element that is equal to the next one - we return false
                return '#f'
        #check for equal element didn't work, so we return true after going through whole argument list
        return '#t'

#(> arg ...)
def more_than_func(args):
    #we check that all arguments is int. If not:
    if not all(isinstance(x, int) for x in args):
            #rasing exception
            raise LispInterException("Exception: you can only use 'More than' with int elements")
    #all arguments are int
    else:
        #check if list is empty, because we can't use it with empty list
        if not args:
            #raising exception
            raise LispInterException("Exception: you can't use that with empty list")
        #we are going through arguments length except last element (because we check current element and next element)
        for i in range(len(args) - 1):
            #we check current element and the next element if first is not bigger than second
            if not args[i] > args[i + 1]:
                #the moment we get an element that is not bigger than next one - we return false
                return '#f'
        #check didn't work, so we return true after going through whole argument list
        return '#t'

#(< arg ...)
def less_than_func(args):
    #we check that all arguments is int. If not:
    if not all(isinstance(x, int) for x in args):
            #rasing exception
            raise LispInterException("Exception: you can only use 'Less than' with int elements")
    #all arguments are int
    else:
        #check if list is empty, because we can't use it with empty list
        if not args:
            #raising exception
            raise LispInterException("Exception: you can't use that with empty list")
        #we are going through arguments length except last element (because we check current element and next element)
        for i in range(len(args) - 1):
            #the moment we get an element that is bigger than next one - we return false
            if not args[i] < args[i + 1]:
                #the moment we get an element that is not less than next one - we return false
                return '#f'
        #check didn't work, so we return true after going through whole argument list
        return '#t'

#(>= arg ...)
def more_or_equal_func(args):
    #we check that all arguments is int. If not:
    if not all(isinstance(x, int) for x in args):
            #rasing exception
            raise LispInterException("Exception: you can only use 'Less than' with int elements")
    #all arguments are int
    else:
        #check if list is empty, because we can't use it with empty list
        if not args:
            #raising exception
            raise LispInterException("Exception: you can't use that with empty list")
        #we are going through arguments length except last element (because we check current element and next element)
        for i in range(len(args) - 1):
            #the moment we get an element that is bigger than next one - we return false
            if not args[i] >= args[i + 1]:
                #the moment we get an element that is not bigger or equal than next one - we return false
                return '#f'
        #check didn't work, so we return true after going through whole argument list
        return '#t'

#(<= arg ...)
def less_or_equal_func(args):
    #we check that all arguments is int. If not:
    if not all(isinstance(x, int) for x in args):
            #rasing exception
            raise LispInterException("Exception: you can only use 'Less than' with int elements")
    #all arguments are int
    else:
        #check if list is empty, because we can't use it with empty list
        if not args:
            #raising exception
            raise LispInterException("Exception: you can't use that with empty list")
        #we are going through arguments length except last element (because we check current element and next element)
        for i in range(len(args) - 1):
            #the moment we get an element that is not less or equal than next one - we return false
            if not args[i] <= args[i + 1]:
                #the moment we get an element that is not bigger or equal than next one - we return false
                return '#f'
        #check didn't work, so we return true after going through whole argument list
        return '#t'

#(cons arg arg) making first argument into head of the second argument list (car + cdr)
def cons_func(args):
    #check if it's exactly 2 arguments
    if len(args) != 2:
            #raising an exception
            raise LispInterException("Exception: wrong amount of args in 'cons' function")
    #actually 2 elements
    else:
        #a is first argument
        a = args[0]
        #b is two argument
        b = args[1]
        #we need to check that second element is list. If not - we can't add a to a list
        if type(b) != list:
            #rasing exception
            raise LispInterException("Exception: this intepreter can't handle pairs")
        #b is actually a list
        else:
            #we return list b with a as a first element
            return [a] + b

#(car arg) - get first element of the arg
def car_func(args):
    if len(args) != 1:
        raise LispInterException("Exception: car works only with a single argument")
    elif type(args[0]) != list:
        raise LispInterException("Exception: car works only with list")
    else:
        #returning first element of the argument list
        return args[0][0]

#(cdr arg) - get an arg without it's head element
def cdr_func(args):
    if len(args) != 1:
        raise LispInterException("Exception: car works only with a single argument")
    elif type(args[0]) != list:
        raise LispInterException("Exception: car works only with list")
    else:
        #returning list without first element of the argument list
        return args[0][1:]    

#(list arg ...) making an argument list as a result
def list_func(args):
    if not args:
        return []
    else:    
        return args

#Dictionaries are used to store values of variables and functions. They are stored inside list containers, for example, x : [42] means variable x has value 42.
#local dictionary, used to store local scope
local_d = {}
 
#list of embedded functions added to the dictionary, used to clear global dictionary. Every value is a function name
basic_global = {
    '+' : [plus_func],
    '-' : [minus_func],
    '*' : [multiply_func],
    '/' : [divide_func],
    'null' : [null_func],
    '=' : [equal_func],
    '/=' : [not_equal_func],
    '>' : [more_than_func],
    '<' : [less_than_func],
    '>=' : [more_or_equal_func],
    '<=' : [less_or_equal_func],
    'cons' : [cons_func],
    'car' : [car_func],
    'cdr' : [cdr_func],
    'list' : [list_func]
    }
 
#global dictionary is created by copying basic global dictionary, it will do this trick every time we need to clear it
global_d = basic_global.copy()
 
#abstract tracing function
def tracing(function):
    #creating a function with unlimited amount of arguments
    def traced_function(*arguments):
        #printing function name and arguments
        print(function.__name__, ' '.join(str(i) for i in arguments))
        #getting a result function as a result of the completed function with these arguments
        result = function(*arguments)
        #printing the result with function name
        print('result for function ', function.__name__, ' '.join(str(i) for i in arguments), ' is ', result)
        #returning result
        return result
    #returning traced function
    return traced_function

#using tracing function with @ sign for the apply function      
#@tracing
#we are using my_apply to apply the "procedure" in the procedure list with arguments in the "arguments" list and global_d to use as global dictionary to look upon for functions/variables
def my_apply(procedure, arguments, global_d):
    print('ARGUMENTS ARE: ', arguments)
    print('PROCEDURE IS: ', procedure)
    #check if procedure in global_d. If this so - we just use the function with arguments as it's argument
    if procedure in global_d:
        #returning function from dictionary construction (that's why [0]) with arguments from "arguments' list
        return global_d[procedure][0](arguments)
    #making lambda expression ((lambda (params) (body)) params-value), procedure holds expression, closure holds local dictionary, that is copied when function is created. We are checking that procedure is a closure
    elif isinstance(procedure, Closures): 
        print('lambda func')
        #changing local dictionary to the one, kept inside closures
        local_d = procedure.dictionary
        #getting a list of arguments
        actuals = [i for i in arguments]
        #adding to local dictionary variables using lambda variables as key and actual elements as value of this key, putting it in a list construction
        for i,j in enumerate(procedure.expression[1]):
            local_d[j] = [actuals[i]]
        #returning evalled lambda body with transplated local dictionary
        return my_eval(procedure.expression[2], global_d, local_d)
    #if none are these - returning exception
    else:
        raise LispInterException('Exception: you gave some bullshit to the interperter')

#list of inbuilt functions to check it
inbuilt_functions = ['+', '-', '*', '/', 'null', '=', '/=', '>', '<', '>=', '<=', 'cons', 'list', 'car', 'cdr', 'lambda']

 
#@tracing 
#my_eval function that takes expression, splits on procedure/arguments or doing a special construction               
def my_eval(expr, global_d, local_d):
    #check if it's int. If it's int - int is self-evalling and we just return itself as a result
    if type(expr) == int: #displaying int number
        print('displaying int')
        #returning self-evalled expression
        return expr

    #kinda clearing the terminal
    elif expr == 'pseudoclear': 
        #spam 50 blanket lines to clear terminal
        for i in range(50):
            print()
        #returning none
        return ''

    #displaying true/false, self-evalled expression
    elif expr == '#t' or expr == '#f': 
        print('displaying bool')
        #returning self-evalled expression
        return expr

    #displaying global dict command
    elif expr == 'global': 
        #just returning global_d as a result
        return global_d

    #Clearing global dict command
    elif expr == 'clear-global':
        #making a global_d into basic global dictionary
        global_d = basic_global.copy()
        #returning message
        return 'global dictionary is cleared'

    #exit command
    elif expr == 'exit': 
        #python exit function
        exit('Exiting terminal')

    #calling a variable, checking that expression is str. If so - it's a variable
    elif type(expr) == str:
        print('looking for variable')
        #if it's in basic global, then we just return it as self-eval element
        if expr in basic_global:
            return expr
        #if it's in local_d then we call value of the variable with expr as the key
        if expr in local_d:
            if local_d[expr] == []:
                raise LispInterException('Exception: variable is created but value is not defined')
            else:
                return local_d[expr][0]
        #if it's in global_d then we call value of the variable with expr as the key
        elif expr in global_d:
            if global_d[expr] == []:
                raise LispInterException('Exception: variable is created but value is not defined')
            else:
                return global_d[expr]
        #we found nothing, which means variable is not around and we need to get an exception
        else:
            raise LispInterException('Exception: variable not defined')

    #if function (if (predicate) (true-body) (false-body)) we check that expression is a list and that if is the first element of the list
    elif type(expr) == list and expr[0] == 'if': 
        print('if func')
        #if predicate result will be true we launch a true body
        if my_eval(expr[1], global_d, local_d) == '#t':
            #my_evalling expr[2] part, which is true body
            return my_eval(expr[2], global_d, local_d)
        #it's false, so we launch a false body
        else:
            #my_evalling expr[3] part, which is false body
            return my_eval(expr[3], global_d, local_d)

    #check if it's quote (quote argument), makes a text out of everything inside quote construction
    elif type(expr) == list and expr[0] == 'quote':
        print('quote  func')
        #check if it's not 2 elements (quote part and argument part). If it's so - raise exception
        if len(expr) != 2:
            #raising exception
            raise LispInterException('Exception: \'quote\' function can only work with 1 argument')
        #returning second part of the expression (argument part)
        return expr[1]

    #local namespace parallel (let ((arg1 value1) (arg2 value2) ...) body) local contrusction contained inside (let ). Difference from let* is that arguments are being evalled all at once
    elif type(expr) == list and expr[0] == 'let': 
        print('let func')
        #making a copy to pseudo avoid mutation
        local_d_new = local_d.copy()
        #filling local_d_new with also new arguments, presented in let
        for i in expr[1]: 
            #adding let arguments to local_d dictionary. arg name as key and evalled value as value
            local_d_new[i[0]] = [my_eval(i[1], global_d, local_d)]
        #returning the result of evalling the let body
        return my_eval(expr[2], global_d, local_d_new)

    #local namespace parallel (let* ((arg1 value1) (arg2 value2) ...) body) local contrusction contained inside (let ). Difference from let* is that arguments are being evalled one by one
    elif type(expr) == list and expr[0] == 'let*': #local namespace one after another (let* ((var1 value1) (var2 value2)) body)
        print('let* func')
        #going through argument list
        for i in expr[1]:
            #creating a new copy of the local_d after every step to go through it one by one with adding previous argument
            local_d = local_d.copy()
            #adding my_evalling result as a value for argument name as a key
            local_d[i[0]] = [my_eval(i[1], global_d, local_d)]
        #returning the my_evalled body of the let*
        return my_eval(expr[2], global_d, local_d)

    elif type(expr) == list and expr[0] == 'letrec': #local namespace parallel (letrec ((var1 value1) (var2 value2)) body)
        print('letrec func')
        local_d_new = local_d.copy() 
        resulting_eval = ['begin']
        for i in expr[1]:
            local_d_new[i[0]] = []
            resulting_eval.append(['set', i[0], i[1]])
        resulting_eval.append(expr[2])
        print('resulting eval is', resulting_eval)
        return my_eval(resulting_eval, global_d, local_d_new)

    #(lambda (argument) body) creating a closure, which is lambda expression and local_d dictionary
    elif type(expr) == list and expr[0] == 'lambda':
        print('single lambda func')
        #creating closure
        closure = Closures(expr, local_d)
        print('creating class')
        #returning closure object
        return closure

    #(define variable_name value) or (define (function_name arg ...))
    elif type(expr) == list and expr[0] == 'define':
        print('define func')
        #check if it's definding a variable
        if type(expr[1]) == str:
            #check that this named variable doesn't exist in global dictionary
            if expr[1] in global_d:
                #rasing exception
                raise LispInterException('Exception: trying to define a variable that already exists in global dictionary')
            elif len(expr) < 2 or len(expr) > 3:
                #rasing exception
                raise LispInterException('Exception: wrong define construction')
            elif len(expr) == 2:
                global_d[expr[1]] = []
                return 'defined a variable without exact value'
            else:
                #adding a variable with variable_name as a key and evalled argument value as a key value
                global_d[expr[1]] = [my_eval(expr[2], global_d, local_d)]
                #returning a message 
                return 'defined a variable'
        #it's not a variable, so, it's a function
        else: 
            #if not everything is str, which means not everything is function name and variable names, we need to call an exception
            if not all(isinstance(n, str) for n in expr[1]):
                #exception text
                raise LispInterException('Exception: define - not an identifier, identifier with default, or keyword for procedure argument')
            #function define is fine and we go for it
            else:
                #check if function name does already exist in global dictionary. If it is - raising exception
                if expr[1][0] in global_d:
                    #rasing exception
                    raise LispInterException('Exception: trying to define a function that already exists in global dictionary')
                elif len(expr[1]) == 1:
                    #rasing exception
                    raise LispInterException('Exception: wrong define function construction')
                #doesn't exist in global dictionary
                else:
                    #We use a lambda for a function define. We create a lambda closure with an expression made of 'lambda' element, list of arguments element without function name and function body element plus current local_d dictionary saved
                    closure = Closures(['lambda', expr[1][1:], expr[2]], local_d)
                    #we add in a global_d the name of the function as key and make a value of a key a created closure
                    global_d[expr[1][0]] = closure
                    #returning message
                    return 'defined a function'

    #(set var/function_name value)                
    elif type(expr) == list and expr[0] == 'set':
        print('set func')
        #check if second element in an expression is str char a variable
        if type(expr[1]) == str:
            #check if that this named variable exist in local dictionary
            if expr[1] in local_d:
                
                #checking if variable has empy list aka value not defined
                if not local_d[expr[1]]:
                    #adding a value argument to an empty list construction
                    local_d[expr[1]].append(my_eval(expr[2], global_d, local_d))
                #variable has a value
                else:
                    #adding a variable with variable_name as a key and evalled argument value as a key value to a local dictionary
                    local_d[expr[1]][0] = my_eval(expr[2], global_d, local_d)
            #it doesn't exist in local, so, we check if that this named variable exist in local dictionary
            elif expr[1] in global_d:
                #checking if variable has empy list aka value not defined
                if not global_d[expr[1]]:
                    #adding a value argument to an empty list construction
                    global_d[expr[1]].append(my_eval(expr[2], global_d, local_d))
                #variable has a value
                else:
                    #adding a variable with variable_name as a key and evalled argument value as a key value to a global dictionary
                    global_d[expr[1]][0] = my_eval(expr[2], global_d, local_d)
            #variable doesn't exist
            else:
                #rasing exception
                raise LispInterException("Exception: trying to redefine a variable that doesn't exists in global dictionary")
            #returning a message 
            return 'Changed a value of a variable'
        #not a str char as a second element
        else:
            #rasing exception
            raise LispInterException("Exception: you need to use a variable name to change it's value")
    
    #(begin expr ...) cycle which launch expr after expr until the last one is completed and last expr is returned
    elif type(expr) == list and expr[0] == 'begin':
        #check if there is no expressions at all to work with
        if len(expr) < 2:
            #resing exception
            raise LispInterException("Exception: begin need to have at least one expression")
        #check if there is only 1 expression
        elif len(expr) == 2:
            #return evalling of that expression
            return my_eval(expr[1], global_d, local_d)
        #more than one
        else:
            #cycle of evalling one expression after another until we get to the last one
            for i in expr[1:-1]:
                my_eval(i, global_d, local_d)
            #evalling last expression and returning it as a result
            return my_eval(expr[-1], global_d, local_d)

    #launching apply, since no special construction worked
    else:
        return my_apply(my_eval(expr[0], global_d, local_d), [my_eval(i, global_d, local_d) for i in expr[1:]], global_d)

# REPL = Read Eval Print Loop

#repl function (read eval print loop)
def repl():
    #global_d = {}
    #permanent loop
    while True:
        #expression message with "micro-lisp: " message
        expr = input("MICRO-LISP: ")
        #try-except construct for custom exception launch
        try:
            #going through evalling of the expression
            result = (my_eval(parse(tokenize(expr)), global_d, {}))
            #checking if the result doesn't need the str translation
            if type(result) == int or type(result) == str or type(result) == dict:
                print(result)
            else:
                #printing the result, going through the str function. 0 is count argument which is not important and '(' is needed because it's not printed in the beginning and without last element, because ')' is added)
                print(to_str(result, 0, '(')[:-1])
                print(result)
        #returning the custom exception
        except LispInterException as e:
            print (e)

#launching repl function      
repl()
