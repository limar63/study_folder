{-
--{-# LANGUAGE FlexibleContexts #-}

import qualified Text.Parsec as Parsec


main = do
    let result = parse (Parsec.char 'H') "Hello"
    case result of
        Right v -> putStrLn "success!"
        Left err -> putStrLn ("whoops, error: "++show err)
-}

lucky :: Int -> String  
lucky 7 = "LUCKY NUMBER SEVEN!"  
lucky x = "Sorry, you're out of luck, pal!"