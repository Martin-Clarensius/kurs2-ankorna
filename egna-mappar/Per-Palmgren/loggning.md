# Loggning: underlag enligt MCFFS 2026:11, 4 kap. 21–23 och 25 §§

Källor för kravet: MCFFS 2026:11, 4 kap. 21–23 och 25 §§. Verktyg: auditd (`auditctl(8)`, `audit.rules(7)`, `ausearch(8)`, `augenrules(8)`).

## Status

- **Verifierat lokalt:** auditd-regeln för root-kommandon är laddad, och testposter med auid loggas.
- **Verifierat som konfigurerat, ej testat centralt:** syslog-kedjan (audisp-syslog → rsyslog → TLS till `log.sec.chas-lab.dev:6514`). Anslutningen var etablerad vid kontrollen 2026-11-05 09:31.
- **Ej verifierat:** att posterna finns på loggservern. Vi har inte åtkomst till den.
- **Inaktivt:** audisp-remote (`active = no`).

## Loggkällekarta (workshop 1, del 1)

| Källa | Var / hur den läses | Exempelrad (klistrad från server) | Vilken fråga den besvarar | Rotation | Hur långt bakåt | Tidsformat |
|---|---|---|---|---|---|---|
| auditd, root-kommandon | `/var/log/audit/audit.log`, `ausearch -k root_cmd -i` | `type=EXECVE msg=audit(11/05/2026 08:25:24.195:9879) : argc=3 a0=sudo a1=/usr/bin/touch a2=/tmp/sparc6e7feb6-2` | Vilket root-kommando kördes och av vilken användare (auid) | `max_log_file = 8`, `num_logs = 5`, `ROTATE` | Ej uppnått än: första posten 2026-08-25. Max ca 40 MB historik plus aktuell fil | `msg=audit(TID:SERIE)`, lokal tid i `ausearch -i` |
| syslog (audisp-syslog) | `/var/log/messages`, `/var/log/secure` | `Nov 5 08:25:24 elev-33 audisp-syslog[103882]: type=EXECVE msg=audit(1793867124.195:9879): argc=3 a0="sudo" a1="/usr/bin/touch" a2="/tmp/sparc6e7feb6-2"` | Samma som auditd, men skickas vidare via rsyslog | `/var/log/messages-YYYYMMDD` (veckorotation, [bekräfta i logrotate.conf]) | Minst 11 oktober 2026 enligt filnamnen | Syslog, UTC |
| journald | `journalctl` | [klistra in] | [ ] | `SystemMaxUse` och `MaxRetentionSec` ej satta, styrs av diskutrymme | Begränsas av diskutrymme. 33,8 MB 2026-11-05 | [ ] |
| rsyslog-TLS (central kopia) | `/etc/rsyslog.d/90-tls-forward.conf` | [ej verifierad på loggservern] | Finns en kopia utanför servern | Okänt, loggserverns konfiguration | Okänt | Okänt |

## Fem frågor och urval (workshop 1, del 2)

| Fråga (tidsspann, subjekt, vad som ska fastställas) | Källor som krävs | Går att besvara idag? |
|---|---|---|
| 1. Vem kördes root-kommandon på elev-33 mellan 2026-11-04 21:00 och 2026-11-05 10:00 UTC, och vilken användare loggade in ursprungligen | auditd (`root_cmd`) | Ja, lokalt |
| 2. Vilka inloggningar lyckades på elev-33 under samma tidsspann, och från vilken adress | `/var/log/secure`, journald (sshd) | [ej kontrollerat] |
| 3. Startades eller stoppades `rsyslog` eller `auditd` under samma tidsspann | auditd (SERVICE_START/STOP), journald | [ej kontrollerat] |
| 4. Nådde en auditpost loggservern, med identifieraren `sparc6e7feb6-2` | auditd/syslog lokalt, loggserver | Nej, loggservern ej åtkomlig |
| 5. Hur länge kan loggarna nås lokalt, och när började lagringen | auditd.conf, filer i `/var/log/audit/` och `/var/log/messages*` | Ja, lokalt |

**Strukna källor och skäl**

| Struken källa | Varför ingen fråga behöver den |
|---|---|
| [ ] | [ange källa och skäl, eller ta bort raden] |

## Verifieringsanteckning (workshop 2)

| Identifierare | Ungefärlig tid (UTC) | Värdnamn | Källa | Söksträng | Hittad centralt? | Avvikelse? |
|---|---|---|---|---|---|---|
| sparc6e7feb6 | 2026-11-04 21:41:28, 21:46:15, 22:09:30 | elev-33 | auditd, `root_cmd` | `sparc6e7feb6` | Ej verifierad (audisp-remote inaktiv) | Serienummer börjar på 1864 efter omstart, behöver förklaras |
| sparc6e7feb6-2 | 2026-11-05 08:25:24, 08:27:01 | elev-33 | auditd, audisp-syslog, rsyslog | `sparc6e7feb6-2` | Ej verifierad: ingen åtkomst till loggservern | `imfile` kan inte läsa `audit.log` vid start (Permission denied). Anslutningstimeout 2026-11-03 13:11 |

## Skyddsbeskrivning av loggkedjan (workshop 2, del 2)

**1. Vem kan ändra eller radera loggen lokalt?**

Root. `/var/log/audit/audit.log` och `/var/log/messages` ägs av `root:root` med rättigheterna `-rw-------`, så bara root kan läsa och skriva.

Belägg: `ls -l /var/log/audit/` ger `-rw-------. 1 root root 3518863 Nov 5 08:13 audit.log`.

**2. Vem kan det centralt?**

Ej verifierat. Loggservern `log.sec.chas-lab.dev` (172.20.1.58) administreras av någon annan. Vi har inte sett dess konfiguration, behörigheter eller lagring.

Belägg: [saknas, ej åtkomst].

**3. Lagringstid och rotation.**

Lokalt auditd: `max_log_file = 8` (MB), `num_logs = 5`, `max_log_file_action = ROTATE`. Belägg: `/etc/audit/auditd.conf`.

Lokalt syslog: veckorotation, [bekräfta]. Belägg: [logrotate.conf].

Lokalt journald: ingen tidsgräns (`SystemMaxUse` och `MaxRetentionSec` är utkommenterade). Begränsas av diskutrymme. Belägg: `/etc/systemd/journald.conf`.

Centralt: okänt. Belägg: [saknas].

**4. Vad händer när mottagaren är onåbar?**

Konfiguration: rsyslog-kön `fwd_tls` är en diskassisterad LinkedList på max 1 GB. Kön sparas vid omstart (`queue.saveOnShutdown="on"`). Det finns oändliga återförsök (`action.resumeRetryCount="-1"`) med 10 sekunders intervall. Belägg: `/etc/rsyslog.d/90-tls-forward.conf`.

Händelse: 2026-11-03 13:11 timeout mot loggservern efter 128 sekunder. Åtgärden stoppades och återupptogs efter några sekunder. Belägg: `journalctl -u rsyslog`, rad `cannot connect to log.sec.chas-lab.dev:6514 (took 128.67 seconds)`.

Vad som händer när 1 GB nås: [Inte granskats ännu. Behöver testas eller bekräftas i rsyslog-dokumentationen för version 8.2510].

audisp-remote: inaktiv (`active = no`), ingen kö. Belägg: `/etc/audit/plugins.d/au-remote.conf`.

## Kvarstående åtgärder

- [ ] Verifiera att `sparc6e7feb6-2` finns på loggservern. Ansvarig: [namn].
- [ ] Bekräfta rsyslogs beteende när kön når 1 GB i version 8.2510.
- [ ] Klargör varningen `certificate file is not set` och `key file is not set`. Om servern kräver klientautentisering fungerar inte anslutningen.
- [ ] Förklara serienummer 1864 efter omstart.
- [ ] Förklara `imfile`-fel för `/var/log/audit/audit.log` vid start.
- [ ] Bekräfta veckorotationen i `logrotate.conf`.
