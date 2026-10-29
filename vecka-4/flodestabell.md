
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
| F4 | Godkända servrar | Loggserver | TCP | 514| Ut/In | Tillåt |
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
| D5 | Loggserver | TCP | 514 | Ut |
| D6 | DHCP | UDP | 67 | Ut |
| D7 | HTTPS för uppdateringar | TCP | 443 | Ut |

## Att bekräfta med gruppen

- Godkänna F-id och flöden.
- Bestämma saknade portnummer och IP-adresser.
- Välja fem flöden att implementera först.
- Kontrollera vilka flöden som passerar molnbrandväggen.
- Dokumentera testresultat och status för varje regel.

**Säkerhetsprincip:** All trafik som inte uttryckligen tillåts ska nekas (default deny).
