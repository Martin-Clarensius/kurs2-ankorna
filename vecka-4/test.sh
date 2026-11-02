#!/bin/bash

CSV="$(dirname "$0")/testfall.csv"
echo "ID,Destination,Port,Forvantat,Faktiskt,Status"

tail -n +2 "$CSV" | while IFS=, read -r id kalla dest port proto riktn forv; do
    if [[ ! "$dest" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "$id,$dest,$port,$forv,ej_testad,SAKNAR_IP"
        continue
    fi

    if [[ "$proto" != "tcp" ]]; then
        echo "$id,$dest,$port,$forv,ej_testad,EJ_STODD"
        continue
    fi

    timeout 3 bash -c 'echo > /dev/tcp/"$1"/"$2"' _ "$dest" "$port" 2>/dev/null
    code=$?

    if [[ "$code" -eq 0 ]]; then
        faktiskt="oppen"
    elif [[ "$code" -eq 124 ]]; then
        faktiskt="tyst"
    else
        faktiskt="avvisad"
    fi

    if [[ "$faktiskt" == "$forv" ]]; then
        status="MATCH"
    else
        status="AVVIKELSE"
    fi

    echo "$id,$dest,$port,$forv,$faktiskt,$status"
done
