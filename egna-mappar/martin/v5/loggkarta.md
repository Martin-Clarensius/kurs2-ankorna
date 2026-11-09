# Vecka 5 – Centralloggning och spårbarhet

**Server:** elev-34
**Nätkort:** eth0 167.233.215.66 (publik), eth1 172.20.1.134 (labbnät, loggtrafik till 172.20.1.58:6514 över TLS), eth2 10.40.2.82 (zonnät)
**Loggserver:** log.sec.chas-lab.dev (172.20.1.58)
**Övriga teamservrar:** dokumenteras av respektive medlem.

---

## 1. Loggkällekarta 

| Källa | Var / hur den läses | Exempelrad (klistrad) | Vilken fråga den besvarar | Rotation | Hur långt bakåt | Tidsformat |
|---|---|---|---|---|---|---|
| Autentisering | `/var/log/secure` | `Nov  9 09:46:37 elev-34 sudo[103812]: pam_unix(sudo:session): session closed for user root` | Vem loggade in eller körde sudo, och när? | weekly (logrotate) | ca 4 veckor (`rotate 4`) | `Nov  9 09:46:37` |
| Systemlogg | `/var/log/messages` | `Nov  9 09:56:55 elev-34 audisp-syslog[100125]: type=BPF msg=audit(1794218215.318:13534): prog-id=518 op=UNLOAD` | Vad hände på servern, vilka tjänster startade eller stannade? | weekly (logrotate) | ca 4 veckor (`rotate 4`) | `Nov  9 09:56:55` |
| Cron | `/var/log/cron` | `Nov  9 09:01:01 elev-34 CROND[103734]: (root) CMDEND (run-parts /etc/cron.hourly)` | Vilka schemalagda jobb kördes, och av vem? | weekly (logrotate) | ca 4 veckor (`rotate 4`) | `Nov  9 09:01:01` |
| Audit | `/var/log/audit/audit.log` (`ausearch`), skickas via audisp-syslog | `type=CRED_DISP msg=audit(1794217597.366:13290): pid=103812 uid=1000 auid=1000 ses=332 ... acct="root" exe="/usr/bin/sudo"` | Vem (auid) körde vilket root-kommando? | auditd.conf: `max_log_file = 8`, `num_logs = 5`, ROTATE | ca 40 MB (5 × 8 MB) | epoch `1794217597.366` + serienummer |
| Journal | `journalctl` | `Nov 09 09:58:44 elev-34 audisp-syslog[619]: type=CRED_DISP msg=audit(1794218324.667:3421): pid=5412 uid=1000 auid=1000 ...` | Samma händelser som secure/messages, med fler fält | Ingen på disk: `/var/log/journal` saknas, `Storage=auto` | Bara sedan senaste omstart (minne) | ISO 8601 |
| Brandvägg | nft-regler med `log prefix "ZON-IN-DROP"` / `"ZONE-UT-DROP"`, kärnloggen läses via journalen (imjournal) | `Nov 09 11:55:21 elev-34 kernel: ZONE-UT-DROPIN= OUT=eth0 SRC=167.233.215.66 DST=1.1.1.1 LEN=60 PROTO=TCP SPT=37234 DPT=80 SYN` | När blockerades trafik, från vilken adress och mot vilken port? | som journal/messages | ca 4 veckor om raden hamnar i messages | `Nov 09 11:55:21` |

Anmärkning: journalen och `/var/log/secure` innehåller samma händelser i två lagringar, inte två olika händelser.

---

## 2. Fem frågor och urval 

| Fråga (tidsspann, subjekt, vad som ska fastställas) | Källor som krävs | Går att besvara idag? |
|---|---|---|
| 1. Vem loggade in som root eller körde sudo på elev-34 mellan 02 och 04 natten till 5/11? | secure, audit | Ja |
| 2. Vilket konto (auid) körde root-kommandon på elev-34 senaste dygnet, och vilka kommandon? | audit | Ja |
| 3. När blockerades senast utgående trafik från elev-34, mot vilken adress och port? | brandvägg | Ja |
| 4. Vilken server slutade skicka loggar till loggservern, och när? | messages, brandvägg, central logg | Delvis (kräver central vy) |
| 5. Vilka schemalagda jobb kördes som root på elev-34 under natten? | cron | Ja |

**Urval:** secure, messages (system), audit, cron och brandväggsloggen. Allt skickas med regeln `*.*` i `/etc/rsyslog.d/50-tls.conf` över TLS (port 6514).

### Strukna källor och skäl

| Struken källa | Varför ingen fråga behöver den |
|---|---|
| `/var/log/httpd` | Ingen av de fem frågorna rör webbserverns åtkomst |
| `maillog`, `spooler` | Tomma (0 byte), ingen fråga rör e-post eller utskrift |

---

## 3. Insamling

Servern skickar system-, autentiserings-, audit- och brandväggsloggar till 172.20.1.58 port 6514 över TLS (rsyslog, gtls, `StreamDriverMode="1"`, `x509/name` mot `log.sec.chas-lab.dev`, CA från `http://log.sec.chas-lab.dev/ca.pem`).

Konfiguration (`/etc/rsyslog.d/50-tls.conf`):

```
global(
  DefaultNetstreamDriver="gtls"
  DefaultNetstreamDriverCAFile="/etc/pki/rsyslog/ca.pem"
)

*.* action(type="omfwd"
  target="172.20.1.58" port="6514" protocol="tcp" template="RSYSLOG_SyslogProtocol23Format"
  StreamDriver="gtls" StreamDriverMode="1"
  StreamDriverAuthMode="x509/name"
  StreamDriverPermittedPeers="log.sec.chas-lab.dev"
  queue.type="LinkedList"
  queue.filename="fwdq"
  queue.maxDiskSpace="100m"
  queue.saveOnShutdown="on"
  action.resumeRetryCount="-1")
```

Tid:

```
$ chronyc tracking
Reference ID    : D5EFEFA6 (ntp3.hetzner.de)
Stratum         : 3
System time     : 0.000003941 seconds fast of NTP time
Leap status     : Normal
```

### Avvikelse och åtgärd

- **Före åtgärd:** brandväggen (`chain ut`, policy drop) saknade regler för utgående TLS (6514) och för NTP mot Hetzner (213.239.239.0/24). Kärnloggen (brandväggsraderna) gick dessutom i klartext via `/etc/rsyslog.d/90-forward.conf` (`kern.*`, port 514, ingen TLS). rsyslog loggade "cannot connect to 172.20.1.58:6514" 11:51–11:53.
- **Åtgärd:** regler tillagda i `chain ut` (F4 logg till log TLS, D4 NTP Hetzner) och sparade i `/etc/sysconfig/nftables.conf` (`nftables` enabled). Klartextfilen flyttad till `/root/`.
- **Verifiering:** rsyslog "resumed" 11:54:16, `tcpdump` visar trafik och ACK på 6514, och brandväggsrader och testhändelser kommer nu över TLS.

---

## 4. Omstartstest

| Server | Omstart (UTC) | Efter omstart | Testhändelser | Hittad centralt? |
|---|---|---|---|---|
| elev-34 | 2026-11-09 12:00:51 | rsyslog active (running), `nftables` enabled, reglerna för 6514 och 123 kvar, ESTAB mot 172.20.1.58:6514 | EFTER-OMSTART, EFTER-OMSTART2, EFTER-OMSTART3 | Ja, kanal TLS (första två mottagna 12:03:07, den tredje 12:04:00) |

Observation: de två första händelserna väntade i kön tills anslutningen var uppe efter omstarten. EFTER-OMSTART3 visades två gånger i en av sökningarna.

---

## 5. Verifieringsanteckning 

Sökning görs på jump med `loggsök <söksträng>`.

| Identifierare | Ungefärlig tid (UTC) | Värdnamn | Källa | Söksträng | Hittad centralt? | Avvikelse? |
|---|---|---|---|---|---|---|
| TEAM-elev-34-2 | 2026-11-09 11:55 | elev-34 | system (logger) | `loggsök TEAM-elev-34-2` | Ja, kanal TLS | Ingen |
| ZONE-UT-DROP (curl 1.1.1.1) | 2026-11-09 11:55–11:57 | elev-34 | brandvägg (kärna) | `loggsök "ZONE-UT" \| grep TLS` | Ja, kanal TLS | Före åtgärd: klartext via 90-forward.conf, 6514 blockerad |
| EFTER-OMSTART / 2 / 3 | 2026-11-09 12:01–12:04 | elev-34 | system (logger) | `loggsök EFTER-OMSTART` | Ja, kanal TLS | Väntade i kön tills anslutningen var uppe |

Utskrifter från jump:

```
$ loggsök TEAM-elev-34-2
mottaget 2026-11-09T11:55:23.561Z TLS | 2026-11-09T11:55:23.258569+00:00 172.20.1.134 elev-34 sparbarhet[5860] TEAM-elev-34-2

$ loggsök "ZONE-UT" | grep TLS
mottaget 2026-11-09T11:55:20.513Z TLS | 2026-11-09T11:55:20.254595+00:00 172.20.1.134 elev-34 kernel ZONE-UT-DROPIN= OUT=eth0 SRC=167.233.215.66 DST=1.1.1.1 LEN=60 PROTO=TCP SPT=37234 DPT=80 SYN
mottaget 2026-11-09T11:55:21.410Z TLS | 2026-11-09T11:55:21.265325+00:00 172.20.1.134 elev-34 kernel ZONE-UT-DROPIN= OUT=eth0 SRC=167.233.215.66 DST=1.1.1.1 LEN=60 PROTO=TCP SPT=37234 DPT=80 SYN
mottaget 2026-11-09T11:57:28.095Z TLS | 2026-11-09T11:57:27.769591+00:00 172.20.1.134 elev-34 kernel ZONE-UT-DROPIN= OUT=eth0 SRC=167.233.215.66 DST=1.1.1.1 LEN=60 PROTO=TCP SPT=43966 DPT=80 SYN
mottaget 2026-11-09T11:57:29.159Z TLS | 2026-11-09T11:57:28.817379+00:00 172.20.1.134 elev-34 kernel ZONE-UT-DROPIN= OUT=eth0 SRC=167.233.215.66 DST=1.1.1.1 LEN=60 PROTO=TCP SPT=43966 DPT=80 SYN

$ loggsök EFTER-OMSTART
mottaget 2026-11-09T12:03:07.526Z TLS | 2026-11-09T12:01:09.050769+00:00 172.20.1.134 elev-34 sparbarhet[2187] EFTER-OMSTART elev-34
mottaget 2026-11-09T12:03:07.526Z TLS | 2026-11-09T12:01:59.792185+00:00 172.20.1.134 elev-34 sparbarhet[2190] EFTER-OMSTART2 elev-34
mottaget 2026-11-09T12:04:00.986Z TLS | 2026-11-09T12:04:00.964501+00:00 172.20.1.134 elev-34 sparbarhet[2248] EFTER-OMSTART3 elev-34
```

---

## 6. Skyddsbeskrivning av loggkedjan 

### 1) Vem kan ändra eller radera loggen lokalt?

Root. `secure` och `messages` har rättigheterna `-rw-------` (root:root). Användaren `student` är med i gruppen `wheel` och har `(ALL) ALL` i sudo, och kan därför agera som root. Loggfilerna har inga skyddsflaggor.

```
$ ls -l /var/log/secure /var/log/messages
-rw-------. 1 root root       0 Nov  9 12:45 /var/log/secure
-rw-------. 1 root root 8409340 Nov  9 12:45 /var/log/messages

$ id
uid=1000(student) gid=1000(student) groups=1000(student),10(wheel) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023

$ sudo -l
User student may run the following commands on elev-34:
    (ALL) ALL

$ sudo lsattr /var/log/messages
----------------e------- /var/log/messages
```

`lsattr` visar inget append-only (`a`) eller immutable (`i`). Root kan därför ändra och radera filen.

### 2) Vem kan det centralt?

Ingen i teamet. Vi har inget konto på loggservern, och `loggsök` på jump visar bara raderna från den egna servern. Loggservern sorterar raderna efter avsändaradress i `/var/log/remote/elev-NN/`, så ingen kan skriva i någon annans loggar. Åtkomst har loggserverns administratörer.

### 3) Lagringstid och rotation lokalt respektive centralt

**Lokalt**
- `secure`, `messages`, `cron`: roteras veckovis, 4 filer sparas (`weekly`, `rotate 4`, ca 4 veckor).
- Audit: roteras vid 8 MB, 5 filer sparas (`max_log_file = 8`, `num_logs = 5`, ca 40 MB).
- Journal: ligger bara i minnet (`/var/log/journal` saknas, `Storage=auto`) och försvinner vid omstart.

```
$ cat /etc/logrotate.d/rsyslog
/var/log/cron
/var/log/maillog
/var/log/messages
/var/log/secure
/var/log/spooler
{
    missingok
    sharedscripts
    postrotate
        /usr/bin/systemctl -s HUP kill rsyslog.service >/dev/null 2>&1 || true
    endscript
}
```

**Centralt:** [OBS, fyll i: okänd, styrs av loggservern. Teamet har ingen åtkomst att kontrollera. Fråga läraren om du vill ha ett exakt värde.]

### 4) Vad händer när mottagaren är onåbar?

`/etc/rsyslog.d/50-tls.conf` använder en diskstödd kö: `queue.type="LinkedList"`, `queue.filename="fwdq"`, `queue.maxDiskSpace="100m"`, `queue.saveOnShutdown="on"` och `action.resumeRetryCount="-1"` (försöker igen utan gräns).

```
$ sudo ls -l /var/lib/rsyslog
-rw-------. 1 root root 35903 Nov  9 12:03 fwdq.00000011
-rw-------. 1 root root   559 Nov  9 12:03 fwdq.qi
-rw-------. 1 root root   122 Nov  9 12:45 imjournal.state
```

Belägg:
- 11:51–11:53 loggade rsyslog "cannot connect to 172.20.1.58:6514: Connection timed out" (brandväggen blockerade). 11:54:16 stod det "action resumed" och skickningen återupptogs.
- Efter omstarten 12:00:51 skickades EFTER-OMSTART (12:01:09) och EFTER-OMSTART2 (12:01:59). De kom fram först 12:03:07, när anslutningen var uppe. Inga händelser tappades.
- Med en ren minneskö hade händelserna försvunnit vid omstart av rsyslog.

**När gränsen 100 MB nås:** [OBS, fyll i: kör `man rsyslog.conf | grep -n -i -A4 maxdiskspace` på elev-34 eller fråga läraren, och skriv det du hittar.]

### 5) Vem kan läsa loggarna?

Lokalt: root, och därmed `student` via sudo. Övriga användare får ingen åtkomst (`-rw-------`). Centralt: loggserverns administratörer. Teamet läser bara sina egna rader via `loggsök` på jump.

### Scenario: angripare med root på min server

- Angriparen kan tömma lokala loggar (`sudo truncate -s 0 /var/log/secure`), rotera bort journalen eller stoppa rsyslog/auditd. `student` har `(ALL) ALL` i sudo och loggfilerna saknar skyddsflaggor, så inget hindrar det lokalt.
- Det som redan skickats finns kvar centralt. Belägg:

  ```
  # På elev-34, 2026-11-09 12:45
  $ sudo truncate -s 0 /var/log/secure
  $ ls -l /var/log/secure
  -rw-------. 1 root root 0 Nov  9 12:45 /var/log/secure

  # På jump: raden finns kvar centralt
  $ loggsök TEAM-elev-34-2
  mottaget 2026-11-09T11:55:23.561Z TLS | 2026-11-09T11:55:23.258569+00:00 172.20.1.134 elev-34 sparbarhet[5860] TEAM-elev-34-2
  ```

- Kedjan fångar också vem som gjorde det: sudo och auditd loggar kommandot med `auid`, och när loggflödet slutar komma syns det centralt.
- Kedjan skyddar inte det som aldrig hunnit skickas, och inte loggservern själv. TLS skyddar transporten, inte innehållet.
- Förbättring: `chattr +a` ger append-only, men root kan ta bort flaggan. Det verkliga skyddet är den centrala kopian.