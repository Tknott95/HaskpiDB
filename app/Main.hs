{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE QuasiQuotes #-}

module Main where

import PSQL

import Prelude hiding (id)
import System.Environment  (getArgs)

import Colors
import Utils as U
import Globals
import API

import Control.Monad.IO.Class (liftIO)
import Control.Monad.Trans.State.Lazy (runState, evalState)

import Data.Aeson (encode, eitherDecode, decode, Object, Key, Value)
import qualified Data.ByteString.Lazy as LB (ByteString)
import Data.ByteString.Lazy.UTF8 as BLU (fromString)

import Data.Monoid.Instances.Stateful (extract)

import Data.Hex (hex)

import Database.PostgreSQL.Simple (connect)
import  Network.Wai.Handler.Warp (run, setPort,
 runSettings,
 defaultSettings,
 setHost)

import Data.Text (Text, unpack, pack)

import Data.IORef
import System.IO.Unsafe

import Data.Streaming.Network.Internal

import Data.Hex

policyIDStatic       = "\\xf8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6" :: String
assetNameHashStatic  = "\\x546865437970686572426f78" :: String

-- will use a proc to return ip below
getIP :: [a] -> Data.Streaming.Network.Internal.HostPreference
getIP [a]  = "192.168.0.8"
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
  

  putStrLn $ alt2
    ++ "\n CONNECTING TO: The cardano-db-sync postgresql database... \n" 
    ++ clr
  
  putStrLn $ bYlw
    ++ "\n      ON IP: " ++ show (getIP cliArgs) ++ "\n"
    ++ clr
  
  conn <- connect localPG

  putStrLn $ bCyan
    ++ "\n\n    API serving on port 1339\n"
    ++ alt
    ++ "  |GET|  /metadata/<policy-id>\n"
    ++ "  |GET|  /metadata_by_name/<policy-id>/<hashed-asset-name>\n"
    ++ "  |GET|  /metadata_by_name_unhashed/<policy-id>/<unhashed-asset-name>\n"
    ++ "  |GET|  /metadata_by_skey/<stake-key>\n"
    ++ "  |GET|  /meta_full_by_skey/<stake-key>\n"
    ++ "  |GET|  /handle_from_skey/<stake-key>\n"
    ++ "  |GET|  /addr_from_handle/<asset-name>\n"
    ++ "  |GET|  /addr_from_handle_unhashed/<asset-name>\n"
    ++ clr
  
  let unhexedKey = hex "TheCypherBox" :: String

  putStrLn $ "\n\n HEX to UNHEX \n" ++ bRed
    ++ (hex "TheCypherBox") ++ "\n"
    ++ (unhexEither $ hex "TheCypherBox")
    ++ "\n"
    ++ clr

  let settings = setPort 1339 $ setHost (getIP cliArgs) defaultSettings
  runSettings settings (app1 conn)
