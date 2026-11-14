# Detektioner och playbooks – milstolpe 6
 
Ansvarig: elev-34
Loggplattform: Wazuh (https://wazuh.sec.chas-lab.dev), OpenSearch Alerting-monitorer

 
## Status
 
| Detektion | Larmar | Brus normaltrafik | Playbook |
|---|---|---|---|
| D1 SSH brute force | ✅ 11:12 | 307 för regeln, 0 för monitorn | ✅ |
| D2 Zonöverträdelse | ✅ 10:34 | 0 | ✅ |
| D3 Root-kommando | ✅ 11:15 | 0 | ✅ |
| D4 Misslyckad sudo | ✅ 10:37 | 0 | ✅ |
| D5 Beaconing (VG) | ✅ 09:04 | 0 | ✅ |
 
---
 
## Gemensamt för alla detektioner
 
| Sak | Värde |
|---|---|
| Index för larm | `wazuh-alerts-*` |
| Index för alla händelser | `wazuh-archives-*` (även händelser som ingen standardregel larmar på) |
| Hur min server känns igen | `location: *elev-34*` (alla poster har `agent.name: log`, eftersom loggservern läser in dem) |
| Värdnamn | Läses i `full_log` |
| Tidszon | elev-34 går på UTC (`timedatectl`: Etc/UTC). Dashboarden visar **svensk tid (CET)**, vilket bekräftas av att D2-larmet kom 10:34 efter testet 09:34 UTC. Alla larmtider nedan är svensk tid. |
| Normaltrafikperiod (utbildarens, enligt `kontrollera U6.3`) | 2026-11-11 08:06–08:37 svensk tid = 31 min ≈ 0,52 h |
| Mitt mätfönster | 2026-11-11 16:30 – 2026-11-12 08:00 = 15,5 h |
| Kända egna källor | jump-servern 172.20.1.2 (egna inloggningar), ctf-servern 172.20.1.10 (CTF-kontroller, loggar in som root med nyckel) |
 
**Faser i playbookarna (NIST SP 800-61):**
1. Förberedelse
2. Detektion och analys
3. Inneslutning, utrotning och återställning
4. Efterarbete (lärdomar)
**Triagens tre frågor (gäller alla larm):** Vad har hänt? Vad har berörts? Vad ska göras?
Observationer och slutsatser hålls i olika fält i triageloggen.
 
---
 
## D1 – SSH brute force
 
### Nedbrytning
 
| Del | Innehåll |
|---|---|
| Händelse | Upprepade misslyckade SSH-inloggningar från samma källadress |
| Loggkälla | Autentiseringsloggen (sshd; på Rocky Linux 9 med programnamnet `sshd-session`) |
| Fält | `rule.id`, `rule.level`, `data.srcip`, `data.srcuser` (bekräftat i posterna), `predecoder.program_name`, `location`, `timestamp` |
| Faktiska värden | `rule.id: 5710` (försök med användare som inte finns), `rule.id: 5712` (brute force, användare som inte finns, samma källa upprepat), `predecoder.program_name: sshd*`, `location: *elev-34*`, `data.srcip: 172.20.1.10` (ctf-servern vid U6.2), `rule.level: 5`, `rule.description: sshd: Attempt to login using a non-existent user`, påhittade användarnamn som `deploy34`, `backup90`, `admin44`, `test16` |
| Gränsfall som inte ska träffa | En enstaka feltryckning vid egen inloggning från jump-servern (172.20.1.2), alltså ett misslyckande följt av en lyckad inloggning. Det ger högst en 5710/5716-post, inte en 5712. |
| ATT&CK | T1110 Brute Force (T1110.001 Password Guessing) |
 
### Detektion
 
| Del | Innehåll |
|---|---|
| Monitornamn | `elev-34 5712 brute force` (trigger `brute force trigger`) och `elev-34 5710` (trigger `minst 5 försök från samma källa`) |
| Typ | Per query monitor, Visual Graph |
| Index | `wazuh-alerts-*` |
| Fråga 5710 | COUNT OF `rule.id`, de senaste 5 min, filter `rule.id is 5710` och `location contains elev-34`, Group by `data.srcip` |
| Trigger 5710 | `minst 5 försök från samma källa`: IS ABOVE 4 (`ctx.results[0].aggregations.metric.value > 4`), severity 1 |
| Trigger 5712 | `brute force trigger`: IS ABOVE 0, sevirity 1 |
| Körintervall | 1 minut |
| Brus i normaltrafik, regeln 5710 utan location-filter | **307 träffar på 0,52 h (08:06–08:37) ≈ 590 per timme** (bekräftat i exakt fönster). Normaltrafikens brute force kommer bland annat från 10.40.2.35, med användarnamn som ftp, pi, support och guest. |
| Brus i normaltrafik, monitorn (med `location contains elev-34`) | 0 – normaltrafikens värdar filtreras bort |
| Lärdom | Utan location-filtret hade monitorn larmat på normaltrafiken. Larmet 2026-11-11 08:09–08:40 sammanfaller med normaltrafikperioden ⟨trolig förklaring: en tidigare version av monitorn utan fungerande location-filter – bekräfta⟩ |
| Brus i mitt mätfönster | 0 träffar på 15,5 h = 0 per timme |
| Falsklarmrisk | Låg för elev-34:s egen trafik. Monitorn måste filtrera på `location` *elev-34* (inte `agent.name`, som alltid är `log`), annars kan andra elevers tester trigga den. Låg för 5712, eftersom regeln redan kräver upprepning från samma källa. Kända källor som ger larm: CTF-kontrollen U6.2 (ctf-servern 172.20.1.10). **Monitorn på 5710 är riskabel:** en träff räcker, så varje enskilt misslyckande blir ett larm. Den behöver en tröskel (till exempel fler än X på Y min) eller ska ses som stöd för 5712. |
| Känd lucka (falskt negativt) | 5712 gäller bara användare som *inte finns*. Gissning mot konton som finns ger 5716/5720 (multiple authentication failures) och fångas inte av den här monitorn. ⟨Beslut: lägg till 5720 eller dokumentera luckan⟩ |
 
### Verifiering
 
| Del | Innehåll |
|---|---|
| Hur händelsen framkallades | `kontrollera U6.2 start` (12 misslyckade försök från 172.20.1.10) |
| Tid då händelsen framkallades | 2026-11-12 10:11:49 UTC (11:11:49 svensk tid) |
| Larmhistorik 5710 | 2026-11-10 14:13; 2026-11-11 08:09, 11:28, 11:52 (alla Completed) |
| Larmhistorik 5712 | Inga larm alls |
| Poster efter U6.2 2026-11-12 10:29:56 | 12 träffar i `wazuh-alerts-*` 10:30:01–10:30:05 från 172.20.1.10, alla "Attempt to login using a non-existent user" (5710, nivå 5). Ingen 5712 syns. |
| Larm efter U6.2 | **Inget larm från någon av monitorerna, trots att posterna finns. Felet sitter i monitorn – felsöks.** |
| Orsak och åtgärd | Filtret var `location is *elev-34*`. `is` kräver exakt match, så stjärnorna tolkades bokstavligt och filtret träffade aldrig något. Ändrat till `location contains elev-34`. |
| Nytt test | `kontrollera U6.2 start` 2026-11-12 10:11:49 UTC (11:11:49 svensk tid). Larm: **2026-11-12 11:12 svensk tid (Active)** från `elev-34 5710` ✅ |
| Bevis | Se bilderna nedan |
 
![D1: larm från elev-34 5710, 11:12 Active](bilder/d1-larm.png)
 
![D1: 12 poster 5710 från 172.20.1.10 efter U6.2](bilder/d1-discover-u62.png)
 
![D1: monitorns fråga efter rättningen](bilder/d1-monitor-fraga.png)
 
![D1: trigger IS ABOVE 4](bilder/d1-monitor-trigger.png)
 
![D1: 307 träffar 5710 i normaltrafiken](bilder/d1-normaltrafik.png)
 
### Playbook D1
 
**1. Förberedelse**
- Kontrollera att monitorn `elev-34 5712 brute force` är Enabled.
- Ha listan med kända källor till hands (jump 172.20.1.2, ctf-server 172.20.1.10, se tabellen överst).
- Se till att du har åtkomst till Wazuh och SSH till elev-34 via jump.
**2. Detektion och analys**
1. Öppna larmet under Alerting → Alerts och anteckna starttiden. *(observation)*
2. Gå till Discover → `wazuh-alerts-*` och sätt tidsfönstret till ±15 min runt larmet. Filtrera: `location: *elev-34* and rule.id: (5710 or 5712 or 5716 or 5720)`.
3. **Vad har hänt?** Notera `data.srcip`, antal försök, tidsspann och vilka användarnamn som provats. *(observationer)*
4. Är källan känd? Jämför med listan över kända källor och, för ctf-servern, med tiden för `kontrollera`-körningen.
5. **Vad har berörts?** Sök efter lyckad inloggning från samma källa efter försöken: `data.srcip: <källan> and rule.id: (5715 or 40112)`. Om det finns en: vilket konto och vilken metod (lösenord eller publickey)?
6. Om regel 40112 ("Multiple authentication failures followed by a success") har gått: läs observationerna (konto, metod, källa) innan du drar slutsatser. Nyckelinloggning som root från ctf-servern direkt efter U6.2 är CTF-kontrollen, inte en lyckad gissning.
7. **Vad ska göras? Beslut:**
   - *Avfärda (falskt positivt / förväntat):* bara med ett granskbart skäl, till exempel "källa 172.20.1.10, tidpunkten stämmer med `kontrollera U6.2 start` kl. hh:mm, inga lyckade lösenordsinloggningar". "Det var nog jag" räcker inte.
   - *Eskalera:* okänd källa, eller en lyckad inloggning efter försöken.
**3. Inneslutning, utrotning och återställning** (endast vid eskalering)
- Blockera källadressen i båda lagren (se Regelverket nedan). I nftables släpper kedjan `in` bara SSH från jump (172.20.1.2, flöde D1) och ctf-servern (172.20.1.10, flöde D2), allt annat stoppas av policy drop. Gäller attacken en tillåten källa: ta bort eller begränsa den regeln i nftables, och kontrollera att molnbrandväggen `itsx26-elev-34` inte släpper in källan.
- Vid lyckad inloggning: lås kontot, avsluta sessionen och granska vad kontot har gjort (D3, root-kommandon).
- Kontrollera att `PasswordAuthentication` och `PermitRootLogin` är satta enligt härdningen.
**4. Efterarbete**
- Skriv en post i triageloggen med observationer och slutsats i separata fält.
- Om larmet var brus: justera tröskel eller undantag och mät bruset igen.
- Om en ny legitim källa dök upp: lägg till den i listan över kända källor.
---
 
## D2 – Zonöverträdelse (paketfiltrets logg)
 
### Nedbrytning
 
| Del | Innehåll |
|---|---|
| Händelse | Trafik som flödestabellen inte tillåter och som paketfiltret därför stoppar och loggar |
| Loggkälla | Brandväggsloggen: nftables, kedja `hook output` (policy drop), loggregel `limit rate 10/minute burst 5 packets log prefix "ZONE-UT-DROP" level info`. Prefixet saknar avslutande mellanslag, så i loggen sitter det ihop med nästa fält: `ZONE-UT-DROPIN= OUT=...`. Därför fungerar sökningen på `ZONE-UT-DROPIN`. (Inkommande kedja: `hook input`, policy drop, prefix `ZON-IN-DROP`.) |
| Fält | `full_log` (innehåller loggprefixet och `SRC=`, `DST=`, `PROTO=`, `DPT=`), `location`, `timestamp` |
| Faktiska värden | Loggprefix `ZONE-UT-DROPIN`; testflöde `DST=1.1.1.1`, `DPT=8080` |
| Gränsfall som inte ska träffa | Uppdateringstrafiken från dnf till `DST=146.75.122.132`, `DPT=443`, som undantas med `must_not` |
 
### Detektion
 
| Del | Innehåll |
|---|---|
| Monitornamn | `elev-34 zonöverträdelse (zon-ut-drop)` |
| Typ | Per query monitor, Extraction Query |
| Index | `wazuh-archives-*` (ingen standardregel larmar på posten) |
| Fråga | `full_log` innehåller `ZONE-UT-DROPIN`, `location` *elev-34*, de senaste 5 min, `must_not` DST=146.75.122.132 och DPT=443 |
| Trigger | `zonöverträdelse`: `ctx.results[0].hits.total.value > 0` |
| Körintervall | 1 minut |
| Brus i normaltrafik | 0 träffar (sökt 2026-11-11 08:00–09:00, alltså även 08:06–08:37) |
| Brus i mitt mätfönster, utan filter | 136 träffar på 15,5 h ≈ 9 per timme, i 4 skurar. Orsak: `dnf makecache` försöker nå mirrors.rockylinux.org på port 443, vilket kedjan ut stoppar. Loggregeln är rate-limiterad (10/min), så 136 är en lägre gräns. |
| Brus i mitt mätfönster, med monitorns undantag | **0 träffar på 15,5 h.** Undantaget tar bort alla 136 dnf-träffar. (Sökt 2026-11-11 08:06 – 2026-11-12 08:00: 8 träffar, alla egna tester mot 1.1.1.1 kl. 14:47–14:55 den 11/11, före mätfönstret.) |
| Falsklarmrisk | Hög utan filter (dnf-skurarna ger ett larm per skur). Andra legitima utgående flöden som saknas i flödestabellen (till exempel uppdateringsspeglar med andra adresser) ger larm. Undantag bör göras genom att flödet läggs in i flödestabellen, inte genom att monitorn breddas. |
 
### Verifiering
 
| Del | Innehåll |
|---|---|
| Hur händelsen framkallades | `timeout 3 bash -c 'echo > /dev/tcp/1.1.1.1/8080'; date` på elev-34 |
| Tid enligt `date` | 2026-11-12 09:34:09 UTC (10:34:09 svensk tid) |
| Larmets starttid | 2026-11-12 10:34 (Completed 10:39) |
| Övriga larm samma dag | 09:32–09:40 och 09:55–10:00: egna tester |
| Bevis | Se bilderna nedan |
 
![D2: monitor och larm 10:34](bilder/d2-monitor-larm.png)
 
![D2/D3: testkommandon och nftables-regler i ssh lab](bilder/d2-d3-test-terminal.png)
 
![D2: 0 träffar i normaltrafiken](bilder/d2-normaltrafik.png)
 
### Playbook D2
 
**1. Förberedelse**
- Kontrollera att monitorn är Enabled och att triggern är `ctx.results[0].hits.total.value > 0`.
- Ha flödestabellen (milstolpe 3/4) öppen. Den avgör vad som är tillåtet.
**2. Detektion och analys**
1. Anteckna larmets starttid.
2. Gå till Discover → `wazuh-archives-*` och sätt ±15 min. Filtrera: `location: *elev-34* and full_log: "ZONE-UT-DROPIN"`.
3. **Vad har hänt?** Läs `SRC`, `DST`, `PROTO` och `DPT` ur `full_log` och notera antal poster och tidsspann. *(observationer)*
4. Jämför med flödestabellen: finns flödet där? Är målet ett känt legitimt mål som saknas i tabellen?
5. **Vad har berörts?** Trafiken stoppades redan, så frågan är *vem på servern* som försökte. Paketfiltrets logg visar ingen process. Logga in på elev-34 och leta efter processen, till exempel med `ss -tunap` (om den fortfarande försöker) och i loggarna runt tidpunkten.
6. Upprepas försöken med jämna mellanrum? Då kan det vara ett program som ringer hem (beacon).
7. **Beslut:**
   - *Avfärda:* eget test med `date`-tid som stämmer, eller ett legitimt flöde som saknas i tabellen. Skapa i så fall ett ändringsärende för flödestabellen.
   - *Eskalera:* okänd process eller okänt mål, eller upprepade försök.
**3. Inneslutning, utrotning och återställning**
- Flödet är redan stoppat av nftables (kedjan `ut`, policy drop). Kontrollera att molnbrandväggen `itsx26-elev-34` inte heller släpper ut det. Den tillåter i dag bara tcp 443 (D7) och udp 123 (D4) utgående.
- Vid okänd process: stoppa den, ta reda på hur den startades (tjänst, cron, användare) och ta bort den.
**4. Efterarbete**
- Skriv en post i triageloggen.
- Om flödet var legitimt: uppdatera flödestabellen, regelverket och testskriptet, och mät bruset igen.
---
 
## D3 – Kommando som körs som root (auditd)
 
### Nedbrytning
 
| Del | Innehåll |
|---|---|
| Händelse | Kommando som körs med root-rättigheter |
| Loggkälla | auditd (regel från vecka 5) |
| Fält | `full_log` (auditd-posten), `location`, `timestamp` |
| Faktiska värden | auditd-nyckel `rootcmd`, `auid=1000` |
| Vem auid=1000 är | `student` (`getent passwd 1000` → `student:x:1000:1000::/home/student:/bin/bash`), alltså root-kommandon som körs via sudo av den inloggade användaren |
| Framkallad | `sudo id; date` i ssh lab, 2026-11-12 09:34:12 UTC (10:34:12 svensk tid) |
| Gränsfall som inte ska träffa | Root-processer som inte startats av en inloggad användare (dnf, cron), som har ett annat auid |
| Känd lucka (falskt negativt) | Direkt root-inloggning, till exempel ctf-serverns kontroller som loggar in som root med nyckel, har inte auid=1000 och fångas inte, eftersom frågan kräver `auid=1000` (bekräftat i monitorns fråga). |
 
### Detektion
 
| Del | Innehåll |
|---|---|
| Monitornamn | `elev-34 root kommando` (trigger `root-kommando`) |
| Typ | Per query monitor, Extraction Query |
| Index | `wazuh-archives-*` |
| Fråga | Extraction query, de senaste 5 min (`{{period_end}}||-5m`). Fyra `match_phrase` på `full_log`, alla måste träffa: `elev-34 audisp-syslog`, `type=SYSCALL`, `rootcmd` och `auid=1000` |
| Trigger | `root-kommando`: `ctx.results[0].hits.total.value > 0`, severity 1 |
| Kontroll i viloläge | Run 2026-11-12 cirka 12:00: frågan körs utan fel och ger `hits.total.value: 0`, och triggern ger `false` när inget root-kommando har körts de senaste 5 min |
| Körintervall | 1 minut |
| Larmhistorik | 2026-11-12 08:19–08:26, 09:25–09:32, **10:29 (Active)** |
| Verifiering | Larmet från 10:29 var Completed 10:41. Nytt test: `sudo id; date` i ssh lab 2026-11-12 10:15:09 UTC (11:15:09 svensk tid). Larm: **2026-11-12 11:15 svensk tid (Active)** ✅ |
| Öppen fråga | Orsaken till larmet 10:29 är inte utredd (inget eget sudo-kommando då). Kontrollera i Discover: `location: *elev-34* and full_log: "rootcmd"` kl. 10:28–10:30 |
| Brus i normaltrafik | 0 träffar 08:06–08:37. (Sökfönstret 08:00–09:00 gav 11 träffar, men alla 08:01–08:05 och från elev-34 själv, före normaltrafikperioden.) |
| Brus i mitt mätfönster | 0 träffar på 15,5 h = 0 per timme |
| Falsklarmrisk | Låg utanför arbetstid. Teamets eget arbete som root dagtid ger larm. |
 
![D3: larm 11:15 efter sudo id](bilder/d3-larm.png)
 
![D3: rootcmd-poster 08:01–08:05 från elev-34, 0 i normaltrafiken](bilder/d3-normaltrafik.png)
 
### Verifiering
 
| Del | Innehåll |
|---|---|
| Hur händelsen framkallades | `sudo id; date` i ssh lab |
| Tid | 2026-11-12 10:15:09 UTC (11:15:09 svensk tid) |
| Larm | 2026-11-12 11:15 svensk tid (Active) |
| Bevis | Bilderna ovan |
 
### Playbook D3
 
**1. Förberedelse**
- Kontrollera att monitorn `elev-34 root kommando` är Enabled.
- Kontrollera att auditd-regeln finns: `sudo auditctl -l` i ssh lab ska visa nyckeln `rootcmd`.
- Ha en lista över vilka som får använda sudo på elev-34 (teamets konton) och när planerat arbete pågår.
**2. Detektion och analys**
1. Öppna larmet under Alerting → Alerts och anteckna starttiden. *(observation)*
2. Gå till Discover → `wazuh-archives-*`, ±15 min runt larmet: `location: *elev-34* and full_log: "rootcmd"`.
3. **Vad har hänt?** Läs i `full_log`: vilket program som kördes (`exe`/`comm`), `auid` (vem som loggade in) och `uid` (vem kommandot kördes som). *(observationer)*
4. **Vem var det?** Översätt `auid` till ett konto: `getent passwd <auid>` i ssh lab (1000 = `student`). Kontrollera lokalt: `sudo ausearch -k rootcmd -ts recent -i`.
5. Var det planerat? Jämför med teamets pågående arbete och ändringar.
6. **Vad har berörts?** Vilka filer, tjänster eller konton ändrades av kommandot?
7. **Beslut:**
   - *Avfärda:* bara med granskbart skäl, till exempel "`sudo id` kört av student i ssh lab kl. 11:15:09, eget test".
   - *Eskalera:* okänt kommando, okänt konto, kommando utanför arbetstid eller ändringar som ingen i teamet känner till.
**3. Inneslutning, utrotning och återställning** (endast vid eskalering)
- Lås kontot: `sudo usermod -L <konto>` och avsluta dess sessioner.
- Ta bort kontots sudo-rätt tills saken är utredd.
- Gå igenom och återställ det kommandot ändrade (filer, tjänster, nya konton, cron).
**4. Efterarbete**
- Skriv en post i triageloggen.
- Lägg in återkommande legitima root-processer som undantag och mät bruset igen.
---
 
## D4 – Misslyckad sudo (teamets egen händelse)
 
| Del | Innehåll |
|---|---|
| Händelse | Felaktigt lösenord till sudo |
| Loggkälla | Autentiseringsloggen (PAM) |
| Fält | `full_log`, `location`, `predecoder.program_name`, `rule.id`, `data.srcuser`, `data.uid`, `data.euid`, `data.tty` |
| Wazuh-regel | `rule.id: 5503` "PAM: User login failed.", nivå 5, grupper `pam, syslog, authentication_failed`. Wazuh märker själv regeln med ATT&CK **T1110.001** (Credential Access, Password Guessing). |
| Exempel på `full_log` | `2026-11-12T09:36:18.796482+00:00 elev-34 sudo: pam_unix(sudo:auth): authentication failure; logname=student uid=1000 euid=0 tty=/dev/pts/0 ruser=student rhost=  user=student` |
| `location` | `/var/log/remote/elev-34/syslog.log` |
| Faktiska värden | `pam_unix(sudo:auth): authentication failure` |
| Framkallad | `echo fel \| sudo -S -k true; date` i ssh lab, 2 gånger: 2026-11-12 09:36:04 och 09:36:20 UTC (10:36:04 och 10:36:20 svensk tid). Utdata: `sudo: 1 incorrect password attempt` |
| Gränsfall som inte ska träffa | ⟨Beslut: en enstaka felskrivning ska väl inte larma? Överväg en tröskel, till exempel fler än X försök inom Y minuter⟩ |
| Monitor | `elev-34 misslyckade sudo` (trigger `misslyckad-sudo`), Per query monitor, Extraction Query, `wazuh-archives-*`, 1 minut |
| Larmets starttid | 2026-11-12 10:37 (Active), efter testerna 10:36:04/10:36:20. Tidigare larm: 2026-11-11 15:11–15:16 |
| Gränsfall verifierat | Lyckad sudo 10:34:15 och 10:35:21 gav inget larm |
| Brus i normaltrafik | 0 träffar (sökt 2026-11-11 08:00–09:00) |
| Brus i mitt mätfönster | 0 träffar på 15,5 h = 0 per timme |
| Falsklarmrisk | Låg. Ett larm betyder normalt att någon har skrivit fel lösenord till sudo. |
 
![D4: monitor och larm 10:37](bilder/d4-monitor-larm.png)
 
![D4: misslyckade sudo-försök i ssh lab](bilder/d4-test-terminal.png)
 
![D4: 0 träffar i normaltrafiken](bilder/d4-normaltrafik.png)
 
### Verifiering
 
| Del | Innehåll |
|---|---|
| Hur händelsen framkallades | `echo fel \| sudo -S -k true; date` i ssh lab, 2 gånger |
| Larm | 2026-11-12 10:37 svensk tid (Active) |
| Gränsfall | Lyckad sudo 10:34:15 och 10:35:21 UTC gav inget larm |
| Bevis | Bilderna ovan |
 
### Playbook D4
 
**1. Förberedelse**
- Kontrollera att monitorn `elev-34 misslyckade sudo` är Enabled.
- Ha en lista över vilka konton som har sudo-rätt på elev-34.
**2. Detektion och analys**
1. Öppna larmet och anteckna starttiden. *(observation)*
2. Gå till Discover → `wazuh-archives-*`, ±15 min: `location: *elev-34* and full_log: "authentication failure" and full_log: "sudo"`.
3. **Vad har hänt?** Läs i `full_log`: vilket konto (`user=`/`ruser=`), vilken terminal (`tty=`) och hur många misslyckanden på hur lång tid. *(observationer)*
4. Följdes misslyckandet av en lyckad sudo från samma konto? Sök: `location: *elev-34* and full_log: "sudo" and full_log: "COMMAND"`.
5. **Vad har berörts?** Vilken session det gällde (inloggning från vilken adress, se autentiseringsloggen) och om någon sudo till slut lyckades.
6. **Beslut:**
   - *Avfärda:* en enstaka felskrivning av ett känt konto, följd av lyckad sudo från samma session. Skälet skrivs ut, till exempel "student skrev fel lösenord 10:36, eget test".
   - *Eskalera:* upprepade misslyckanden utan lyckad sudo, okänt konto eller en session som ingen i teamet känner till. Det kan vara någon som gissar lösenord efter att ha tagit sig in.
**3. Inneslutning, utrotning och återställning** (endast vid eskalering)
- Avsluta sessionen och lås kontot: `sudo usermod -L <konto>`.
- Byt kontots lösenord och kontrollera hur sessionen kom in (D1, autentiseringsloggen).
**4. Efterarbete**
- Skriv en post i triageloggen.
- Om larmet ofta beror på felskrivningar: överväg en tröskel (till exempel fler än 2 på 5 min) och mät bruset igen.
---
 
## D5 – Periodisk utgående beaconing (U6.5, frivillig VG-uppgift)
 
### Nedbrytning
 
| Del | Innehåll |
|---|---|
| Händelse | Ett program på servern ringer hem till samma externa adress med jämna mellanrum, som ett tjänstekonto |
| Loggkälla | Programmets egen logg via syslog, sparad i `wazuh-archives-*` (ingen standardregel larmar) |
| Fält | `predecoder.program_name`, `full_log`, `location`, `timestamp` |
| Faktiska värden | Program `syncagent`, konto `svc-backup`, `action=upload`, `bytes=8627`, `status=200`, mål `https://sync.telemetri-app.net/v1/beacon` |
| Gränsfall som inte ska träffa | Enstaka anrop från samma program (färre än 5 på 5 min) |
| ATT&CK | **T1071.001 Application Layer Protocol: Web Protocols** (taktik Command and Control). Trafiken går över HTTPS och kan blandas med vanlig webbtrafik. T1029 Scheduled Transfer valdes bort eftersom den hör till taktiken Exfiltration. |
 
### Detektion
 
| Del | Innehåll |
|---|---|
| Monitornamn | `utgående beaconing (T1071.001) VG-uppgift` |
| Typ | Per query monitor, Visual Graph |
| Index | `wazuh-archives-*`, tidsfält `timestamp`, de senaste 5 min |
| Filter | `predecoder.program_name` is `syncagent` och `location` contains `elev-34` |
| Trigger | `Beaconing`: COUNT IS ABOVE 4 |
| Körintervall | 1 minut |
| Brus i normaltrafik | 0 träffar (sökt 2026-11-11 08:00–09:00) |
| Brus i mitt mätfönster | **0 träffar på 15,5 h.** (Sökt 2026-11-11 08:06 – 2026-11-12 08:00: 18 träffar, alla 09:16–09:17 den 11/11 från en tidigare körning av U6.5, före mätfönstret.) |
| Falsklarmrisk | Ett tjänstekonto kan vara en riktig backup- eller synkjänst som laddar upp regelbundet. Regeln bygger på frekvens, inte på om målet är skadligt. |
| Känd lucka (falskt negativt) | Regeln är bunden till programnamnet `syncagent`: ett annat eller omdöpt program fångas inte. Ett anrop som går mer sällan än 5 gånger på 5 minuter fångas inte heller. |
 
### Verifiering
 
| Del | Innehåll |
|---|---|
| Hur händelsen framkallades | `kontrollera U6.5 start` i ssh jump |
| Larmets starttid | 2026-11-12 09:04 svensk tid (Completed 09:11) |
| Bevis | Flaggan från `kontrollera U6.5` och bilderna nedan |
 
![D5: monitor och larm 09:04](bilder/d5-monitor-larm.png)
 
![D5: 0 träffar i normaltrafiken](bilder/d5-normaltrafik.png)
 
### Playbook D5 (kort)
 
1. **Förberedelse:** ha en lista över godkända externa destinationer och tjänstekonton.
2. **Detektion och analys:** läs program, konto, mål och intervall i `full_log`. Är målet känt och godkänt? Är programmet installerat av teamet?
3. **Inneslutning, utrotning och återställning:** vid okänt mål, stoppa processen, ta reda på hur den startas (tjänst eller cron) och spärra målet i kedjan ut.
4. **Efterarbete:** lägg till godkända mål i listan, eller gör regeln bredare om den missade något.
---
 
## Regelverket på elev-34 (båda lagren)
 
Blockering och inneslutning i playbookarna görs i båda lagren.
 
**Lager 1 – nftables på servern** (`sudo nft list ruleset` i ssh lab), tabell `inet zon`:
 
| Kedja | Policy | Tillåtet (flöde i flödestabellen) |
|---|---|---|
| `in` (hook input) | drop | established/related, lo, SSH tcp 22 från 172.20.1.2 (D1, jump), SSH tcp 22 från 172.20.1.10 (D2, ctf-kontroll). Övrigt loggas med prefix `ZON-IN-DROP`. |
| `ut` (hook output) | drop | established/related, lo, DNS 53 till 185.12.64.1/.2 (D3), syslog tcp 514 till 172.20.1.58 (D5), DHCP (D6), NTP udp 123 till 2.28.43.156 och 213.239.239.0/24 (D4), syslog-TLS tcp 6514 till 172.20.1.58 (F4). Övrigt loggas med prefix `ZONE-UT-DROP`. |
 
**Lager 2 – molnplattformen** (`moln status` i ssh jump): privat nät `itsx26-team-2` 10.40.2.0/24. elev-34 har 172.20.1.134 och 10.40.2.82. Molnbrandväggen `itsx26-elev-34` har två regler: ut tcp 443 till 0.0.0.0/0 (D7 Paketuppdateringar) och ut udp 123 till 0.0.0.0/0 (D4 NTP).
 
**Fynd: lagren stämmer inte överens för flöde D7.** Molnbrandväggen släpper ut tcp 443 (D7 Paketuppdateringar), men nftables-kedjan `ut` saknar regel för D7. Därför stoppas `dnf makecache` mot speglarna på port 443 av nftables. Det är orsaken till bruset i D2 (136 träffar på 15,5 h), som i dag hanteras med ett undantag i monitorn. Rätt åtgärd är att lägga in D7 i nftables (tcp 443 ut till speglarna). Då försvinner bruset vid källan och undantaget i monitorn kan tas bort. ⟨Teambeslut⟩
 
**Status 2026-11-12:** under 2 dygn blockerades 379 försök på port 443, alla mot 146.75.122.132. Regeln `ip daddr 146.75.122.132 tcp dport 443 accept comment "D7 Paketuppdateringar"` är tillagd tillfälligt i kedjan `ut` (handle 20, före loggregeln). Den är inte permanent och försvinner vid omstart. **Resultat:** `dnf makecache` fick nu svar från 146.75.122.132 (spegellistan), men listan pekar vidare till ett 20-tal speglar med olika adresser på port 443 och 80 (till exempel mirrors.hostiserver.com, rockylinux.mirrorservice.org, ftp.fau.de). Alla blockerades, och dnf avbröts efter timeout (2026-11-12 11:10:45 UTC). Kärnloggen visar 24 blockerade försök på port 443 mot 11 olika adresser på 3 minuter (11:07:24–11:10:34 UTC), bland annat 137.226.34.46, 34.49.219.67, 87.121.121.5, 172.65.90.80/81, 104.18.8.165/9.165, 212.219.56.184 och 34.160.10.244. Den tillfälliga regeln togs bort efter testet (`sudo nft delete rule inet zon ut handle 20`). **Slutsats:** ett smalt D7-flöde mot en enda adress räcker inte så länge dnf använder spegellistan. Regeln ger dessutom mer brus i D2, eftersom dnf då försöker nå många nya adresser. Alternativ för teamet: (A) lås dnf till en fast spegel (`baseurl`) och öppna bara mot den, (B) öppna tcp 443 ut mot alla adresser (som molnregeln gör i dag, men det släpper också ut beaconing som D5), (C) behåll blockeringen och undantaget i D2, och dokumentera att servern inte får uppdateringar. ⟨Teambeslut⟩
 
![Regelverket i nftables](bilder/nftables-regelverk.png)
 
![Molnresurser och molnbrandvägg](bilder/moln-status.png)
 
---
 
## AI-användning
 
Jag har använt AI (Claude) som stöd under arbetet med milstolpe 6. Det fullständiga underlaget med prompter, AI:ns svar och mina rättelser finns i metodbilagan.
 
**Vad AI hjälpte till med**
- Bolla idéer och komma vidare när jag fastnade, till exempel med att felsöka varför D1-monitorn inte larmade.
- Föreslå vilka sökningar i Wazuh jag kunde köra för att mäta brus och kontrollera larm.
- Strukturen i den här filen och formuleringar i nedbrytning, playbooks och triagelogg.
  
**Vad jag gjorde själv**
- Byggde och testade alla monitorer i Wazuh.
- Framkallade händelserna (U6.2, `sudo id`, misslyckad sudo, testet mot 1.1.1.1:8080, U6.5) och tog skärmdumparna.
- Körde alla sökningar och kommandon och läste av resultaten. Siffror och värden i dokumentet kommer från min egen miljö, inte från AI.
- Tog besluten. Till exempel valde jag bort AI:ns förslag på ATT&CK-tekniker för D2–D4.
  
**Där AI:ns förslag inte stämde eller behövde kontrolleras**
- AI:ns första gissning om varför D1 inte larmade var ett filter på `agent.name`. När jag öppnade monitorn visade det sig att felet var `location is *elev-34*` (exakt match) i stället för `contains`.
- AI skrev först att loggprefixet var `ZONE-UT-DROPIN`. När jag listade reglerna med `nft` visade det sig att prefixet är `ZONE-UT-DROP` och att `IN=` bara sitter ihop med det i loggen.
- AI:s förslag om orsaken till D3-larmet 10:29 (ctf-serverns root-inloggning) stämde inte. Monitorns fråga kräver `auid=1000`, så larmet kom från mitt eget konto.