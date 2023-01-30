{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
-- {-# LANGUAGE QuasiQuotes #-}

module PSQL where

import Metadata

import Prelude hiding (id)
import GHC.Generics

import Database.PostgreSQL.Simple
import Database.PostgreSQL.Simple.FromRow

import Data.Aeson.Types as AT
import Data.Aeson as A

-- import Database.PostgreSQL.Simple.Newtypes

import Text.JSON
import Data.Text (Text)


instance FromRow Text where
  fromRow = field

instance FromRow AT.Value where
  fromRow = field

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


grabMetaWithPID :: Connection -> String -> IO [AT.Value] -- IMetadata -- 
grabMetaWithPID conn pid = do 
  [ijk]  <- query conn "SELECT json(tx_metadata.json) \
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
-- adding an int bypasses error of no instance of FromRow I can't seem to get past without it. Keaving for now.
-- I use a function called unwrapTuple to unwrap this tuple to serve only [AT.Value] as a workaround
-- so to void issues I just placeholder a 0 into a tuple then unwrap it for now before serving
grabMetaWithStakeKey :: Connection -> String ->  IO [AT.Value]
grabMetaWithStakeKey conn sKey = query conn "SELECT  json(json) FROM utxo_view \
   \ JOIN stake_address ON stake_address.id = utxo_view.stake_address_id \
   \ RIGHT JOIN tx_metadata ON utxo_view.tx_id=tx_metadata.tx_id \
   \ WHERE view = ?;" [sKey :: String]


grabFullMetaWithStakeKey :: Connection -> String ->  IO [(Text, Text, Text, AT.Value)]
grabFullMetaWithStakeKey conn sKey = query conn "SELECT convert_from(multi_asset.name, 'UTF8'), \
\ encode(multi_asset.fingerprint::bytea, 'escape'), \
\ encode(multi_asset.policy::bytea, 'hex'), json(json) \
\ FROM utxo_view JOIN stake_address \
\ ON stake_address.id = utxo_view.stake_address_id \
\ RIGHT JOIN tx_metadata ON utxo_view.tx_id = tx_metadata.tx_id \
\ RIGHT JOIN ma_tx_mint ON ma_tx_mint.tx_id = tx_metadata.tx_id \
\ LEFT JOIN multi_asset ON ma_tx_mint.ident = multi_asset.id \
\ WHERE view = ?;" [sKey :: String]



grabHandlesFromSKey :: Connection -> String -> IO [Text]
grabHandlesFromSKey conn sKey = query conn "SELECT convert_from(multi_asset.name, 'UTF8') \
\ FROM utxo_view JOIN stake_address \
\ ON stake_address.id = utxo_view.stake_address_id \
\ RIGHT JOIN tx_metadata ON utxo_view.tx_id = tx_metadata.tx_id \
\ RIGHT JOIN ma_tx_mint ON ma_tx_mint.tx_id = tx_metadata.tx_id \
\ LEFT JOIN multi_asset ON ma_tx_mint.ident = multi_asset.id \
\ WHERE view = ? \
\ AND multi_asset.policy='\\xf0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a';" [sKey :: String]


-- THIS SEEMS USELESS AND QUITE FRANKLY, REDUNDANT
-- -- stake_test1urc63cmezfacz9vrqu867axmqrvgp4zsyllxzud3k6danjsn0dn70
-- grabHandlesFromSKeyFull :: Connection -> String -> IO [(String, String, String)]
-- grabHandlesFromSKeyFull conn sKey = query conn "SELECT address, view, \
-- \ convert_from(multi_asset.name, 'UTF8') \
-- \ FROM utxo_view JOIN stake_address \
-- \ ON stake_address.id = utxo_view.stake_address_id \
-- \ RIGHT JOIN tx_metadata ON utxo_view.tx_id = tx_metadata.tx_id \
-- \ RIGHT JOIN ma_tx_mint ON ma_tx_mint.tx_id = tx_metadata.tx_id \
-- \ LEFT JOIN multi_asset ON ma_tx_mint.ident = multi_asset.id \
-- \ WHERE view = 'stake_test1urc63cmezfacz9vrqu867axmqrvgp4zsyllxzud3k6danjsn0dn70 \
-- \ AND multi_asset.policy='\\xf0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a';" [sKey :: String]


-- NEW QUERY TO GRAB ADDRS FROM ASSET NAME (HEXED/HASHED)
-- select address from multi_asset ma RIGHT JOIN ma_tx_mint mtxm on mtxm.ident = ma.id RIGHT JOIN utxo_view uv on uv.tx_id = mtxm.tx_id  where ma.name = '\x6a616d6573' LIMIT 1;

-- hex encoded assetName to test w/ \x6a616d6573
grabAddrFromHandle :: Connection -> String -> IO [Text]
grabAddrFromHandle conn assetName = query conn "SELECT address \
\ FROM multi_asset ma \
\ RIGHT JOIN ma_tx_mint mtxm on mtxm.ident = ma.id \
\ RIGHT JOIN utxo_view uv on uv.tx_id = mtxm.tx_id \
\ WHERE ma.name = ? LIMIT 1;" [assetName :: String]
