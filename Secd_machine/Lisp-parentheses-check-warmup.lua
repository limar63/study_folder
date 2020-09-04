function parentheses(line, count_o, count_c)
    if string.len(line) == 1 then
        if string.sub(line, 0, 1) == ')' then
            return true
        else
            return false
        end
    else
        if string.sub(line, 0, 1) == '(' then
            count_o = count_o + 1
        else
            count_c = count_c + 1
        end
        if count_o > count_c then
            return parentheses(string.sub(line, 2), count_o, count_c)
        else
            return false
        end
    end
end

print(parentheses('(())(())', 0, 0))