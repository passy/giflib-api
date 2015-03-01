module Main where

import Test.Hspec
import Test.QuickCheck

main :: IO ()
main = hspec $ do
    describe "app" $ do
        it "apps" $ property $
          \x -> (read . show $ x) == (x :: Int)
