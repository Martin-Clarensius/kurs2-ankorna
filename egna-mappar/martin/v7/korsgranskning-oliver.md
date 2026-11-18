# Korsgranskning – Olivers härdningsrapport (labbserver elev-29)

**Granskare:** Martin Clarensius
**Datum:** 2026-11-18
**Granskat:** `hardningsrapport.md`, `metodbilaga.md` och `hardningslista.md` i Olivers mapp (`Oliver/Vecka 7`)
**Metod:** Jag har läst dokumenten och jämfört varje påstående med det belägg som anges. Jag har inte tillgång till Olivers server och har därför inte kört kommandona själv. Granskningen bedömer alltså om belägget räcker för påståendet, inte om utdatan är riktig.

*Utkast skrivet av Claude (AI) utifrån dagens chatt, att läsas och godkännas av Martin innan det skickas.*

---

## Sammanfattning

Rapporten är genomarbetad. Nästan varje påstående har en dom och ett kommando, rättelseloggen visar sex fel som hittades i AI-utkastet, och granskningen hittade dessutom två egna fynd (N1, N2) och ett verkligt fel på servern (krypterad loggning blockeras av brandväggen). Det som återstår är dels några påståenden vars belägg är för svagt eller går i cirkel, dels ett par ofyllda fält i metodbilagan.

## Styrkor

- Varje påstående har nummer, dom och kommando, och rättelseloggen i metodbilagan visar utdata för varje dom.
- Felet med loggningen (A1) är hittat, belagt med två kommandon och följs av en konkret åtgärd (R1) och ett förslag till förbättrat skript (R3).
- Rapporten är ärlig om det som inte är kontrollerat (Ö1 är markerat som ogrundat) och om vad som gick fel vid maskningen (utelämningslistan, avvikelse 1–3).
- Nya fynd (N1 om loggraden före 7529-regeln, N2 om att radnummer i historiken inte är stabila) visar att AI-utkastet granskades på riktigt och inte bara godkändes.

## Påståenden där belägget behöver stärkas

| Påstående | Problem | Förslag |
|---|---|---|
| **Ö1** (okrypterad loggning på tcp/514) | Enda påståendet utan kommando och utdata, alltså ogrundat enligt dagens regel. | Kör R5 nu: `sudo grep -rn '514' /etc/rsyslog.conf /etc/rsyslog.d/` och skriv in utdatan, så blir den en dom i stället för en öppen fråga. |
| **P20, P22, P12, P32** | Belägget är utdata från det egna skriptet `verifiera-hardning`. Studieguiden varnar för skript som säger GÄLLER utan att egentligen kontrollera. | Lägg till ett direkt belägg: P20 `sudo semanage fcontext -l -C \| grep zonwebb` och `ls -Z /srv/zonwebb/kvitto.txt`, P22 `sudo semanage permissive -l \| grep zonvakt` (ska ge ingen träff), P32 `sudo ss -tlnp \| grep 7529`, P12 `systemctl is-enabled nftables`. |
| **P13, P3, P34** | Bygger på `brandvagg-test.sh`, men rapporten medger själv i P39 att del C räknar en misslyckad anslutning som PASS. Dessutom säger utdraget i metodbilagan (`målet lyssnar, så block = bevis`) något annat än P39 (att målet kan ha varit onåbart). | Reda ut vilket som gäller och skriv det i P39. Lägg gärna till ett direkt belägg för att SSH ut blockeras, till exempel `sudo nft list chain inet zon ut` som visar `policy drop` och ingen regel för tcp/22. |
| **P27** | Belägget visar bara att modulen `permissivedomains` finns, inte att den är en standardmodul eller att ingen domän är permissiv. | Använd `sudo semanage permissive -l`, som direkt listar permissiva domäner. |
| **P31** | Ett påstående om att något saknas (inga `unconfined_service_t`) som belägg bara "ps -eZ". | Visa `ps -eZ \| grep -c unconfined_service_t` med utdatan `0`. |
| **P23** | Belägget är ett ensamt tal (8539) utan förklaring eller jämförelse. | Skriv en mening om vad talet visar, till exempel att antalet dontaudit-regler är högt när de är påslagna, och hänvisa till `semodule -B` som körts. |

## Övrigt som behöver rättas

1. **Ofyllda fält i metodbilagan.** Utelämningslistan har raden `Värdnamn (elev-29)` med texten "fyll i parets beslut", och avvikelse 4 om CTF-flaggan är en platshållare. Hostnamnet syns i rapportens rubrik och i `prompt.txt`, så svaret är sannolikt "Behölls", men Oliver måste själv avgöra och fylla i. Metodbilagan prövas vid den muntliga valideringen.
2. **Belägget i rapporten är oftast bara ett kommando.** Dagens regel är kommando och utdata. Utdatan finns i metodbilagan, men en läsare av rapporten ser den inte. Ta med ett kort utdrag i kolumnen Belägg, som P5–P10 redan gör.
3. **Domkategorier.** Dagens regel har tre domar (stämmer, fel, ogrundat). Rättelseloggen använder också "Delvis fel", "Inaktuell", "Stämmer, förstärkt" och "Rekommendation". Förklara dem eller för in dem under de tre.
4. **Samma fynd på flera ställen.** Loggningsfelet står som P4, P15, P17 och A1, och avsnitt 4 upprepar avsnitt 2 (P25/P6, P26/P21, P40/P9). Lägg in hänvisningar mellan dem så att det syns att det är samma sak.
5. **A1 är inte åtgärdat.** Central loggning är en del av tidigare milstolpar. Om R1 kan göras före måndag, gör det och lägg till en rad med nytt belägg efter åtgärden, annars står felet kvar som öppen risk till Checkpoint.
6. **Placering i repot.** Filerna ligger i `Oliver/Vecka 7`, utanför `egna-mappar/`. Flytta dem när teamet har bestämt var rapporterna ska ligga.

## Kontroller jag gjort

- Sökning efter IP-adresser och hemligheter i `prompt.txt`, `rasvar.md`, rapporten, listan och metodbilagan gav inga träffar. Endast värdnamnet elev-29 syns, i `prompt.txt` och metodbilagan.
- Portnumret 7529 stämmer med kursens regel (7500 plus elevnumret 29) i alla filer.

## Viktigast att rätta först

1. Fyll i de två tomma fälten i metodbilagan.
2. Kör kommandot för Ö1 och gör den till en dom.
3. Byt cirkelbeläggen (P20, P22, P32) och P27 mot direkta kommandon.
4. Reda ut P39 mot utdraget för del C.
