# Triagelogg – milstolpe 6

**Ansvarig:** elev-33 (Per Palmgren)

En post per larm. Observation och slutsats hålls i skilda fält. Tider är svensk tid (CET) om inte UTC anges. Servern elev-33 loggar i UTC (svensk tid = UTC + 1).

## Post 1 – D1 SSH brute force

| Fält | Innehåll |
|---|---|
| Larm (monitor) | `elev-33`, trigger `Susp SSH` (regel 5710, IS ABOVE 4) |
| Larmets starttid | 2026-11-12 11:12 (slut 11:16) |
| Observationer (det som syns i loggen) | Poster med regel 5710 ("Attempt to login using a non-existent user") i `wazuh-alerts-*` för elev-33 kl. 11:11–11:12. ⟨Antal poster, `data.srcip` och exempel på `data.srcuser`⟩. Sökning efter lyckad inloggning `data.srcip: 172.20.1.10 and rule.id: (5715 or 40112)` gav ⟨n⟩ träffar. Samtidigt larmade `elev-34 5710` (11:12) och andra elevers SSH-monitorer. |
| Slutsats | Upprepade inloggningsförsök mot konton som inte finns, från samma källa inom kort tid: brute force-mönster. Larmet sammanfaller med teamets körning av `kontrollera U6.2 start` mot den gemensamma testservern. |
| Berört (värd, konto, tjänst) | Värd elev-33, tjänst sshd. Bara konton som inte finns provades. |
| Beslut (avfärda / eskalera) | Avfärda |
| Granskbart skäl | Jag körde själv `kontrollera U6.2 start` i ssh jump strax före larmet, och samma minut larmade andra elevers monitorer för samma kontroll. ⟨Källan 172.20.1.10 är ctf-servern, tillåten i nftables som flöde D2.⟩ |
| Åtgärd | Ingen. Larmet dokumenterat som verifiering av D1. |
| Triagerat av / tid | elev-33, 2026-11-16 |

## Post 2 – D1 SSH brute force i normaltrafiken (sökning, inget larm)

| Fält | Innehåll |
|---|---|
| Händelse | Inget larm (monitorn fanns inte då), men brusmätningen visade träffar som monitorn hade larmat på. |
| Tid | 2026-11-11 08:06–08:37 (utbildarens normaltrafik) |
| Observationer | `rule.id: 5710 and location: *elev-33*` i `wazuh-alerts-*`: 39 träffar. 9 av dem från `data.srcip: 10.40.1.126`. ⟨Övriga källor⟩. Dessutom 3 träffar med regel 5760 från 172.20.1.2 (jump) mot kontot `student`. |
| Slutsats | 10.40.1.126 är varken jump eller ctf-servern och finns inte bland kända källor. Mönstret (många försök mot konton som inte finns) är brute force. De 3 träffarna från jump mot `student` är egna felskrivningar. |
| Berört | Värd elev-33, tjänst sshd. |
| Beslut | Avfärda som del av utbildarens normaltrafik. I skarp drift: eskalera, eftersom källan är okänd. |
| Granskbart skäl | Tiden ligger inom normaltrafikperioden enligt `kontrollera U6.3`. |
| Åtgärd | Dokumenterat som brus i D1 (falsklarmrisk medel). 10.40.1.126 läggs inte till som känd källa. |
| Triagerat av / tid | elev-33, 2026-11-16 |

## Post 3 – D3 Root-kommando

| Fält | Innehåll |
|---|---|
| Larm (monitor) | `elev-33-root-kommando`, trigger `root-kommando` |
| Larmets starttid | 2026-11-16 09:28 (3 larm t.o.m. 09:36). Nya larm 11:03–11:16 under testerna av D4. |
| Observationer | `/var/log/secure` på elev-33: `sudo[114428]: student : TTY=pts/0 ; PWD=/home/student ; USER=root ; COMMAND=/bin/grep -iE 'incorrect password\|authentication failure' /var/log/secure` kl. 08:29:15 UTC (09:29:15). I `wazuh-alerts-*` regel 5402 "Successful sudo to ROOT executed" för samma kommando. Lyckad `sudo id` kl. 10:14:01 UTC (11:14:01), utdata `uid=0(root)`. |
| Slutsats | Kontot `student` (auid 1000) körde kommandon som root via sudo. |
| Berört | Värd elev-33, konto `student`. |
| Beslut | Avfärda |
| Granskbart skäl | Egna kommandon i ssh lab under felsökningen av D4: `sudo grep` 09:29:15 och `sudo id` 11:14:01. Kommandot och tiden stämmer med posterna. |
| Åtgärd | Ingen. |
| Triagerat av / tid | elev-33, 2026-11-16 |

## Post 4 – D4 Misslyckad sudo

| Fält | Innehåll |
|---|---|
| Larm (monitor) | `Misslyckad-sudo-elev-33`, trigger `misslyckad-sudo` |
| Larmets starttid | 2026-11-16 ⟨hh:mm⟩ |
| Observationer | Två misslyckade försök 10:10:48 och 10:11:06 UTC (11:10:48 och 11:11:06), utdata `Sorry, try again.` … `sudo: 1 incorrect password attempt`. I `wazuh-archives-*` per försök tre poster från elev-33 med `pam_unix(sudo:auth)`: `authentication failure; logname=student uid=1000 euid=0 tty=/dev/pts/0 ... user=student` (regel 5503, T1110.001), `conversation failed` och `auth could not identify password for [student]`. Lyckad `sudo id` 11:14:01 ⟨gav inget D4-larm⟩. |
| Slutsats | Fel lösenord angavs till sudo två gånger från kontot `student` i terminal pts/0. Ingen höjd behörighet uppnåddes. |
| Berört | Värd elev-33, konto `student`, tjänst sudo. |
| Beslut | Avfärda |
| Granskbart skäl | Eget test `echo fel \| sudo -S -k true; date` två gånger, `date` visade 10:10:48 och 10:11:06 UTC. |
| Åtgärd | Ingen för larmet. Testet 09:18 gav inget larm eftersom monitorn inte sökte i något index (`_shards.total: 0`). Indexet valdes om och monitorn larmar nu. |
| Triagerat av / tid | elev-33, 2026-11-16 |

## Post 5 – D5 Beaconing

| Fält | Innehåll |
|---|---|
| Larm (monitor) | `elev-33-C2-becon-(T1071.001)`, trigger `Becon c2` (COUNT IS ABOVE 4) |
| Larmets starttid | 2026-11-12 14:29 (slut 14:31) |
| Observationer | Fler än 4 poster på 5 min med `predecoder.program_name: syncagent` från elev-33 i `wazuh-archives-*`. ⟨Konto, mål-URL och intervall ur `full_log`⟩ |
| Slutsats | Periodisk utgående kommunikation från programmet `syncagent` till en extern adress: beaconing-mönster (T1071.001). |
| Berört | Värd elev-33, program `syncagent` ⟨konto⟩. |
| Beslut | Avfärda (övning). I skarp drift: eskalera, eftersom målet inte finns på någon lista över godkända destinationer. |
| Granskbart skäl | Framkallat av `kontrollera U6.5 start` strax före larmet. Larmet 14:10 samma dag var en tidigare körning av U6.5. |
| Åtgärd | Ingen i övningen. I skarp drift: stoppa processen, ta reda på hur den startas och spärra målet i kedjan `ut`. |
| Triagerat av / tid | elev-33, 2026-11-16 |
