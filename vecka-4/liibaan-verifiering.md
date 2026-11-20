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
- Dokumenterat delvis verifierade tester för D2 och D6.
- Verifierat en etablerad rsyslog-anslutning till den centrala loggservern via TCP 6514.

## F1 – Internet till Webb/DMZ, TCP 443

**Status: Verifierad.**

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

**Status: Delvis verifierad.**

- Källa: 10.40.2.3
- Testdestination: 10.40.2.34
- F2-regeln är aktiv i nftables.
- tcpdump visade utgående SYN-paket.
- Inget SYN-ACK observerades.
- Anslutningen gav timeout.

Application-serverns faktiska IP och tjänst är inte bekräftade. Fullständig anslutning återstår att verifiera.

## F3 – Application till Databas, TCP 5432

**Status: Ej verifierad.**

Applikationsserverns och databasserverns faktiska IP-adresser behöver bekräftas med gruppen. Fullständig anslutning har inte verifierats från elev-03.

## F4 – Godkända servrar till central loggserver, TCP 6514 (TLS)

**Status: TCP-anslutning verifierad.**

- Källserver: 172.20.1.103 (elev-03)
- Loggserver: 172.20.1.58
- Port: TCP 6514
- Brandväggsregel finns i `/etc/nftables/u41.nft`.
- `ss -tnp` visade en etablerad TCP-anslutning (`ESTAB`) från rsyslogd till loggservern.

Mottagning och sökbarhet för en specifik testlogg behöver bekräftas på den centrala loggservern.

## F5 – Jump-server till Management, TCP 22

**Status: Inte verifierad i denna dokumentation.**

Verifiering av flödet behöver genomföras tillsammans med gruppen.

## F6 – Management till godkända servrar, TCP 22

**Status: Inte verifierad i denna dokumentation.**

Flödet är enligt gruppens flödestabell redan genomfört i brandväggen på elev-34. Verifiering från elev-03 återstår.

## F7 – Internet till Databas

**Status: Ej verifierad.**

Databasserverns faktiska IP och en lämplig extern testväg behöver bekräftas med teamet.

## F8 – Internet till Management

**Status: Ej verifierad.**

Management-adresser enligt adressplanen:

- Oliver: 10.40.2.98
- Per: 10.40.2.99

Blockering från Internet behöver verifieras tillsammans med ansvariga.

## F9 – Webb/DMZ till databaszon

**Status: Lokalt blockeringstest genomfört.**

- Källa: 10.40.2.3
- Testdestination: 10.40.2.65
- Resultat: Timeout, exitkod 124.
- Brandväggslogg: ZON-UT-DROP, DPT=5432.

nftables loggade blockering av testtrafiken.

10.40.2.65 är en testadress, inte en bekräftad databasserver.

## F10 – Otillåten trafik, TCP 8080

**Status: Lokalt blockeringstest genomfört.**

- Källa: 10.40.2.3
- Testdestination: 10.40.2.65
- Resultat: Timeout, exitkod 124.
- Brandväggslogg: ZON-UT-DROP, DPT=8080.

nftables loggade blockering av testtrafiken.

## Driftflöden D1–D4 och D6–D9

- D1: SSH från jump, TCP 22 – verifierad.
- D2: SSH från CTF, TCP 22 – regel konfigurerad, test från rätt källa återstår.
- D3: DNS TCP/UDP 53 – verifierad.
- D4: NTP UDP 123 – verifierad.
- D6: DHCP – konfiguration och brandväggsregel verifierade, nytt DHCP-utbyte inte fångat.
- D7: Utgående HTTPS TCP 443 till 146.75.122.132 – verifierad.
- D8: Webbkvitto från CTF 172.20.1.10, TCP 80 – teststatus behöver bekräftas.
- D9: Zonvakt från CTF 172.20.1.10, TCP 7534 – teststatus behöver bekräftas. Portnumret behöver stämmas av med gruppen eftersom zonvakten tidigare observerats lyssna på TCP 7503.

## Teamets subnät och begränsningar – 2 november 2026

Team Ankorna består av fyra personer.

Enligt diskussion med Per behöver vi inte placera en server i varje subnät. Vi använder de servrar som finns och dokumenterar begränsningarna.

Min server elev-03 använder 10.40.2.3 i Webb/DMZ, 10.40.2.0/27.

Applikationsserver och databasserver har ännu inte bekräftats.

Tester som inte kan genomföras dokumenteras som ej fullständigt verifierade, med en förklaring. Det innebär inte automatiskt att de är godkända.

## Återstående arbete

- F2: Bekräfta Application-serverns IP och tjänst samt verifiera fullständig anslutning.
- F3: Verifiera flödet tillsammans med gruppen.
- F5–F6: Komplettera verifiering tillsammans med gruppen.
- F7 och F8: Genomföra tester från rätt källa.
- F4: Bekräfta mottagning och sökbarhet för en specifik testlogg på den centrala loggservern.
- D2: Testa SSH från rätt CTF-källa.
- D8: Bekräfta teststatus.
- D9: Bekräfta rätt port med gruppen och genomföra test.
- F9 och F10: Kompletterande verifiering vid behov.
- Krav 8: Fullständig testkörning.
- Krav 10: Två fullständiga testkörningar, med dokumenterade resultat och begränsningar.

## Slutsats

Webb/DMZ-servern är ansluten till teamnätet. HTTPS från Internet fungerar och brandväggsreglerna finns kvar efter omstart.

Flera tillåtna och blockerade trafikflöden har testats och dokumenterats. För F4 har en etablerad TCP-anslutning från rsyslogd till den centrala loggservern via TCP 6514 verifierats.

Fullständig verifiering kräver fortsatt samarbete med teamet, framför allt för flöden där målservrar eller rätt testkällor saknas. Mottagning av testloggar behöver också bekräftas på den centrala loggservern.
