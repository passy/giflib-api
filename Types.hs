{-# LANGUAGE GeneralizedNewtypeDeriving, DeriveDataTypeable, TypeFamilies, TemplateHaskell, OverloadedStrings #-}
module Types where

import Control.Applicative
import Control.Monad.Reader
import Control.Monad.State
import Data.Aeson
import Data.Aeson.TH (deriveJSON, defaultOptions)
import Data.SafeCopy (deriveSafeCopy, base)
import Data.Typeable (Typeable)
import Network.URI (URI)

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
