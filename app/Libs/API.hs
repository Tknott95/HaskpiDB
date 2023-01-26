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
server1 conn = metaByPID :<|> metaByPIDAName :<|> metaByStakeKey
  where 
    metaByPID :: Text -> Handler [Value]
    metaByPID _pid = getMeta _pid
    metaByPIDAName :: Text -> Text -> Handler [Value]  
    metaByPIDAName _pid _hashedAssetName = (getMetaByName _pid _hashedAssetName)
    metaByStakeKey :: Text -> Handler [Value]
    metaByStakeKey _sKey = metaBySKey _sKey
  -- return $ liftIO $ getMeta conn 3
-- 3 is supposed to be the val of the query apram

-- server2 :: Server UserAPI2
-- server2 = return users2
--      :<|> return albert
--      :<|> return isaac

metaAPI :: Proxy MetaAPI_00
metaAPI = Proxy

app1 :: Connection -> Application
app1 conn = serve metaAPI (server1 conn)

getMeta :: Text -> Handler [Value]
getMeta _policyID = do
  -- liftIO $ putStrLn $ bRed ++
  --   "\n\n  BEFORE\n" ++
  --   " liftIO $ putGlobPID _policyID \
  --   \ liftIO $ getGlobIO"
  --   ++ clr
  -- liftIO $ getGlobIO
  -- liftIO $ putGlobPID (unpack _policyID)
  -- liftIO $ putStrLn $ alt ++
  --   "\n\n  AFTER\n" ++
  --   " liftIO $ putGlobPID _policyID \
  --   \ liftIO $ getGlobIO"
  --   ++ clr
  -- liftIO $ getGlobIO

  let paramPID = "\\x" ++ (unpack _policyID)
  liftIO $ print $ "\\x" ++ (unpack _policyID)
  -- QUERY PARAM WORKING
  conn <- liftIO $ connect localPG
  jj <- liftIO $ grabMetaWithPID conn paramPID
  let j_bstring =  encode jj :: LB.ByteString
  let jType = decode j_bstring :: Maybe Value
  let unwrappedObj = maybeUnwrap jType
  return [unwrappedObj]

getMetaByName :: Text -> Text -> Handler [Value]
getMetaByName _policyID _hashedAssetName = do
  liftIO $ print $ "\\x" ++ (unpack _policyID)
  liftIO $ print $ "\\x" ++ (unpack _hashedAssetName)
  liftIO $ print $ (unhexEither $ unpack _hashedAssetName)
  let paramPID = "\\x" ++ (unpack _policyID)
  let hashedAssetName = "\\x" ++ (unpack _hashedAssetName)
  -- liftIO $ putStrLn $ dYlw ++
  --   "\n\n  BEFORE\n" ++
  --   " liftIO $ putGlobPID _policyID \
  --   \ liftIO $ putAssetHash (unpack _hashedAssetName) \
  --   \ liftIO $ getGlobIO"
  --   ++ clr
  -- liftIO $ getGlobAllIO
  -- liftIO $ putAssetHash (unpack _hashedAssetName)
  -- liftIO $ putGlobPID (unpack _policyID)
  -- liftIO $ putStrLn $ alt2 ++
  --   "\n\n  AFTER\n" ++
  --   " liftIO $ putGlobPID _policyID \
  --   \ liftIO $ putAssetHash (unpack _hashedAssetName) \
  --   \ liftIO $ getGlobIO"
  --   ++ clr
  -- liftIO $ getGlobAllIO

  
  -- liftIO $ print $ "\\x" ++ (unpack _hashedAssetName)
  -- liftIO $ print $ "\\x" ++ (unpack _policyID)

  --   liftIO $ print $ unhexEither "546865437970686572426f78"
  -- DOESNT WORK IDK WHY

  -- liftIO $ print getGlobAssetHash
  -- liftIO $ print $ unsafePerformIO $ readIORef globalAssetHash
  -- liftIO $ print $ unhexEither $ unsafePerformIO $ readIORef globalAssetHash
  -- QUERY PARAM WORKING
  conn <- liftIO $ connect localPG
  jj <- liftIO $ grabMetaWithPIDAndName conn hashedAssetName paramPID
  let j_bstring =  encode jj :: LB.ByteString
  let jType = decode j_bstring :: Maybe Value
  let unwrappedObj = maybeUnwrap jType
  return [unwrappedObj]


metaBySKey :: Text -> Handler [Value]
metaBySKey _sKey = do
  let skey = unpack _sKey
  liftIO $ print $ skey
  -- QUERY PARAM WORKING
  conn <- liftIO $ connect localPG
  jj <- liftIO $ grabMetaWithStakeKey conn (unpack _sKey)
  let j_bstring =  encode jj :: LB.ByteString
  print $ j_bstring
  let jType = decode j_bstring :: Maybe Value
  let unwrappedObj = maybeUnwrap jType
  return [unwrappedObj]
