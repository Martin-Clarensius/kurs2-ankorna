# Tillgångsförteckning – Servrar

## Syfte

Syftet med denna dokumentation är att identifiera och dokumentera
servrar och andra relevanta värdar i labbmiljön.

För varje server dokumenteras:

- Servernamn
- Roll och funktion
- Intern IP-adress
- Belägg för identifieringen

Informationen har samlats in genom terminalkommandon,
uppgifter från labbmiljön och analys av nätverksfångster
från U1.3 (Lagerkartan) och U1.4 (Avvikelsen).

## Identifierade interna servrar

| Namn | Roll | Intern IP-adress | Belägg |
|---|---|---|---|
| jump.sec.chas-lab.dev | Jump host / åtkomstserver | 172.20.1.2 | Servernamn enligt labbmiljön, `hostname`, `ip -br addr`, U1.3 och U1.4 |
| sladd.sec.chas-lab.dev | Webbserver | 172.20.1.58 | DNS-svar och webbtrafik i `U1.3-lagerkartan.pcap` |
| elev-29 | Personlig labbserver | 172.20.1.129 | `hostname`, `hostname -f` och SSH-kommunikation i `U1.4-avvikelsen.pcap` |

## Dokumentation av identifierade servrar

### jump.sec.chas-lab.dev

- **Namn:** `jump.sec.chas-lab.dev`
- **Kortnamn:** `jump`
- **Roll:** Jump host / åtkomstserver
- **Intern IP-adress:** `172.20.1.2`
- **Beskrivning:** Servern används som åtkomstpunkt till labbmiljön via SSH. När man loggar in visas kortnamnet `jump` i terminalen.
- **Belägg:** Serverns fullständiga namn är känt från labbmiljön. Kommandot `hostname` visar `jump` och `ip -br addr` visar den interna IP-adressen `172.20.1.2`. Servern förekommer även i nätverksfångsterna U1.3 och U1.4.

### sladd.sec.chas-lab.dev

- **Namn:** `sladd.sec.chas-lab.dev`
- **Roll:** Webbserver
- **Intern IP-adress:** `172.20.1.58`
- **Beskrivning:** Servern identifierades genom DNS-trafik i U1.3. Ett DNS-svar kopplar domännamnet `sladd.sec.chas-lab.dev` till IP-adressen `172.20.1.58`. Nätverksfångsten visar även att servern besvarar HTTP-förfrågningar.
- **Belägg:** DNS-svar och HTTP-kommunikation i `U1.3-lagerkartan.pcap`.

### elev-29

- **Namn:** `elev-29`
- **Roll:** Personlig labbserver
- **Intern IP-adress:** `172.20.1.129`
- **Beskrivning:** Detta är min individuella labbserver som används för kursens praktiska laborationer. Servern kan nås via jump-servern.
- **Belägg:** Kommandona `hostname` och `hostname -f` visar båda `elev-29`. I `U1.4-avvikelsen.pcap` observerades även SSH-kommunikation mellan jump-servern och `172.20.1.129`.
- **Kommentar:** Något längre fullständigt domännamn har inte kunnat fastställas. Därför används det verifierade namnet `elev-29`.

## Övriga observerade servrar och tjänster

Följande adresser har observerats i nätverksfångsterna.
De redovisas separat eftersom det ännu inte är fastställt
om de tillhör labbmiljöns egna tillgångar.

| Namn | Observerad funktion | IP-adress | Belägg |
|---|---|---|---|
| log.sec.chas-lab.dev | Webb-/statustjänst | 46.224.108.117 | DNS-svar och HTTP-kommunikation i U1.4 |
| Ej identifierat | DNS-server | 185.12.64.1 | DNS-svar i U1.3 och U1.4 |
| Ej identifierat | NTP-server | 185.12.64.2 | NTP-svar i U1.4 |

### log.sec.chas-lab.dev

- **Namn:** `log.sec.chas-lab.dev`
- **IP-adress:** `46.224.108.117`
- **Observerad funktion:** Webb-/statustjänst
- **Beskrivning:** Domännamnet identifierades genom DNS-trafik i U1.4. Nätverksfångsten visar även en HTTP-förfrågan till `/status.json` som besvarades av servern.
- **Belägg:** `U1.4-avvikelsen.pcap`
- **Kommentar:** Serverns tillhörighet till labbmiljön behöver verifieras.

### DNS-server – 185.12.64.1

- **Namn:** Ej identifierat
- **IP-adress:** `185.12.64.1`
- **Observerad funktion:** DNS-server
- **Beskrivning:** Adressen förekommer som avsändare av DNS-svar i nätverksfångsterna.
- **Belägg:** `U1.3-lagerkartan.pcap` och `U1.4-avvikelsen.pcap`
- **Kommentar:** Serverns tillhörighet till labbmiljön behöver verifieras.

### NTP-server – 185.12.64.2

- **Namn:** Ej identifierat
- **IP-adress:** `185.12.64.2`
- **Observerad funktion:** NTP-server
- **Beskrivning:** Adressen förekommer som avsändare av NTP-svar i U1.4.
- **Belägg:** `U1.4-avvikelsen.pcap`
- **Kommentar:** Serverns tillhörighet till labbmiljön behöver verifieras.

## Metod och kommandon

Följande terminalkommandon användes vid undersökningen.

### Identifiering av servernamn

```bash
hostname
hostname -f
```

Kommandot `hostname` användes för att identifiera serverns namn.

På min personliga labbserver visade både `hostname`
och `hostname -f` resultatet:

```text
elev-29
```

På jump-servern visade `hostname`:

```text
jump
```

Jump-serverns fullständiga namn är
`jump.sec.chas-lab.dev` enligt labbmiljön.

### Identifiering av IP-adress

```bash
ip -br addr
```

På jump-servern visade kommandot bland annat:

```text
eth1    UP    172.20.1.2/32
```

Detta användes som belägg för jump-serverns interna IP-adress.

### Analys av nätverksfångster

```bash
tcpdump -nn -r U1.3-lagerkartan.pcap
tcpdump -nn -r U1.4-avvikelsen.pcap
```

Kommandona användes för att läsa sparade nätverksfångster.

I U1.3 identifierades bland annat:

- `172.20.1.2` – jump-servern
- `172.20.1.58` – webbservern `sladd.sec.chas-lab.dev`
- `172.20.1.129` – min personliga labbserver

I U1.4 identifierades bland annat:

- SSH-kommunikation mellan `172.20.1.2` och `172.20.1.129`
- DNS- och HTTP-kommunikation med `log.sec.chas-lab.dev`
- DNS-svar från `185.12.64.1`
- NTP-svar från `185.12.64.2`

## Begränsningar och fortsatt arbete

Följande återstår att undersöka eller komplettera:

- Identifiera de övriga fyra gruppmedlemmarnas personliga labbservrar.
- Dokumentera deras servernamn, roller och interna IP-adresser.
- Samla belägg för de ytterligare servrarna.
- Verifiera om de observerade publika IP-adresserna tillhör labbmiljöns egna tillgångar.
- Komplettera den gemensamma tillgångsförteckningen med gruppmedlemmarnas resultat.

Tjänster, protokoll och portar dokumenteras av en annan
gruppmedlem och sammanställs senare i den gemensamma
tillgångsförteckningen.

## Sammanfattning

Hittills har tre interna servrar eller värdar identifierats:

1. `jump.sec.chas-lab.dev` – åtkomstserver med IP-adressen `172.20.1.2`.
2. `sladd.sec.chas-lab.dev` – webbserver med IP-adressen `172.20.1.58`.
3. `elev-29` – min personliga labbserver med IP-adressen `172.20.1.129`.

Därutöver har tre externa eller ännu ej klassificerade
servrar och tjänster observerats i nätverksfångsterna.

Inventeringen behöver kompletteras med de övriga
gruppmedlemmarnas individuella labbservrar innan
gruppens gemensamma tillgångsförteckning är färdig.