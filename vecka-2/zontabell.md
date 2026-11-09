# Zontabell – Team Ankorna, Workshop 2

**Status:** Förslag för gruppgranskning, inte driftsatta brandväggsregler. **Adressplan:** v02, 2026-10-14.

## Zoner

| Zon | Planerat subnät | Syfte | Tillåten åtkomst (princip) |
|---|---|---|---|
| Webb / DMZ | `10.40.0.0/27` | Hålla webbserver separat från interna system | Externa klienter till godkänd webbtjänst; endast nödvändig anslutning vidare till appzon. |
| Applikation | `10.40.0.32/27` | Köra applikationslogik | Godkänd webbserver och administration via management. |
| Databas | `10.40.0.64/28` | Lagra skyddsvärda uppgifter | Endast godkänd applikationsserver och behörig administration. |
| Logg / övervakning | `10.40.0.80/28` | Samla och skydda interna loggar | Godkända loggkällor och behörig administration. |
| Management / admin | `10.40.0.96/28` | Centraliserad administration via jumpserver | Endast behöriga administratörer via godkänd säker anslutning. |
| Labb-/övningsservrar (**föreslagen extra zon**) | **Ej tilldelat** | Isolera personliga labbservrar, t.ex. `elev-29` | Behörig SSH via jumpserver; annan trafik enligt särskilt behov. |
| Externa beroenden (**inte intern zon**) | **Inget internt subnät** | DNS, NTP och observerad statuswebb med obekräftat ägarskap | Endast dokumenterad utgående trafik där tjänsten behövs. |

## Trafikregler: föreslaget respektive observerat

| Från | Till | Port/protokoll | Bedömning | Varför |
|---|---|---|---|---|
| Internet | Webb / DMZ | TCP 443 HTTPS | **Föreslagen tillåtelse** | Säker webbåtkomst; HTTPS/443 är inte belagt i vecka 1-underlaget. |
| Webb / DMZ | Applikation | **TBD – godkänd app-port** | **Föreslagen tillåtelse** | Endast den apptjänst som verkligen behövs. |
| Applikation | Databas | **TBD – godkänd DB-port** | **Föreslagen tillåtelse** | Endast appservern ska nå databasen. |
| Godkända servrar | Logg / övervakning | **TBD – loggprotokoll och port** | **Föreslagen tillåtelse** | Central logginsamling. |
| Behöriga administratörer | Management / admin | **TBD – säker ingång, MFA** | **Föreslagen tillåtelse** | Begränsa vem som kan nå jumpservern. |
| Jumpserver | Godkända labb-/servervärdar | TCP 22 SSH | **Observerat vecka 1; föreslagen begränsad tillåtelse** | SSH mellan `172.20.1.2` och `172.20.1.129` har dokumenterats. |
| Labbvärd | DNS-resolver | UDP 53 DNS | **Observerat vecka 1; fortsatt behov verifieras** | DNS-frågor och svar finns i trafikbaslinjen. |
| Labbvärd | NTP-server | UDP 123 NTP (standard; verifiera port i fångst) | **Tjänst observerad; regel TBD** | NTP-svar finns dokumenterade, men exakt regel behöver verifieras. |
| Labbvärd | Observerad extern statuswebb | TCP 80 HTTP | **Observerat vecka 1; ej automatiskt godkänt** | Okrypterad HTTP-trafik till `46.224.108.117` har dokumenterats. |
| Webb / DMZ | Databas | Alla direkta flöden | **Neka** | Förhindra direkt åtkomst till känslig databas. |
| Övriga källor | Alla zoner | All trafik som inte uttryckligen godkänts | **Neka som standard** | Minsta privilegium och segmentering. |

## Kommentarer till beläggen

- Vecka 1 innehåller både DNS- och NTP-uppgifter för `185.12.64.2` i olika fångster; kontrollera protokoll och källadresser innan reglerna beslutas.
- Höga UDP-källportar i DNS-trafik är inte automatiskt DNS-tunnling eller tjänster på ovanliga portar.
- TCP-portarna `8080` och `9000` förekommer i trafikunderlaget, men tjänsternas funktion är inte verifierad; öppna dem inte enbart på grund av portnumret.
- Den publika statuswebben `log.sec.chas-lab.dev` är **inte** bekräftad som den planerade interna loggservern.

## Kontroll före godkännande

- [ ] Bekräfta varje tillgång och tjänst mot hela inventeringen från vecka 1.
- [ ] Bestäm IP/subnät för labbserverzonen om den ska ingå.
- [ ] Fastställ exakta protokoll, portar, källor och mål för alla `TBD`-regler.
- [ ] Dokumentera om en annan grupp granskat zonskissen och vilka synpunkter som kom fram.
- [ ] Godkänn reglerna i teamet innan GitHub Pull Request sammanfogas.
