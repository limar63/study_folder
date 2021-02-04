--It's a bullshit code that doesn't work

--function min_cuts_off(str)
    --if all_odd(str) and minimum_strokes(str) then
        --return table.concat(str, "|")
    --elseif not all_odd(str) then
        --return (min_cuts_off(add_strokes(str)))
    --elseif type(str) == 'string' then
        --return (min_cuts_off(add_strokes({str})))
    --else
        --return (min_cuts_off(decreasing_strokes(str)))
    --end
--end

--function add_strokes(nonoddarray)
    --local maybe_odd_array = {}
    --for i = 1, #nonoddarray do
        --if not part_odd_check(nonoddarray[i], {}, {}) then
            --if string.len(nonoddarray[i]) % 2 == 0 then
                --table.insert(maybe_odd_array, string.sub(nonoddarray[i], 1, string.len(nonoddarray[i]) / 2))
                --table.insert(maybe_odd_array, string.sub(nonoddarray[i], string.len(nonoddarray[i]) / 2 + 1))
            --else
                --table.insert(maybe_odd_array, string.sub(nonoddarray[i], 1, string.len(nonoddarray[i]) / 2 - 0.5))
                --table.insert(maybe_odd_array, string.sub(nonoddarray[i], string.len(nonoddarray[i]) / 2 + 0.5))
            --end
        --else
            --table.insert(maybe_odd_array, nonoddarray[i])
        --end
    --end
    --return maybe_odd_array
--end

function all_odd(arr)
    for i = 1, #arr do
        if not (part_odd_check(arr[i], {}, {})) then
            return false
        end
    end
    return true
end

--function minimum_strokes(arr)
    --local potentially_less_strokes_arr = {}
    --for i = 1, #arr do
        --minimum
    --end
--end

--function min_cuts_off(baseline)
    --if string.len(baseline) == 0 then
        --return {''}
    --else
        --local table_test = {}
        --for i = 1, #baseline do
            --TableConcat(table_test, char_apply(string.sub(baseline, i, i), min_cuts_off(string.sub(baseline, 1, i - 1) .. string.sub(baseline, i + 1))))
        --end
        --return table_test
    --end
--end
--print(min_cuts_off({'bacacababa'}))
--listt = min_cuts_off('aaccbbb')
--result = ''
--print(listt[3])
--for i = 1, #listt do
    --result = result .. ' ' .. min_cuts_off({listt[i]})
--end
--print(result)


--function table.shallow_copy(t)
    --local t2 = {}
    --for k,v in pairs(t) do
      --t2[k] = v
    --end
    --return t2
--end
  
--copy = table.shallow_copy(a)

--ba|c|ac|ab|a|ba

function TableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

function char_add(charac, arr)
    local arr1 = {}
    for i = 1, #arr do
        local arr2 = {charac}
        TableConcat(arr1, TableConcat(arr2, arr[i]))
    end
    return arr1
end

function addNewItem(keyTable, myTable, key, value)
    table.insert(keyTable, key)
    myTable[key] = value 
end 

function char_apply(charac, arr)
    local arr1 = {}
    for i = 1, #arr do
        arr1[i] = arr[i] .. charac
    end
    return arr1
end

function min_cuts_off(baseline)
    if string.len(baseline) == 0 then
        return {''}
    else
        local table_test = {}
        for i = 1, #baseline do
            TableConcat(table_test, TableConcat(char_add(string.sub(baseline, i, i), min_cuts_off(string.sub(baseline, 1, i - 1) .. string.sub(baseline, i + 1))), char_apply(string.sub(baseline, i, i), min_cuts_off(string.sub(baseline, 1, i - 1) .. string.sub(baseline, i + 1)))))
            --TableConcat(table_test, char_apply((string.sub(baseline, 1, i) .. '|'), min_cuts_off(string.sub(baseline, i + 1))))
        end
        return table_test
    end
end

--print(table.concat(min_cuts_off('bacacababa'), ' '))

--Doing set()
function strokes_all_odd(line)
    local last_stroke = 1
    for i = 1, string.len(line) do
        if string.sub(line, i, i) == '|' then
            if not (part_odd_check(string.sub(line, last_stroke, i - 1), {}, {})) then
                return false
            end
            last_stroke = i
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

function checking_odd(array)
    local result = ''
    local count = 999
    for i = 1, #array do
        if strokes_all_odd(array[i]) then
            local check_count = 0
            for j = 1, string.len(array[i]) do   
                if array[i][j] == '|' then
                    check_count = check_count + 1
                end
            end
            if count > check_count then
                result = array[i]
            end
        end
    end
    return result
end

--print(table.concat(min_cuts_off('bacba'), ' '))
local test = min_cuts_off('bacba')
local hash = {}
local res = {}

for _,v in ipairs(test) do
   if (not hash[v]) then
       res[#res+1] = v -- you could print here instead of saving to result table if you wanted
       hash[v] = true
   end
end

for i = 1, #test do
    print(test[i])
end 