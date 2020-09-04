function alternative_stroke_filling(baseline)
    if string.len(baseline) == 0 then
        return {''}
    else
        local table_test = {}
        for i = 1, #baseline do
            TableConcat(table_test, char_apply(string.sub(baseline, i, i), transpositions(string.sub(baseline, 1, i - 1) .. string.sub(baseline, i + 1))))
            --TableConcat(table_test, char_apply(string.sub(baseline, i, i), transpositions(string.sub(baseline, 1, i - 1) .. string.sub(baseline, i + 1))))
        end
    end
end

function alternative_stroke_filling(baseline)
    if string.len(baseline) == 0 then
        print(not doing)
        return {''}
    else
        print('doing')
        local table_test = {}
        for i = 1, string.len(baseline) - 1 do
            print('forring')
            TableConcat(table_test, {string.sub(baseline, 1, i) .. '|' .. string.sub(baseline, i + 1)})
            --alternative_stroke_filling(string.sub(baseline, 1, i - 1) .. string.sub(baseline, i + 1))
            --TableConcat(table_test, char_apply(string.sub(baseline, i, i), transpositions(string.sub(baseline, 1, i - 1) .. string.sub(baseline, i + 1))))
        end
        print('thingy happened')
        return table_test
    end
end