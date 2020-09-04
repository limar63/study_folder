function table.slice(tbl, first, last, step)
    local sliced = {}
    for i = first or 1, last or #tbl, step or 1 do
        sliced[#sliced + 1] = tbl[i]
    end
    return sliced
end

function table.concat(t1,t2)
    print('t1 is', t1)
    print('t2 is', t2)
    if t1 == nil then
        return t2
    elseif t2 == nil then
        return t1
    --elseif type(t2) == 'number' then
        --t2 = {t2}
    else
        for i=1,#t2 do
            t1[#t1+1] = t2[i]
        end
    end
    return t1
end

function Remove2(L)
    if L[1] == nil then
        print('L1 is nil')
        return L[1]
    elseif L[2] == nil then
        print('L2 is nil')
        return {L[1]}
    else
        print('going', table.slice(L, 3))
        return table.concat({L[1]}, Remove2(table.slice(L, 3)))
    end
end

array_for_delete = Remove2({1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11})

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
--Написать функцию (Remove2 L), удаляющую из списка каждый
--второй элемент верхнего уровня:
--(Remove2 '(A B C D E)) => (A C E).