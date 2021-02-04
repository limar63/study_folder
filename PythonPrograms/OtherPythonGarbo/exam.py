#'abc' -> 
['bac','cab','acb','cba','bca','abc']

# n!=1*2*...*n

# 3!=1*2*3=6

# 'a','bc'
# ['bc','cb']
# ['bc','cb']
# ['abc','acb']
# 'b','ac'
# ['bac','bca']
# 'c','ab'
# ['cab','cba']
#permutations

a=[1,2]
b=[3,4]
c=[5,6]
[1,2,3,4,5,6]
a.append(b)

def permutations(s):
    if s == '':
        return [s] # since 'abc' => permutates to 'abc' (itself)
    b = []
    for i in range(len(s)):
        b += [s[i] + j for j in permutations(s[:i] + s[i+1:])]
        #s2 = s[i] + permutations(s1)
    return b
#print(permutations('abcd'))
# for i in range(1,10):
#     a=1
#     a+=a
    
# sum=0
# for i in range(1,10):
#     sum+=i
    
# a=[1,2,3]
# for i in a:
#     b.append(i*2)
# print(b)


# 'abcd'


# "".join(['a','bcd'])
# [['a','bcd']
# ['ab','cd']
# ['abc','d']
# ['abcd'] ]

# 'abcd'
# 'a','bcd'

# [['b','cd'], ['bc','d'], ['b','c','d']]
# [['a','b','cd'], ['a','bc','d'], ['a', 'b','c','d']]
# [['ab','cd'], ['abc','d'], ['ab','c','d']]

# [['a','b','cd'], ['a','bc','d'], ['a', 'b','c','d'],['ab','cd'], ['abc','d'], ['ab','c','d']]

def breakups(s):
    if len(s) <=1:
        return [[s]]
    
    first = s[0]
    other = breakups(s[1:])
    lst = [[first] + i for i in other]
    lst_1 = [[first + i[0]] + i[1:] for i in other]
    return lst + lst_1

# 'aabbb'  -> False
# 'abcccccbb' -> True

# {'a','b','c'}
#print(breakups(''))
def odd(s):
    return all(s.count(i)%2==1 for i in set(s))
    # for i in set(s):
    #     if s.count(i)%2 == 1:
    #         return True
    # return False
    
#print(odd('abcccccbb'))

#['a','b','cd'] -> 'a|b|cd'

def min_counts_odds(s):
    lst = [i for i in breakups(s) if len(i) > 1 and all(odd(j) for j in i) ]
    #print(lst)
    a =  min(lst,key = lambda x:len(x))
    #print(a)
    return '|'.join(a)
    
print(min_counts_odds('bacacababa'))
    
# join all funcs together in breakups 