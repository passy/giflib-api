{-# LANGUAGE GeneralizedNewtypeDeriving, DeriveDataTypeable, TypeFamilies, TemplateHaskell, OverloadedStrings, InstanceSigs #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}
module Types where

import Network.URI (URI, URIAuth, parseURI)
import Control.Applicative ((<$>), pure)
import Control.Monad (forM_, mzero)
import Control.Monad.Reader (ask)
import Control.Monad.State (get, put)
import Data.Acid (Query, Update, makeAcidic)
import Data.Aeson ((.:))
import Data.Aeson.TH (deriveJSON, deriveToJSON, defaultOptions)
import Data.Aeson.Types (FromJSON(..), Parser, Value(..))
import Data.Foldable (concat)
import Data.SafeCopy (deriveSafeCopy, base)
import Data.Typeable (Typeable)
import Prelude hiding (concat)

import qualified Data.Map as Map

newtype Tag = Tag String
    deriving (Show, Typeable, Eq, Ord)

data Link = Link { link :: URI
                 , tags :: [Tag]
                 }
    deriving (Show, Typeable)

-- Seems like a horrible hack, but let's make this work first
-- before worrying about space/update efficiency.
newtype Links = Links { getLinkMap :: Map.Map Tag [Link] }
    deriving (Show, Typeable)

instance FromJSON Link where
    parseJSON :: Value -> Parser Link
    parseJSON (Object o) = do
        linkStr <- o .: "link"
        let link' = parseURI linkStr
        tags' <- o .: "tags"

        -- Well, this works.
        -- Goes without saying there's a better way to do this.
        -- But with Haskell, the make it work first, then refactor rule works
        -- incredibly well thanks to the type system. So this is for next time.
        case link' of
             Just l -> return $ Link l tags'
             Nothing -> mzero

    parseJSON _ = mzero

-- Orphan safecopy instances for URI-related things
deriveSafeCopy 0 'base ''URI
deriveSafeCopy 0 'base ''URIAuth

deriveSafeCopy 0 'base ''Tag
deriveSafeCopy 0 'base ''Link
deriveSafeCopy 0 'base ''Links

-- Orphan JSON instances for URI-related things
deriveJSON defaultOptions ''URI
deriveJSON defaultOptions ''URIAuth
deriveJSON defaultOptions ''Tag
deriveToJSON defaultOptions ''Link

getLinksByTag :: Tag -> Query Links [Link]
getLinksByTag tag = concat . Map.lookup tag . getLinkMap <$> ask

getLinks :: Query Links [Link]
getLinks = concat . Map.elems . getLinkMap <$> ask

postLink :: Link -> Update Links ()
postLink link' = forM_ (tags link') $ \t -> do
    linkMap <- getLinkMap <$> get
    let newLinks = maybe (pure link') (link' :) (Map.lookup t linkMap)
    put . Links $ Map.insert t newLinks linkMap

makeAcidic ''Links ['getLinksByTag, 'getLinks, 'postLink]
