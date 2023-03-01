module ServerTypes where

-- @NOTE - using Aeson.Value for the middle man api. 
-- (Bug comments below with type function) If fetching local another way then ImEtadata is fine if IORef bug is fixed
-- combine types to maybe make this cleaner? Make one foreach type of proc getting done
type IServerType = "metadata" :> Capture "policy_id_test" Text :>  Get '[JSON] [A.Value]
  :<|> "metadata_by_name" :> Capture "policy_id_test" Text :> Capture "asset_name_hash" Text  :>  Get '[JSON] [A.Value]
  :<|> "metadata_by_name_unhashed" :> Capture "policy_id_test" Text :> Capture "asset_name_hash" Text  :>  Get '[JSON] [A.Value]
  :<|> "metadata_by_skey" :> Capture "skey" Text :>  Get '[JSON] [A.Value]
  :<|> "meta_full_by_skey" :> Capture "skey" Text :>  Get '[JSON] [(Text, Text, Text, A.Value)]
  :<|> "handle_from_skey" :> Capture "skey" Text :> Get '[JSON] [Text]
  :<|> "addr_from_handle" :> Capture "aNameHash" Text :> Get '[JSON] [Text]
  :<|> "addr_from_handle_unhashed" :> Capture "aName" Text :> Get '[JSON] [Text]
