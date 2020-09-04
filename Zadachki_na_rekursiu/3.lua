function Buble(N, A)
    if N == 0 then
        return A
    else
        return {Buble(N - 1, A)}
    end
end

print(Buble(3, 5)[1][1][1])