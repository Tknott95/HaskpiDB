module API where

import Utils (maybeUnwrap, unhexEither)
import Globals 
import PSQL

import Colors

import Data.Aeson (Value, encode, decode)
import           Servant
import           Servant.API

import Metadata (MetaAPI_00)

import qualified Data.ByteString.Lazy as LB (ByteString)
import Database.PostgreSQL.Simple (Connection, connect)
import Data.Text (Text, unpack)
import Control.Monad.IO.Class (liftIO)
import Data.Hex (hex)

server1 :: Connection -> Server MetaAPI_00
server1 conn = metaByPID 
  :<|> metaByPIDAName
  :<|> metaByPIDANameUnhashed 
  :<|> metaByStakeKey
  :<|> metaFullByStakeKey
  where 
    metaByPID :: Text -> Handler [Value]
    metaByPID _pid = getMeta _pid

    metaByPIDAName :: Text -> Text -> Handler [Value]  
    metaByPIDAName _pid _hashedAssetName = (getMetaByName _pid _hashedAssetName)

    metaByPIDANameUnhashed :: Text -> Text -> Handler [Value]  
    metaByPIDANameUnhashed _pid _unhashedAssetName = (getMetaByNameUnhashed _pid _unhashedAssetName)

    metaByStakeKey :: Text -> Handler [Value]
    metaByStakeKey _sKey = metaBySKey _sKey

    metaFullByStakeKey :: Text -> Handler  [(Text, Text, Text, Value)]
    metaFullByStakeKey _sKey = metaFullBySKey _sKey

metaAPI :: Proxy MetaAPI_00
metaAPI = Proxy

app1 :: Connection -> Application
app1 conn = serve metaAPI (server1 conn)

getMeta :: Text -> Handler [Value]
getMeta _policyID = do
  liftIO $ 
    putStrLn $ alt2 ++ "\n  getMeta" ++ clr
  let paramPID = "\\x" ++ (unpack _policyID)
  liftIO $ print $ "\\x" ++ (unpack _policyID)
  -- QUERY PARAM WORKING
  conn <- liftIO $ connect localPG
  qlQuery <- liftIO $ grabMetaWithPID conn paramPID

  return qlQuery

getMetaByName :: Text -> Text -> Handler [Value]
getMetaByName _policyID _hashedAssetName = do
  liftIO $ 
    putStrLn $ alt2 ++ "\n  getMetaByName" ++ clr
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
  liftIO $ 
    putStrLn $ alt2 ++ "\n  metaBySKey" ++ clr
  let skey = unpack _sKey
  liftIO $ print $ skey
  -- QUERY PARAM WORKING
  conn <- liftIO $ connect localPG
  qlQuery <- liftIO $ grabMetaWithStakeKey conn (unpack _sKey)

  let qlUnwrapped =  unwrapTuple qlQuery
  return qlUnwrapped


-- this might be sloppy to do just to return a wrapped
-- data IMultiAsset =  IMultiAsset Text Text Text Value deriving (Show)
-- instance Show IMultiAsset where
--   show (IMultiAsset a t l v) = "IMultiAsset { asset: " ++ show a ++ ", type: " ++ show t ++ ", location: " ++ show l ++ ", value: " ++ show v ++ " }"

-- multiAssets ::  [(Text, Text, Text, Value)] -> [IMultiAsset]
-- multiAssets _ijk = [IMultiAsset a t l v | (a, t, l, v) <- _ijk]

metaFullBySKey :: Text -> Handler [(Text, Text, Text, Value)]
metaFullBySKey _sKey = do
  liftIO $ 
    putStrLn $ alt2 ++ "\n  metaFullBySKey" ++ clr
  let skey = unpack _sKey
  liftIO $ print $ skey
  -- QUERY PARAM WORKING
  conn <- liftIO $ connect localPG
  qlQuery <- liftIO $ grabFullMetaWithStakeKey conn (unpack _sKey)
 
  -- liftIO $ print $ multiAssets qlQuery
  -- let multi = IMultiAsset (qlQuery !! 0) (qlQuery !! 1) (qlQuery !! 2)
  -- let val = qlQuery !! 4
  return qlQuery

getMetaByNameUnhashed :: Text -> Text -> Handler [Value]
getMetaByNameUnhashed _policyID _unhashedAssetName = do
  liftIO $ 
    putStrLn $ alt2 ++ "\n  getMetaByNameUnhashed" ++ clr

  liftIO $ print $ "\\x" ++ (unpack _policyID)
  liftIO $ print $ "\\x" ++ (unpack _unhashedAssetName)
  liftIO $ print $ (hex $ unpack _unhashedAssetName)
  let paramPID = "\\x" ++ (unpack _policyID)
  let hashedAssetName = "\\x" ++ (hex $ unpack _unhashedAssetName)

  conn <- liftIO $ connect localPG
  qlQuery <- liftIO $ grabMetaWithPIDAndName conn hashedAssetName paramPID
  return [qlQuery]

