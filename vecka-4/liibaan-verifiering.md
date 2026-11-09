# Vecka 4 – Webb/DMZ – Liibaan

## Server
- Server: elev-03
- Team: Ankorna
- Zon: Webb/DMZ
- Privat IP: 10.40.2.3
- Subnät: 10.40.2.0/27
- Publik IP: 2.28.98.141

## Genomfört
- Kopplat servern till teamnätet.
- Verifierat IP-adressen 10.40.2.3 på eth2.
- Konfigurerat F1: inkommande TCP 443 i molnbrandväggen och nftables.
- Kontrollerat nftables-konfigurationens syntax.
- Verifierat fortsatt SSH-åtkomst.
- Verifierat att brandväggsreglerna finns kvar efter omstart.
- Verifierat HTTPS lokalt, via privat IP och från Internet.
- Genomfört två separata F1-testkörningar.
- Dokumenterat sex planerade testfall i testfall.csv.
- Testat F2, F9 och F10 med dokumenterade resultat.
- Verifierat D1, D3, D4 och D7.
- Dokumenterat delvis verifierade tester för D5 och D6.

## F1 – Internet till Webb/DMZ, TCP 443

Status: Verifierad.

Webbserver: Apache 2.4.62

Kontroller:
- TCP 443 lyssnar på servern.
- Lokal HTTPS-kontroll gav HTTP/1.1 200 OK.
- HTTPS via 10.40.2.3 gav HTTP/1.1 200 OK.
- Extern HTTPS-kontroll från Mac till 2.28.98.141 gav HTTP/1.1 200 OK.

Två separata testkörningar har dokumenterats:
- f1-testkorning-1.txt
- f1-testkorning-2.txt

Dessa verifierar F1, men inte två fullständiga testkörningar av alla flöden.

## F2 – Webb/DMZ till Application, TCP 80

Status: Delvis verifierad.

- Källa: 10.40.2.3
- Testdestination: 10.40.2.34
- F2-regeln är aktiv i nftables.
- tcpdump visade utgående SYN-paket.
- Inget SYN-ACK observerades.
- Anslutningen gav timeout.

Application-serverns faktiska IP och tjänst är inte bekräftade. Fullständig anslutning återstår att verifiera.

## F7 – Internet till Databas

Status: Ej verifierad.

Databasserverns faktiska IP och en lämplig extern testväg behöver bekräftas med teamet.

## F8 – Internet till Management

Status: Ej verifierad.

Management-adresser enligt adressplanen:
- Oliver: 10.40.2.98
- Per: 10.40.2.99

Blockering från Internet behöver verifieras tillsammans med ansvariga.

## F9 – Webb/DMZ till databaszon, TCP 5432

Status: Lokalt blockeringstest genomfört.

- Källa: 10.40.2.3
- Testdestination: 10.40.2.65
- Resultat: Timeout, exitkod 124.
- Brandväggslogg: ZON-UT-DROP, DPT=5432.

nftables loggade blockering av testtrafiken.

10.40.2.65 är en testadress, inte en bekräftad databasserver.

## F10 – Otillåten trafik, TCP 8080

Status: Lokalt blockeringstest genomfört.

- Källa: 10.40.2.3
- Testdestination: 10.40.2.65
- Resultat: Timeout, exitkod 124.
- Brandväggslogg: ZON-UT-DROP, DPT=8080.

nftables loggade blockering av testtrafiken.

## Driftflöden D1–D7

- D1: SSH från jump – verifierad.
- D2: SSH från CTF – regel konfigurerad, test från rätt källa återstår.
- D3: DNS TCP/UDP 53 – verifierad.
- D4: NTP UDP 123 – verifierad.
- D5: Logg TCP 514 – etablerad rsyslog-anslutning verifierad, mottagning återstår att bekräfta.
- D6: DHCP – konfiguration och brandväggsregel verifierade, nytt DHCP-utbyte inte fångat.
- D7: Utgående HTTPS TCP 443 – verifierad.

## Teamets subnät och begränsningar – 2 november 2026

Team Ankorna består av fyra personer.

Enligt diskussion med Per behöver vi inte placera en server i varje subnät. Vi använder de servrar som finns och dokumenterar begränsningarna.

Min server elev-03 använder 10.40.2.3 i Webb/DMZ, 10.40.2.0/27.

Applikationsserver och databasserver har ännu inte bekräftats.

Tester som inte kan genomföras dokumenteras som ej fullständigt verifierade, med en förklaring. Det innebär inte automatiskt att de är godkända.

## Återstående arbete

- F2: Fullständig anslutning till Application.
- F3–F6: Verifiering tillsammans med teamet.
- F7 och F8: Tester från rätt källa.
- F9 och F10: Kompletterande verifiering vid behov.
- Krav 8: Fullständig testkörning.
- Krav 10: Två fullständiga testkörningar, med dokumenterade resultat och begränsningar.

## Slutsats

Webb/DMZ-servern är ansluten till teamnätet. HTTPS från Internet fungerar och brandväggsreglerna finns kvar efter omstart.

Flera tillåtna och blockerade trafikflöden har testats och dokumenterats.

Fullständig verifiering kräver fortsatt samarbete med teamet, framför allt för flöden där målservrar eller rätt testkällor saknas.