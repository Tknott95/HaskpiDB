#!/bin/sh

url=127.0.0.1
port=1339

tmp_pol_id=f8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6
tmp_name_hash=546865437970686572426f78 

skey='stake_test1uz87hafc2aqhhfrvarqtxf3c25lzhfqa938l8pl4t9fu9jqj0jamq'
handle_skey='stake_test1urc63cmezfacz9vrqu867axmqrvgp4zsyllxzud3k6danjsn0dn70'

curl http://$url:$port/metadata/$tmp_pol_id; echo -e "\n"
curl http://$url:$port/metadata_by_name/$tmp_pol_id/$tmp_name_hash;  echo -e "\n"
curl -s http://$url:$port/metadata_by_skey/$skey | jq; echo -e "\n"
curl -s http://$url:$port/meta_full_by_skey/$skey | jq; echo -e "\n"
curl -s http://$url:$port/handle_from_skey/$handle_skey | jq

