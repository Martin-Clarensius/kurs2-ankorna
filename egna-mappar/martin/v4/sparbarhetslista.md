| Rad-id | Riktning | Källa | Mål | Proto/port | Lager | Regelns identifierare | Loggar? | Status |
|---|---|---|---|---|---|---|---|---|
| D1 | in | 172.20.1.2 (jump) | min server | tcp/22 | värd | nft in "D1" | nej | implementerad, ej testad |
| D2 | in | 172.20.1.10 (ctf) | min server | tcp/22 | värd | nft in "D2" | nej | implementerad, ej testad |
| D3 | ut | min server | 185.12.64.1/.2 | tcp+udp/53 | värd (molnet släpper alltid) | nft ut "D3" | nej | testad: D3-till, D3-nek |
| D4 | ut | min server | internet | udp/123 | moln + värd | molnregel 2, nft ut "D4" | nej | implementerad, ej testad (UDP) |
| D5 | ut | min server | 172.20.1.58 | tcp/514 | värd (privat nät) | nft ut "D5" | nej | testad: D5-till, D5-nek |
| D6 | ut | min server | DHCP-servrar | udp 68→67 | värd (molnet släpper alltid) | nft ut "D6" | nej | implementerad, ej testad (UDP) |
| D7 | ut | min server | internet | tcp/443 | moln + värd | molnregel 1, nft ut "D7" | nej | testad: D7-till, D7-nek |
| F4 | in | Webb/App/DB (10.40.2.0–.79) | min server (Logg) | tcp/514 | värd | nft in "F4" | nej | implementerad, ej testad |
| F4 | ut | min server | 172.20.1.58 | tcp/6514 | värd | nft ut "F4 (TLS)" | nej | testad: F4-ut-till |
| F6 | in | Management 10.40.2.96/28 | min server | tcp/22 | värd | nft in "F6" | nej | implementerad, ej testad |
| F10 | in/ut | övriga | övriga | alla | värd | policy drop + loggregel | ZON-IN-DROP / ZON-UT-DROP | testad (ut): F10-nek-ut |