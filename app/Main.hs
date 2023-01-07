{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE QuasiQuotes #-}

module Main where

import Metadata 
import PSQL

import Prelude hiding (id)

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
import           Network.Wai.Handler.Warp (run)

-- import           Servant
-- import           Servant.API
-- -- import           Network.Wai
-- import           Network.Wai.Handler.Warp

import Data.Text (Text, unpack, pack)

import Data.IORef
import System.IO.Unsafe


import Data.Hex

policyIDStatic       = "\\xf8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6" :: String
assetNameHashStatic  = "\\x546865437970686572426f78" :: String

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

  run 1339 (app1 conn)
