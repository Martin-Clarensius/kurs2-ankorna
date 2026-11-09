# Klassificeringslista – Team Ankorna, Workshop 2

**Status:** Arbetsförslag för gruppgranskning. **Underlag:** Vecka 1 (serverinventering och trafikbaslinje) och adressplan v02, 2026-10-14.

**Viktigt:** `172.20.1.x` är observerade adresser från vecka 1. `10.40.0.0/16` är ett *planerat* adressutrymme för vecka 2. Ingen flytt av servrar har verifierats.

## Identifierade tillgångar

| Tillgång | Observerad IP | Planerat subnät / zon | Skyddsklass (förslag) | Motivering |
|---|---|---|---|---|
| `jump.sec.chas-lab.dev` – åtkomstserver | `172.20.1.2` | `10.40.0.96/28` – Management/admin | **Hög** | Jumpservern ger SSH-åtkomst till andra system och måste skyddas mot obehörig administration. |
| `sladd.sec.chas-lab.dev` – webbserver | `172.20.1.58` | `10.40.0.0/27` – Webb/DMZ | **Medel** | Webbservern kan exponeras för klienttrafik och bör isoleras från interna skyddsvärda system. |
| `elev-29` – personlig labbserver | `172.20.1.129` | **Ej tilldelat** – separat labb-/övningszon föreslås | **Medel (preliminär)** | Övningsmiljön bör vara avskild från administration, databas och övrig drift. |
| `log.sec.chas-lab.dev` – observerad status-/webbtjänst | `46.224.108.117` | **Ej tilldelat** – extern/ägarskap okänt | **Ej fastställd** | En HTTP-statustjänst har observerats men det är inte klarlagt att den är teamets interna loggserver. |
| DNS-server (namn okänt) | `185.12.64.1` | **Ej tilldelat** – extern/ägarskap okänt | **Ej fastställd** | DNS-svar finns som belägg men ägarskap och tillgångens skyddsbehov är inte verifierade. |
| NTP-server (namn okänt) | `185.12.64.2` | **Ej tilldelat** – extern/ägarskap okänt | **Ej fastställd** | NTP-svar finns som belägg men ägarskap och tillgångens skyddsbehov är inte verifierade. |

## Planerade serverroller – ännu inte identifierade som faktiska servrar

| Serverroll | Planerat subnät | Skyddsklass (förslag) | Motivering |
|---|---|---|---|
| Applikationsserver | `10.40.0.32/27` – Applikation | **Hög** | Applikationslogik och kopplingar till databaser behöver begränsad åtkomst. |
| Databasserver | `10.40.0.64/28` – Databas | **Hög** | Databaser kan innehålla skyddsvärda uppgifter och ska inte vara direkt åtkomliga från DMZ. |
| Intern loggserver | `10.40.0.80/28` – Logg/övervakning | **Hög** | Säkerhetsloggar behöver skydd mot obehörig läsning och manipulation. |

## Saknas innan listan kan godkännas

- [ ] Identifiera och klassificera de övriga gruppmedlemmarnas labbservrar (namn, IP, funktion, belägg).
- [ ] Jämför med Pers separata tjänsteförteckning och komplettera med saknade tillgångar/tjänster.
- [ ] Bestäm om en separat labb-/klientzon ingår i uppdraget och ge den ett subnät.
- [ ] Verifiera om observerade publika DNS-, NTP- och statustjänster tillhör labbmiljön eller är externa beroenden.
- [ ] Godkänn klassificeringarna i gruppen.

**Princip:** En rad per *verifierad* tillgång. Planerade serverroller redovisas separat så att de inte förväxlas med redan identifierade servrar.
