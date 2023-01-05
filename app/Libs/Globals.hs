module Globals where

import Data.IORef
import System.IO.Unsafe

{-# NOINLINE globalPolicyIDState #-}
globalPolicyIDState :: IORef String
globalPolicyIDState = unsafePerformIO $ newIORef "this-is-a-default-global-policy-id"


putGlob :: String -> IO ()
putGlob _string  = atomicModifyIORef globalPolicyIDState  (\m -> (_string , ())) 

getGlobIO :: IO ()
getGlobIO = do
  ijk <- readIORef globalPolicyIDState
  print ijk

getGlob :: IO String
getGlob = ijk
  where ijk = readIORef globalPolicyIDState

getGlobalPID :: String
getGlobalPID =  unsafePerformIO $ readIORef globalPolicyIDState
