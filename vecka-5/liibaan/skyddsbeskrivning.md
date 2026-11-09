# Skyddsbeskrivning – Central logginsamling

**Utbildning:** Chas Academy – ITSX26  
**Kurs:** 2 – Nätverk och säkerhet  
**Vecka:** 5 – Centralloggning och spårbarhet  
**Server:** elev-03  
**Datum:** 5 november 2026

## 1. Syfte

Syftet är att beskriva hur säkerhetsloggar på elev-03 skyddas, lagras och skickas till den centrala loggservern.

Loggarna ska kunna användas för att upptäcka säkerhetshändelser, utreda incidenter och följa administrativa aktiviteter.

## 2. Loggkedjan

Loggkedjan i labbmiljön är:

Program och systemhändelser → journald → rsyslog → lokal loggfil och central loggserver.

Den centrala loggservern är:

- Server: `log.sec.chas-lab.dev`
- IP-adress: `172.20.1.58`
- Protokoll: TCP
- Port: 6514
- Transportskydd: TLS

Rsyslog använder TLS med certifikatverifiering för att skydda loggtrafiken under överföringen.

## 3. Åtkomst och behörigheter

### Lokal åtkomst

Loggfilerna på elev-03 skyddas med Linux filbehörigheter.

Auditd lagrar sina händelser i `/var/log/audit/audit.log`. Vid kontroll hade filen behörigheten `600` och katalogen `/var/log/audit` behörigheten `700`.

Det innebär att vanliga användare inte har direkt åtkomst till dessa auditloggar.

Root kan däremot läsa, ändra och radera lokala loggfiler.

### Central åtkomst

Loggar skickas till en separat loggserver. Eleven har inte administrativ åtkomst till den centrala logglagringen.

Det minskar risken för att en angripare som får root på elev-03 även kan ändra redan mottagna centrala loggar.

Den centrala serverns exakta behörighetskonfiguration har inte verifierats.

## 4. Lagringstid och rotation

### Lokal lagring

På elev-03 används logrotate med inställningarna:

```text
weekly
rotate 4
```

Det innebär normalt veckovis rotation och fyra sparade äldre versioner.

Rotationsfiler har verifierats från 11, 18 och 25 oktober samt 1 november 2026.

Auditd använder separat rotation med följande konfiguration:

```text
max_log_file = 8
num_logs = 5
max_log_file_action = ROTATE
```

Auditloggarna roteras alltså efter storlek, med en konfigurerad gräns på 8 MB per loggfil och fem loggar enligt auditd-inställningarna.

### Journald

Katalogen `/var/log/journal` saknas på elev-03.

Med `Storage=auto` innebär detta normalt att journalen lagras under `/run/log/journal` och inte överlever en omstart.

Rsyslogs vanliga loggfiler under `/var/log` lagras däremot på disk.

### Central lagring

Centrala loggar från både 4 och 5 november har hittats med `loggsök`.

Föreläsning 1 anger minst sex månader som rekommenderat riktmärke för relevanta säkerhetsloggar.

Den centrala loggserverns faktiska lagringstid, rotation och automatiska radering har inte kunnat verifieras eftersom vi saknar administrativ åtkomst.

Detta behöver bekräftas av ansvarig administratör.

## 5. Kö och buffert vid avbrott

Rsyslog använder följande inställningar:

```text
queue.type="LinkedList"
queue.filename="fwd"
queue.saveOnShutdown="on"
action.resumeRetryCount="-1"
```

Konfigurationen använder en diskstödd kö och försöker återuppta leveransen vid avbrott.

Vid kontroll av `/var/lib/rsyslog/` hittades:

- `fwd.00000001` – 21 KB
- `fwd.qi` – 548 byte
- `imjournal.state` – 124 byte

Filerna visar att diskbaserad köhantering har använts.

I rsyslogs tjänstelogg den 4 november kl. 11:09:14 hittades meddelanden om att vidarebefordringen först blev `suspended` och sedan `resumed`.

Det visar att rsyslog har rapporterat ett avbrott och återupptagit vidarebefordringen.

### Kögränser och risker

Inga uttryckliga värden för `queue.size` eller `queue.maxDiskSpace` hittades i den undersökta vidarebefordringskonfigurationen.

Därför kan ingen särskilt konfigurerad numerisk kögräns anges.

Vid längre avbrott kan köhanteringen påverkas av standardgränser och tillgängliga systemresurser. Det finns risk för fördröjning eller förlust av loggmeddelanden.

Köfiler på disk är inte i sig bevis för att meddelanden fortfarande väntar på leverans.

## 6. Verifiering av central logginsamling

En testhändelse skapades genom att försöka ansluta till TCP-port 12345 på den centrala loggservern.

Värdbrandväggen blockerade trafiken och genererade loggrader med prefixet:

```text
ZON-UT-DROP
```

På jump-servern användes:

```bash
loggsök ZON-UT-DROP | grep 'DPT=12345'
```

Två händelser från elev-03 hittades centralt den 5 november:

- 08:26:57.935 UTC
- 08:26:58.836 UTC

Båda var märkta `TLS`.

Det verifierar att de aktuella brandväggshändelserna nådde den centrala loggservern över den skyddade loggkanalen.

## 7. Angriparscenario – root på elev-03

Om en angripare får root-behörighet på elev-03 kan angriparen:

- Läsa, ändra eller radera lokala loggfiler.
- Stoppa rsyslog eller auditd.
- Ändra loggkonfigurationen.
- Försöka dölja säkerhetshändelser.
- Störa vidarebefordringen till loggservern.

Central logginsamling minskar denna risk eftersom redan överförda loggar lagras utanför den komprometterade servern.

En angripare med root på elev-03 kan däremot fortfarande försöka stoppa framtida loggöverföring.

Därför är det viktigt att övervaka avbrott och uteblivna loggar.

## 8. Slutsats

På elev-03 har vi verifierat:

- Central logginsamling över TLS.
- Att brandväggshändelser når den centrala loggservern.
- Lokal loggrotation.
- Auditd och skyddade auditloggar.
- Diskbaserad köhantering.
- Rsyslogs avbrott och återanslutning.

De viktigaste lokala kontrollerna är genomförda.

**Kvarstående begränsning:** Den centrala loggserverns exakta lagringstid, rotationspolicy och administratörsbehörigheter är inte verifierade. Dessa uppgifter behöver bekräftas av ansvarig administratör.

Skyddsbeskrivningen redovisar därför både verifierade resultat och de delar som fortfarande är okända.