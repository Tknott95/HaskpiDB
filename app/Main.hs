{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE QuasiQuotes #-}

module Main where

import Metadata 
import PSQL

import Prelude hiding (id)

import Colors
import Utils as U

import Control.Monad.IO.Class (liftIO)
import Control.Monad.Trans.State.Lazy (runState, evalState)

import Database.PostgreSQL.Simple

import Data.Aeson (encode, eitherDecode, decode, Object, Key, Value)
import qualified Data.ByteString.Lazy as LB (ByteString)
import Data.ByteString.Lazy.UTF8 as BLU (fromString)

import Data.Monoid.Instances.Stateful (extract)

import Control.Monad.State

import Data.Hex



import           Servant
import           Servant.API
-- import           Network.Wai
import           Network.Wai.Handler.Warp

import Data.Text (Text, unpack, pack)

import Data.IORef
import System.IO.Unsafe

import Globals

import Data.Hex

policyIDStatic       = "\\xf8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6" :: String
assetNameHashStatic  = "\\x546865437970686572426f78" :: String


-- putGlob :: String -> IO ()
-- -- putGlob _  = atomicModifyIORef globalPolicyIDState  (\m -> ("this-is-a-global-state" , ())) 
-- putGlob _string  = atomicModifyIORef globalPolicyIDState  (\m -> (_string , ())) 

--   -- ijk <- readIORef globalPolicyIDState
--   -- print 
--   -- put $ globalPolicyIDState "globalString"

-- getGlob :: IO ()
-- getGlob = do
--   ijk <- readIORef globalPolicyIDState
--   print ijk

server1 :: Connection -> Server MetaAPI_00
server1 conn = x :<|> y
  where 
    x :: Text -> Handler [Value]
    x _pid = getMeta _pid
    y :: Text -> Text -> Handler [Value]  
    y _pid _hashedAssetName = (getMetaByName _pid _hashedAssetName) 
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

main :: IO ()
main = do
  putStrLn $ bCyan
    ++ "\n CONNECTING TO: The cardano-db-sync postgresql database... \n" 
    ++ clr
  
  conn <- connect localPG

  print getGlobalPID
  print getGlobAssetHash

  i <- grabMetaWithPID conn policyIDStatic
  j <- grabMetaWithPIDAndName conn assetNameHashStatic policyIDStatic

  putStrLn $ bCyan
    ++ "\n\n    API serving on port 8081\n"
    ++ alt
    ++ "  |GET|  /metadata/<policy-id>\n"
    ++ "  |GET|  /metadata_by_name/<policy-id>/<hashed-asset-name>"
    ++ clr
  
  let unhexedKey = hex "TheCypherBox" :: String

  putStrLn $ "\n\n HEX to UNHEX \n" ++ bRed
    ++ (hex "TheCypherBox") ++ "\n"
    ++ (unhexEither $ hex "TheCypherBox")
    ++ "\n"
    ++ clr
  
  -- unwrp <- getMeta conn
  -- print $ unwrp

  run 8081 (app1 conn)
