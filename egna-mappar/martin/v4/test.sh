#!/usr/bin/env bash
# Läser testfall.csv rad för rad, provar en TCP-anslutning med timeout och skriver faktiskt utfall.
fil="${1:-testfall.csv}"
echo "id,forvantat,faktiskt"
tail -n +2 "$fil" | while IFS=, read -r id kalla dest port proto riktn forv _; do
  start=$(date +%s%N)
  timeout 3 bash -c "exec 3<>/dev/tcp/$dest/$port" 2>/dev/null
  rc=$?
  ms=$(( ($(date +%s%N) - start) / 1000000 ))
  if [ $rc -eq 0 ]; then utfall=oppen
  elif [ $rc -eq 124 ]; then utfall=tyst # timeout avbröt – inget svar
  else utfall=avvisad # snabbt nej: RST eller ICMP-fel
  fi
  echo "$id,$forv,$utfall ($ms ms)"
done
