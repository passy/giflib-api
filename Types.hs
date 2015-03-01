{-# LANGUAGE GeneralizedNewtypeDeriving, DeriveDataTypeable, TypeFamilies, TemplateHaskell, OverloadedStrings #-}
module Types where

-- import Network.URI (URI)
import Control.Applicative ((<$>), pure)
import Control.Monad (forM_)
import Control.Monad.Reader (ask)
import Control.Monad.State (get, put)
import Data.Acid (Query, Update, makeAcidic)
import Data.Aeson.TH (deriveJSON, defaultOptions)
import Data.Foldable (concat)
import Data.SafeCopy (deriveSafeCopy, base)
import Data.Typeable (Typeable)

import Prelude hiding (concat)

import qualified Data.Map as Map

newtype Tag = Tag String
    deriving (Show, Typeable, Eq, Ord)

data Link = Link { link :: String -- TODO: Make this a URI (and find out how to seralize that)
                 , tags :: [Tag]
                 }
    deriving (Show, Typeable)

-- Seems like a horrible hack, but let's make this work first
-- before worrying about space/update efficiency.
newtype Links = Links { getLinkMap :: Map.Map Tag [Link] }
    deriving (Show, Typeable)

deriveSafeCopy 0 'base ''Tag
deriveSafeCopy 0 'base ''Link
deriveSafeCopy 0 'base ''Links

deriveJSON defaultOptions ''Tag
deriveJSON defaultOptions ''Link
-- deriveJSON defaultOptions ''Links

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
