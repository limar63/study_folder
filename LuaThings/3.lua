--Запрограммировать функцию (Bubl N A) с двумя вычисляемыми
--аргументами – числом N и атомом A. Функция строит список глубины
--N; на самом глубоком уровне элементом списка является A, а на
--любом другом уровне список состоит из одного элемента. Например:
--(Bubl 3 5)=>(((5))).

function Buble(N, A)
    if N == 0 then
        return A
    else
        return {Buble(N - 1, A)}
    end
end

print(Buble(3, 5)[1][1][1])

