{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE QuasiQuotes #-}

module Main where

import Database.PostgreSQL.Simple
import Colors
import GHC.Generics

import Text.JSON
import qualified Data.ByteString.Lazy as LB
import Data.ByteString.Lazy.UTF8 as BLU

import Data.Aeson.Types as AT
import Data.Aeson   as A

import Data.Text
import Data.Either
import Data.Maybe

import Data.Row.Aeson

import Prelude hiding (id)

import Data.Aeson.Lens

import Data.Maybe (maybeToList)


-- data IMeta = IMeta [IMetadata] deriving (Show, Generic)
-- instance FromJSON IMeta
-- instance ToJSON IMeta

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

newtype Items = Items
  { items :: [IMetadata]
  } deriving (Generic, Show)

instance FromJSON Items
instance ToJSON Items

instance ToJSON IMetadata where
  toJSON metadataObj = object
    [
      "f8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6" .= toJSON (policy_id metadataObj)
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


-- this is dogshit
-- setup fromfield foreach and it should be good 
grabMeta :: Connection -> String -> IO AT.Value -- IMetadata -- 
grabMeta conn pid = do 
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


main :: IO ()
main = do
  putStrLn $ bCyan
    ++ "\n CONNECTING TO: The cardano-db-sync postgresql database... \n" 
    ++ clr
  conn <- connect localPG
  i <- grabMeta conn "\\xf8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6"
  -- mapM_ print =<< grabMeta conn "\\xf8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6"
  -- print $ show $ ((A.encode (bst i)) :: IMetadata)
  -- print (show (A.decode (Just i) :: Maybe AT.Value))
  -- d <- (eitherDecode <$> (Just i)) :: IO (Either String [IMetadata])

  print $ show $  i


  let bstring = BLU.fromString $ show i
  putStrLn $ dYlw ++ "\n BYTESTRING " ++ show bstring ++ clr
  -- print $ show $ (i !! 0)

  putStrLn "\n\n  "

  let iij =  A.encode i :: LB.ByteString
  putStrLn $ bYlw ++ "\n a.ecnode bytesring \n " ++  show iij ++ clr

  -- let fxt =  iij !! 0
  -- putStrLn $ show fxt

  let abcc = A.eitherDecode iij ::Either String Object
  --  A.decode iij :: Maybe Object
  let custTypeEither = A.eitherDecode iij :: Either String IMetadata
  let custType = A.decode iij :: Maybe IMetadata



  putStrLn $ alt 
    ++  (show $ Just custType) 
    ++ clr

  let unwrappedObj = maybeUnwrap custType
  let unwrappedObj01 = policy_id unwrappedObj
  let unwrappedObj02 = nft_name unwrappedObj01

  putStrLn $ alt2 
    ++ (show $  maybeUnwrap custType)
    ++ clr

  putStrLn $ dYlw 
    ++ (show $ unwrappedObj01)
    ++ clr
  
  putStrLn $ bRed 
    ++ (show $  unwrappedObj02)
    ++ clr
  
  putStrLn $ bCyan 
    ++ (show $  image unwrappedObj02)
    ++ clr


maybeUnwrap :: Maybe a -> a
maybeUnwrap (Just n) = n
maybeUnwrap Nothing = undefined