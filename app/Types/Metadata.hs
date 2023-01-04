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

import Control.Monad.State

-- Global IORef Imports
import Data.IORef
import System.IO.Unsafe

-- WILL MOVE TO A GLOBALS.HS FILE
data IGlobalState = IGlobalState {  polID :: Key,
   assNameHash :: Key
}

putGlob :: String -> IO ()
-- putGlob _  = atomicModifyIORef globalPolicyIDState  (\m -> ("this-is-a-global-state" , ())) 
putGlob _string  = atomicModifyIORef globalPolicyIDState  (\m -> (_string , ())) 

getGlob :: IO ()
getGlob = do
  ijk <- readIORef globalPolicyIDState
  print ijk

type MetaAPI_00 = "metadata" :> Capture "policy_id_test" Text :>  Get '[JSON] [IMetadata]
  :<|> "metadata_by_name" :> Capture "policy_id_test" Text :> Capture "asset_name_hash" Text  :>  Get '[JSON] [IMetadata]



-- rigging states here first
{-# NOINLINE globalPolicyIDState #-}
globalPolicyIDState :: IORef String
globalPolicyIDState = unsafePerformIO $ newIORef "this-is-a-default-global-policy-id"


setGlobalStateAll :: String -> String -> State IGlobalState ()
setGlobalStateAll _policyID _hashedName = do
 put $ IGlobalState (fromString _policyID) (fromString _hashedName)

-- passing these in on the get call and setting so will figure it all out (needs to be concurrent if doing such shyte bc setting these types dynamic? idfk rn will think)
-- Will take a in values as possibly keys or find a way to convert string to key for dynamic grabs
defaultPID = "f8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6" :: Key
defaultNftNameUnhashed = "TheCypherBox" :: Key
-- if i cant get globals like state machines handling these vars with the hadnler return function then i will have to firugre something out with query params setting globals.
-- maybe even nott typing and running A.Value values instead of Custom Types

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
