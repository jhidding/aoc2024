-- ~/~ begin <<docs/day11.md#haskell/app/Day11.hs>>[init]
module Main where

import qualified Data.Text as T
import qualified Data.Text.IO as T.IO
import Control.Monad.IO.Class (MonadIO, liftIO)
import Data.MemoTrie (memoFix)

readInput :: (MonadIO m) => m [Int]
readInput = liftIO $ fmap (read . T.unpack) . T.words <$> T.IO.getContents

ndigits :: Int -> Int
ndigits x
    | x < 10 = 1
    | otherwise = ndigits (x `div` 10) + 1

countStones :: ((Int, Int) -> Int) -> (Int, Int) -> Int
countStones f (x, n)
    | n == 0            = 1
    | x == 0            = f (1, n - 1)
    | even $ ndigits x  = f (x `div` q, n - 1) + f (x `mod` q, n - 1)
    | otherwise         = f (x * 2024, n - 1)
    where q = 10^(ndigits x `div` 2)

blink :: [Int] -> Int -> Int
blink input n = sum [cs (i, n) | i <- input]
    where cs = memoFix countStones

main :: IO()
main = do
    input <- readInput
    print $ blink input 25
    print $ blink input 75
-- ~/~ end
