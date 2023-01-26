# HaskpiDB
Haskell middleman api to serve cardano-db-sync sql queries


###  API REF
*  |GET|  **/metadata/^policy-id^** 
*  |GET|  **/metadata_by_name/^policy-id^/^hashed-asset-name^** 
*  |GET|  **/metadata_by_skey/^stake-key^** 
***

```HOW TO RUN

cabal install HaskpiDB

HaskpiDB

or

HaskpiDB pub
```

@TODO 
- add new query for fetching metadata from stake-key
- possibly want to move to this middleman for most analytics. 
- possibly even run anodapi inside to use haskell to get POSTS and work with the cardano-node
 * anodapi is an internal lib I built for haskell to interact with the cardano-node and cardano-cli
- refactor the api code to a file called API.hs 
- set such accordingly and run a test with API.hs to call in Main.hs

@DONE
- make a HEX encoder
- make a HEX decoder
- map the proper decoded/encoded asset_name to ToJSON object (unhashed)
- unhashshed asset name is actually hashed


TESTING RESOURCES
```
  defaultPID = "f8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6"
  defaultNftNameUnhashed = "TheCypherBox" 
```

#### REMOVED JSON IMETADATA TYPING AT COMMIT HASH
`14824002c8b7c91eb91778e980a7406549a26391`




## OLD CODE

``` main.hs

-- old function before using handlers for query params
-- getMeta :: Connection -> Int -> IO [IMetadata]
-- getMeta conn testID = do
--   print $ testID
--   jj <- grabMetaWithPIDAndName conn assetNameHashStatic policyIDStatic
--   let j_bstring =  encode jj :: LB.ByteString
--   let jType = decode j_bstring :: Maybe IMetadata
--   let unwrappedObj = maybeUnwrap jType
--   return [unwrappedObj]

-- defaultPID = "f8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6" :: Key
-- defaultNftNameUnhashed = "TheCypherBox" 

```


### QUERIES

* metadata json from stake-key
```
select json from utxo_view join stake_address on stake_address.id = utxo_view.stake_address_id RIGHT JOIN tx_metadata on utxo_view.tx_id=tx_metadata.tx_id where view = 'stake_test1uz87hafc2aqhhfrvarqtxf3c25lzhfqa938l8pl4t9fu9jqj0jamq';
```
