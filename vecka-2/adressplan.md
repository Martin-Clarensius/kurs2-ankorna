# Adressplan

Adressutrymme: 10.40.2.0/24 (RFC 1918, endast IPv4), tilldelat teamet ur kursens block 10.40.0.0/16 (team Ankorna, T=2)
(Hetzner): 10.40.2.0/24
Gateway för hela nätet: 10.40.2.1 (reserverad av plattformen, får inte användas av servrar)
Plattform: Egna labbmiljöer (labbservrar nås via jump-server). Per subnät reserveras nätadress och broadcast.
Version / datum / ansvarig: v03 / 2026-10-26 / Team-ankorna

Antagande: Webb- och applikationszonerna (/27) rymmer upp till 23 servrar inklusive tillväxt. Databas-, logg- och managementzoner (/28) rymmer upp till 9 servrar efter reserverade adresser.

| Prefix | Syfte | Serveradresser (första–sista) | Reserverat för tillväxt | Ansvarig tjänst |
|---|---|---|---|---|
| 10.40.2.0/27 | Webb / DMZ | 10.40.2.2 – 10.40.2.24 | 10.40.2.25 – 10.40.2.30 | Webbserver |
| 10.40.2.32/27 | Applikation | 10.40.2.34 – 10.40.2.56 | 10.40.2.57 – 10.40.2.62 | Appserver |
| 10.40.2.64/28 | Databas | 10.40.2.66 – 10.40.2.74 | 10.40.2.75 – 10.40.2.78 | Databasserver |
| 10.40.2.80/28 | Logg / övervakning | 10.40.2.82 – 10.40.2.90 | 10.40.2.91 – 10.40.2.94 | Loggserver |
| 10.40.2.96/28 | Management / admin | 10.40.2.98 – 10.40.2.106 | 10.40.2.107 – 10.40.2.110 | Jump/SSH |
| Resten av 10.40.2.0/24 | Ej allokerat | 10.40.2.112 – 10.40.2.254 | Hela blocket | – |
| 172.20.1.0/24 | Labbnät (ej teamets, bara filtrering) | Jump 172.20.1.2, ctf 172.20.1.10, log 172.20.1.58 | – | Kursens drift |

Regel: Ej allokerat utrymme får inte användas utan att planen uppdateras.

## Tilldelade serveradresser

| Adress | Server | Zon | Ansvarig |
|---|---|---|---|
| 10.40.2.98 | elev-29 (eth2) | Management / admin | Oliver |
| 10.40.2.99 | elev-33 (eth2) | Management / admin | Per |
| 10.40.2.82 | elev-34 (eth2) | Logg / övervakning | Martin |