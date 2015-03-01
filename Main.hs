{-# LANGUAGE OverloadedStrings #-}

import qualified Web.Scotty as S

import Types

main :: IO ()
main = S.scotty 3000 $
    S.get "/" $
        S.html "Hello, World!"
