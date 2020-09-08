--Определить функцию (LastAtom L), выбирающую последний от
--начала списка (невзирая на скобки) атом списка:
--(LastAtom '(((5)A))) => A

--Just realized I should add reversing of the given table in case if step is <0 and maybe check it for a valid input
function table.slice(tbl, first, last, step)
    local sliced = {}
    for i = first or 1, last or #tbl, step or 1 do
        sliced[#sliced + 1] = tbl[i]
    end
    return sliced
end



function LastAtom(L)
    if not (type(L) == 'table') then
        return L
    else
        if not (L[2] == nil) then
            return LastAtom(table.slice(L, 2))
        else
            return LastAtom(L[1])
        end
    end
end

print(LastAtom({{2}}))
