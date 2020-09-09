--2+3*4

--3*4

--[]+2

--cont=function(x) return x+2 end

--cont(3*4)

--1+f(42)*2

--1+[]*2

--cont = function(x) return x*2 + 1

--cont(f(42))

function rec(number)
    if number == 1 then
	    return 1
    else
	    return number * rec(number - 1)
    end
end



function rec(number, cont)
    if number == 1 then
	    return cont(1)
    else
	    return rec(number - 1, function(x) return cont(number * x) end)
    end
end

--4   fact(3,[]*4)

function identity(argument)
    return argument
end

--print(rec(5, identity))


function fibo(number)
    if number == 1 or number == 2 then
	    return 1
    else
	    return fibo(number - 1) + fibo(number - 2)
    end
end


function fibo(number, cont)
    --print('number is', number)
    if number == 1 or number == 2 then
	    return cont(1)
    else
	    return fibo(number - 1, function(x) return fibo(number - 2, function (y) return cont(x + y) end) end)
    end
end

print(fibo(5, identity))

function tail_fact(number, accum)
    if number == 1 then
	return accum
    else
	return tail_fact(number - 1, accum * number)
    end
end

function tail_fact(number, accum, cont)
    if number == 1 then
	    return cont(accum)
    else
	    return tail_fact(number - 1, accum * number, cont)
    end
end


--(LAMBDA (X) (CAR X)) = CAR

a={{1,42},{5,13},{8,666}}

--assoc(5,a) -> 13

function table.slice(tbl, first, last, step)
    local sliced = {}
  
    for i = first or 1, last or #tbl, step or 1 do
      sliced[#sliced+1] = tbl[i]
    end
  
    return sliced
end


function assoc(key, array, cont_t, cont_f)
    if #array == 0 then
	return cont_f()
    elseif key == array[1][1] then 
	return cont_t(array[1][2])
    else
	return assoc(key, table.slice(array, 2), cont_t, cont_f)
    end
end

--(errset (/ 1 0))

--assoc(5, a, function(x) print(x) end, function() print('Exception: Element not found') end)




