# Korstest – SSH brute force (regel 5712)

**Testare:** elev-34 (Martin)  
**Playbookansvarig:** elev-03 (Liibaan)  
**Playbook:** `vecka-6/playbooks/ssh-brute-force.md`  
**Datum:** 2026-11-16  
**Resultat:** Godkänt med förbättringar

## Hur testet gick till

elev-03 körde `kontrollera U6.2 start` utan att säga exakt när. Jag fick beskedet "klart" strax efter att han hade kört kommandot. Försöken syns i loggen 10:48:36–10:48:38. Sedan följde jag playbooken i Wazuh Discover (`wazuh-alerts-*`) utan hjälp från elev-03. Tiderna nedan är svensk tid så som Discover visar dem.

## Observationer

| Steg | Vad jag gjorde | Vad jag såg |
|---|---|---|
| 1 | `rule.id: 5712`, 10:30–11:00 | 1 larm 10:48:36, källa `172.20.1.10`, server elev-03 |
| 2 | `data.srcip: 172.20.1.10`, 10:30–11:00 | 12 träffar 10:48:36–10:48:38, alla i `/var/log/remote/elev-03/syslog.log`. Regel 5710 ("Attempt to login using a non-existent user") och en 5712 |
| 2 | Användarnamn i `data.srcuser` | Bara konton som inte finns, till exempel admin86, support65, deploy99, deploy83, test63 |
| 2–3 | `data.srcip: 172.20.1.10 and rule.id: (5715 or 40112)` | 0 träffar. Ingen lyckad inloggning, så frågan om metod (lösenord eller nyckel) blev inte aktuell |
| 3 | Sökning utan värdfilter (fältet `location`) | Bara elev-03. Alla 12 träffar har `location` `/var/log/remote/elev-03/syslog.log`. Inga andra servrar berördes |

## Bedömning (steg 4)

- **Vad hände?** 12 misslyckade SSH-inloggningar på cirka 7 sekunder från 172.20.1.10 mot konton som inte finns.
- **Vad berördes?** Servern elev-03, tjänsten sshd. Inget riktigt konto provades och ingen inloggning lyckades.
- **Vad ska göras?** Avfärda.
- **Granskbart skäl:** källan 172.20.1.10 är ctf-servern, som playbooken listar som känd källa. Tiden stämmer med att elev-03 körde `kontrollera U6.2 start` strax före sitt besked "klart" (försöken 10:48:36–10:48:38). Bara påhittade användarnamn och 0 lyckade inloggningar.

## Det som fungerade

- Steg 1 hittade larmet direkt med `rule.id: 5712`.
- Ordningen larm → källadress → lyckad inloggning → beslut var lätt att följa.
- Kriterierna för "Avfärda endast om" och "Eskalera om" var tydliga och gick att pröva mot loggarna.

## Förbättringar

1. **Steg 1 anger inte index eller tidsfönster.** Skriv ut `wazuh-alerts-*` och till exempel "senaste 30 minuterna eller 15 minuter före och efter larmet".
2. **Berörd server står inte som fält.** Skriv att servern läses i `location` (till exempel `/var/log/remote/elev-03/syslog.log`), eftersom `agent.name` alltid är `log`.
3. **Steg 2 saknar färdiga sökningar.** Lägg till sökningarna, till exempel `data.srcip: <källa>` och `data.srcip: <källa> and rule.id: (5715 or 40112)`. Playbooken nämner bara 40112, så regel 5715 (lyckad inloggning) fick jag lägga till själv.
4. **Det står inte var dokumentationen av CTF-tester finns** (punkt 14 under steg 3). Ange var testtider skrivs upp, till exempel triageloggen, så att testaren kan avfärda utan att fråga författaren.

## AI-användning

Utkastet till den här loggen är skrivet med stöd av Claude (AI) utifrån mina egna sökningar och skärmdumpar. Alla värden kommer från min egen sökning i Wazuh.
