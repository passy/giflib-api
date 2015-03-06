{-# LANGUAGE OverloadedStrings #-}
module Main where

import Data.Aeson (decode)
import Data.Maybe (fromJust)
import Network.URI (parseURI)
import Test.Hspec
import Test.QuickCheck
import Types

main :: IO ()
main = hspec $ do
    describe "app" $ do
        it "apps" . property $
          \x -> (read . show $ x) == (x :: Int)
    describe "FromJSON Link" $ do
        it "parses a valid link" $ do
            let json = "{\"link\": \"https://twitter.com/\", \"tags\": [\"foo\", \"bar\"]}"
            let obj = decode json :: Maybe Link
            obj `shouldBe` Just Link {link = fromJust $ parseURI "https://twitter.com/", tags = [Tag "foo", Tag "bar"]}
        it "parses an invalid link" $ do
            let json = "{\"link\": \"!not/a/link\", \"tags\": [\"foo\", \"bar\"]}"
            let obj = decode json :: Maybe Link
            obj `shouldBe` Nothing
