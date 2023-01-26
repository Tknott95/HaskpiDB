{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
-- {-# LANGUAGE QuasiQuotes #-}

module PSQL where

import Metadata

import Prelude hiding (id)
import GHC.Generics

import Database.PostgreSQL.Simple
import Data.Aeson.Types as AT
import Data.Aeson as A

import Database.PostgreSQL.Simple.Newtypes

import Text.JSON

-- -- Will take a in values as possibly keys or find a way to convert string to key for dynamic grabs
-- defaultPID = "f8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6" :: Key
-- defaultNftNameUnhashed = "TheCypherBox" :: Key

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


grabMetaWithPIDAndName :: Connection -> String -> String -> IO AT.Value -- IMetadata -- 
grabMetaWithPIDAndName conn asName pid = do 
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
   \ AND multi_asset.name = ? \
   \ GROUP BY multi_asset.id) a JOIN tx_metadata ON tx_metadata.id = a.tx_metadata_id;"  (pid, asName)
  return ijk


-- BUG IS BECAUSE IT RETURNS MORE THAN ONE VAL
-- stake_test1uz87hafc2aqhhfrvarqtxf3c25lzhfqa938l8pl4t9fu9jqj0jamq
grabMetaWithStakeKey :: Connection -> String -> IO [(Int, AT.Value)]
grabMetaWithStakeKey conn sKey = query_ conn "SELECT json(json) FROM utxo_view \
   \ JOIN stake_address ON stake_address.id = utxo_view.stake_address_id \
   \ RIGHT JOIN tx_metadata ON utxo_view.tx_id=tx_metadata.tx_id \
   \ WHERE view = 'stake_test1uz87hafc2aqhhfrvarqtxf3c25lzhfqa938l8pl4t9fu9jqj0jamq';"
  --return ijk

