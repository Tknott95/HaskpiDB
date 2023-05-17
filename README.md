# HaskpiDB

Haskell middleman api to serve cardano-db-sync sql queries

- prep this to get ready for open source

@TODO
- rig some haskpiDB api endpoints for use w/ unity
- make a query for grabbing handles from asset_name
- query above is made. Maybe make it so I can pass both unhashed and hashed handle names 
- add some tx queries to analyze transactions

***

@QUERY-IDEAS
- ...

***
###  API REF
*  |GET|  /metadata/**policy-id** 
*  |GET|  /metadata_by_name/**policy-id**/**hashed-asset-name** 
*  |GET|  /metadata_by_name_unhashed/**policy-id**/**unhashed-asset-name**
*  |GET|  /metadata_by_skey/**stake-key** 
*  |GET|  /meta_full_by_skey/**stake-key** (DEPRECATED)
*  |GET|  /handle_from_skey/**stake-key**
*  |GET|  /addr_from_handle/**hashed-asset-name**
*  |GET|  /addr_from_handle_unhashed/**asset-name**

DOING
* ...

###### @API_TODO
* some trans queries and then stop using wallet as much?
* some queries for analytics
* ...
***

```HOW TO RUN

cabal install HaskpiDB

HaskpiDB

or

HaskpiDB pub
```
***
##### @TODO 
- possibly want to move to this middleman for most analytics. 
- add policy-id and unhashed asset-name
- possibly even run anodapi inside to use haskell to get POSTS and work with the cardano-node
 * anodapi is an internal lib I built for haskell to interact with the cardano-node and cardano-cli
- refactor the api code to a file called API.hs 
- set such accordingly and run a test with API.hs to call in Main.hs

***

TESTING RESOURCES
```
  defaultPID = "f8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6"
  defaultNftNameUnhashed = "TheCypherBox" 
```
***
#### REMOVED JSON IMETADATA TYPING AT COMMIT HASH
`14824002c8b7c91eb91778e980a7406549a26391`



***
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

***
### QUERIES

* metadata json from stake-key
```
select json from utxo_view join stake_address on stake_address.id = utxo_view.stake_address_id RIGHT JOIN tx_metadata on utxo_view.tx_id=tx_metadata.tx_id where view = 'stake_test1uz87hafc2aqhhfrvarqtxf3c25lzhfqa938l8pl4t9fu9jqj0jamq';
```
