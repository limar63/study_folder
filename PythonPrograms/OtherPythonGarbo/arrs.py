def arraying(i, j, array, size_of_nested):
    return array[size_of_nested*i + j]

m =[[1,2,3],[4,5,6],[7,8,9]]
w =[1,2,3,4,5,6,7,8,9]

i = 0
j = 0
print(arraying(0, 0, w, len(m[0])))
print(m[0][0])
