--Составить функцию (Delete L X), удаляющую из списка L на его верхнем уровне
--  а) первое вхождение значения Х;
--  б) все вхождения значения Х.
--Работает только с первичной глубиной, остальные игнорирует!

function table.slice(tbl, first, last, step)
    local sliced = {}
    for i = first or 1, last or #tbl, step or 1 do
        sliced[#sliced + 1] = tbl[i]
    end
    return sliced
end

function TableConcat(t1,t2)                                                                                    --Function which adds second table to the first one and returns the summed table
    if t2 ~= nil then
        for i=1,#t2 do
            t1[#t1+1] = t2[i]
        end
    end
    return t1
end


function map(tbl, f)                                                                                           --higher order function, which applies function to all elements inside the table
    -- print('Mapping ', tbl)
     local t = {}
     for k,v in pairs(tbl) do
         t[k] = f(v)
     end
     return t
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

function DeleteA(L, X)
    if L[1] == X then
        return table.slice(L, 2)
    else
        return TableConcat({L[1]}, DeleteA(table.slice(L, 2), X))
    end
end

function DeleteB(L, X)
    if L[1] == nil then
        return nil
    elseif L[1] == X then
        return DeleteB(table.slice(L, 2), X)
    else
        return TableConcat({L[1]}, DeleteB(table.slice(L, 2), X))
    end
end
var_for_delition = 'b'
print('Only one deletion of', var_for_delition, 'is:', printArray(DeleteA({'a', {'b', 'c'}, 'b', 'c', 'x', 'x', 'b', 'b', 'c', 'd'}, var_for_delition)))
print('Deleting of all   ', var_for_delition, 'is:', printArray(DeleteB({'a', {'b', 'c'}, 'b', 'c', 'x', 'x', 'b', 'b', 'c', 'd'}, var_for_delition))) 
