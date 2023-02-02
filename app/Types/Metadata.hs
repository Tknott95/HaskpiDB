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
import Data.Aeson.Key (fromString)
-- import Text.JSON
import Data.Text (Text, unpack)

import           Servant
import           Servant.API

import Data.IORef (readIORef)
import System.IO.Unsafe (unsafePerformIO)

import Globals -- (getGlobalPID, getGlobAssetHash, globalAssetHash) -- , globalAssetHash
import Utils (unhexEither)

-- THIS IS NOT IN USE. THIS POSSIBLY WILL BE REMOVED AND THE NAMING IS UGLY FROM JUST RIGGIN AN MVP RETURN.
-- I REMOVED THIS TYPING AS Aeson.Value allows for alreayd built ambiguity.

-- passing these in on the get call and setting so will figure it all out (needs to be concurrent if doing such shyte bc setting these types dynamic? idfk rn will think)
-- Will take a in values as possibly keys or find a way to convert string to key for dynamic grabs
defaultPID = "f8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6" :: Key
defaultNftNameUnhashed = "TheCypherBox" :: Key
-- if i cant get globals like state machines handling these vars with the hadnler return function then i will have to firugre something out with query params setting globals.
-- maybe even nott typing and running A.Value values instead of Custom Types


-- @NOTE - using Aeson.Value for the middle man api. 
-- (Bug comments below with type function) If fetching local another way then ImEtadata is fine if IORef bug is fixed
-- combine types to maybe make this cleaner? Make one foreach type of proc getting done
type IServerType = "metadata" :> Capture "policy_id_test" Text :>  Get '[JSON] [A.Value]
  :<|> "metadata_by_name" :> Capture "policy_id_test" Text :> Capture "asset_name_hash" Text  :>  Get '[JSON] [A.Value]
  :<|> "metadata_by_name_unhashed" :> Capture "policy_id_test" Text :> Capture "asset_name_hash" Text  :>  Get '[JSON] [A.Value]
  :<|> "metadata_by_skey" :> Capture "skey" Text :>  Get '[JSON] [A.Value]
  :<|> "meta_full_by_skey" :> Capture "skey" Text :>  Get '[JSON] [(Text, Text, Text, A.Value)]
  :<|> "handle_from_skey" :> Capture "skey" Text :> Get '[JSON] [Text]
  :<|> "addr_from_handle" :> Capture "aNameHash" Text :> Get '[JSON] [Text]
  :<|> "addr_from_handle_unhashed" :> Capture "aName" Text :> Get '[JSON] [Text]


-- TYPED METADATA BY HAND BEFORE USING AESON TO TYPE AMBIGUOUS JSON ON THE FLY
-- data IMetadata = IMetadata {
--   policy_id :: IMetadata01
-- } deriving (Show, Generic)

-- data IMetadata01 = IMetadata01 { 
--   nft_name :: IMetadata02
-- } deriving (Show, Generic)

-- data IMetadata02 = IMetadata02
--   { id    :: String
--   , name  :: String
--   , image :: String
--   , description :: String
--   } deriving (Show, Generic)

-- instance ToJSON IMetadata where
--   toJSON metadataObj = object
--     [
--       (fromString $ unsafePerformIO $ readIORef globalPolicyIDState) .= toJSON (policy_id metadataObj)
--     ]

-- instance ToJSON IMetadata01 where
--   toJSON metadataObj = object
--     [ 
--     -- this kills a meta only fetch where this is set from waht comes in. 
--     --This also isn't fetching the new set global a few executed lines prior in the func. Odd tbh as it does above.
--       (fromString $ unsafePerformIO $ readIORef globalAssetHash) .= toJSON (nft_name metadataObj)
--     ]

-- instance ToJSON IMetadata02 where
--   toJSON metadataObj = object
--     [ "id" .= toJSON (id metadataObj)
--     , "name" .= toJSON (name metadataObj)
--     , "image" .= toJSON (image metadataObj)
--     , "description" .= toJSON (description metadataObj)
--     ]

-- instance FromJSON IMetadata where
--   parseJSON = withObject "IMetadata" $ \o -> do
--     _iMeta01 <- o .: defaultPID -- "nft_name"
--     return $ IMetadata _iMeta01
  
-- instance FromJSON IMetadata01 where
--   parseJSON = withObject "IMetadata01" $ \o -> do
--     _nftName <- o .: defaultNftNameUnhashed -- "nft_name"
--     return $ IMetadata01 _nftName

-- -- instance FromJSON IMetadata where
-- --   parseJSON = withObject "IMetadata" $ \o -> do
-- --     _iMeta01 <- o .: (fromString getGlobalPID) -- "nft_name"
-- --     return $ IMetadata _iMeta01
  
-- -- instance FromJSON IMetadata01 where
-- --   parseJSON = withObject "IMetadata01" $ \o -> do
-- --     _nftName <- o .: (fromString getGlobAssetHash)  -- policy_id
-- --     return $ IMetadata01 _nftName
 

-- instance FromJSON IMetadata02 where
--   parseJSON = withObject "IMetadata02" $ \o -> IMetadata02
--     <$> o .: "id"
--     <*> o .: "name"
--     <*> o .: "image"
--     <*> o .: "description"
