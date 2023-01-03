{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE QuasiQuotes #-}

module Main where


import Colors
import PSQL

import Database.PostgreSQL.Simple


import Data.Aeson as A
import qualified Data.ByteString.Lazy as LB
import Data.ByteString.Lazy.UTF8 as BLU


import Data.Text
import Data.Either
import Data.Maybe

-- import Data.Row.Aeson




main :: IO ()
main = do
  putStrLn $ bCyan
    ++ "\n CONNECTING TO: The cardano-db-sync postgresql database... \n" 
    ++ clr
  conn <- connect localPG
  i <- grabMeta conn "\\xf8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6"

  print $ show $  i


  let bstring = BLU.fromString $ show i
  putStrLn $ dYlw ++ "\n BYTESTRING " ++ show bstring ++ clr
  -- print $ show $ (i !! 0)

  putStrLn "\n\n  "

  let iij =  A.encode i :: LB.ByteString
  putStrLn $ bYlw ++ "\n a.ecnode bytesring \n " ++  show iij ++ clr

  -- let fxt =  iij !! 0
  -- putStrLn $ show fxt

  let abcc = A.eitherDecode iij ::Either String Object
  --  A.decode iij :: Maybe Object
  let custTypeEither = A.eitherDecode iij :: Either String IMetadata
  let custType = A.decode iij :: Maybe IMetadata



  putStrLn $ alt 
    ++  (show $ Just custType) 
    ++ clr

  let unwrappedObj = maybeUnwrap custType
  let unwrappedObj01 = policy_id unwrappedObj
  let unwrappedObj02 = nft_name unwrappedObj01

  putStrLn $ alt2 
    ++ (show $ image $ nft_name $ policy_id $ maybeUnwrap custType)
    ++ clr

  putStrLn $ dYlw 
    ++ (show $ unwrappedObj01)
    ++ clr
  
  putStrLn $ bRed 
    ++ (show $ unwrappedObj02)
    ++ clr
  
  putStrLn $ bCyan 
    ++ (show $  image unwrappedObj02)
    ++ clr


maybeUnwrap :: Maybe a -> a
maybeUnwrap (Just n) = n
maybeUnwrap Nothing = undefined
