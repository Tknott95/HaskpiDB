module API where

import Utils (maybeUnwrap, unhexEither)
import Globals 
import PSQL

import Data.Aeson (Value, encode, decode)
import           Servant
import           Servant.API

import Metadata (MetaAPI_00)

import qualified Data.ByteString.Lazy as LB (ByteString)
import Database.PostgreSQL.Simple (Connection, connect)
import Data.Text (Text, unpack)
import Control.Monad.IO.Class (liftIO)

server1 :: Connection -> Server MetaAPI_00
server1 conn = metaByPID 
  :<|> metaByPIDAName
  :<|> metaByPIDANameUnhashed 
  :<|> metaByStakeKey
  where 
    metaByPID :: Text -> Handler [Value]
    metaByPID _pid = getMeta _pid
    metaByPIDAName :: Text -> Text -> Handler [Value]  
    metaByPIDAName _pid _hashedAssetName = (getMetaByName _pid _hashedAssetName)
    metaByPIDANameUnhashed :: Text -> Text -> Handler [Value]  
    metaByPIDANameUnhashed _pid _unhashedAssetName = (getMetaByNameUnhashed _pid _unhashedAssetName)
    metaByStakeKey :: Text -> Handler [Value]
    metaByStakeKey _sKey = metaBySKey _sKey

metaAPI :: Proxy MetaAPI_00
metaAPI = Proxy

app1 :: Connection -> Application
app1 conn = serve metaAPI (server1 conn)

getMeta :: Text -> Handler [Value]
getMeta _policyID = do
  let paramPID = "\\x" ++ (unpack _policyID)
  liftIO $ print $ "\\x" ++ (unpack _policyID)
  -- QUERY PARAM WORKING
  conn <- liftIO $ connect localPG
  qlQuery <- liftIO $ grabMetaWithPID conn paramPID

  return qlQuery

getMetaByName :: Text -> Text -> Handler [Value]
getMetaByName _policyID _hashedAssetName = do
  liftIO $ print $ "\\x" ++ (unpack _policyID)
  liftIO $ print $ "\\x" ++ (unpack _hashedAssetName)
  liftIO $ print $ (unhexEither $ unpack _hashedAssetName)
  let paramPID = "\\x" ++ (unpack _policyID)
  let hashedAssetName = "\\x" ++ (unpack _hashedAssetName)
  
  conn <- liftIO $ connect localPG
  qlQuery <- liftIO $ grabMetaWithPIDAndName conn hashedAssetName paramPID
  return [qlQuery]

-- had to unwrap to solve a bug where I was forced to pass a tuple
-- could rmv this and just call it inline but I like the clarity for now. Will possibly on refactor. I imagine I will use this more.
unwrapTuple :: [(Int, Value)] -> [Value]
unwrapTuple = fmap snd

metaBySKey :: Text -> Handler [Value]
metaBySKey _sKey = do
  let skey = unpack _sKey
  liftIO $ print $ skey
  -- QUERY PARAM WORKING
  conn <- liftIO $ connect localPG
  qlQuery <- liftIO $ grabMetaWithStakeKey conn (unpack _sKey)

  let qlUnwrapped =  unwrapTuple qlQuery
  return qlUnwrapped

getMetaByNameUnhashed :: Text -> Text -> Handler [Value]
getMetaByNameUnhashed _policyID _unhashedAssetName = do
  liftIO $ print $ "\\x" ++ (unpack _policyID)
  liftIO $ print $ "\\x" ++ (unpack _unhashedAssetName)
  liftIO $ print $ (unhexEither $ unpack _unhashedAssetName)
  let paramPID = "\\x" ++ (unpack _policyID)
  let hashedAssetName = "\\x" ++ (hex $ unpack _unhashedAssetName)

  conn <- liftIO $ connect localPG
  qlQuery <- liftIO $ grabMetaWithPIDAndName conn hashedAssetName paramPID
  return [qlQuery]

