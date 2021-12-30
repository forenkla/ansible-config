#!/bin/sh
# /usr/bin/env bash
# id: scripts/trivial-inventory-script.sh

HOST_LIST=$(/usr/local/bin/prlctl list | /usr/bin/awk -v col=4 '{print $col}' | /usr/bin/awk 'NR>1')

#echo $HOST_LIST;

IP_LIST=$('/usr/bin/xargs -I{} /usr/local/bin/prlctl exec {} ip -4 -br addr show enp0s5 | awk '{print $3}' | cut -d / -f 1)


ALL_INFO=$(paste <(echo "$HOST_LIST") <(echo "$IP_LIST"))

NUM_OF_HOSTS=$(echo "$HOST_LIST" | wc -l)
n=1
while read -r vm; do
        if [[ "$NUM_OF_HOSTS" -gt "$n" ]]; then
                        HOSTS="$HOSTS \"$(echo "$vm" |  awk 'BEGIN {FS="\t"}; {print $1}')\", "
                        HOST_VARS="$HOST_VARS \"$(echo "$vm" |  awk 'BEGIN {FS="\t"}; {print $1}')\": { \"ansible_host\": \"$(echo "$vm" | awk 'BEGIN {FS="\t"}; {print $2}')\" },"
        else
                        HOSTS="$HOSTS \"$(echo "$vm" |  awk 'BEGIN {FS="\t"}; {print $1}')\""
                        HOST_VARS="$HOST_VARS \"$(echo "$vm" |  awk 'BEGIN {FS="\t"}; {print $1}')\": { \"ansible_host\": \"$(echo "$vm" | awk 'BEGIN {FS="\t"}; {print $2}')\" }"
        fi
        let n=n+1;
done <<< "$ALL_INFO"

echo "{"
echo   "\"all\": {"  
echo        "\"hosts\": [" 
echo $HOSTS ;
echo   "] }," 
echo   " \"_meta\": {" 
echo       " \"hostvars\": {" 
echo $HOST_VARS "}}}" 
