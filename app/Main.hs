{-# LANGUAGE OverloadedStrings #-}
module Main where

import Database.PostgreSQL.Simple
import Colors

localPG :: ConnectInfo
localPG = defaultConnectInfo
        { connectHost = "127.0.0.1"
        , connectDatabase = "testnet"
        , connectUser = "x4"
        , connectPassword = "lorem_ipsum"
        }

main :: IO ()
main = do
  putStrLn $ bCyan
    ++ "\n CONNECTING TO: The cardano-db-sync postgresql database... \n" 
    ++ clr
  conn <- connect localPG
  mapM_ print =<< (query_ conn "SELECT 1 + 1" :: IO [Only Int])
