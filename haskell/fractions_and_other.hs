data Fractions = Fraction Int Int | Integral Int deriving (Show)


canon (Fraction a b) gcd_var = let numer = a `div` gcd_var; denom = b `div` gcd_var in 
    if denom == 1 then 
        Integral numer
    else 
        if denom > 0 then 
            Fraction numer denom 
        else 
            Fraction (-numer) (-denom)
            
add (Integral 0) (Integral 0) = Integral 0          
add (Integral 0) (Fraction c d) = canon (Fraction c d) (gcd c d)
add (Fraction a b) (Integral 0) = canon (Fraction a b) (gcd a b)
add (Fraction a 0) (Fraction c d) = error "Exception: You have 0 in one of the denominators"
add (Fraction a b) (Fraction c 0) = error "Exception: You have 0 in one of the denominators"
add (Fraction 0 b) (Fraction 0 d) = Integral 0 
add (Fraction a b) (Fraction 0 d) = canon (Fraction a b) (gcd a b)
add (Fraction 0 b) (Fraction c d) = canon (Fraction c d) (gcd c d)

add (Fraction a b) (Fraction c d) = let num = a*d + b*c; den = b*d; gcd_var = gcd num den in 
    canon (Fraction num den) gcd_var
    
  
sub (Integral 0) (Integral 0) = Integral 0          
sub (Integral 0) (Fraction c d) = canon (Fraction (-c) d) (gcd c d)
sub (Fraction a b) (Integral 0) = canon (Fraction a b) (gcd a b)
sub (Fraction a 0) (Fraction c d) = error "Exception: You have 0 in one of the denominators"
sub (Fraction a b) (Fraction c 0) = error "Exception: You have 0 in one of the denominators"
sub (Fraction 0 b) (Fraction 0 d) = Integral 0 
sub (Fraction a b) (Fraction 0 d) = canon (Fraction a b) (gcd a b)
sub (Fraction 0 b) (Fraction c d) = canon (Fraction (-c) d) (gcd c d)

sub (Fraction a b) (Fraction c d) = let num = a*d - b*c; den = b*d; gcd_var = gcd num den in 
    canon (Fraction num den) gcd_var

multip (Integral 0) (Integral 0) = Integral 0          
multip (Integral 0) (Fraction c d) = Integral 0 
multip (Fraction a b) (Integral 0) = Integral 0 
multip (Fraction a 0) (Fraction c d) = error "Exception: You have 0 in one of the denominators"
multip (Fraction a b) (Fraction c 0) = error "Exception: You have 0 in one of the denominators"
multip (Fraction 0 b) (Fraction 0 d) = Integral 0 
multip (Fraction a b) (Fraction 0 d) = Integral 0 
multip (Fraction 0 b) (Fraction c d) = Integral 0 

multip (Fraction a b) (Fraction c d) = let num = a*c; den = b*d; gcd_var = gcd num den in 
    canon (Fraction num den) gcd_var

divide (Integral 0) (Integral 0) = Integral 0          
divide (Integral 0) (Fraction c d) = Integral 0 
divide (Fraction a b) (Integral 0) = error "Exception: can't delete on 0 1"
divide (Fraction a 0) (Fraction c d) = error "Exception: You have 0 in one of the denominators"
divide (Fraction a b) (Fraction c 0) = error "Exception: You have 0 in one of the denominators"
divide (Fraction 0 b) (Fraction 0 d) = error "Exception: can't delete on 0 2"
divide (Fraction a b) (Fraction 0 d) = error "Exception: can't delete on 0 3"
divide (Fraction 0 b) (Fraction c d) = Integral 0 

divide (Fraction a b) (Fraction c d) = let num = a*d; den = b*c; gcd_var = gcd num den in 
    canon (Fraction num den) gcd_var



--add Integral a Integral b = Integral (a + b)
{-
--Peano

data Peano = Zero | Succ Peano deriving (Show)

add Zero b = b
add (Succ a) b = Succ (add a b)

sub a Zero = a

sub (Succ a) (Succ b) = sub a b
-}

{-
--length

length' :: (Num b) => [a] -> b  
length' [] = 0  
length' (_:xs) = 1 + length' xs

--1)
max' (x:[]) = x
max' (x:y:xs) = if x < y then max' (y:xs) else max' (x:xs)
--2)
max'(x:[]) = x
max'(x:xs) = let y = max' (xs) in if x < y then y else x

--factorial

factorial 1 = 1
factorial x = x * factorial (x - 1)

--fibo

fibo 0 = 0
fibo 1 = 1
fibo n = fibo (n - 2) + fibo (n - 1)

--map

map' f ([]) = []
map' f (x:[]) = f(x):[]
map' f (x:xs) = let y = f(x); z =  map' f xs in y:z

--filter

filter' f ([]) = []
filter' f (x:xs) = if f(x) == True then filter f (x:xs) else filter f xs

--partition 

qsort [] = []
qsort (x:[]) = x:[]
qsort x = let ancor = head (drop ((length x) `div` 2) x) in qsort (filter (< ancor) x) ++ (ancor:(filter (> ancor) x)) 


merging [] [] = []
merging [] (y:ys) = y:merging [] ys
merging (x:xs) [] = x:merging xs []
merging (x:xs) (y:ys) = if x < y then x:(merging xs (y:ys)) else y:(merging (x:xs) ys)


mergeSort [] = []
mergeSort (x:[]) = x:[]
mergeSort xs = let 
    x = mergeSort (take ((length xs) `div` 2) xs); 
    y = mergeSort (drop ((length xs) `div` 2) xs) 
    in 
        merging x y

-- bubble 


bubbling [] = []
bubbling (x:[]) = x:[]
bubbling (x:y:xs) = if x < y then x:bubbling (y:xs) else y:bubbling (x:xs)

bubbleSort [] = []
bubbleSort (x:[]) = x:[]
bubbleSort (x:xs) = let sorted = bubbling (x:xs) in 
    if (x:xs) /= sorted then 
        bubbleSort(sorted)
    else
        x:xs
-}