
# Team Ankorna – Flödestabell, vecka 4

**Status:** Förslag – ska godkännas av gruppen  
**Adressutrymme:** 10.40.2.0/24

## Nätverkszoner

| Zon | Subnät |
|---|---|
| Webb / DMZ | 10.40.2.0/27 |
| Applikation | 10.40.2.32/27 |
| Databas | 10.40.2.64/28 |
| Logg / övervakning | 10.40.2.80/28 |
| Management | 10.40.2.96/28 |

## Föreslagna trafikflöden

| ID | Källa | Mål | Protokoll | Port | Riktning | Beslut |
|---|---|---|---|---|---|---|
| F1 | Internet | Webb / DMZ | TCP | 443 | In | Tillåt |
| F2 | Webb / DMZ | Applikation | TCP | 80 | Ut/In | Tillåt |
| F3 | Applikation | Databas | TCP | 5432 | Ut/In | Tillåt |
| F4 | Godkända servrar | Loggserver 172.20.1.58 | TCP | 6514 (TLS) | Ut | Tillåt |
| F5 | Jump-server | Management | TCP | 22 | In | Tillåt |
| F6 | Management | Godkända servrar | TCP | 22 | Ut/In | Tillåt |
| F7 | Internet | Databas | Alla | Alla | In | Neka |
| F8 | Internet | Management | Alla | Alla | In | Neka |
| F9 | Webb / DMZ | Databas | Alla | Alla | Mellan zoner | Neka |
| F10 | Övriga källor | Övriga mål | Alla | Alla | In/Ut | Neka |

## Driftflöden

| ID | Trafik | Protokoll | Port | Riktning |
|---|---|---|---|---|
| D1 | SSH från jump | TCP | 22 | In |
| D2 | SSH från CTF | TCP | 22 | In |
| D3 | DNS | TCP/UDP | 53 | Ut |
| D4 | NTP | UDP | 123 | Ut |
| D6 | DHCP | UDP | 67 | Ut |
| D7 | HTTPS för uppdateringar (bara 146.75.122.132, Rockys paketserver) | TCP | 443 | Ut |
| D8 | Webbkvitto från CTF (172.20.1.10) | TCP | 80 | In |
| D9 | Zonvakt från CTF (172.20.1.10) | TCP | 7534 | In |

## Att bekräfta med gruppen

- Godkänna F-id och flöden.
- Bestämma saknade portnummer och IP-adresser.
- Välja fem flöden att implementera först.
- Kontrollera vilka flöden som passerar molnbrandväggen.
- Dokumentera testresultat och status för varje regel.

**Säkerhetsprincip:** All trafik som inte uttryckligen tillåts ska nekas (default deny).

## Ändringslogg (2026-11-17)

Status: tabellerna ovan är ändrade av Martin (elev-34) den 2026-11-17 enligt listan nedan. Förslag, inte godkänt av gruppen.

**Borttaget**
- D5 (loggserver, tcp 514 ut): ersatt av F4, som gäller loggservern 172.20.1.58 på tcp 6514 (TLS)
- F4 "Ej bestämd" (dubblett av F4)
- F2 "Ej bestämd" och F3 "Ej bestämd" (dubbletter)

**Ändrat**
- F4: tcp 514, Ut/In, mål "Loggserver" blev tcp 6514 (TLS), Ut, mål loggservern 172.20.1.58 (loggarna skickas med TLS till den centrala loggservern, enligt vecka 5)
- D7: gäller nu bara 146.75.122.132 (Rockys paketserver), tcp 443, ut. Testas med `sudo dnf makecache`

**Tillagt**
- D8: ctf-servern 172.20.1.10 till webbserver, tcp 80, in (U7.2)
- D9: ctf-servern 172.20.1.10 till zonvakt, tcp 7534, in (U7.3)

**Redan genomfört i brandväggen på elev-34:** F6 (management 10.40.2.96/28 till tcp 22, in via eth2)
