# Adressplan
Adressutrymme: 10.40.0.0/16 (RFC 1918), endast IPv4
Plattform: Egna labbmiljöer (labbservrar nås via jump-server). Per subnät reserveras nätadress, gateway (första adressen) och broadcast.
Version / datum / ansvarig: v02 / 2026-10-19 / Team-ankorna

Antagande: Webb- och applikationszonerna (/27) rymmer upp till 23 servrar inklusive tillväxt. Databas-, logg- och managementzoner (/28) rymmer upp till 9 servrar efter reserverade adresser.

| Prefix | Syfte | Gateway | Serveradresser (första–sista) | Reserverat för tillväxt | Ansvarig tjänst |
|---|---|---|---|---|---|
| 10.40.0.0/27 | Webb / DMZ | 10.40.0.1 | 10.40.0.2 – 10.40.0.24 | 10.40.0.25 – 10.40.0.30 | Webbserver |
| 10.40.0.32/27 | Applikation | 10.40.0.33 | 10.40.0.34 – 10.40.0.56 | 10.40.0.57 – 10.40.0.62 | Appserver |
| 10.40.0.64/28 | Databas | 10.40.0.65 | 10.40.0.66 – 10.40.0.74 | 10.40.0.75 – 10.40.0.78 | Databasserver |
| 10.40.0.80/28 | Logg / övervakning | 10.40.0.81 | 10.40.0.82 – 10.40.0.90 | 10.40.0.91 – 10.40.0.94 | Loggserver |
| 10.40.0.96/28 | Management / admin | 10.40.0.97 | 10.40.0.98 – 10.40.0.106 | 10.40.0.107 – 10.40.0.110 | Jump/SSH |
| Resten av 10.40.0.0/16 | Ej allokerat | – | 10.40.0.112 – 10.40.255.254 | Hela blocket | – |

Regel: Ej allokerat utrymme får inte användas utan att planen uppdateras.