
function printArray(array)                                                              --function to print arrayt of any length
    if type(array) == 'number' then
        return tostring(array)
    elseif type(array) == 'string' then
        return "'" .. array .. "'"
    else
        return '{' .. table.concat(map(array, function(x) return printArray(x) end), ', ') .. '}'
    end
end

function id(argument)
    return argument
end

function letting(expr, newldict, local_d, cont)
    if #expr[1] == 0 then
        return my_eval(expr[2], global_d, newldict, cont)
    else
        return my_eval(expr[1][1][2], global_d, local_d, function(x) 
            newldict[expr[1][1][1]] = x return letting(TableConcat({table.slice(expr[1], 2)}, {expr[2]}) , newldict, local_d, cont) end)
    end
end

function asterLetting(expr, newldict, cont)
    if #expr[1] == 0 then
        return my_eval(expr[2], global_d, newldict, cont)
    else
        return my_eval(expr[1][1][2], global_d, newldict, function(x) 
            newldict[expr[1][1][1]] = x return asterLetting(TableConcat({table.slice(expr[1], 2)}, {expr[2]}) , newldict, cont) end)
    end
end

--function Evalling_args(array, global_d, local_d)
    --if #array == 0 then
        --return {}
    --else
        --local temp = {my_eval(array[1], global_d, local_d)}
        --return TableConcat(temp, Evalling_args(table.slice(array, 2), global_d, local_d))
    --end
--end

function Evalling_args(array, global_d, local_d, cont)
    if #array == 0 then
        --print('got zero')
        return cont({})
    else
        --print('going')
        return my_eval(array[1], global_d, local_d, function(x) return Evalling_args(table.slice(array, 2), global_d, local_d, function(y) return cont(TableConcat({x}, y)) end) end) 
    end
end

function TableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

function takeBool(bool_val)
    if bool_val then
        return '#t'
    else
        return '#f'
    end
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else                                                                                -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else                                                                                -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function table.slice(tbl, first, last, step)
    local sliced = {}
  
    for i = first or 1, last or #tbl, step or 1 do
      sliced[#sliced+1] = tbl[i]
    end
  
    return sliced
end

function all(iterable)
    for i = 1, #iterable do
        if not iterable[i] then
            return false
        end
    end
    return true
end

function map(tbl, f)
    local t = {}
    for k,v in pairs(tbl) do
        t[k] = f(v)
    end
    return t
end

function table.slice(tbl, first, last, step)
    local sliced = {}
  
    for i = first or 1, last or #tbl, step or 1 do
      sliced[#sliced+1] = tbl[i]
    end
  
    return sliced
end

function reduce(fun, seq)
    local result = fun(seq[1], seq[2])
    for i = 3, #seq do
        result = fun(result, seq[i])
    end
    return result
end


function tokenize(line)                                                                 --tokenizing an expression, making every single
    local word_holder = ''                                                              --used to differ between 1 element formed by many letters and elements formed by 1 letter. After adding word_hodler to the table, it's set to '' value again
    local tokenized_array = {}                                                          --resulting table
    for i = 1, string.len(line) do                                                      --going through the expression line
        local element = string.sub(line, i, i)                                          --using variable to avoid substringing everytime to check
        if element == '(' or element == ')' then                                        --check if it's a non spacebar separator
            if word_holder == '' then                                                   --if word_holder is empty we can just add parentheses to the resulting list
                table.insert(tokenized_array, #tokenized_array + 1, element)            --the way to append an element to a table
            else                                                                        --else we need to add word holder characters before adding the separator
                table.insert(tokenized_array, #tokenized_array + 1, word_holder)
                word_holder = ''                                                        --emptying word holder after inserting it
                table.insert(tokenized_array, #tokenized_array + 1, element)
            end
        elseif element == ' ' then                                                      --if we get a spacebar as a current character
            if word_holder ~= '' then                                                   --if word_holder is not empty we need to add word_holder to the stack, since we got to the separator
                table.insert(tokenized_array, #tokenized_array + 1, word_holder)        --adding what word_holder contains
                word_holder = ''
            end
        else                                                                            --not a separator so we just fill the word_holder
            word_holder = word_holder .. element                                        --adding another character to word_holder list
        end
    end
    if word_holder ~= '' then                                                           --we check that after getting to the end of the expression line word_holder is empty. If not - it should be added to the resulting list
        table.insert(tokenized_array, #tokenized_array + 1, word_holder)                --adding what word_holder contains
    end  
    return tokenized_array                                                              --returning tokenized array
end


function parse(tokenized_array)                                                         --parsing the list of tokenized elements via stack method. Elements, closed by parentheses, will become nested lists
    local stack = {}                                                                    --creating the resulting stack
    for i = 1, #tokenized_array do
        if tokenized_array[i] ~= ')' then
            if tonumber(tokenized_array[i]) ~= nil then
                table.insert(stack, #stack + 1, tonumber(tokenized_array[i]))           --if it's a digit character we append it to a stack as a number by parsing it to int
            else
                table.insert(stack, #stack + 1, tokenized_array[i])                     --we append it to stack, either it's a '(' or other characters, that is not a ')'
            end
        
        else                                                                            --we got the ')', which means that we need to make a nested stack to put it inside the outer stack
            local placeholder_stack={}
            while #stack > 0 and stack[#stack] ~= '(' do                                --until we get to the closest opening '(', which means, that we got properly formed expression construction, or until we run off the elements without getting to '(', which means, expression is wrong.
                table.insert(placeholder_stack, 1, table.remove(stack))                 --adding top element from the stack to the beginning of the placeholder stack
            end  
            local last_element = table.remove(stack)                                    --removing opening parentheses 
            if last_element == nil then                                                 --if not - expression is wrong and exception will be thrown
                return print("Exception: Missing opening parentheses")
            else
                table.insert(stack, #stack + 1, placeholder_stack)                      --putting nested stack inside
            end
        end
    end  
    return table.remove(stack)                                                          --result is inside another table. So, we need to pop it out
end

function printLispExpression(array)                                                     --resursive function which prints a lisp-looking expression
    if type(array) == 'number' then
        return tostring(array)
    elseif type(array) == 'string' then
        return array
    else
        return '(' .. table.concat(map(array, function(x) return printLispExpression(x) end), ' ') .. ')'
    end
end

--embedded functions:


function plus_func(args, cont)
    if #args == 0 then
        return cont(0)                                                                       --(+ arg ...)
    elseif #args == 1 then
        return my_eval(args[1], global_d, local_d, cont)
    else
        return my_eval(args[1], global_d, local_d, function(x) 
            return plus_func(table.slice(args, 2), function(y) 
                return cont(x + y) end) end)
    end
end
          

function minus_func(args, cont)                                                              --(- arg ...)
    if #args == 0 then
        return cont(0)                                                                
    elseif #args == 1 then
        return my_eval(args[1], global_d, local_d, cont)
    else
        return my_eval(args[1], global_d, local_d, function(x) 
            return plus_func(table.slice(args, 2), function(y) 
                return cont(x - y) end) end)
    end
end

function multip_func(args, cont)                                                              --(* arg ...)
    if #args == 0 then
        return cont(0)                                                            
    elseif #args == 1 then
        return my_eval(args[1], global_d, local_d, cont)
    else
        return my_eval(args[1], global_d, local_d, function(x) 
            return multip_func(table.slice(args, 2), function(y) 
                return cont(x * y) end) end)
    end
end

function divide_func(args, cont)                                                              --(/ arg ...)
    if #args == 0 then
        return cont(0)                                                               
    elseif #args == 1 then
        return my_eval(args[1], global_d, local_d, cont)
    else
        return my_eval(args[1], global_d, local_d, function(x) 
            return multip_func(table.slice(args, 2), function(y) 
                return cont(x / y) end) end)
    end
end

function null_func(args, cont)                                                                --returns --t if argument is empty list (null (list)), otherwise --f (null arg) 
    if type(args[1]) == 'table' and #args[1] == 0 then
        return cont('#t')
    else                                                                                --anything else that is not empty list
        return cont('#f')
    end
end

function list_func(args, cont)                                                                --(list arg ...) making an argument list as a result
    if not args then
        return cont({})
    else
        return cont(args)
    end
end


function equal_func(args,cont)                                                               --returns --t if all arguments are equal, otherwise --f (= arg ...)
    if #args == 0 then
        return cont('#f')
    elseif #args == 1 then
        return cont('#t')
    elseif #args == 2 then
        return cont(takeBool(args[1] == args[2]))
    else
        if args[1] ~= args[2] then                                                      --we check current element and the next element if they are not equal
            return cont('#f') 
        else
            return equal_func(table.slice(args, 2), cont)      
        end
    end                                                            
end

function not_equal_func(args, cont)                                                           --(/= arg ...) returns --t if all arguments are unequal, otherwise --f
    if #args == 0 then
        return cont('#f')
    elseif #args == 1 then
        return cont('#t')
    elseif #args == 2 then
        return cont(takeBool(args[1] ~= args[2]))
    else
        if args[1] == args[2] then                                                      --we check current element and the next element if they are equal
            return cont('#f') 
        else
            return not_equal_func(TableConcat(table.slice(args, 1, 1), table.slice(args, 3)), cont)      
        end
    end                                                            
end


function more_than_func(args, cont)                                                           --(> arg ...)
    if #args == 0 then
        return cont('#f')
    elseif #args == 1 then
        return cont('#t')
    elseif #args == 2 then
        return cont(takeBool(args[1] > args[2]))
    else
        if args[1] <= args[2] then                                                      
            return cont('#f')
        else
            return more_than_func(TableConcat(table.slice(args, 1, 1), table.slice(args, 3)), cont)      
        end
    end                                                            
end


function less_than_func(args, cont)                                                           --(< arg ...)
    if #args == 0 then
        return cont('#f')
    elseif #args == 1 then
        return cont('#t')
    elseif #args == 2 then
        return cont(takeBool(args[1] < args[2]))
    else
        if args[1] >= args[2] then                                                      
            return cont('#f') 
        else
            return less_than_func(TableConcat(table.slice(args, 1, 1), table.slice(args, 3)), cont)       
        end
    end                                                            
end

function more_or_equal_func(args, cont)                                                        --(>= arg ...)
    if #args == 0 then
        return cont('#f')
    elseif #args == 1 then
        return cont('#t')
    elseif #args == 2 then
        return cont(takeBool(args[1] >= args[2]))
    else
        if args[1] < args[2] then                                                      
            return cont('#f') 
        else
            return more_or_equal_func(TableConcat(table.slice(args, 1, 1), table.slice(args, 3)), cont)      
        end
    end                                                            
end

function less_or_equal_func(args, cont)                                                       --(<= arg ...)
    if #args == 0 then
        return cont('#f')
    elseif #args == 1 then
        return cont('#t')
    elseif #args == 2 then
        return cont(takeBool(args[1] <= args[2]))
    else
        if args[1] > args[2] then                                                      
            return cont('#f')  
        else
            return less_or_equal_func(TableConcat(table.slice(args, 1, 1), table.slice(args, 3)), cont)      
        end
    end                                                            
end


function cons_func(args)                                                                --(cons arg arg) making first argument into head of the second argument list (car + cdr)
    table.insert(args[2], 1, args[1])
    return cont(args[2])
end

function car_func(args)                                                                 --(car arg) - get first element of the arg
    return cont(args[1][1])                                                                   --returning first element of the argument list
end

function cons_func(args)                                                                --(cons arg) - get first element of the arg
    return cont(table.slice(args[1], 2))                                                     --returning first element of the argument list
end

--Dictionaries are used to store values of variables and functions. They are stored inside list containers, for example, x : [42] means variable x has value 42.
--Since, LUA has no proper dictionaries, I will use tables with custom indexes as dictionaries
--local dictionary, used to store local scope
local_d = {}

basic_global = {}                                                                       --list of embedded functions added to the dictionary, used to clear global dictionary. Every value is a function name
basic_global['+'] = plus_func
basic_global['-'] = minus_func
basic_global['*'] = multip_func
basic_global['/'] = divide_func
basic_global['null'] = null_func
basic_global['='] = equal_func
basic_global['/='] = not_equal_func
basic_global['>'] = more_than_func
basic_global['<'] = less_than_func
basic_global['>='] = more_or_equal_func
basic_global['<='] = less_or_equal_func
basic_global['cons'] = cons_func
basic_global['car'] = car_func
basic_global['cdr'] = cdr_func
basic_global['list'] = list_func

global_d = shallowcopy(basic_global)                                                    --global dictionary is created by copying basic global dictionary, it will do this trick every time we need to clear it
 
function my_apply(procedure, arguments, global_d, cont)                                 --we are using my_apply to apply the "procedure" in the procedure list with arguments in the "arguments" list and global_d to use as global dictionary to look upon for functions/variables
    --print('applying', procedure)
    --print(arguments)
    if basic_global[procedure] ~= nil then                                                  --check if procedure in global_d. If this so - we just use the function with arguments as it's argument
        return basic_global[procedure](arguments, cont)
    elseif global_d[procedure] ~= nil then                                                  --check if procedure in global_d. If this so - we just use the function with arguments as it's argument
        return global_d[procedure](arguments)                                           --returning function from dictionary construction (that's why [0]) with arguments from "arguments' list
    else                                                                                --making lambda expression ((lambda (params) (body)) params-value), procedure holds expression, closure holds local dictionary, that is copied when function is created. We are checking that procedure is a closure
        --print('lambda func')
        local lambd_exp = procedure.expression                                          --changing local dictionary to the one, kept inside closures
        local_d = procedure.dictionary
        actuals = shallowcopy(arguments)                                                --getting a list of arguments
        for i,j in pairs(lambd_exp[2]) do                                               --adding to local dictionary variables using lambda variables as key and actual elements as value of this key, putting it in a list construction
            local_d[j] = actuals[i]
        end                              
        return my_eval(lambd_exp[3], global_d, local_d, cont)                                 --returning evalled lambda body with transplated local dictionary
    end
end

                                                                                        --inbuilt_functions = {'+', '-', '*', '/', 'null', '=', '/=', '>', '<', '>=', '<=', 'cons', 'list', 'car', 'cdr', 'lambda'}

          
function my_eval(expr, global_d, local_d, cont)                                               --my_eval function that takes expression, splits on procedure/arguments or doing a special construction     
    --print('expr is', printArray(expr))
    if type(expr) == 'number' then                                                      --displaying int number
        --print('displaying int')
        return cont(expr)                                                               --returning self-evalled expression                                                                       --returning none
    
    elseif expr == '#t' or expr == '#f' then                                            --displaying true/false, self-evalled expression
        --print('displaying bool')
        return cont(expr)                                                               --returning self-evalled expression
    
    --displaying global dict command
    --elseif expr == 'global' then
        --just returning global_d as a result
        --return global_d
    
    
    elseif expr == 'clear-global' then                                                  --Clearing global dict command
        global_d = shallowcopy(basic_global)                                            --making a global_d into basic global dictionary
        return cont('global dictionary is cleared')                                     --returning message
    
    --exit command
    --elseif expr == 'exit' then
        --python exit function
        --return print('Exiting terminal')
    
    elseif type(expr) == 'string' then                                                  --calling a variable, checking that expression is str. If so - it's a variable
        --print('looking for variable')
        if basic_global[expr] ~= nil then                                               --if it's in basic global, then we just return it as self-eval element
            --print('got embedded')
            return cont(expr)
        elseif local_d[expr] ~= nil then                                                --if it's in local_d then we call value of the variable with expr as the key
            --print('got real local', printArray(local_d[expr]))
            return cont(local_d[expr])
        else                                                                            --if it's in global_d then we call value of the variable with expr as the key
            --print('got global', #global_d[expr])
            return cont(global_d[expr])
        end
    
    elseif type(expr) == 'table' and expr[1] == 'if' then                               --if function (if (predicate) (true-body) (false-body)) we check that expression is a list and that if is the first element of the list
        --print('if func')
        if my_eval(expr[2], global_d, local_d, cont) == '#t' then                             --if predicate result will be true we launch a true body
            return my_eval(expr[3], global_d, local_d, cont)                            --my_evalling expr[3] part, which is true body
        else                                                                            --it's false, so we launch a false body
            return my_eval(expr[4], global_d, local_d, cont)                            --my_evalling expr[4] part, which is false body
        end
    
    elseif type(expr) == 'table' and expr[1] == 'quote' then                            --check if it's quote (quote argument), makes a text out of everything inside quote construction
        --print('quote  func')
        return cont(expr[2])
    
    elseif type(expr) == 'table' and expr[1] == 'let' then                              --local namespace parallel (let ((arg1 value1) (arg2 value2) ...) body) local contrusction contained inside (let ). Difference from let* is that arguments are being evalled all at once
        print('let func')
        local local_d_new = shallowcopy(local_d)                                        --making a copy to pseudo avoid mutation
        return letting(table.slice(expr, 2), local_d_new, local_d, cont)                                  --returning the result of evalling the let body with new local dict

    elseif type(expr) == 'table' and expr[1] == 'let*' then                             --local namespace parallel (let* ((arg1 value1) (arg2 value2) ...) body) local contrusction contained inside (let ). Difference from let* is that arguments are being evalled one by one
        --print('let* func')
        local local_d_new = shallowcopy(local_d)                                        --creating a new copy of the local_d after every step to go through it one by one with adding previous argument
        return asterLetting(table.slice(expr, 2), local_d_new, cont)                                  --returning the my_evalled body of the let*
    
    --elseif type(expr) == 'table' and expr[1] == 'letrec' then                           --local namespace parallel (letrec ((var1 value1) (var2 value2)) body)
        --print('letrec func')
        --local local_d_new = shallowcopy(local_d)
        --local resulting_eval = {'begin'}
        --for i = 1, #expr[2] do
            --local_d_new[expr[2][i][1]] = {}
            --table.insert(resulting_eval, #resulting_eval + 1, {'set', expr[2][i][1], expr[2][i][2]})
        --end
        --table.insert(resulting_eval, #resulting_eval + 1, expr[3])
        --print('resulting eval is', printArray(resulting_eval))
        --return my_eval(resulting_eval, global_d, local_d_new)

    elseif type(expr) == 'table' and expr[1] ==  'lambda' then                          --(lambda (argument) body) creating a closure, which is lambda expression and local_d dictionary
        --print('single lambda func')
        local closure = {expression = expr, dictionary = local_d}                       --creating closure record
        return cont(closure)
    
    elseif type(expr) == 'table' and expr[1] == 'define' then                           --(define variable_name value) or (define (function_name arg ...))
        --print('define func')
        if type(expr[2]) == 'string' then                                               --check if it's definding a variable
            if #expr == 2 then
                global_d[expr[2]] = {}
                return cont('defined a variable without exact value')
            else
                return my_eval(expr[3], global_d, local_d, function(x) global_d[expr[2]] = {x} return cont('defined a variable') end)              --adding a variable with variable_name as a key and evalled argument value as a key value
            end
        else                                                                            --it's not a variable, so, it's a function  
                                                                                        --We use a lambda for a function define. We create a lambda closure with an expression made of 'lambda' element, list of arguments element without function name and function body element plus current local_d dictionary saved
            local closure = {expression = {'lambda', table.slice(expr[2], 2), expr[3]}, dictionary = local_d}
            global_d[expr[2][1]] = closure                                              --we add in a global_d the name of the function as key and make a value of a key a created closure
            return cont('defined a function')
        end
                
    elseif type(expr) == 'table' and expr[1] == 'set' then                              --(set var/function_name value)    
        --print('set func')
        if local_d[expr[2]] ~= nil then                                                 --check if that this named variable exist in local dictionary 
            return my_eval(expr[3], global_d, local_d, function(x) local_d[expr[2]] = {x} return cont('Changed a value of a local variable') end)                  --changing a value of an argument
        else                                                                            --it doesn't exist in local, so, we check if that this named variable exist in local dictionary
            return my_eval(expr[3], global_d, local_d, function(x) global_d[expr[2]] = {x} return cont('Changed a value of a local variable') end)                    --changing a value of an argument
        end
        
    
    elseif type(expr) == 'table' and expr[1] == 'begin' then                            --(begin expr ...) cycle which launch expr after expr until the last one is completed and last expr is returned
        if #expr == 2 then                                                              --check if there is only 1 expression
            return my_eval(expr[2], global_d, local_d, cont)                            --return evalling of that expression  
        else                                                                            --more than one
                                                                                        --evalling last expression and returning it as a result
            return my_eval(expr[2], global_d, local_d, function(x) 
                return my_eval(table.insert(table.slice(expr, 3), 1, 'begin'), global_d, local_d, function(y) 
                    return cont(y) end) end)
        end
    
    
    else                                                                                --launching apply, since no special construction worked
        return my_eval(expr[1], global_d, local_d, function(x) 
            return Evalling_args(table.slice(expr, 2), global_d, local_d, function(y) 
                return my_apply(x, y, global_d, cont) end) end)
    end
end


function repl()                                                                         --repl function (read eval print loop)
    --global_d = {}
    --permanent loop
    while true do
        --expression message with "micro-lisp: " message
        io.write("MICRO-LISP: ")
        expr = io.read()
        --print('expr in beginning is', printArray(parse(tokenize(expr))))
        print(printLispExpression(my_eval(parse(tokenize(expr)), global_d, local_d, id)))   --try-except construct for custom exception launch
    end
end
    
--launching repl function      
repl()

