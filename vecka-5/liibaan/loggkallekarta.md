# Loggkällekarta – Centralloggning och spårbarhet

**Utbildning:** Chas Academy – ITSX26  
**Kurs:** 2 – Nätverk och säkerhet  
**Vecka:** 5  
**Server:** elev-03  
**Datum:** 5 november 2026

## 1. Syfte

Syftet med loggkällekartan är att identifiera viktiga loggkällor på elev-03 och beskriva hur de kan användas för att upptäcka, analysera och utreda säkerhetshändelser.

## 2. Inventering av sex loggkällor

| Loggkälla | Var finns loggen? | Vad visar den? | Säkerhetsnytta |
|---|---|---|---|
| 1. Systemloggar | `/var/log/messages` | Systemhändelser, fel och tjänstmeddelanden | Upptäcka driftproblem och avvikande aktivitet |
| 2. Autentiseringsloggar | `/var/log/secure` | SSH-inloggningar, misslyckade försök och sudo | Identifiera obehörig åtkomst |
| 3. SSH-tjänsten | `journalctl -u sshd` | SSH-anslutningar och sessioner | Undersöka vem som anslutit och när |
| 4. Brandväggsloggar | `journalctl -k` | Blockerad trafik, exempelvis `ZON-UT-DROP` | Upptäcka otillåten nätverkstrafik |
| 5. Auditd | `/var/log/audit/audit.log` | Administrativa kommandon och audit-händelser | Spåra aktiviteter med förhöjd behörighet |
| 6. Cron | `/var/log/cron` | Schemalagda jobb | Upptäcka oväntade automatiserade aktiviteter |

## 3. Lokal lagring

Rsyslog skriver loggar till filer under `/var/log`.

Den lokala logrotationen är konfigurerad med:

- `weekly` – veckovis rotation.
- `rotate 4` – fyra äldre versioner sparas.

Auditd använder separat rotation med `max_log_file=8`, `num_logs=5` och `max_log_file_action=ROTATE`.

Journald använder normalt tillfällig lagring i `/run/log/journal` på denna server eftersom `/var/log/journal` saknas.

## 4. Central insamling

Rsyslog vidarebefordrar loggmeddelanden till:

- **Server:** `log.sec.chas-lab.dev`
- **IP-adress:** `172.20.1.58`
- **Port:** TCP 6514
- **Transport:** TLS

Det har verifierats att brandväggsloggar från elev-03 når den centrala loggservern.

Att alla sex loggkällor finns lokalt innebär inte automatiskt att varje källa har verifierats separat centralt. Den centrala täckningen behöver bedömas utifrån de genomförda testerna.

## 5. Prioriterade säkerhetshändelser

De viktigaste händelserna att kunna undersöka är:

1. Misslyckade och lyckade SSH-inloggningar.
2. Användning av sudo och root-behörighet.
3. Blockerad nätverkstrafik.
4. Administrativa kommandon som registreras av auditd.
5. Systemfel och oväntade tjänsteavbrott.
6. Oväntade schemalagda aktiviteter.

## 6. Skydd och begränsningar

Lokala loggfiler skyddas genom Linux filbehörigheter.

Central insamling minskar risken för att en angripare på elev-03 kan radera all historik.

TLS skyddar loggtrafiken under överföringen.

Den centrala loggserverns exakta lagringstid och rotationspolicy är inte verifierade.

## 7. Slutsats

Sex relevanta loggkällor har identifierats på elev-03.

Loggkällorna ger tillsammans möjlighet att undersöka autentisering, administrativa aktiviteter, nätverkstrafik, systemhändelser och schemalagda jobb.

Loggkällekartan utgör den första versionen av vår loggstrategi inför checkpoint den 9 november 2026.