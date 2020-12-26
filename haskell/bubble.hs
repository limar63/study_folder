import Debug.Trace
--length' :: (Num b) => [a] -> b  
--length' [] = 0  
--length' (_:xs) = 1 + length' xs

--max' (x) = x 

{-
max' (x:xs) = if length xs == 0 then 
    if x < head xs then 
        max xs 
    else max' (x:tail xs) 
else x
-}

--1)
--max' (x:[]) = x
--max' (x:y:xs) = if x < y then max' (y:xs) else max' (x:xs)
--2)
--max'(x:[]) = x
--max'(x:xs) = let y = max' (xs) in if x < y then y else x

--factorial 1 = 1
--factorial x = x * factorial (x - 1)

--fibo 0 = 0
--fibo 1 = 1
--fibo n = fibo (n - 2) + fibo (n - 1)

--map' f ([]) = []
--map' f (x:[]) = f(x):[]
--map' f (x:xs) = let y = f(x); z =  map' f xs in y:z

--filter' f ([]) = []
--filter' f (x:xs) = if f(x) == True then filter f (x:xs) else filter f xs

--partition 

--qsort [] = []
--qsort (x:[]) = x:[]
--qsort x = let ancor = head (drop ((length x) `div` 2) x) in qsort (filter (< ancor) x) ++ (ancor:(filter (> ancor) x)) 

{- 
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
-}
bubbling [] = []
bubbling (x:[]) = x:[]
bubbling (x:y:[]) = if x < y then x:y:[] else y:x:[]
bubbling (x:y:xs) = if x < y then x:bubbling (y:xs) else y:bubbling (x:xs)

bubbleSort [] = []
bubbleSort (x:[]) = x:[]
bubbleSort (x:xs) = let sorted = bubbling (x:xs) in 
    if (x:xs) /= sorted then 
        bubbleSort(x:xs)
    else
        x:xs

