import math

def merge_sort(arr):
    if len(arr) < 2:
        return arr
    else:
        q = math.trunc(len(arr)/2)
        return merge(merge_sort(arr[0:q]), merge_sort(arr[q:len(arr)]))


def merge(arr1, arr2):
    temp = []
    i = 0
    j = 0
    while i < len(arr1) and j < len(arr2):
        if arr1[i] < arr2[j]:
            temp.append(arr1[i])
            i = i + 1
        else:
            temp.append(arr2[j])
            j = j + 1
    return temp + arr1[i:len(arr1)] + arr2[j:len(arr2)]

print(merge_sort([5,2,4,6,1,3,2,6]))