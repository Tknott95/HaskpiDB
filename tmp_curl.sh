#!/bin/sh

url=127.0.0.1
port=8081


curl http://$url:$port/metadata/f8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6
echo -e "\n"
curl http://$url:$port/metadata_by_name/f8ff8eb4ac1fb039ab105fcc4420217ca3792ed1f8eba8458ac3a6d6/546865437970686572426f78 

