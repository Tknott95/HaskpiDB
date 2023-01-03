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

import Database.PostgreSQL.Simple

import Data.Aeson (encode, eitherDecode, decode, Object)
import qualified Data.ByteString.Lazy as LB (ByteString)
import Data.ByteString.Lazy.UTF8 as BLU (fromString)

import           Servant
import           Servant.API
-- import           Network.Wai
import           Network.Wai.Handler.Warp


policyIDStatic       = "\\xf8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6" :: String
assetNameHashStatic  = "\\x546865437970686572426f78" :: String

server1 :: Connection -> Server MetaAPI_00
server1 conn = return $ liftIO $ getMeta conn 3
-- 3 is supposed to be the val of the query param

-- server2 :: Server UserAPI2
-- server2 = return users2
--      :<|> return albert
--      :<|> return isaac

metaAPI :: Proxy MetaAPI_00
metaAPI = Proxy

app1 :: Connection -> Application
app1 conn = serve metaAPI (server1 conn)

getMeta :: Connection -> Int -> IO [IMetadata]
getMeta conn testID = do
  print $ testID
  jj <- grabMetaWithPIDAndName conn assetNameHashStatic policyIDStatic
  let j_bstring =  encode jj :: LB.ByteString
  let jType = decode j_bstring :: Maybe IMetadata
  let unwrappedObj = maybeUnwrap jType
  return [unwrappedObj]


main :: IO ()
main = do
  putStrLn $ bCyan
    ++ "\n CONNECTING TO: The cardano-db-sync postgresql database... \n" 
    ++ clr
  
  conn <- connect localPG

  i <- grabMetaWithPID conn policyIDStatic
  j <- grabMetaWithPIDAndName conn assetNameHashStatic policyIDStatic

  print $ show $  j
  print $ show $  i


  let bstring = BLU.fromString $ show i
  putStrLn $ dYlw ++ "\n BYTESTRING " ++ show bstring ++ clr
  -- print $ show $ (i !! 0)

  putStrLn "\n\n  "

  let iij =  encode i :: LB.ByteString
  putStrLn $ bYlw ++ "\n a.ecnode bytesring \n " ++  show iij ++ clr

  -- let fxt =  iij !! 0
  -- putStrLn $ show fxt

  let abcc = eitherDecode iij ::Either String Object
  --  A.decode iij :: Maybe Object
  let custTypeEither = eitherDecode iij :: Either String IMetadata
  let custType = decode iij :: Maybe IMetadata


  putStrLn $ alt 
    ++  (show $ Just custType) 
    ++ clr

  let unwrappedObj = maybeUnwrap custType
  let unwrappedObj01 = policy_id unwrappedObj
  let unwrappedObj02 = nft_name unwrappedObj01

  -- INSTEAD OF UNWRAPPING COULD JUST <$>
  putStrLn $ alt2 
    ++ (show $ nft_name $ policy_id $ U.maybeUnwrap custType)
    ++ clr
  putStrLn $ alt2
    ++ (show $ policy_id $ U.maybeUnwrap custType)
    ++ clr
  putStrLn $ alt2 
    ++ (show $ id $ nft_name $ policy_id $ U.maybeUnwrap custType)
    ++ clr
  putStrLn $ alt2 
    ++ (show $ name $ nft_name $ policy_id $ U.maybeUnwrap custType)
    ++ clr
  putStrLn $ alt2 
    ++ (show $ image $ nft_name $ policy_id $ U.maybeUnwrap custType)
    ++ clr
  putStrLn $ alt2 
    ++ (show $ description $ nft_name $ policy_id $ U.maybeUnwrap custType)
    ++ clr
 

  putStrLn $ dYlw 
    ++ (show $ unwrappedObj01)
    ++ clr
  
  putStrLn $ bRed 
    ++ (show $ unwrappedObj02)
    ++ clr
  
  putStrLn $ alt2 
    ++ (show $  image unwrappedObj02)
    ++ clr
  
  putStrLn $ bCyan 
    ++ "\n\n    API serving on port 8081\n"
    ++ alt
    ++ "  |GET|  /metadata"
    ++ clr
  
  -- unwrp <- getMeta conn
  -- print $ unwrp

  run 8081 (app1 conn)
