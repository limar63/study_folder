

function takeBool(bool_val)
    if bool_val then
        return '#t'
    else
        return '#f'
    end
end

function table.slice(tbl, first, last, step)
    local sliced = {}
  
    for i = first or 1, last or #tbl, step or 1 do
      sliced[#sliced+1] = tbl[i]
    end
  
    return sliced
end

function TableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

function compare(f, cont)
    return function(x) 
        if #x == nil then
            return cont('#f')
        elseif #x == 1 then
            return cont('#t')
        elseif #x == 2 then
            return cont(takeBool(f(x)))
        else
            if not f(x) then
                return cont('#f')
            else
                return takeBool(f(TableConcat(table.slice(x, 1, 1), table.slice(x, 3))))
            end
        end
    end
end

more_than = compare(function(x) return x[1] > x[2] end, cont)
less_than = compare(function(x) return x[1] < x[2] end, cont)
equal_or_less_than = compare(function(x) return x[1] <= x[2] end, cont)
equal_or_more_than = compare(function(x) return x[1] >= x[2] end, cont)
equal = compare(function(x) return x[1] == x[2] end, cont)
nonequal = compare(function(x) return x[1] ~= x[2] end, cont)

print(more_than({5, 4, 3}))

--function equal_func(args,cont)                                                               --returns --t if all arguments are equal, otherwise --f (= arg ...)
--    if #args == 0 then
--        return cont('#f')
--    elseif #args == 1 then
--        return cont('#t')
--    elseif #args == 2 then
--        return cont(takeBool(args[1] == args[2]))
--    else
--        if not (args[1] == args[2]) then                                                      --we check current element and the next element if they are not equal
--            return cont('#f') 
--        else
--            return equal_func(TableConcat(table.slice(args, 1, 1), table.slice(args, 3)), cont)      
--        end
--    end                                                            
--end