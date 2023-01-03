{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE TypeOperators #-}

module Metadata where

import Prelude hiding (id)
import GHC.Generics

import Database.PostgreSQL.Simple
import Data.Aeson.Types as AT
import Data.Aeson as A
-- import Text.JSON
import Data.Text

import           Servant
import           Servant.API

type MetaAPI_00 = "metadata" :> Capture "policy_id_test" Int :>  Get '[JSON] [IMetadata]


-- passing these in on the get call and setting so will figure it all out (needs to be concurrent if doing such shyte bc setting these types dynamic? idfk rn will think)
-- Will take a in values as possibly keys or find a way to convert string to key for dynamic grabs
defaultPID = "f8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6" :: Key
defaultNftNameUnhashed = "TheCypherBox" :: Key

setdefaultPID :: Key -> Key
setdefaultPID a = a

data IMetadata = IMetadata {
  policy_id :: IMetadata01
} deriving (Show, Generic)

data IMetadata01 = IMetadata01 { 
  nft_name :: IMetadata02
} deriving (Show, Generic)

data IMetadata02 = IMetadata02
  { id    :: String
  , name  :: String
  , image :: String
  , description :: String
  } deriving (Show, Generic)

instance ToJSON IMetadata where
  toJSON metadataObj = object
    [
      defaultPID .= toJSON (policy_id metadataObj)
    ]

instance ToJSON IMetadata01 where
  toJSON metadataObj = object
    [
      defaultNftNameUnhashed .= toJSON (nft_name metadataObj)
    ]

instance ToJSON IMetadata02 where
  toJSON metadataObj = object
    [ "id" .= toJSON (id metadataObj)
    , "name" .= toJSON (name metadataObj)
    , "image" .= toJSON (image metadataObj)
    , "description" .= toJSON (description metadataObj)
    ]

instance FromJSON IMetadata where
  parseJSON = withObject "IMetadata" $ \o -> do
    _iMeta01 <- o .: defaultPID -- "nft_name"
    return $ IMetadata _iMeta01
  
instance FromJSON IMetadata01 where
  parseJSON = withObject "IMetadata01" $ \o -> do
    _nftName <- o .: defaultNftNameUnhashed -- "nft_name"
    return $ IMetadata01 _nftName

instance FromJSON IMetadata02 where
  parseJSON = withObject "IMetadata02" $ \o -> IMetadata02
    <$> o .: "id"
    <*> o .: "name"
    <*> o .: "image"
    <*> o .: "description"
