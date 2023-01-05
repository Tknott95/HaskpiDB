module Utils where

import Data.Hex (unhex)

maybeUnwrap :: Maybe a -> a
maybeUnwrap (Just n) = n
maybeUnwrap Nothing = undefined

unhexEither :: String -> String 
unhexEither ijk = case unhex ijk of 
  Left err  -> err
  Right ijk -> ijk
