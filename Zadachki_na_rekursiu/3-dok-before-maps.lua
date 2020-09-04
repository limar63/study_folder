function NestedNonsenseIntoString(array)
    local result = '{'
    for i = 1, #array do
        result = result .. '{'
        for j = 1, #array[i] do
            result = result .. array[i][j] .. ', '
        end
        result = string.sub(result, 1, string.len(result) - 2)
        result = result .. '}, '
    end
    result = string.sub(result, 1, string.len(result) - 2) .. '}'
    return result
end

function table.slice(tbl, first, last, step)
    local sliced = {}
  
    for i = first or 1, last or #tbl, step or 1 do
      sliced[#sliced+1] = tbl[i]
    end
  
    return sliced
  end

function copy_string_arr(array)
    local copy = {}
    for i = 1, #array do
        copy[i] = string.sub(array[i], 1)
    end
    return copy
end

function char_apply(charac, arr)
    local arr1 = {{}}
    for i = 1, #arr do
        if arr1[i] == nil then
            table.insert(arr1, i, {})
        end
        arr1[i][1] = charac .. arr[i][1]
        for j = 2, #arr[i] do
            arr1[i][j] = arr[i][j]
        end
    end
    return arr1
end
    
function char_add(charac, arr)
    local arr1 = {}
    local var = {}
    for i = 1, #arr do
        if table.concat(arr[i]) == '' then
            var = {string.sub(charac, 1)}
        else
            var = TableConcat({string.sub(charac, 1)}, copy_string_arr(arr[i]))
        end
        table.insert(arr1, var)
    end
    return arr1
end

function table.shallow_copy(t)
    local t2 = {}
    for k,v in pairs(t) do
      t2[k] = v
    end
    return t2
end

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

function all_odd(arr)
    for i = 1, #arr do
        if not (part_odd_check(arr[i], {}, {})) then
            return false
        end
    end
    return true
end

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

function mic_cut_off(line)
    if string.len(line) == 0 then
        return {{''}}
    else
        local var = mic_cut_off(string.sub(line, 2))
        print('var is', NestedNonsenseIntoString(var))
        print('charac is', string.sub(line, 1, 1))
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

function map(tbl, f)
    local t = {}
    for k,v in pairs(tbl) do
        t[k] = f(v)
    end
    return t
end

function addNewItem(keyTable, myTable, key, value)
    table.insert(keyTable, key)
    myTable[key] = value 
end 

result = mic_cut_off('bacac')

print(NestedNonsenseIntoString(result))

function final_check(array_of_arrays)
    local length = string.len(table.concat(array_of_arrays[1]))
    local resulting = ''
    for i = 1, #array_of_arrays do
        if all_odd(array_of_arrays[i]) and #array_of_arrays[i] < length then
            resulting = table.concat(array_of_arrays[i], '|')
            length = #array_of_arrays[i]
        end
    end
    return resulting
end

print(final_check(result))
