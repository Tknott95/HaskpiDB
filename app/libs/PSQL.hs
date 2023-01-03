{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
-- {-# LANGUAGE QuasiQuotes #-}

module PSQL where

import Prelude hiding (id)
import GHC.Generics

import Database.PostgreSQL.Simple
import Data.Aeson.Types as AT
import Data.Aeson as A

import Text.JSON

defaultPID = "f8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6" :: Key


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
      --(setdefaultPID "f8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6") .= toJSON (policy_id metadataObj)
    ]

instance ToJSON IMetadata01 where
  toJSON metadataObj = object
    [
      "TheCypherBox" .= toJSON (nft_name metadataObj)
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
    _iMeta01 <- o .: "f8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6" -- "nft_name"
    return $ IMetadata _iMeta01
  
instance FromJSON IMetadata01 where
  parseJSON = withObject "IMetadata01" $ \o -> do
    _nftName <- o .: "TheCypherBox" -- "nft_name"
    return $ IMetadata01 _nftName

instance FromJSON IMetadata02 where
  parseJSON = withObject "IMetadata02" $ \o -> IMetadata02
    <$> o .: "id"
    <*> o .: "name"
    <*> o .: "image"
    <*> o .: "description"

-- GENERICS
-- instance ToJSON IMetadata
-- instance FromJSON IMetadata
-- instance ToJSON IMetadata01
-- instance FromJSON IMetadata01
-- instance ToJSON IMetadata02
-- instance FromJSON IMetadata02

localPG :: ConnectInfo
localPG = defaultConnectInfo
  { connectHost = "127.0.0.1"
  , connectDatabase = "testnet"
  , connectUser = "x4"
  , connectPassword = "lorem_ipsum"
  }


grabMetaWithPID :: Connection -> String -> IO AT.Value -- IMetadata -- 
grabMetaWithPID conn pid = do 
  [Only ijk]  <- query conn "SELECT json(tx_metadata.json) \
   \ FROM ( SELECT multi_asset.id, encode(multi_asset.policy, 'hex') \
   \ AS policy_id, encode(multi_asset.name, 'escape') \
   \ AS asset_name, multi_asset.fingerprint \
   \ AS fingerprint, sum(ma_tx_mint.quantity) AS quantity, count(DISTINCT ma_tx_mint.id) \
   \ AS mint_or_burn_count, max(tx_metadata.id) AS tx_metadata_id, min(tx.id) \
   \ AS tx_id FROM multi_asset JOIN ma_tx_mint ON ma_tx_mint.ident = multi_asset.id JOIN tx ON tx.id = ma_tx_mint.tx_id \
   \ JOIN tx_metadata ON tx_metadata.tx_id = ma_tx_mint.tx_id \
   \ WHERE tx_metadata.key IN(721) \
   \ AND multi_asset.policy = ? \
   \ GROUP BY multi_asset.id) a JOIN tx_metadata ON tx_metadata.id = a.tx_metadata_id;" [pid :: String] 

  return ijk
