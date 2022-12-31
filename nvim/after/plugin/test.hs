module Main where


main :: IO ()
main = do
    let a = length [1,3,4,5]
    putStrLn (show a)
    return ()
