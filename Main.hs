{-# LANGUAGE OverloadedStrings #-}

import Types (Links(Links)
            , Tag(Tag)
            , PostLink(PostLink)
            , GetLinks(GetLinks)
            , GetLinksByTag(GetLinksByTag))
import Control.Applicative ((<$>))
import Control.Monad.Trans (lift)
import Data.Acid (openLocalState, query, update)
import Data.Time (getCurrentTime)
import qualified Web.Scotty as S
import qualified Data.Map as Map

main :: IO ()
main = do
    acid <- openLocalState (Links Map.empty)
    S.scotty 3000 $ do
        S.get "/" $ do
            links <- lift $ query acid GetLinks
            S.json links
        S.post "/" $ do
            link <- S.jsonData
            now <- lift getCurrentTime
            lift $ update acid (PostLink now link)
        S.get "/tags/:tag" $ do
            tag <- Tag <$> S.param "tag"
            links <- lift $ query acid (GetLinksByTag tag)
            S.json links
