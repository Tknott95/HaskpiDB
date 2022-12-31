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

-- {"f8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6": 
-- {"TheCypherBox": 
-- {"id": "1", "name": "The Cypher Box", "image": 
-- "ipfs://QmQumL3C5yqa3KxtFUogo6RLvjTfss7Xwp1S4C3YuVV6if", "description": "This is a little cypher box NFT."}}}


-- will pass in a and b, as parameterized types, after one run to set name if possible
-- probably can just set things in TOJSON
data IMetadata = IMetadata {
  policy_id :: IMetadata01
}
-- will pass in a, as a parameterized type, after one run to set name if possible
-- probably can just set things in TOJSON
data IMetadata01 = IMetadata01 { 
  nft_name :: IMetadata02
}

data IMetadata02 = IMetadata02
  { id    :: Int
  , name  :: String
  , image :: String
  , description :: String
  } deriving (Show, Eq)

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

main :: IO ()
main = do
  putStrLn $ bCyan
    ++ "\n CONNECTING TO: The cardano-db-sync postgresql database... \n" 
    ++ clr
  conn <- connect localPG
  i <- grabMeta conn "\\xf8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6"
  -- mapM_ print =<< grabMeta conn "\\xf8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6"
  -- print $ show $ A.encode i :: Maybe IMetadata
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