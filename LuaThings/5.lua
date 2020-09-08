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

function table.concat(t1,t2)
    if t1 == nil then
        return t2
    elseif t2 == nil then
        return t1
    else
        for i=1,#t2 do
            t1[#t1+1] = t2[i]
        end
    end
    return t1
end

function DeleteA(L, X)
    if L[1] == X then
        return table.slice(L, 2)
    else
        return table.concat({L[1]}, DeleteA(table.slice(L, 2), X))
    end
end

function DeleteB(L, X)
    if L[1] == nil then
        return nil
    elseif L[1] == X then
        return DeleteB(table.slice(L, 2), X)
    else
        return table.concat({L[1]}, DeleteB(table.slice(L, 2), X))
    end
end

array_for_delete = DeleteB({'a', {'b', 'c'}, 'b', 'c', 'x', 'x', 'b', 'b', 'c', 'd'}, 'b')

result = ''
for i = 1, #array_for_delete do
    if type(array_for_delete[i]) == 'table' then
        result = result .. '{'
        for j=1, #array_for_delete[i] do
            result = result .. array_for_delete[i][j] .. ' '
        end
        result = string.sub(result, 1, string.len(result) - 1)
        result = result .. '}' .. ' '
    else
        result = result .. array_for_delete[i] .. ' '
    end
end

print(result)