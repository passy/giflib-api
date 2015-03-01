{-# LANGUAGE GeneralizedNewtypeDeriving, DeriveDataTypeable, TypeFamilies, TemplateHaskell, OverloadedStrings #-}
module Types where

-- import Network.URI (URI)
import Control.Monad (void)
import Control.Applicative ((<$>))
import Control.Monad.Reader (ask)
import Control.Monad.State (get, put)
import Data.Acid (Query, Update, makeAcidic)
import Data.Aeson.TH (deriveJSON, defaultOptions)
import Data.SafeCopy (deriveSafeCopy, base)
import Data.Typeable (Typeable)

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

deriveSafeCopy 0 'base ''Tag
deriveSafeCopy 0 'base ''Link
deriveSafeCopy 0 'base ''Links

deriveJSON defaultOptions ''Tag
deriveJSON defaultOptions ''Link
-- deriveJSON defaultOptions ''Links

-- TODO: join Maybe [] together
getLinksByTag :: Tag -> Query Links (Maybe [Link])
getLinksByTag tag = Map.lookup tag . getLinkMap <$> ask

postLink :: Link -> Update Links ()
postLink link = do
    linkMap <- getLinkMap <$> get
    -- TODO: obvious
    let tag = head $ tags link
    void $ case Map.lookup tag linkMap of
             Just links -> put . Links $ (Map.insert tag (link : links) linkMap)
             Nothing    -> put . Links $ (Map.insert tag [link] linkMap)

makeAcidic ''Links ['getLinksByTag]
