--Task for that program is located in the same folder, .png type picture

--function to print arrayt of any length
function printArray(array)
    if type(array) == 'number' then
        return tostring(array)
    elseif type(array) == 'string' then
        return "'" .. array .. "'"
    else
        return '{' .. table.concat(map(array, function(x) return printArray(x) end), ', ') .. '}'
    end
end

function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

--fucktion which make slices of a table
function table.slice(tbl, first, last, step)
    local sliced = {}
  
    for i = first or 1, last or #tbl, step or 1 do
      sliced[#sliced+1] = tbl[i]
    end
  
    return sliced
end

--my function for shallow copying of a string array
function copy_string_arr(array)
    local copy = {}
    for i = 1, #array do
        copy[i] = string.sub(array[i], 1)
    end
    return copy
end

--function which adds to every first element of the nested list a chracter
function char_apply(charac, arr)
    return map(arr, 
    function(x) 
        return TableConcat({charac .. x[1]}, table.slice(x, 2))
    end)
end
    
--function which inserts to every nested list a chracter as a first element
function char_add(charac, arr)
    local var = map (arr, 
    function(x) 
        if x[1] == '' then 
            return {string.sub(charac, 1)} 
        else 
            return TableConcat({string.sub(charac, 1)}, copy_string_arr(x)) 
        end
    end)
    return var
end


--function table.shallow_copy(t)
    --local t2 = {}
    --for k,v in pairs(t) do
      --t2[k] = v
    --end
    --return t2
---end

--function which concats 2 tables to a single table
function TableConcat(t1,t2)
    local result = {}
    local global_i = 0
    for i=1,#t1 do
        result[i] = t1[i]
        global_i = global_i + 1
    end
    global_i = global_i + 1
    for i = 1, #t2 do
        result[global_i] = t2[i]
        global_i = global_i + 1
    end
    return result
end

--going through array which needs to be checked that every element is full of odd amount of elements
function all_odd(arr)
    for i = 1, #arr do
        if not (part_odd_check(arr[i], {}, {})) then
            return false
        end
    end
    return true
end

--checking if string has odd amount of letters
function part_odd_check(str_for_check, kTable, vTable)
    if string.len(str_for_check) == 0 then
        local check = 0
        for i = 1, #kTable do
            if (vTable[kTable[i]]%2) == 0 then
                check = 1
            end
        end
        if check == 1 then
            return false
        else
            return true
        end
    else
        if vTable[string.sub(str_for_check, 1, 1)] == nil then
            addNewItem(kTable, vTable, string.sub(str_for_check, 1, 1), 1)
            
        else
            vTable[string.sub(str_for_check, 1, 1)] = vTable[string.sub(str_for_check, 1, 1)] + 1
        end
        return part_odd_check(string.sub(str_for_check, 2), kTable, vTable)
    end
end

--main recursive function
function mic_cut_off(line)
    if string.len(line) == 0 then
        return {{''}}
    else
        local var = mic_cut_off(string.sub(line, 2))
        return TableConcat(char_add(string.sub(line, 1, 1), var), char_apply(string.sub(line, 1, 1), var))
    end
end

--mic_cut_off('bacac')
--var = mic_cut_off('acac') = 
--var = mic_cut_off('cac') = {{'c', 'a', 'c'}, {'c', 'a', 'c'}, {'c', 'ac'}, {'c', 'ac'}, {'ca', 'c'}, {'ca', 'c'}, {'cac'}, {'cac'}}
--var = mic_cut_off('ac') = {{'a', 'c'}, {'a', 'c'}, {'ac'}, {'ac'}}
--var = mic_cut_off('c') = {{'c'}, {'c'}}
--var = mic_cut_off('') = {{''}}
--return TableConcat(char_add('c', {{''}}), char_apply('c', {{''}})) -> TableConcat({{'c'}}, {{'c'}}) -> {{'c'}, {'c'}}
--return TableConcat(char_add('a', {{'c'}, {'c'}}), char_apply('a', {{'c'}, {'c'}})) -> {{'a', 'c'}, {'a', 'c'}, {'ac'}, {'ac'}}
--return TableConcat(char_add('c', {{'a', 'c'}, {'a', 'c'}, {'ac'}, {'ac'}}), char_apply('a', {{'a', 'c'}, {'a', 'c'}, {'ac'}, {'ac'}})) -> {{'c', 'a', 'c'}, {'c', 'a', 'c'}, {'c', 'ac'}, {'c', 'ac'}, {'ca', 'c'}, {'ca', 'c'}, {'cac'}, {'cac'}}
--return TableConcat(char_add('a', {{'c', 'a', 'c'}, {'c', 'a', 'c'}, {'c', 'ac'}, {'c', 'ac'}, {'ca', 'c'}, {'ca', 'c'}, {'cac'}, {'cac'}}), char_apply('a', {{'c', 'a', 'c'}, {'c', 'a', 'c'}, {'c', 'ac'}, {'c', 'ac'}, {'ca', 'c'}, {'ca', 'c'}, {'cac'}, {'cac'}})) ->
---> {{'a', 'c', 'a', 'c'}, {'a', 'c', 'a', 'c'}, {'a', 'c', 'ac'}, {'a', 'c', 'ac'}, {'a', 'ca', 'c'}, {'a', 'ca', 'c'}, {'a', 'cac'}, {'a', 'cac'}, {'ac', 'a', 'c'}, {'ac', 'a', 'c'}, {'ac', 'ac'}, {'ac', 'ac'}, {'aca', 'c'}, {'aca', 'c'}, {'acac'}, {'acac'}}
--return TableConcat(char_add('b', var), char_apply('b', var)) ->
--->...

--map function
function map(tbl, f)
    local t = {}
    for k,v in pairs(tbl) do
        t[k] = f(v)
    end
    return t
end

--filter function (like python one)
function table.filter(tbl, f)
    local t = {}
    for i = 1, #tbl do
        if f(tbl[i]) then 
            t[#t + 1] = tbl[i]
        end
    end
    return t
end


--function for analog of dictionary
function addNewItem(keyTable, myTable, key, value)
    table.insert(keyTable, key)
    myTable[key] = value 
end 

--getting minimum out of table. Key is an optional function parameter, if you need to change value of elements to get integer value
function min(array, key)
    if key == nil then
        key = function (x) return x end
    end
    local key_value = key(array[1])
    local result = array[1]
    for i = 2, #array do
        local temp = key(array[i])
        if temp < key_value then
            result = array[i]
            key_value = temp
        end
    end
    return result
end


result = mic_cut_off('bacacababa')
--uncomment next line if you want to see what it looks like before filtering (A LOT OF TEXT)
--print(printArray(result))
--checking whole table of tables and getting best table
function final_check(array_of_arrays)
    local result_local = {''}
    --getting a table where all characters are odd through filtering it
    local tble = table.filter(array_of_arrays, all_odd)
    --finding the one table with minimum amount of elements
    return table.concat(min(tble, function(x) return #x end), '|')
end
--printing best table
print(final_check(result))


--2: Details of min_cuts_odd:
--The min_cuts_odd function takes one argument that is a str containing lower-case letters. It returns a str containing those
--letters and the minimum number of '|' (vertical stroke) characters, cutting the string into substrings, such that every character
--appearing in a substring appears an odd number of times (call this the odd-count criteria). For example, calling
--min_cuts_odd('bacacababa') returns the solution 'bac|acaba|ba'. This solution cuts the argument string into 3 substrings
--('bac', 'acaba', and 'ba') that each satisfy the odd-count criteria; there is no solution with fewer than 2 '|' characters.
--There is alway a trivial solution to the odd-count criteria that is typically non-minimal: for example, 'cbbbbcca' has the
--trivial (non-minimal) solution 'c|b|b|b|b|c|c|a'. There are often multiple solutions for the same input: for example, 'cbbbbcca'
--has two minimal solutions, 'cb|bbbc|ca' and 'cbbb|bc|ca'. Your solution doesn't have to match the one I show, but it should
--always (a) satisfy the odd-count criteria and (b) have the same/minimum number of '|' characters.
