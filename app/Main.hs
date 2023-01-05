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

import Data.Aeson (encode, eitherDecode, decode, Object, Key)
import qualified Data.ByteString.Lazy as LB (ByteString)
import Data.ByteString.Lazy.UTF8 as BLU (fromString)

import Data.Monoid.Instances.Stateful (extract)

import Control.Monad.State


import           Servant
import           Servant.API
-- import           Network.Wai
import           Network.Wai.Handler.Warp

import Data.Text (Text, unpack)

import Data.IORef
import System.IO.Unsafe

import Globals

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
    x :: Text -> Handler [IMetadata]
    x _pid = getMeta _pid
    y :: Text -> Text -> Handler [IMetadata]  
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

getMeta :: Text -> Handler [IMetadata]
getMeta _policyID = do
  liftIO $ putStrLn $ bRed ++
    "\n\n  BEFORE\n" ++
    " liftIO $ getGlobIO \
    \ liftIO $ putGlob _policyID \
    \ liftIO $ getGlobIO"
    ++ clr
  liftIO $ getGlobIO
  liftIO $ putGlob (unpack _policyID)
  liftIO $ putStrLn $ alt ++
    "\n\n  AFTER\n" ++
    " liftIO $ getGlobIO \
    \ liftIO $ putGlob _policyID \
    \ liftIO $ getGlobIO"
    ++ clr

  let paramPID = "\\x" ++ (unpack _policyID)
  liftIO $ print $ "\\x" ++ (unpack _policyID)
  -- QUERY PARAM WORKING
  conn <- liftIO $ connect localPG
  jj <- liftIO $ grabMetaWithPID conn paramPID
  let j_bstring =  encode jj :: LB.ByteString
  let jType = decode j_bstring :: Maybe IMetadata
  let unwrappedObj = maybeUnwrap jType
  return [unwrappedObj]

getMetaByName :: Text -> Text -> Handler [IMetadata]
getMetaByName _policyID _hashedAssetName = do
  let paramPID = "\\x" ++ (unpack _policyID)
  let hashedAssetName = "\\x" ++ (unpack _hashedAssetName)

  liftIO $ print $ "\\x" ++ (unpack _hashedAssetName)
  liftIO $ print $ "\\x" ++ (unpack _policyID)
  -- QUERY PARAM WORKING
  conn <- liftIO $ connect localPG
  jj <- liftIO $ grabMetaWithPIDAndName conn hashedAssetName paramPID
  let j_bstring =  encode jj :: LB.ByteString
  let jType = decode j_bstring :: Maybe IMetadata
  let unwrappedObj = maybeUnwrap jType
  return [unwrappedObj]

-- old function before using handlers for query params
-- getMeta :: Connection -> Int -> IO [IMetadata]
-- getMeta conn testID = do
--   print $ testID
--   jj <- grabMetaWithPIDAndName conn assetNameHashStatic policyIDStatic
--   let j_bstring =  encode jj :: LB.ByteString
--   let jType = decode j_bstring :: Maybe IMetadata
--   let unwrappedObj = maybeUnwrap jType
--   return [unwrappedObj]

-- defaultPID = "f8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6" :: Key
-- defaultNftNameUnhashed = "TheCypherBox" 

main :: IO ()
main = do
  putStrLn $ bCyan
    ++ "\n CONNECTING TO: The cardano-db-sync postgresql database... \n" 
    ++ clr
  
  conn <- connect localPG

  -- liftIO $ getGlobIO
  -- liftIO $ putGlob "f8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6"
  -- liftIO $ getGlobIO

  -- x <- liftIO $ getGlob
  -- print $ x

  print getGlobalPID

  -- liftIO $ evalState $ (setGlobalStateAll "f8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6"  "TheCypherBox" )

  i <- grabMetaWithPID conn policyIDStatic
  j <- grabMetaWithPIDAndName conn assetNameHashStatic policyIDStatic

  putStrLn $ bCyan
    ++ "\n\n    API serving on port 8081\n"
    ++ alt
    ++ "  |GET|  /metadata/<policy-id>\n"
    ++ "  |GET|  /metadata_by_name/<policy-id>/<hashed-asset-name>"
    ++ clr
  
  -- unwrp <- getMeta conn
  -- print $ unwrp

  run 8081 (app1 conn)
