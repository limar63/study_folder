final_array = {}

function map(f, t)
    local t1 = {}
    local t_len = #t
    for i = 1, t_len do
        t1[i] = f(t[i])
    end
    return t1
end

function char_apply(charac, arr)
    local arr1 = {}
    for i = 1, #arr do
        arr1[i] = arr[i] .. charac
    end
    return arr1
end


function transpositions(baseline)
    if string.len(baseline) == 0 then
        return {''}
    else
        local table_test = {}
        for i = 1, #baseline do
            TableConcat(table_test, char_apply(string.sub(baseline, i, i), transpositions(string.sub(baseline, 1, i - 1) .. string.sub(baseline, i + 1))))
        end
        return table_test
    end
end

function TableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

print(table.concat(transpositions('abcde'), ', '))

--TableConcat({}, char_apply('a', transpositions('bcde')))
--TableConcat({}, char_apply('a', TableConcat({}, char_apply('b', transpositions('cde')))))
--TableConcat({}, char_apply('a', TableConcat({}, char_apply('b', TableConcat({}, char_apply('c', TableConcat({}, char_apply('d', transpositions('e')))))))))
--TableConcat({}, char_apply('a', TableConcat({}, char_apply('b', TableConcat({}, char_apply('c', TableConcat({}, char_apply('d', TableConcat({}, char_apply('e', transpositions('')))))))))))
--TableConcat({}, char_apply('a', TableConcat({}, char_apply('b', TableConcat({}, char_apply('c', TableConcat({}, char_apply('d', TableConcat({}, char_apply('e', {''}))))))))))
--TableConcat({}, char_apply('a', TableConcat({}, char_apply('b', TableConcat({}, char_apply('c', TableConcat({}, char_apply('d', {'e'}))))))))
--TableConcat({}, char_apply('a', TableConcat({}, char_apply('b', TableConcat({}, char_apply('c', {'de'}))))))
--TableConcat({}, char_apply('a', TableConcat({}, char_apply('b', {'cde'}))))
--TableConcat({}, char_apply('a', {'bcde'}))
--{'abcde'}
