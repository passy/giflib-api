{-# LANGUAGE GeneralizedNewtypeDeriving, DeriveDataTypeable, TypeFamilies, TemplateHaskell, OverloadedStrings, InstanceSigs #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}
module Types where

import Control.Applicative ((<$>), pure, (<*>))
import Control.Monad (forM_, mzero)
import Control.Monad.Reader (ask)
import Control.Monad.State (get, put)
import Data.Acid (Query, Update, makeAcidic)
import Data.Aeson ((.:), (.=), object)
import Data.Aeson.TH (deriveJSON, defaultOptions)
import Data.Aeson.Types (FromJSON(..), ToJSON(..), Parser, Value(..))
import Data.Foldable (concat)
import Data.SafeCopy (deriveSafeCopy, base)
import Data.Time (UTCTime)
import Data.Typeable (Typeable)
import Network.URI (URI, URIAuth, parseURI)
import Prelude hiding (concat)

import qualified Data.Map as Map

newtype Tag = Tag String
    deriving (Show, Typeable, Eq, Ord)

data Link = Link { uri  :: URI
                 , tags :: [Tag]
                 }
    deriving (Show, Typeable, Eq)

data DateLink = DateLink { link :: Link
                         , date :: UTCTime
                         }
    deriving (Show, Typeable, Eq)

-- Seems like a horrible hack, but let's make this work first
-- before worrying about space/update efficiency.
newtype Links = Links { getLinkMap :: Map.Map Tag [DateLink] }
    deriving (Show, Typeable)

instance FromJSON Link where
    parseJSON :: Value -> Parser Link
    parseJSON (Object o) = Link
        <$> (maybe mzero return . parseURI =<< o .: "link")
        <*> o .: "tags"
    parseJSON _ = mzero

instance ToJSON Link where
    toJSON (Link uri' tags') = object [ "uri"  .= show uri'
                                      , "tags" .= tags' ]

-- Orphan safecopy instances for URI-related things
deriveSafeCopy 0 'base ''URI
deriveSafeCopy 0 'base ''URIAuth

deriveSafeCopy 0 'base ''Tag
deriveSafeCopy 0 'base ''DateLink
deriveSafeCopy 0 'base ''Link
deriveSafeCopy 0 'base ''Links

-- Orphan JSON instances for URI-related things
deriveJSON defaultOptions ''URI
deriveJSON defaultOptions ''URIAuth
deriveJSON defaultOptions ''Tag
deriveJSON defaultOptions ''DateLink

getLinksByTag :: Tag -> Query Links [DateLink]
getLinksByTag tag = concat . Map.lookup tag . getLinkMap <$> ask

getLinks :: Query Links [DateLink]
getLinks = concat . Map.elems . getLinkMap <$> ask

postLink :: UTCTime -> Link -> Update Links ()
postLink now link' = forM_ (tags link') $ \t -> do
    let dateLink = DateLink link' now
    linkMap <- getLinkMap <$> get
    let newLinks = maybe (pure dateLink) (dateLink :) (Map.lookup t linkMap)
    put . Links $ Map.insert t newLinks linkMap

makeAcidic ''Links ['getLinksByTag, 'getLinks, 'postLink]
