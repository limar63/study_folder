import math

def Sort(p, r):
    global A
    if p < r:
        q = math.trunc((p+r)/2)
        Sort(p, q)
        Sort(q + 1, r)
        Merge(p, q, r)

def Merge(p, q, r):
    global A
    print("Getting two sortings ", A[p - 1:q], " and ", A[q:r], " whole A is ", A, "P is", p, "q is ", q, "r is ", r)
    if ((q - p + 1) <= 1) and ((r - q) <= 1):
        #print("Got it")
        if A[p - 1] > A[q]:
            temp = A[p - 1]
            A[p - 1] = A[q]
            A[q] = temp
    else:
        #print("Not got it")
        temp = []
        i = p - 1
        j = q
        #print("I is ", A[i], "J is", A[j], "len 1 is ", len(A[:q]), "len2 is ", len(A[:r]), " i index is", i, " j index is ", j)
        while (i < len(A[:q])) and (j < len(A[:r])):
            #print("Then I is ", A[i], "J is", A[j], "i index is ", i, "j index is ", j)
            if A[i] < A[j]:
                print("Adding ", A[i])
                temp = temp + [A[i]]
                i = i + 1
            else:
                print("Adding ", A[j])
                temp = temp + [A[j]]
                j = j + 1
        #print("Temp is ", temp)
        #print("before", A, "not temp ", A[p - 1:r], "temp", temp)
        #Sort(temp, p + 1, len(temp))
        temp = temp + A[i:q] + A[j:r]
        print("Temp after is ", temp, "A before is ", A, "also ", A[:p])
        A = A[:p - 1] + temp + A[r:len(A)]
        print("after", A)

A = [5,2,4,6,1,3,2,6, 1, 0, 3, 2, 4, 6, 10, 9, 8, 4]

Sort(1, len(A))
print(A)
