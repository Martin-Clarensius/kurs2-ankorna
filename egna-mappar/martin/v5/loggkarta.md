# Vecka 5 – Centralloggning och spårbarhet

Team: [team-ankorna] · Servrar: elev-34 (172.20.1.134), 10.40.2.82 [logg/övervakning] · Loggserver: log.sec.chas-lab.dev (172.20.1.58)

## Loggkällekarta 

| Källa | Var / hur den läses | Exempelrad (klistrad) | Vilken fråga den besvarar | Rotation | Hur långt bakåt | Tidsformat |
|---|---|---|---|---|---|---|
| Autentisering | `/var/log/secure` | `Nov  9 09:46:37 elev-34 sudo[103812]: pam_unix(sudo:session): session closed for user root` | Vem loggade in eller körde sudo, och när? | weekly (logrotate) | ca 4 veckor (`rotate 4`) | `Nov  9 09:46:37` |
| Systemlogg | `/var/log/messages` | `Nov  9 09:56:55 elev-34 audisp-syslog[100125]: type=BPF msg=audit(1794218215.318:13534): prog-id=518 op=UNLOAD` | Vad hände på servern, vilka tjänster startade eller stannade? | weekly (logrotate) | ca 4 veckor | `Nov  9 09:56:55` |
| Cron | `/var/log/cron` | `Nov  9 09:01:01 elev-34 CROND[103734]: (root) CMDEND (run-parts /etc/cron.hourly)` | Vilka schemalagda jobb kördes, och av vem? | weekly (logrotate) | ca 4 veckor | `Nov  9 09:01:01` |
| Audit | `/var/log/audit/audit.log` (`ausearch`), skickas via audisp-syslog | `type=CRED_DISP msg=audit(1794217597.366:13290): pid=103812 uid=1000 auid=1000 ses=332 ... acct="root" exe="/usr/bin/sudo"` | Vem (auid) körde vilket root-kommando? | auditd.conf: `max_log_file = 8`, `num_logs = 5`, ROTATE | ca 40 MB (5 × 8 MB) | epoch `1794217597.366` + serienummer |
| Journal | `journalctl` | `Nov 09 09:58:44 elev-34 audisp-syslog[619]: type=CRED_DISP msg=audit(1794218324.667:3421): pid=5412 uid=1000 auid=1000 ...` | Samma händelser som secure/messages, med fler fält | Ingen på disk: `/var/log/journal` saknas, `Storage=auto` | Bara sedan senaste omstart (minne) | ISO 8601 |
| Brandvägg | nft-regler med `log prefix "ZON-IN-DROP"` / `"ZONE-UT-DROP"`, kärnloggen läses via journalen (imjournal) | `Nov 09 11:55:21 elev-34 kernel: ZONE-UT-DROPIN= OUT=eth0 SRC=167.233.215.66 DST=1.1.1.1 LEN=60 PROTO=TCP SPT=37234 DPT=80 SYN` | När blockerades trafik, från vilken adress och mot vilken port? | som journal/messages | ca 4 veckor (om i messages) | `Nov 09 11:55:21` |

Anmärkning: journalen och `/var/log/secure` innehåller samma händelser i två lagringar, inte två olika händelser.

## Fem frågor och urval 

| Fråga (tidsspann, subjekt, vad som ska fastställas) | Källor som krävs | Går att besvara idag? |
|---|---|---|
| 1. Vem loggade in som root eller körde sudo på elev-34 mellan 02 och 04 natten till 5/11? | secure, audit | Ja |
| 2. Vilket konto (auid) körde root-kommandon på elev-34 senaste dygnet, och vilka kommandon? | audit | Ja |
| 3. När blockerades senast utgående trafik från elev-34, mot vilken adress och port? | brandvägg | Ja |
| 4. Vilken server slutade skicka loggar till loggservern, och när? | messages, brandvägg, central logg | Delvis (kräver central vy) |
| 5. Vilka schemalagda jobb kördes som root på elev-34 under natten? | cron | Ja |

Urval: teamet samlar in secure, messages (system), audit, cron och brandväggsloggen. Allt skickas med regeln `*.*` i `/etc/rsyslog.d/50-tls.conf` över TLS (port 6514).

### Strukna källor och skäl

| Struken källa | Varför ingen fråga behöver den |
|---|---|
| `/var/log/httpd` | Ingen av de fem frågorna rör webbserverns åtkomst |
| `maillog`, `spooler` | Tomma (0 byte), ingen fråga rör e-post eller utskrift |

## Insamling och omstartstest

Alla servrar skickar system-, autentiserings- och brandväggsloggar till 172.20.1.58 port 6514 över TLS (rsyslog, gtls, CA från `http://log.sec.chas-lab.dev/ca.pem`, `x509/name` mot `log.sec.chas-lab.dev`).

| Server | Omstart (UTC) | Efter omstart | Testhändelser | Hittad centralt? |
|---|---|---|---|---|
| elev-34 | 2026-11-09 12:00:51 | rsyslog active (running), nftables enabled, regler 6514 och 123 kvar, ESTAB mot 172.20.1.58:6514 | EFTER-OMSTART, EFTER-OMSTART2, EFTER-OMSTART3 | Ja, kanal TLS (kom fram 12:03:07 respektive 12:04:00) |
| [10.40.2.82 / servernamn] | [tid] | [fyll i] | [fyll i] | [fyll i] |

## Verifieringsanteckning 

Sökning gjord på jump med `loggsök <söksträng>`.

| Identifierare | Ungefärlig tid (UTC) | Värdnamn | Källa | Söksträng | Hittad centralt? | Avvikelse? |
|---|---|---|---|---|---|---|
| TEAM-elev-34-2 | 2026-11-09 11:55 | elev-34 | system (logger) | `loggsök TEAM-elev-34-2` | Ja, kanal TLS | Ingen |
| ZONE-UT-DROP (curl 1.1.1.1) | 2026-11-09 11:55 | elev-34 | brandvägg (kärna) | `loggsök "ZONE-UT" \| grep TLS` | Ja, kanal TLS | Före åtgärd gick brandväggsloggen i klartext och 6514 blockerades (se nedan) |
| EFTER-OMSTART / 2 / 3 | 2026-11-09 12:01–12:04 | elev-34 | system (logger) | `loggsök EFTER-OMSTART` | Ja, kanal TLS | De två första väntade i kön tills anslutningen var uppe; EFTER-OMSTART3 visades två gånger |
| [TEAM-servernamn-1] | [tid] | [servernamn] | [källa] | [söksträng] | [ja/nej, kanal] | [ingen/beskriv] |

### Avvikelse och åtgärd
- Före åtgärd: brandväggen (`chain ut`, policy drop) saknade regler för utgående TLS (6514) och för NTP mot Hetzner (213.239.239.0/24). Regelverket hade inte sparats, och kärnloggen gick i klartext via `/etc/rsyslog.d/90-forward.conf` (`kern.*`, port 514, ingen TLS).
- Åtgärd: regler tillagda i `chain ut`, sparade i `/etc/sysconfig/nftables.conf` (`nftables` enabled), klartextfilen flyttad till `/root/`.
- Verifiering: rsyslog "resumed" 11:54:16, `tcpdump` visar trafik och ACK på 6514, brandväggsrader och testhändelser kommer över TLS.

Utskrift från `loggsök` (bevis på hur vi letade):

[klistra in utskrift, t.ex. `loggsök EFTER-OMSTART` och `loggsök "ZONE-UT" | grep TLS`]

## Skyddsbeskrivning av loggkedjan 

### 1) Vem kan ändra eller radera loggen lokalt?
Root. `secure` och `messages` har rättigheterna `-rw-------` (root:root), och katalogerna `audit/`, `httpd/` och `private/` är `drwx------` (root). Användaren `student` är med i gruppen `wheel` och har `(ALL) ALL` i sudo, och kan därför agera som root. Belägg: `ls -l /var/log`, `id`, `sudo -l`.

### 2) Vem kan det centralt?
Ingen i teamet. Vi har inget konto på loggservern, och `loggsök` visar bara raderna från den egna servern. Loggservern sorterar raderna per avsändaradress i `/var/log/remote/elev-NN/`, så ingen kan skriva i någon annans loggar. Åtkomst har loggserverns administratörer.

### 3) Lagringstid och rotation lokalt respektive centralt
- Lokalt: `secure`, `messages`, `cron` roteras veckovis, 4 filer sparas (`weekly`, `rotate 4`, ca 4 veckor). Auditloggen roteras vid 8 MB och 5 filer sparas (`max_log_file = 8`, `num_logs = 5`, ca 40 MB). Journalen ligger bara i minnet (`/var/log/journal` saknas, `Storage=auto`) och försvinner vid omstart.
- Centralt: [okänd, styrs av loggservern / fyll i om läraren vet].

### 4) Vad händer när mottagaren är onåbar?
`/etc/rsyslog.d/50-tls.conf` använder en diskstödd kö: `queue.type="LinkedList"`, `queue.filename="fwdq"`, `queue.maxDiskSpace="100m"`, `queue.saveOnShutdown="on"` och `action.resumeRetryCount="-1"` (försöker igen utan gräns). Köfiler: `fwdq.00000011` och `fwdq.qi` i `/var/lib/rsyslog`.
Belägg: före TLS-regeln fick rsyslog "cannot connect to 172.20.1.58:6514" (11:51–11:53) och återupptog skickningen 11:54:16 utan att tappa händelser. Efter omstarten 12:00:51 skickades EFTER-OMSTART (12:01:09) och EFTER-OMSTART2 (12:01:59), men de kom fram först 12:03:07.
När gränsen 100 MB nås: [fyll i, kontrollera i rsyslog-dokumentationen för `queue.maxDiskSpace`].
Med en ren minneskö hade händelserna försvunnit vid omstart av rsyslog.

### 5) Vem kan läsa loggarna?
Lokalt: root (och därmed `student` via sudo). Centralt: loggserverns administratörer. Teamet läser bara sina egna rader via `loggsök` på jump.

### Scenario: angripare med root på min server
- Angriparen kan tömma lokala loggar (`truncate -s 0 /var/log/secure`), rotera bort journalen eller stoppa rsyslog/auditd.
- Det som redan skickats finns kvar centralt. Belägg: [klistra in `loggsök TEAM-elev-34-2` efter att `secure` tömts, samt `ls -l /var/log/secure`].
- Kedjan fångar också vem som gjorde det: sudo och auditd loggar kommandot med `auid`, och när loggflödet slutar komma syns det centralt.
- Kedjan skyddar inte det som aldrig hunnit skickas, och inte loggservern själv. TLS skyddar transporten, inte innehållet.