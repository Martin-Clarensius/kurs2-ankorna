# Spårbarhet – Team Ankorna, vecka 4

## Trafikflöden

| Regel | Trafik | Status | Bevis |
|---|---|---|---|
| F1 | Internet → Webb/DMZ TCP 443 | Konfigurerad | Regel finns i nftables. HTTPS-test är dokumenterat. |
| F2 | Webb/DMZ → Application TCP 80 | Delvis verifierad | Källa 10.40.2.3, mål 10.40.2.34. SYN observerades men ingen SYN-ACK. Timeout. |
| F3 | Application → Databas TCP 5432 | Väntar | Teamverifiering saknas. |
| F4 | Godkända servrar → Loggserver TCP 6514 TLS | Konfigurerad | Regel finns i nftables till 172.20.1.58. |
| F5 | Jump → Management TCP 22 | Väntar | Teamverifiering. |
| F6 | Management → Servrar TCP 22 | Väntar | Teamverifiering. |
| F7 | Internet → Databas | Väntar | Test från rätt källa saknas. |
| F8 | Internet → Management | Väntar | Test från rätt källa saknas. |
| F9 | Webb → Databas TCP 5432 | Testad | Timeout och ZON-UT-DROP. Testad mot obekräftad adress 10.40.2.65. |
| F10 | Otillåten TCP 8080 | Testad | Timeout och ZON-UT-DROP. |

## Driftflöden

| Regel | Trafik | Status | Bevis |
|---|---|---|---|
| D1 | SSH från jump TCP 22 | Verifierad | SSH till elev-03 fungerar. |
| D2 | SSH från CTF TCP 22 | Konfigurerad | nftables-regel finns. |
| D3 | DNS TCP/UDP 53 | Konfigurerad | nftables-regler finns. |
| D4 | NTP UDP 123 | Konfigurerad | nftables-regel finns. |
| D5 | Logg TCP 514 | Ersatt | Loggtrafiken dokumenteras som F4 TCP 6514 TLS enligt Pers instruktion. |
| D6 | DHCP UDP 67 | Konfigurerad | nftables-regel finns. |
| D7 | HTTPS till uppdateringsserver TCP 443 | Konfigurerad | Regel till 146.75.122.132 finns. |
| D8 | CTF-server → Webbserver TCP 80 | Konfigurerad | Regel från 172.20.1.10 finns. |
| D9 | CTF-server → Zonvakt TCP 7503 | Konfigurerad | Regel från 172.20.1.10 finns på elev-03. |

## Viktiga begränsningar

- Konfigurerad betyder inte att trafiktest är godkänt.
- F2 har inte fullständigt verifierad anslutning till Application.
- F3–F8 kräver fortsatt verifiering tillsammans med teamet.
- F9 och F10 har testats mot 10.40.2.65, som är en obekräftad testadress.
- F4 använder TCP 6514 med TLS till loggservern 172.20.1.58.
- D8 och D9 är konfigurerade, men fullständiga trafiktester är inte dokumenterade här.
- D5 TCP 514 ska inte beskrivas som den aktiva loggregeln.

## Slutsats

Brandväggsreglerna på elev-03 har granskats och syntaxkontrollerats.

Flera tillåtna och blockerade trafikflöden har testats och dokumenterats.

Fullständig verifiering kräver fortsatt samarbete med teamet, framför allt för flöden där målservrar eller rätt testkällor saknas.

Dokumentationen skiljer mellan konfigurerade regler, genomförda tester och fullständigt verifierade trafikflöden.
