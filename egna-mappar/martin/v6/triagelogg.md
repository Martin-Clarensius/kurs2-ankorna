## Triagelogg
 
En post per larm. Observation och slutsats hålls i skilda fält. Tider är svensk tid (CET) om inte UTC anges.
 
### Post 1
 
| Fält | Innehåll |
|---|---|
| Larm (monitor) | `elev-34 5710` (D1 SSH brute force), trigger `minst 5 försök från samma källa` |
| Larmets starttid | 2026-11-12 11:12 svensk tid |
| Observationer (det som syns i loggen) | 12 poster med regel 5710 (nivå 5, "Attempt to login using a non-existent user") i `wazuh-alerts-*` inom några sekunder. Källa `data.srcip: 172.20.1.10`. Påhittade användarnamn i `data.srcuser` (`deploy34`, `backup90`, `admin44`, `test16` …, sett vid körningen 10:30). Ingen lyckad inloggning från källan: `data.srcip: 172.20.1.10 and rule.id: (5715 or 40112)` gav 0 träffar kl. 11:10–11:20. |
| Slutsats (vad jag drar av observationerna) | Upprepade inloggningsförsök mot konton som inte finns, från en och samma källa: brute force-mönster. Källan är ctf-servern. |
| Berört (värd, konto, tjänst) | Värd elev-34, tjänst sshd. Bara konton som inte finns provades. |
| Beslut (avfärda / eskalera) | Avfärda |
| Granskbart skäl | Källan 172.20.1.10 är ctf-servern (tillåten i nftables som flöde D2), och tiden stämmer med `kontrollera U6.2 start` kl. 10:11:49 UTC (11:11:49 svensk tid). |
| Åtgärd | Ingen. Larmet dokumenterat som verifiering av D1. |
| Triagerat av / tid | elev-34, 2026-11-12 |
 
### Post 2
 
| Fält | Innehåll |
|---|---|
| Larm (monitor) | `elev-34 zonöverträdelse (zon-ut-drop)` (D2), trigger `zonöverträdelse` |
| Larmets starttid | 2026-11-12 10:34 svensk tid |
| Observationer (det som syns i loggen) | Poster i `wazuh-archives-*` med prefixet `ZONE-UT-DROP` (i loggen `ZONE-UT-DROPIN=`), `DST=1.1.1.1`, `DPT=8080`, från elev-34. |
| Slutsats (vad jag drar av observationerna) | Utgående anslutning till en adress och port som inte finns i flödestabellen. Den stoppades av nftables-kedjan `ut`. |
| Berört (värd, konto, tjänst) | Värd elev-34. Ingen trafik gick ut. |
| Beslut (avfärda / eskalera) | Avfärda |
| Granskbart skäl | Eget test `timeout 3 bash -c 'echo > /dev/tcp/1.1.1.1/8080'` i ssh lab kl. 09:34:09 UTC (10:34:09 svensk tid). |
| Åtgärd | Ingen. Larmen samma dag 09:32 och 09:55 var också egna tester. |
| Triagerat av / tid | elev-34, 2026-11-12 |
 
### Post 3
 
| Fält | Innehåll |
|---|---|
| Larm (monitor) | `elev-34 root kommando` (D3), trigger `root-kommando` |
| Larmets starttid | 2026-11-12 11:15 svensk tid |
| Observationer (det som syns i loggen) | auditd-post i `wazuh-archives-*` med nyckeln `rootcmd` och `auid=1000`. |
| Slutsats (vad jag drar av observationerna) | Kontot med auid 1000 (`student`) körde ett kommando som root via sudo. |
| Berört (värd, konto, tjänst) | Värd elev-34, konto `student`. |
| Beslut (avfärda / eskalera) | Avfärda |
| Granskbart skäl | Eget test `sudo id` i ssh lab kl. 10:15:09 UTC (11:15:09 svensk tid). Utdata `uid=0(root)`. |
| Åtgärd | Ingen. |
| Triagerat av / tid | elev-34, 2026-11-12 |
 
### Post 4
 
| Fält | Innehåll |
|---|---|
| Larm (monitor) | `elev-34 root kommando` (D3), trigger `root-kommando` |
| Larmets starttid | 2026-11-12 10:29 svensk tid (Completed 10:41) |
| Observationer (det som syns i loggen) | Monitorns fråga kräver `auid=1000`, så alla poster som gav larmet kom från kontot student. 5 auditd-poster (`audisp-syslog`, `type=SYSCALL`, `syscall=59` execve, `success=yes`) med nyckeln `rootcmd` från elev-34: 09:29:01, 09:29:15 och 09:29:57–09:29:58 UTC. Inget eget sudo-kommando vid tidpunkten. Tiden sammanfaller med `kontrollera U6.2 start` 09:29:56 UTC och med inloggningen i ssh lab strax före 09:29:13 UTC. Vilket program som kördes (`exe`) är inte avläst. |
| Slutsats (vad jag drar av observationerna) | Kontot student (auid 1000) körde något som root. Det var inte ctf-serverns root-inloggning, eftersom den inte har auid 1000. Exakt kommando är inte fastställt. |
| Berört (värd, konto, tjänst) | Värd elev-34, konto `student`. |
| Beslut (avfärda / eskalera) | Avfärda preliminärt. Eget konto, ingen okänd session. |
| Granskbart skäl | auid=1000 = `student` (`getent passwd 1000`), egen inloggning i ssh lab vid tidpunkten. |
| Åtgärd | Granska posten i Discover: `location: *elev-34* and full_log: "rootcmd"`, kl. 10:28–10:30. Läs `exe` och `comm` för att fastställa kommandot. |
| Triagerat av / tid | elev-34, 2026-11-12 |
 
### Post 5
 
| Fält | Innehåll |
|---|---|
| Larm (monitor) | `elev-34 misslyckade sudo` (D4), trigger `misslyckad-sudo` |
| Larmets starttid | 2026-11-12 10:37 svensk tid |
| Observationer (det som syns i loggen) | Två poster `pam_unix(sudo:auth): authentication failure` för kontot `student` kl. 10:36:04 och 10:36:20 UTC. Ingen lyckad sudo direkt efter. Lyckade sudo 10:34:15 och 10:35:21 UTC gav inget larm. |
| Slutsats (vad jag drar av observationerna) | Fel lösenord angavs till sudo två gånger från kontot student. |
| Berört (värd, konto, tjänst) | Värd elev-34, konto `student`, tjänst sudo. Ingen höjd behörighet uppnåddes. |
| Beslut (avfärda / eskalera) | Avfärda |
| Granskbart skäl | Eget test `echo fel | sudo -S -k true` i ssh lab, två gånger 10:36:04 och 10:36:20 UTC. |
| Åtgärd | Ingen. |
| Triagerat av / tid | elev-34, 2026-11-12 |
 
### Post 6
 
| Fält | Innehåll |
|---|---|
| Larm (monitor) | `utgående beaconing (T1071.001) VG-uppgift` (D5), trigger `Beaconing` |
| Larmets starttid | 2026-11-12 09:04 svensk tid (Completed 09:11) |
| Observationer (det som syns i loggen) | Fler än 4 poster på 5 min från programmet `syncagent` som kontot `svc-backup`: `action=upload`, `status=200`, mål `https://sync.telemetri-app.net/v1/beacon`, med jämna mellanrum. |
| Slutsats (vad jag drar av observationerna) | Periodisk utgående HTTPS-kommunikation från ett tjänstekonto till en extern adress (beaconing). |
| Berört (värd, konto, tjänst) | Värd elev-34, konto `svc-backup`, program `syncagent`. |
| Beslut (avfärda / eskalera) | Avfärda (övning). I skarp drift: eskalera, eftersom målet inte finns på någon lista över godkända destinationer. |
| Granskbart skäl | Framkallat av `kontrollera U6.5 start` i ssh jump. |
| Åtgärd | Ingen i övningen. I skarp drift: stoppa processen, ta reda på hur den startas och spärra målet. |
| Triagerat av / tid | elev-34, 2026-11-12 |