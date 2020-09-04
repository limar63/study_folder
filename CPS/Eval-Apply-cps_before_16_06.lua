
function printArray(array)                                                                          --function to print arrayt of any length
    if type(array) == 'number' then
        return tostring(array)
    elseif type(array) == 'string' then
        return "'" .. array .. "'"
    else
        return '{' .. table.concat(map(array, function(x) return printArray(x) end), ', ') .. '}'   --doing nested tables
    end
end

function id(argument)                                                                               --self evalling function for continuation
    return argument
end

function letting(expr, newldict, local_d, catch_env, cont, errcont)                                 --function which performs local dictionary section with expression without let keyword. Difference from let* is that variables are assigned in parallel
    if #expr[1] == 0 then
        return my_eval(expr[2], global_d, newldict, cont, errcont)                                  --table with variables is empty and we can proceed to evaluating let body. We put created formed newldict dictonary in place of local_d
    else
        return my_eval(expr[1][1][2], global_d, local_d, catch_env, function(x)                     --first we eval the value that we need to assign to a local variable
            if type(expr[1][1][1]) ~= 'string' then                                                 --exception returned as errcont continuation
                return errcont('Exception: variable name is needed, instead got "' .. tostring(expr[1][1][1]) .. '"')       
            elseif #expr[1][1] ~= 2 then                                                            --exception returned as errcont continuation
                return errcont('Exception: wrong amount of arguments inside list "' .. printLispExpression(expr[1][1]) .. '"')
            else                                                                                    --First we put the variable name as index and variable value (result x) as a value. Then, we launch the recusrive call of the function without (var_name var_value) that we added
                newldict[expr[1][1][1]] = x return letting(TableConcat({table.slice(expr[1], 2)}, {expr[2]}) , newldict, local_d, catch_env, cont, errcont) 
            end
        end, errcont)
    end
end

function asterLetting(expr, newldict, cont, errcont)                                                --function which performs local dictionary section with expression without let* keyword. Difference from let is that variables are assigned one after another
    if #expr[1] == 0 then
        return my_eval(expr[2], global_d, newldict, cont, errcont)                                  --table with variables is empty and we can proceed to evaluating let body. We put created formed newldict dictonary in place of local_d
    else
        return my_eval(expr[1][1][2], global_d, newldict, function(x)                               --first we eval the value that we need to assign to a local variable
            if type(expr[1][1][1]) ~= 'string' then                                                 --exception returned as errcont continuation
                return errcont('Exception: variable name is needed, instead got "' .. tostring(expr[1][1][1]) .. '"')
            elseif #expr[1][1] ~= 2 then                                                            --exception returned as errcont continuation
                return errcont('Exception: wrong amount of arguments inside list "' .. printLispExpression(expr[1][1]) .. '"')
            else                                                                                    --First we put the variable name as index and variable value (result x) as a value. Then, we launch the recusrive call of the function without (var_name var_value) that we added with added variable as local dictionary
                newldict[expr[1][1][1]] = x return asterLetting(TableConcat({table.slice(expr[1], 2)}, {expr[2]}) , newldict, cont, errcont) 
            end 
        end, errcont)
    end
end

function Evalling_args(array, global_d, local_d, catch_env, cont, errcont)                          --function which evals all arguments before sending them to my_apply
    if #array == 0 then                                                                             --list of arguments is empty, so, we return an empty table. Putting it in cont finished Evalling_args recursion
        --print('got zero')
        return cont({})
    else
        --print('going')
        return my_eval(array[1], global_d, local_d, catch_env, function(x) 
            return Evalling_args(table.slice(array, 2), global_d, local_d, catch_env, function(y)  print('x is', x)
                return cont(TableConcat({x}, y)) 
            end, errcont) 
        end, errcont) 
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


function parse(tokenized_array, errcont)                                                         --parsing the list of tokenized elements via stack method. Elements, closed by parentheses, will become nested lists
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
                return errcont("Exception: Missing opening parentheses")
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
    elseif array.expression ~= nil then
        return '(' .. table.concat(map(array.expression, function(x) return printLispExpression(x) end), ' ') .. ')'
    else
        return '(' .. table.concat(map(array, function(x) return printLispExpression(x) end), ' ') .. ')'
    end
end

--embedded functions:


function plus_func(args, cont, errcont)
    if #args == 0 then
        return errcont('Exception: Can\'t have a plus function with zero arguments')                                                                       --(+ arg ...)
    elseif #args == 1 then
        if type(args[1]) ~= 'number' then
            return errcont('Exception: A nonnumber element in plus function "' .. tostring(args[1]) .. '"')
        else
            return my_eval(args[1], global_d, local_d, catch_env, cont, errcont)
        end
    else
        if type(args[1]) ~= 'number' then
            return errcont('Exception: A nonnumber element in plus function "' .. printArray(args[1]) .. '"')
        else
            return plus_func(table.slice(args, 2), function(y) 
                return cont(args[1] + y) 
            end, errcont) 
        end
    end
end
          

function minus_func(args, cont, errcont)                                                              --(- arg ...)
    if #args == 0 then
        return errcont('Exception: Can\'t have a minus function with zero arguments')                                                                 
    elseif #args == 1 then
        if type(args[1]) ~= 'number' then
            return errcont('Exception: A nonnumber element in minus function "' .. tostring(args[1]) .. '"')
        else
            return my_eval(-1 * args[1], global_d, local_d, catch_env, cont, errcont)
        end
    else
        if type(args[1]) ~= 'number' then
            return errcont('Exception: A nonnumber element in minus function "' .. tostring(args[1]) .. '"')
        else
            return plus_func(table.slice(args, 2), function(y) 
                return cont(args[1] - y) 
            end, errcont) 
        end
    end
end

function multip_func(args, cont, errcont)                                                              --(* arg ...)
    if #args == 0 then
        return errcont('Exception: Can\'t have a multiply function with zero arguments')                                                            
    elseif #args == 1 then
        if type(args[1]) ~= 'number' then
            return errcont('Exception: A nonnumber element in multiply function "' .. tostring(args[1]) .. '"')
        else
            return my_eval(args[1], global_d, local_d, catch_env, cont, errcont)
        end
    else
        if type(args[1]) ~= 'number' then
            return errcont('Exception: A nonnumber element in multip function "' .. tostring(args[1]) .. '"')
        else
            return multip_func(table.slice(args, 2), function(y) 
                return cont(args[1] * y) 
            end, errcont) 
        end
    end
end

function divide_func(args, cont, errcont)                                                              --(/ arg ...)
    if #args == 0 then
        return errcont('Exception: Can\'t have a delete function with zero arguments')                                                              
    elseif #args == 1 then
        return errcont('Exception: Can\'t have a delete function with a single argument')
    else
        if type(args[1]) ~= 'number' then
            return errcont('Exception: A nonnumber element in divide function "' .. tostring(args[1]) .. '"')
        else
            return multip_func(table.slice(args, 2), function(y) 
                return cont(args[1] / y) 
            end, errcont) 
        end
    end
end

function null_func(args, cont, errcont)                                                                --returns --t if argument is empty list (null (list)), otherwise --f (null arg) 
    if #args == 1 then    
        if type(args[1]) == 'table' and #args[1] == 0 then
            return cont('#t')
        else                                                                                --anything else that is not empty list
            return cont('#f')
        end
    else
        return errcont('Exception: Can\'t have a null function with more than 1 argument')
    end
end

function list_func(args, cont, errcont)                                                                --(list arg ...) making an argument list as a result
    if not args then
        return cont({})
    else
        return cont(args)
    end
end

function compare(f, cont, errcont)
    return function(x, cont, errcont) 
        if #x == nil then
            return cont('#f')
        elseif #x == 1 then
            if type(x[1]) ~= 'number' then
                return errcont('Exception: A nonnumber element in compare function "' .. tostring(x[1]) .. '"')
            else
                return cont('#t')
            end
        elseif #x == 2 then
            if type(x[1]) ~= 'number' or type(x[2]) ~= 'number' then
                return errcont('Exception: A nonnumber element in compare function "' .. tostring(x[1]) .. '" "' .. tostring(x[2]) .. '"')
            else
                return cont(takeBool(f(x, cont, errcont)))
            end
        else
            if type(x[1]) ~= 'number' then
                return errcont('Exception: A nonnumber element in compare function "' .. tostring(x[1]) .. '"')
            else
                while #x > 1 do
                    if type(x[2]) ~= 'number' then
                        return errcont('Exception: A nonnumber element in compare function "' .. tostring(x[2]) .. '"')
                    elseif not f(x, cont, errcont) then
                        return cont('#f')
                    else
                        x = TableConcat(table.slice(x, 1, 1), table.slice(x, 3))
                    end
                end
                return cont('#t')
            end
        end
    end
end

more_than = compare(function(x) return x[1] > x[2] end, cont, errcont)

less_than = compare(function(x) return x[1] < x[2] end, cont, errcont)

equal_or_less_than = compare(function(x) return x[1] <= x[2] end, cont, errcont)

equal_or_more_than = compare(function(x) return x[1] >= x[2] end, cont, errcont)

equal = compare(function(x) return x[1] == x[2] end, cont, errcont)

nonequal = compare(function(x) return x[1] ~= x[2] end, cont, errcont)


function cons_func(args, cont, errcont)                                                                --(cons arg arg) making first argument into head of the second argument list (car + cdr)
    if #args ~= 2 then
        return errcont('Exception: Cons only works with 2 elements, given amount is - "' .. tostring(#args) .. '" elements')
    else
        if type(args[2]) ~= 'table' then
            return errcont('Exception: Second element' .. tostring(args[2]) .. '" should be a list')
        else
            table.insert(args[2], 1, args[1])
            return cont(args[2], cont, errcont)
        end
    end
end

function car_func(args, cont, errcont)                                                                 --(car arg) - get first element of the arg
    if #args ~= 1 then
        return errcont('Exception: Car only works with 1 element')
    elseif type(args[1]) ~= 'table' then
            return errcont('Exception: Car only works with tables but element type is "' .. type(args[1]) .. '"')
    else
        return cont(args[1][1], cont, errcont)   
    end                                                                --returning first element of the argument list
end

function cdr_func(args, cont, errcont)                                                                --(cons arg) - get first element of the arg
    if #args ~= 1 then
        return errcont('Exception: Cdr only works with 1 element')
    elseif type(args[1]) ~= 'table' then
            return errcont('Exception: Cdr only works with tables but element type is "' .. type(args[1]) .. '"')
    else
        return cont(table.slice(args[1], 2), cont, errcont)                                                     --returning first element of the argument list
    end
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
basic_global['='] = equal
basic_global['/='] = nonequal
basic_global['>'] = more_than
basic_global['<'] = less_than
basic_global['>='] = equal_or_more_than
basic_global['<='] = equal_or_less_than
basic_global['cons'] = cons_func
basic_global['car'] = car_func
basic_global['cdr'] = cdr_func
basic_global['list'] = list_func

global_d = shallowcopy(basic_global)                                                    --global dictionary is created by copying basic global dictionary, it will do this trick every time we need to clear it
 
function my_apply(procedure, arguments, global_d, cont, errcont)                                 --we are using my_apply to apply the "procedure" in the procedure list with arguments in the "arguments" list and global_d to use as global dictionary to look upon for functions/variables
    --print('applying', procedure)
    --print(arguments)
    if basic_global[procedure] ~= nil then                                                  --check if procedure in global_d. If this so - we just use the function with arguments as it's argument
        return basic_global[procedure](arguments, cont, errcont)
    elseif procedure.expression ~= nil then                                                                                --making lambda expression ((lambda (params) (body)) params-value), procedure holds expression, closure holds local dictionary, that is copied when function is created. We are checking that procedure is a closure
        --print('lambda func')
        local lambd_exp = procedure.expression                                          --changing local dictionary to the one, kept inside closures
        local_d = procedure.dictionary
        actuals = shallowcopy(arguments)                                                --getting a list of arguments
        for i,j in pairs(lambd_exp[2]) do                                               --adding to local dictionary variables using lambda variables as key and actual elements as value of this key, putting it in a list construction
            local_d[j] = actuals[i]
        end                              
        return my_eval(lambd_exp[3], global_d, local_d, catch_env, cont, errcont)                                 --returning evalled lambda body with transplated local dictionary
    else
        return errcont('Exception: my_apply got some nonsense and can\'t recognize it')
    end
end

                                                                                        --inbuilt_functions = {'+', '-', '*', '/', 'null', '=', '/=', '>', '<', '>=', '<=', 'cons', 'list', 'car', 'cdr', 'lambda'}

          
function my_eval(expr, global_d, local_d, catch_env, cont, errcont)                                               --my_eval function that takes expression, splits on procedure/arguments or doing a special construction     
    --print('expr is', printArray(expr))
    if type(expr) == 'number' then                                                      --displaying int number
        --print('displaying int')
        return cont(expr)                                                               --returning self-evalled expression                                                                       --returning none
    
    elseif expr == '#t' or expr == '#f' then                                            --displaying true/false, self-evalled expression
        --print('displaying bool')
        return cont(expr)                                                               --returning self-evalled expression    
    
    elseif expr == 'clear-global' then                                                  --Clearing global dict command
        global_d = shallowcopy(basic_global)                                            --making a global_d into basic global dictionary
        return cont('global dictionary is cleared')                                     --returning message
    
    elseif type(expr) == 'string' then                                                  --calling a variable, checking that expression is str. If so - it's a variable
        --print('looking for variable')
        if basic_global[expr] ~= nil then                                               --if it's in basic global, then we just return it as self-eval element
            --print('got embedded')
            return cont(expr)
        elseif local_d[expr] ~= nil then                                                --if it's in local_d then we call value of the variable with expr as the key
            --print('got real local', printArray(local_d[expr]))
            return cont(local_d[expr])
        elseif global_d[expr] ~= nil then                                                                               --if it's in global_d then we call value of the variable with expr as the key
            --print('got global', #global_d[expr])
            return cont(global_d[expr])
        else
            return errcont('Exception: Current variable doesn\'t exist "' .. expr .. '"')
        end
    
    elseif type(expr) == 'table' and expr[1] == 'if' then                               --if function (if (predicate) (true-body) (false-body)) we check that expression is a list and that if is the first element of the list
        --print('if func')
        if #expr ~= 4 then
            return errcont('Exception: Wrong amount of arguments for If function - "' .. tostring(#expr) .. '"')
        else
            return my_eval(expr[2], global_d, local_d, catch_env, function(x)
            if x == '#t' then 
                return my_eval(expr[3], global_d, local_d, catch_env, cont, errcont) 
            else 
                return my_eval(expr[4], global_d, local_d, catch_env, cont, errcont) end end, errcont)
        end
    
    elseif type(expr) == 'table' and expr[1] == 'quote' then                            --check if it's quote (quote argument), makes a text out of everything inside quote construction
        --print('quote  func')
        if #expr ~= 2 then
            return errcont('Exception: Wrong amount of arguments for quote function, should be 2, but instead "' .. tostring(#expr) .. '"')
        else
            return cont(expr[2])
        end
    
    elseif type(expr) == 'table' and expr[1] == 'let' then                              --local namespace parallel (let ((arg1 value1) (arg2 value2) ...) body) local contrusction contained inside (let ). Difference from let* is that arguments are being evalled all at once
        --print('let func')
        if #expr ~= 3 then
            return errcont('Exception: Wrong amount of arguments for let function, should be 3, but instead "' .. tostring(#expr) .. '"')
        elseif type(expr[2]) ~= 'table' then
            return errcont('Exception: Wrong form of let, missing table of variables')
        else
            local local_d_new = shallowcopy(local_d)                                        --making a copy to pseudo avoid mutation
            return letting(table.slice(expr, 2), local_d, catch_env_new, local_d, catch_env, cont, errcont)                                  --returning the result of evalling the let body with new local dict
        end

    elseif type(expr) == 'table' and expr[1] == 'let*' then                             --local namespace parallel (let* ((arg1 value1) (arg2 value2) ...) body) local contrusction contained inside (let ). Difference from let* is that arguments are being evalled one by one
        --print('let* func')
        if #expr ~= 3 then
            return errcont('Exception: Wrong amount of arguments for let* function, should be 3, but instead "' .. tostring(#expr) .. '"')
        elseif type(expr[2]) ~= 'table' then
            return errcont('Exception: Wrong form of let*, missing table of variables')
        else
            local local_d_new = shallowcopy(local_d)                                        --creating a new copy of the local_d after every step to go through it one by one with adding previous argument
            return asterLetting(table.slice(expr, 2), local_d, catch_env_new, cont, errcont)                                  --returning the my_evalled body of the let*
        end

    elseif type(expr) == 'table' and expr[1] ==  'lambda' then                          --(lambda (argument) body) creating a closure, which is lambda expression and local_d dictionary
        --print('single lambda func')
        if #expr ~= 3 then
            return errcont('Exception: Wrong amount of arguments for lambda forming function, should be 3, but instead "' .. tostring(#expr) .. '"')
        elseif type(expr[2]) ~= 'table' then
            return errcont('Exception: Missing list of lambda variables')
        else
            local closure = {expression = expr, dictionary = local_d}                       --creating closure record
            return cont(closure)
        end
    
    elseif type(expr) == 'table' and expr[1] == 'define' then                           --(define variable_name value) or (define (function_name arg ...))
        --print('define func')
        if #expr ~= 3 then
            return errcont('Exception: Wrong amount of arguments for define function, should be 3, but instead "' .. tostring(#expr) .. '"')
        elseif type(expr[2]) == 'string' then                                               --check if it's definding a variable
            if global_d[expr] ~= nil then
                return errcont('Exception: Variable "' .. expr .. '" already exists')
            elseif #expr == 2 then
                global_d[expr[2]] = {}
                return cont('Defined a variable without exact value')
            else
                return my_eval(expr[3], global_d, local_d, catch_env, function(x) global_d[expr[2]] = x return cont('defined a variable') end, errcont)              --adding a variable with variable_name as a key and evalled argument value as a key value
            end
        else                                                                            --it's not a variable, so, it's a function  
                                                                                        --We use a lambda for a function define. We create a lambda closure with an expression made of 'lambda' element, list of arguments element without function name and function body element plus current local_d dictionary saved
            if global_d[expr] ~= nil then
                return errcont('Exception: Function "' .. expr .. '" already exists')
            elseif type(expr[2]) ~= 'table' then
                return errcont('Excpetion: Missing function table')
            else
                local closure = {expression = {'lambda', table.slice(expr[2], 2), expr[3]}, dictionary = local_d}
                global_d[expr[2][1]] = closure                                              --we add in a global_d the name of the function as key and make a value of a key a created closure
                return cont('Defined a function')
            end
        end
                
    elseif type(expr) == 'table' and expr[1] == 'set' then                              --(set var/function_name value)    
        --print('set func')
        if local_d[expr[2]] ~= nil then                                                 --check if that this named variable exist in local dictionary 
            return my_eval(expr[3], global_d, local_d, catch_env, function(x) 
                local_d[expr[2]] = {x} return cont('Changed a value of a local variable') 
            end, errcont)                  --changing a value of an argument
        elseif global_d[expr[2]] ~= nil then                                                                            --it doesn't exist in local, so, we check if that this named variable exist in local dictionary
            return my_eval(expr[3], global_d, local_d, catch_env, function(x) 
                global_d[expr[2]] = {x} return cont('Changed a value of a local variable') 
            end, errcont)                    --changing a value of an argument
        else
            return errcont('Excpetion: Variable doesn\'t exist "' .. expr[2] .. '"')
        end
    
    elseif type(expr) == 'table' and expr[1] == 'begin' then   
        if #expr < 2 then
            return errcont('Excpetion: Begin needs to have at least 1 argument')
        elseif #expr == 2 then
            --print('going for eval', printArray(expr[2]))
            return my_eval(expr[2], global_d, local_d, catch_env, cont, errcont)
        else
            return my_eval(expr[2], global_d, local_d, catch_env, function(x) 
                return  my_eval(TableConcat({'begin'}, table.slice(expr, 3)), global_d, local_d, catch_env, cont, errcont) 
            end, errcont)
        end

    else                                                                             --launching apply, since no special construction worked
        return my_eval(expr[1], global_d, local_d, catch_env, function(x) 
            return Evalling_args(table.slice(expr, 2), global_d, local_d, catch_env, function(y) 
                return my_apply(x, y, global_d, cont, errcont) 
            end, errcont) 
        end, errcont)
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
        print(printLispExpression(my_eval(parse(tokenize(expr), id), global_d, local_d, catch_env, id, id)))   --try-except construct for custom exception launch
    end
end
    
--launching repl function      
repl()

