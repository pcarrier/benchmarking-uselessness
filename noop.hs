module Main where
import System.Exit

main :: IO ()
main = do
 exitWith (ExitFailure 42)
