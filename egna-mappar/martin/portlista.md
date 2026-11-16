# Portlista – elev-34

Server: elev-34, privat adress 172.20.1.134 (zonen Logg/övervakning).
Regelverket ligger i `/etc/sysconfig/nftables.conf`, som tjänsten nftables läser in vid start.
Grundprincip: båda kedjorna har `policy drop` (deny by default). Bara det som står nedan släpps igenom.

## Aktiva regler i nftables – inkommande (kedjan `in`)

| Nr | Från | Port | Syfte |
|----|------|------|-------|
| D1 | jump-servern 172.20.1.2 | tcp/22 | SSH från jump-servern (min egen inloggning) |
| D2 | ctf-servern 172.20.1.10 | tcp/22 | Kontroller från ctf-servern |
| D8 | ctf-servern 172.20.1.10 | tcp/80 | U7.2: ctf-servern hämtar kvittot från httpd (`/zon/kvitto.txt`). Tillagd 2026-11-16 |

Grundregler i samma kedja:
- `ct state established,related accept` – svar på trafik som redan är tillåten
- `ct state invalid drop` – trasiga eller ogiltiga paket släpps
- `iif "lo" accept` – trafik inom servern själv (till exempel `curl http://127.0.0.1`)
- Sist: allt annat loggas med prefixet `ZON-IN-DROP` (högst 10 per minut) och släpps av policyn

## Aktiva regler i nftables – utgående (kedjan `ut`)

| Nr | Till | Port | Syfte |
|----|------|------|-------|
| D3 | 185.12.64.1, 185.12.64.2 | tcp+udp/53 | DNS |
| D6 | (alla, DHCP) | udp 68 → udp 67 | Förnyelse av DHCP-adressen |
| D4 | 2.28.43.156 | udp/123 | NTP (tidssynkronisering) |
| D4 | 213.239.239.0/24 | udp/123 | NTP hos Hetzner |
| F4 | loggservern 172.20.1.58 | tcp/6514 | Loggar till loggservern över TLS |

Grundregler i samma kedja:
- `ct state established,related accept` – svar på tillåten inkommande trafik (till exempel SSH och webbsidan i D8)
- `oif "lo" accept` – trafik inom servern själv
- Sist: allt annat loggas med prefixet `ZONE-UT-DROP` (högst 10 per minut) och släpps av policyn

## Molnbrandväggen hos Hetzner (`itsx26-elev-34`)

| Nr | Riktning | Till | Port | Syfte |
|----|----------|------|------|-------|
| D7 | ut | 0.0.0.0/0 | tcp/443 | Paketuppdateringar |
| D4 | ut | 0.0.0.0/0 | udp/123 | NTP |

Molnbrandväggen har inga inkommande regler. Den privata trafiken på 172.20.1.x (jump, ctf-servern, loggservern) går inte genom den – därför fungerar D1, D2 och D8 ändå.

## Borttagna regler

| Nr | Riktning | Till | Port | Syfte | Varför borttagen |
|----|----------|------|------|-------|------------------|
| D5 | ut | loggservern 172.20.1.58 | tcp/514 | Loggar till loggservern (syslog i klartext) | Ersatt av F4 (syslog över TLS på tcp/6514). Fanns i säkerhetskopian 2026-11-09, borta i filen 2026-11-13 |

## Att fylla i / kontrollera

- ⟨Varför har loggflödet beteckningen F4 och inte D-nummer?⟩
- ⟨D7 (tcp/443 för paketuppdateringar) finns bara i molnbrandväggen. I nftables-kedjan `ut` finns ingen regel för tcp/443 – kontrollera om paketuppdateringar fungerar eller om de stoppas av nftables.⟩
- ⟨Egna motiveringar: varför just dessa DNS- och NTP-adresser?⟩
