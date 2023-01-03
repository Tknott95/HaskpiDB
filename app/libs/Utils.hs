module Utils where

maybeUnwrap :: Maybe a -> a
maybeUnwrap (Just n) = n
maybeUnwrap Nothing = undefined
