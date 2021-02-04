function TableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end


function reduce(fun, seq)
    local result = fun(seq[1], seq[2])
    for i = 3, #seq do
        result = fun(result, seq[i])
    end
    return result
end

function map(tbl, f)
    local t = {}
    for k,v in pairs(tbl) do
        t[k] = f(v)
    end
    return t
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

function printArray(array)                                                              --function to print arrayt of any length
    if type(array) == 'number' then
        return tostring(array)
    elseif type(array) == 'string' then
        return "'" .. array .. "'"
    else
        return '{' .. table.concat(map(array, function(x) return printArray(x) end), ', ') .. '}'
    end
end

function combing(number)
    if number == 0 then
        return {}
    else
        local result = {}
        for i = 1, number do
            local temp_table = {i}
            TableConcat(temp_table, combing(number - i))
            TableConcat(result, temp_table)
            --print(printArray(result))
        end
        return result 
    end
end

function not_repeating(array_for_check, filled_array)
    local check_string = {}
    for i = 1, #array_for_check do
        if check_string[array_for_check[i]] == nil then
            check_string[array_for_check[i]] = 1
        else
            check_string[array_for_check[i]] = check_string[array_for_check[i]] + 1
        end
    end
    --print(printArray(check_string))
    for i = 1, #filled_array do
        local temp_table = {}
        --print('filled array', printArray(filled_array[i]))
        for j = 1, #filled_array[i] do
            if temp_table[filled_array[i][j]] == nil then
                temp_table[filled_array[i][j]] = 1
            else
                --print('hmm', printArray(temp_table[filled_array[i][j]]))
                temp_table[filled_array[i][j]] = temp_table[filled_array[i][j]] + 1
            end
        end
        print('temptable is', printArray(temp_table))
        print('check string is', printArray(check_string))
        if #check_string == #temp_table then
            local check = true
            for k = 1, #check_string do
                print('checking ', k)
                print('tested array is ', check_string[k])
                print('filled elem is', temp_table[k])
                if check_string[k] ~= temp_table[k] then
                    check = false
                end
                --print('check now is', check)
            end
            if check == true then
                --print('check failed', #check_string)
                --print(#temp_table)
                --print(check)
                return false
            end
        end
    end
    return true
end

function filteringComb(array, number)
    print('array is', printArray(array))
    print('number is', number)
    local copy = shallowcopy(array)
    local stack = {table.remove(copy, 1)}
    local result = {}
    while #copy > 0 do
        print('copy is', printArray(copy))
        local var = table.remove(copy, 1)
        print('var is', var)
        table.insert(stack, 1, var)
        print('stack is', printArray(stack))
        local check = reduce(function(x, y) return x + y end, stack)
        if check > number then
            print ('stack is higher than number', printArray(stack))
            table.insert(copy, math.random(1, #copy), table.remove(stack, 1))
            if stack[1] == 6 then
                table.insert(result, 1, shallowcopy(stack))
                stack = {table.remove(copy, 1)}
            end
        elseif check == number then 
            if #result == 0 or not_repeating(stack, result) == false then
                print('inserting', printArray(stack))
                table.insert(result, 1, shallowcopy(stack))
                stack = {table.remove(copy, 1)}
                print('result now is', printArray(result))
            else
                print('got repeat with', printArray(stack))
                copy = TableConcat(copy, shallowcopy(stack))
                stack = {table.remove(copy, 1)}
                print('result is', printArray(result))
            end
        end
    end
    print('not assigned numbers are', printArray(stack))
    return result
end


--print('result is', printArray(filteringComb({5, 4, 4, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, 6)))

print(not_repeating({1, 1, 1, 2}, {{1, 1, 1, 2}, {1, 3}, {2, 2}}))

print(printArray(filteringComb(combing(6), 6)))