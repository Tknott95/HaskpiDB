{-# LANGUAGE OverloadedStrings #-}
module Main where

import Database.PostgreSQL.Simple
import Colors
import Text.JSON
-- import qualified Data.ByteString.Lazy.Char8 as BLC
import qualified Data.ByteString.Lazy as LB

-- import Text.JSONb.Simple as TJS
import Data.Aeson.Types as AT
import Data.Aeson as A
import Data.ByteString.Lazy.UTF8 as BLU

import Prelude hiding (id)
-- import qualified Data.ByteString.Char8 as BS
-- import qualified Data.Text             as T

-- {"f8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6": 
-- {"TheCypherBox": 
-- {"id": "1", "name": "The Cypher Box", "image": 
-- "ipfs://QmQumL3C5yqa3KxtFUogo6RLvjTfss7Xwp1S4C3YuVV6if", "description": "This is a little cypher box NFT."}}}


-- will pass in a and b, as parameterized types, after one run to set name if possible
-- probably can just set things in TOJSON
data IMetadata = IMetadata {
  policy_id :: IMetadata01
} deriving (Show, Eq)

-- will pass in a, as a parameterized type, after one run to set name if possible
-- probably can just set things in TOJSON
data IMetadata01 = IMetadata01 { 
  nft_name :: IMetadata02
} deriving (Show, Eq)


data IMetadata02 = IMetadata02
  { id    :: Int
  , name  :: String
  , image :: String
  , description :: String
  } deriving (Show, Eq)

instance ToJSON IMetadata where
  toJSON metadataObj = object
    [
      "policy_id" .= toJSON (policy_id metadataObj)
    ]

instance ToJSON IMetadata01 where
  toJSON metadataObj = object
    [
      "nft_name" .= toJSON (nft_name metadataObj)
    ]

instance ToJSON IMetadata02 where
  toJSON metadataObj = object
    [ "id" .= toJSON (id metadataObj)
    , "name" .= toJSON (name metadataObj)
    , "image" .= toJSON (image metadataObj)
    , "description" .= toJSON (description metadataObj)
    ]

instance FromJSON IMetadata where
  parseJSON = withObject "f8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6" $ \o -> do
    _nftName <- o .: "TheCypherbox" -- "nft_name"
    return $ IMetadata _nftName
  
instance FromJSON IMetadata01 where
  parseJSON = withObject "IMetadata01" $ \o -> do
    _nftName <- o .: "TheCypherbox" -- "nft_name"
    return $ IMetadata01 _nftName

instance FromJSON IMetadata02 where
  parseJSON = withObject "IMetadata02" $ \o -> do
    _id <- o .: "id"
    _name <- o .: "name"
    _image <- o .: "image"
    _description <- o .: "description"
    return $ IMetadata02 _id _name _image _description


localPG :: ConnectInfo
localPG = defaultConnectInfo
  { connectHost = "127.0.0.1"
  , connectDatabase = "testnet"
  , connectUser = "x4"
  , connectPassword = "lorem_ipsum"
  }


grabMeta :: Connection -> String -> IO [Only AT.Value]
grabMeta conn pid = ijk
  where ijk = query conn "SELECT tx_metadata.json \
   \ FROM ( SELECT multi_asset.id, encode(multi_asset.policy, 'hex') \
   \ AS policy_id, encode(multi_asset.name, 'escape') \
   \ AS asset_name, multi_asset.fingerprint \
   \ AS fingerprint, sum(ma_tx_mint.quantity) AS quantity, count(DISTINCT ma_tx_mint.id) \
   \ AS mint_or_burn_count, max(tx_metadata.id) AS tx_metadata_id, min(tx.id) \
   \ AS tx_id FROM multi_asset JOIN ma_tx_mint ON ma_tx_mint.ident = multi_asset.id JOIN tx ON tx.id = ma_tx_mint.tx_id \
   \ JOIN tx_metadata ON tx_metadata.tx_id = ma_tx_mint.tx_id \
   \ WHERE tx_metadata.key IN(721) \
   \ AND multi_asset.policy = ? \
   \ GROUP BY multi_asset.id) a JOIN tx_metadata ON tx_metadata.id = a.tx_metadata_id;"  $ (Only pid)

-- bst :: BS.ByteString -> T.Text
-- bst = T.pack . BS.unpack

main :: IO ()
main = do
  putStrLn $ bCyan
    ++ "\n CONNECTING TO: The cardano-db-sync postgresql database... \n" 
    ++ clr
  conn <- connect localPG
  i <- grabMeta conn "\\xf8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6"
  -- mapM_ print =<< grabMeta conn "\\xf8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6"
  print $ show $ ((A.encode (bst i)) :: IMetadata)
  -- print (show (A.decode (Just i) :: Maybe AT.Value))
  
  print $ show $ Just i
  




  -- OLD CODE LEAVING FOR NOW
  -- mapM_ print =<< (query_ conn "SELECT 1 + 1" :: IO [Only Int])
  -- mapM_ print =<< (query_ conn "SELECT tx_metadata.json \
  --  \ FROM ( SELECT multi_asset.id, encode(multi_asset.policy, 'hex') \
  --  \ AS policy_id, encode(multi_asset.name, 'escape') \
  --  \ AS asset_name, multi_asset.fingerprint \
  --  \ AS fingerprint, sum(ma_tx_mint.quantity) AS quantity, count(DISTINCT ma_tx_mint.id) \
  --  \ AS mint_or_burn_count, max(tx_metadata.id) AS tx_metadata_id, min(tx.id) \
  --  \ AS tx_id FROM multi_asset JOIN ma_tx_mint ON ma_tx_mint.ident = multi_asset.id JOIN tx ON tx.id = ma_tx_mint.tx_id JOIN tx_metadata ON tx_metadata.tx_id = ma_tx_mint.tx_id \
  --  \ WHERE tx_metadata.key IN(721) \
  --  \ AND multi_asset.policy = '\\xf8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6' \
  --  \ GROUP BY multi_asset.id) a JOIN tx_metadata ON tx_metadata.id = a.tx_metadata_id;" ::  IO [Only BLC.ByteString])
  
  -- ijk <- "SELECT tx_metadata.json \
  --  \ FROM ( SELECT multi_asset.id, encode(multi_asset.policy, 'hex') \
  --  \ AS policy_id, encode(multi_asset.name, 'escape') \
  --  \ AS asset_name, multi_asset.fingerprint \
  --  \ AS fingerprint, sum(ma_tx_mint.quantity) AS quantity, count(DISTINCT ma_tx_mint.id) \
  --  \ AS mint_or_burn_count, max(tx_metadata.id) AS tx_metadata_id, min(tx.id) \
  --  \ AS tx_id FROM multi_asset JOIN ma_tx_mint ON ma_tx_mint.ident = multi_asset.id JOIN tx ON tx.id = ma_tx_mint.tx_id JOIN tx_metadata ON tx_metadata.tx_id = ma_tx_mint.tx_id \
  --  \ WHERE tx_metadata.key IN(721) \
  --  \ AND multi_asset.policy = '\\xf8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6' \
  --  \ GROUP BY multi_asset.id) a JOIN tx_metadata ON tx_metadata.id = a.tx_metadata_id;"
  
  -- print ijk