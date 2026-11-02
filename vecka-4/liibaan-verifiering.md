# Vecka 4 – Webb/DMZ – Liibaan

## Server
- Server: elev-03
- Team: Ankorna
- Zon: Webb/DMZ
- Privat IP: 10.40.2.3

## Genomfört
- Kopplat servern till teamnätet.
- Verifierat IP-adressen 10.40.2.3 på eth2.
- Lagt till F1: inkommande TCP 443 i molnbrandväggen.
- Lagt till TCP 443 i nftables input-kedja.
- Kontrollerat nftables-konfigurationens syntax.
- Aktiverat reglerna och verifierat fortsatt SSH-åtkomst.
- Dokumenterat sex planerade testfall i testfall.csv.

## Återstår att verifiera
- HTTPS-tjänst på port 443 (ingen lyssnande tjänst verifierad).
- F2: Webb/DMZ till Application TCP 80 (Application-IP saknas).
- F7–F10: faktiska trafiktester och mätresultat.
- F3–F6: verifiering tillsammans med ansvariga teammedlemmar.

## Slutsats
Brandväggsregeln F1 är konfigurerad och SSH-åtkomst
fungerar efter aktivering. Fullständig trafikverifiering
återstår. Testfallens förväntade resultat är inte
uppmätta resultat.

## Trafiktester – 2 november 2026

### F9 – Webb/DMZ till databaszon
- Källa: 10.40.2.3
- Testdestination: 10.40.2.65
- Port: TCP 5432
- Resultat: timeout, exit code 124
- Logg: ZON-UT-DROP, DPT=5432
- Slutsats: nftables blockerade testtrafiken.

### F10 – Otillåten trafik
- Källa: 10.40.2.3
- Testdestination: 10.40.2.65
- Port: TCP 8080
- Resultat: timeout, exit code 124
- Logg: ZON-UT-DROP, DPT=8080
- Slutsats: nftables blockerade testtrafiken.

Observera: 10.40.2.65 är en testadress.
Databasserverns faktiska IP har inte bekräftats.
