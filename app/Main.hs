{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE QuasiQuotes #-}

module Main where

import Metadata 
import PSQL

import Prelude hiding (id)
import System.Environment  (getArgs)

import Colors
import Utils as U
import Globals
import API

import Control.Monad.IO.Class (liftIO)
import Control.Monad.Trans.State.Lazy (runState, evalState)

-- import Database.PostgreSQL.Simple

import Data.Aeson (encode, eitherDecode, decode, Object, Key, Value)
import qualified Data.ByteString.Lazy as LB (ByteString)
import Data.ByteString.Lazy.UTF8 as BLU (fromString)

import Data.Monoid.Instances.Stateful (extract)

import Control.Monad.State

import Data.Hex

import Database.PostgreSQL.Simple (connect)
import  Network.Wai.Handler.Warp (run,
 runSettings,
 defaultSettings,
 setHost)

-- import           Servant
-- import           Servant.API
-- -- import           Network.Wai
-- import           Network.Wai.Handler.Warp

import Data.Text (Text, unpack, pack)

import Data.IORef
import System.IO.Unsafe

import Data.Streaming.Network.Internal

import Data.Hex

policyIDStatic       = "\\xf8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6" :: String
assetNameHashStatic  = "\\x546865437970686572426f78" :: String

getIP :: [a] -> Data.Streaming.Network.Internal.HostPreference
getIP [a]  = "192.168.0.16"
getIP _ = "127.0.0.1"

main :: IO ()
main = do
  cliArgs <- getArgs


  -- let IP_USING = "127.0.0.1";

  -- if (length cliArgs > 0) 
  --   then
  --     print "192.168.0.*"
  --   else 
  --     print "127.0.0.1"
  
  
  putStrLn $ bCyan
    ++ "\n CONNECTING TO: The cardano-db-sync postgresql database... \n" 
    ++ clr
  
  putStrLn $ bRed
    ++ "\n ON IP: " ++ show (getIP cliArgs) ++ "\n"
    ++ clr
  
  conn <- connect localPG

  print getGlobalPID
  print getGlobAssetHash

  i <- grabMetaWithPID conn policyIDStatic
  j <- grabMetaWithPIDAndName conn assetNameHashStatic policyIDStatic

  putStrLn $ bCyan
    ++ "\n\n    API serving on port 1339\n"
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

  let settings = setHost (getIP (cliArgs)) defaultSettings
  runSettings settings (app1 conn)
  run 1339 (app1 conn)
