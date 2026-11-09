# Verifieringsanteckning – Central logginsamling

**Utbildning:** Chas Academy – ITSX26  
**Kurs:** 2 – Nätverk och säkerhet  
**Vecka:** 5 – Centralloggning och spårbarhet  
**Server:** elev-03  
**Datum:** 5 november 2026

## 1. Syfte

Syftet med verifieringen är att kontrollera att säkerhetsloggar från elev-03 skickas till den centrala loggservern över skyddad transport.

Testet ska visa att en lokal säkerhetshändelse kan identifieras centralt med korrekt värdnamn, tidsstämpel och transporttyp.

## 2. Testmiljö

| Parameter | Värde |
|---|---|
| Källserver | elev-03 |
| Källadress | 172.20.1.103 |
| Central loggserver | log.sec.chas-lab.dev |
| Mottagaradress | 172.20.1.58 |
| Protokoll | TCP |
| Port | 6514 |
| Transportskydd | TLS |
| Sökverktyg | `loggsök` på jump |

## 3. Genomförande

### Steg 1 – Skapa en säkerhetshändelse

På elev-03 utfördes ett test mot TCP-port 12345 på loggservern:

```bash
timeout 3 bash -c 'echo > /dev/tcp/172.20.1.58/12345' 2>/dev/null || true
```

Porten var inte tillåten i värdbrandväggens utgående regler.

Brandväggen blockerade trafiken och genererade loggmeddelanden med prefixet:

`ZON-UT-DROP`

### Steg 2 – Kontrollera händelsen lokalt

De lokala brandväggsloggarna visade blockerad trafik mot destinationsport 12345 den 5 november kl. 08:26:57–08:26:58 UTC.

Händelsen innehöll information om bland annat destination, protokoll och destinationsport.

### Steg 3 – Söka efter händelsen centralt

På jump-servern användes:

```bash
loggsök ZON-UT-DROP | grep 'DPT=12345'
```

Sökningen gav två centrala träffar från elev-03.

## 4. Verifierade resultat

| Fält | Resultat |
|---|---|
| Första mottagningstid | 2026-11-05 08:26:57.935 UTC |
| Andra mottagningstid | 2026-11-05 08:26:58.836 UTC |
| Avsändande server | elev-03 |
| Avsändaradress | 172.20.1.103 |
| Transportmarkering | TLS |
| Loggprefix | ZON-UT-DROP |
| Destinationsport | TCP 12345 |

De två händelserna hittades på den centrala loggservern med rätt avsändare och förväntat logginnehåll.

De centrala mottagningstiderna överensstämde med den observerade lokala händelseperioden på sekundnivå.

## 5. Skyddad transport

Rsyslog på elev-03 använder TLS för att vidarebefordra loggar till loggservern.

Den undersökta konfigurationen innehåller:

```text
target="172.20.1.58"
port="6514"
protocol="tcp"
StreamDriver="gtls"
StreamDriverMode="1"
StreamDriverAuthMode="x509/name"
StreamDriverPermittedPeers="log.sec.chas-lab.dev"
```

Detta visar att rsyslog är konfigurerat för krypterad överföring med certifikatbaserad kontroll av mottagarens namn.

De centrala testhändelserna var markerade `TLS`, vilket stöder att de mottogs via den skyddade loggkanalen.

## 6. Kontroll av kö och återanslutning

Vid en separat kontroll av rsyslogs tjänstelogg hittades följande händelser den 4 november kl. 11:09:14:

- `action 'action-1-builtin:omfwd' suspended`
- `no working target servers in pool available`
- `action 'action-1-builtin:omfwd' resumed`

Det visar att rsyslog rapporterade ett tillfälligt avbrott och därefter återupptog vidarebefordringen.

Diskbaserade köfiler hittades också i `/var/lib/rsyslog/`:

- `fwd.00000001` – 21 KB
- `fwd.qi` – 548 byte

Filerna bekräftar att diskbaserad köhantering har använts. De bevisar däremot inte ensamma att alla meddelanden har levererats eller att inga loggar har förlorats.

## 7. Bedömning

Testet visar att en säkerhetshändelse från elev-03 kan registreras lokalt och återfinnas på den centrala loggservern.

Följande är verifierat:

- Brandväggen genererade den förväntade testhändelsen.
- Händelsen hittades centralt.
- Rätt värdnamn och källadress identifierades.
- Händelsen hade en UTC-tidsstämpel.
- Den centrala mottagningen var markerad TLS.
- Diskbaserad köhantering och återanslutning har observerats.

Testet verifierar den undersökta loggströmmen, men innebär inte att samtliga loggkällor eller alla tänkbara avbrottsscenarier har testats.

## 8. Slutsats

**Verifieringen är godkänd för den testade brandväggshändelsen på elev-03.**

Logginsamlingen fungerade och händelsen kunde identifieras centralt med rätt avsändare, tidsuppgifter och TLS-markering.

Resultatet utgör evidens för milstolpen om central logginsamling under kursvecka 5.