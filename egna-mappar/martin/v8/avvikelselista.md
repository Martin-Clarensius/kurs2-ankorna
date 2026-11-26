# Vecka 8 – Avvikelselista (U8.1-fångsten)

Utkast. Verifiera varje rad mot paketnumren i Wireshark innan du lämnar in.

**Tidsreferens:** alla tider är UTC, 2026-11-18.
**Målet:** den egna servern 172.20.1.134.

## Avvikelselista

| Tid (UTC) | Flöde | Vad som avviker | Paketnummer | Säkerhet | Bedömning |
|---|---|---|---|---|---|
| 11:16:26 till 11:19:11 | 172.20.1.134 → 172.20.1.58, port 1514 | 34 SYN i jämn takt (var femte sekund), alla besvarade med RST. Ett enda mål och en enda port. | 5, 6, 7, 8 … 756 (34 SYN och 34 RST) | Hög | Felkonfiguration |
| 11:16:51–11:19:04 | fem olika interna adresser → 172.20.1.134, port 80 | En `GET /` var, svar `200 OK` med tre byte. Baslinjen har bara en HTTP-förfrågan, från en extern adress. | 18/20, 36/38, 56/58, 80/82, 746/748 | Låg | Oklart |
| 11:18:10 | 172.20.1.118 → 172.20.1.134, 220 olika portar | 236 SYN, nästan alla besvarade med RST. En källa träffar många portar en gång vardera. | 87–533 | Hög | Angrepp |
| 11:18:25–11:18:28 | 172.20.1.118 → 172.20.1.134, port 22 | 15 korta SSH-sessioner i snabb följd, var och en med handslag och nedkoppling. | 535–686 | Medel | Angrepp |
| 11:18:32–11:18:49 | 172.20.1.118:48159 → 172.20.1.134, port 22 | En längre SSH-session med stora paket (2221 och 2621 byte). Troligen den lyckade inloggningen. | 689–736 | Medel | Angrepp |
| 11:18:40–11:18:45 | 172.20.1.134 → resolvern, DNS TXT-frågor | 14 TXT-frågor till slumpartade underdomäner under `sync.telemetri-app.net`. Pågår medan SSH-sessionen är öppen. | 698, 700, 706, 708 … 728 | Hög | Angrepp |

Säkerhet anger hur starkt paketen visar det som påstås. Hög: fångsten visar det direkt. Medel: mönstret passar, men något (till exempel kryptering) döljer det sista. Låg: fångsten avgör inte syftet.

## Jämförelse mot baslinjen

Baslinjen (`egen-baslinje.pcap`) är tagen 2026-10-21 12:41–12:51 UTC och har 439 paket: 401 TCP, 32 ARP, 4 ICMP och 2 UDP (inte DNS). Linktypen är Linux cooked (SLL2), inte vanlig Ethernet.

| Det som avviker i scenariot | Vad baslinjen visar | Slutsats |
|---|---|---|
| SSH mot 172.20.1.134 från 172.20.1.118 | SSH förekommer bara mellan 172.20.1.2 och 172.20.1.134, en enda session. | 172.20.1.118 är en ny SSH-källa. Starkt stöd för avvikelse. |
| 15 korta SSH-sessioner i följd | Bara en lång session i baslinjen. | Mönstret finns inte i baslinjen. |
| Portskanning mot 220 portar från intern adress | Baslinjen har mycket skanning från externa adresser mot den publika adressen (till exempel 36 SYN mot 36 portar från en källa), alla besvarade med RST. Ingen skanning från interna adresser. | Skanning utifrån är normalt bakgrundsbrus. Skanning från en intern adress finns inte i baslinjen. |
| 34 SYN mot 172.20.1.58 port 1514 | Ingen trafik till 172.20.1.58 alls. Baslinjen är tagen före central logginsamling. | Baslinjen kan inte avgöra detta. Bedömningen felkonfiguration bygger på mönstret (jämn takt, ett mål, en port). |
| DNS-frågor, bland annat TXT mot `sync.telemetri-app.net` | Ingen DNS alls i baslinjen. | Baslinjen kan inte avgöra detta. Bedömningen bygger på frågetyp och namn. |
| HTTP `GET /` från fem interna adresser | En HTTP-förfrågan från en extern adress, besvarad av en Apache-server. | Baslinjen visar inte interna förfrågningar. Kan inte avgöras. |

Baslinjen är inte facit. Där den saknar underlag är rätt kategori "kan inte avgöras".

## Angreppsstegen i tidsordning

1. Portskanning, från 11:18:10
2. Upprepade SSH-försök, 11:18:25–11:18:28
3. Lyckad SSH-inloggning, från 11:18:32
4. Dataläckage via DNS, 11:18:40–11:18:45

## Tidslinje (utkast, loggkolumnerna fylls i efter sökning i Wazuh)

Tidsreferens: UTC, 2026-11-18. Alla paketnummer kommer från U8.1-fångsten.

| Nr | Tid (UTC) | Händelse | Paketbevis | Loggpost i Wazuh | Larmade en detektion? | Lucka |
|---|---|---|---|---|---|---|
| 0 | 11:16:26 och var femte sekund | Loggagenten på 172.20.1.134 försöker nå loggservern 172.20.1.58 på port 1514 och avvisas (felkonfiguration, inte angrepp) | 5, 6, 7, 8 … 756 | | | |
| 1 | 11:18:10 | Portskanning från 172.20.1.118 mot 220 portar | 87–533 | | | |
| 2 | 11:18:25 | 15 korta SSH-sessioner från 172.20.1.118 | 535–686 | | | |
| 3 | 11:18:32 | Längre SSH-session från 172.20.1.118:48159, troligen lyckad inloggning | 689–736 | | | |
| 4 | 11:18:40 | DNS-tunnel: 14 TXT-frågor mot `sync.telemetri-app.net` | 698, 700, 706, 708 … 728 | | | |

## Förslag på ändring (utkast, skriv om med egna ord)

Luckorna nedan är kandidater som paketen pekar på. Bekräfta eller stryk varje lucka när du har sökt i Wazuh.

| Lucka | Förslag på ändring | Varför det ger bättre spårbarhet |
|---|---|---|
| Loggagenten kan inte leverera loggar till loggservern på port 1514 (paket 5–756), så poster från incidenten kan saknas | Larma när agenten upprepat nekas av loggservern, och ge agenten en kö så att loggar sparas lokalt och skickas när anslutningen fungerar igen | Luckan i loggningen märks direkt, och inga poster förloras under avbrottet |
| Skanningen från en intern adress syns i trafiken (paket 87–533) men inte nödvändigtvis i någon logg | Logga nekade anslutningar i paketfiltret och larma när en intern källa skickar SYN mot många portar | Skanningen blir en loggpost med tid, källa och mål som går att koppla till paketen |
| DNS-tunneln (paket 698–728) syns bara i trafiken | Tillåt DNS ut bara via den interna resolvern, och logga DNS-frågor så att TXT-frågor mot okända domäner kan sökas och larmas på | Dataläckaget får en loggpost och kan spåras till servern |

## Metod: så togs utkastet fram

Verktyget tshark fanns inte i miljön, så utkastet togs fram med ett eget Python-skript (`pcapsum.py`) som läser pcap-filen direkt och inte med Wireshark. Skriptet fick först fel linktyp för baslinjen (276) och gav missvisande resultat. Det rättades och baslinjen kördes om. Skriptet kördes med `python3 -I pcapsum.py FIL LÄGE`. Lägena som kördes, på U8.1-fångsten om inget annat anges:

| Körning | Vad den gjorde |
|---|---|
| `info` (på båda filerna) | Räknade paket per protokoll, tidsspann och mest aktiva adresser. Visade vad baslinjen innehåller (se jämförelsen nedan). |
| `conv` | Räknade paket, nyttolast och TCP-flaggor per flöde (källa, mål, målport). |
| `syn` | Räknade SYN-paket utan ACK per källa och mål, och hur många olika målportar. Visade skanningen och de 34 SYN mot port 1514. |
| `dns` | Listade DNS-frågor och svar med tid, frågetyp och namn. Visade TXT-frågorna mot `sync.telemetri-app.net`. |
| `http` | Listade HTTP-förfrågningar och svar. |
| `ssh` | Listade SSH-paket med nyttolast på port 22. Visade de korta sessionerna och den långa. |
| `list` med textfilter | Listade enskilda paket med paketnummer, tid, adresser, portar och flaggor. Användes för att hitta första och sista paketet i varje steg. |

Motsvarande kontroll i tshark eller Wireshark (dessa kördes inte av mig, men visar samma sak):

| Kommando | Vad det betyder |
|---|---|
| `tshark -r U8.1-scenario.pcap -q -z io,phs` | `-r` läser fångstfilen. `-q` döljer paketlistan så att bara statistiken skrivs ut. `-z io,phs` visar protokollhierarkin: vilka protokoll som finns och hur många paket vart och ett har. |
| `tshark -r U8.1-scenario.pcap -q -z conv,tcp` | `-z conv,tcp` listar alla TCP-konversationer: vilka två adresser som pratar, hur många paket och byte, och hur länge. |
| `tshark -r U8.1-scenario.pcap -Y 'tcp.flags.syn==1 && tcp.flags.ack==0' -T fields -e ip.src -e ip.dst -e tcp.dstport \| sort \| uniq -c \| sort -rn` | `-Y` är ett visningsfilter: bara SYN-paket utan ACK, alltså de som försöker öppna en anslutning. `-T fields -e ...` skriver bara ut källadress, måladress och målport. `sort \| uniq -c` räknar hur många gånger varje rad förekommer, och `sort -rn` visar flest först. Många SYN från en källa mot många portar är en skanning. |
| `tshark -r U8.1-scenario.pcap -Y 'dns.flags.response==0' -T fields -e frame.number -e frame.time -e dns.qry.type -e dns.qry.name` | Visar bara DNS-frågor (inte svar). Skriver ut paketnummer, tid, frågetyp (TXT är typ 16) och namnet som frågades efter. Långa, slumpartade underdomäner är ett tecken på en DNS-tunnel. |
| `tshark -r U8.1-scenario.pcap -Y 'http.request \|\| http.response'` | Visar bara HTTP-förfrågningar och HTTP-svar, så att du ser vad som begärdes och vad servern svarade. |
| `tshark -r U8.1-scenario.pcap -Y 'tcp.port==22'` | Visar all trafik till eller från port 22, alltså SSH. Där ser du de korta sessionerna och den längre. |

I Wireshark skriver du samma uttryck (utan `tshark` och `-Y`) i filterraden.

## Dömda AI-förslag

| Förslag | Dom (stämmer, fel eller ogrundat) | Skäl | Paketnummer |
|---|---|---|---|
| Filtret `tcp.flags.syn==1 && tcp.flags.ack==0` hittar skanningen | Stämmer | Filtret listar 236 SYN från 172.20.1.118 mot 172.20.1.134: 220 mot olika portar, en gång var, nästan alla besvarade med RST (skanningen), och 16 mot port 22 (SSH-sessionerna). Det visar också andra flöden (34 mot port 1514 och fem mot port 80), så filtret måste kombineras med käll- och måladress. | 87–533 |
| De 15 korta SSH-sessionerna är upprepade inloggningsförsök | Ogrundat | Fångsten visar 15 sessioner i följd från samma källa, var och en 10 paket och 0,12–0,28 sekunder. SSH är krypterat, så misslyckad autentisering syns inte. Mönstret passar inloggningsförsök, men fångsten visar inte att det är inloggning. Loggen får avgöra i workshop 2. | 535–686 |
| Den längre SSH-sessionen är den lyckade inloggningen | Ogrundat | Sessionen varar 17 sekunder och bär 4842 byte nyttolast, mot 420–760 byte i de korta, och pågår när DNS-tunneln börjar. Men krypteringen döljer om inloggningen lyckades. Bekräftas först av loggposten Accepted i Wazuh (U8.3). | 689–736 |
| De 34 SYN mot 172.20.1.58 port 1514 är en felkonfiguration | Stämmer | Alla 34 SYN från 172.20.1.134 kommer med exakt 5,0 sekunders mellanrum under hela fångsten, mot en enda adress och port, och alla besvaras med RST. Jämn takt, ett mål och en port är en trasig klient, inte en skanning. Fångsten visar inte varför loggservern avvisar porten. | 5, 6, 7, 8 … 756 |
| Frågorna mot `sync.telemetri-app.net` är en DNS-tunnel | Stämmer | 14 TXT-frågor (typ 16) mellan 11:18:40 och 11:18:45 mot slumpartade underdomäner, medan de vanliga A-frågorna mot ctf och log.sec.chas-lab.dev (paket 704 och 730) ser normala ut. Baslinjen har ingen DNS, så domen bygger på frågetyp och namn. | 698, 700, 706, 708 … 728 |
| HTTP-förfrågningarna från de fem interna adresserna är hälsokontroller | Ogrundat | Fångsten visar bara en `GET /` från varje adress och ett svar `200 OK` med tre byte. Baslinjen har inga interna HTTP-förfrågningar att jämföra mot, så syftet kan inte avgöras. | 18, 20, 36, 38, 56, 58, 80, 82, 746, 748 |
| Baslinjen innehåller bara ICMP | Fel | Baslinjen har 439 paket: 401 TCP, 32 ARP, 4 ICMP och 2 UDP, bland annat en SSH-session mellan 172.20.1.2 och 172.20.1.134. Förslaget byggde på att filens linktyp (276, Linux cooked) lästes fel. | 1, 3, 5, 6 (i baslinjen) |
