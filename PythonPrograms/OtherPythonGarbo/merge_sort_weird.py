import math

def Sort(A, p, r):
    if p < r:
        q = math.trunc((p+r)/2)
        Sort(A, p, q)
        Sort(A, q + 1, r)
        Merge(A, p, q, r)

def Merge(A, p, q, r):
    i = p - 1
    j = q
    first_limit = q
    while (i != first_limit) and (j != r):
        if A[i] > A[j]:
            A[i], A[j] = A[j], A[i]
            first_limit = first_limit + 1
            i = p - 1
            j = q
        elif i == j:
            i = p - 1
            j = j + 1
        else:
            i = i + 1


A = [5,2,4,6,1,3,2,6,0,4,9,12,11,3,2,6,7,-5]

Sort(A, 1, len(A))
print(A)
