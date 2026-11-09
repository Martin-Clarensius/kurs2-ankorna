# Fem säkerhetsfrågor och urval

**Utbildning:** Chas Academy – ITSX26  
**Kurs:** 2 – Nätverk och säkerhet  
**Vecka:** 5 – Centralloggning och spårbarhet  
**Server:** elev-03  
**Datum:** 5 november 2026

## 1. Syfte

Syftet är att formulera fem säkerhetsfrågor som kan besvaras genom systemets loggar.

Varje fråga innehåller ett tidsspann, relevanta loggkällor och sökvillkor. Tillsammans hjälper frågorna oss att upptäcka obehörig åtkomst, spåra administrativa aktiviteter och analysera nätverkshändelser.

## 2. Fem säkerhetsfrågor

### Fråga 1 – Har någon försökt logga in via SSH utan att lyckas?

**Tidsspann:** Senaste 24 timmarna.

**Loggkällor:** `/var/log/secure` och SSH-tjänstens journal.

**Sökvillkor:** `Failed password`, `authentication failure`, `sshd`.

**Kommando:**

```bash
sudo journalctl -u sshd --since "24 hours ago" --no-pager | grep -Ei 'Failed password|authentication failure'
```

**Syfte:** Identifiera misslyckade inloggningsförsök och eventuella mönster som kan tyda på lösenordsattacker.

### Fråga 2 – Vem har använt sudo eller utfört administrativa kommandon?

**Tidsspann:** Senaste 24 timmarna.

**Loggkällor:** `/var/log/secure` och `/var/log/audit/audit.log`.

**Sökvillkor:** `sudo`, `root_commands`, `auid`.

**Kommandon:**

```bash
sudo grep 'sudo:' /var/log/secure
sudo ausearch -k root_commands -i
```

**Syfte:** Spåra administrativa aktiviteter och koppla dem till en användaridentitet.

**Verifiering:** Auditd har tidigare registrerat ett testkommando med root-behörighet på elev-03.

### Fråga 3 – Vilken nätverkstrafik har blockerats av brandväggen?

**Tidsspann:** Senaste 24 timmarna.

**Loggkälla:** Kärnans brandväggsloggar.

**Sökvillkor:** `ZON-UT-DROP`, `SRC`, `DST`, `DPT`.

**Kommando:**

```bash
sudo journalctl -k --since "24 hours ago" --no-pager | grep 'ZON-UT-DROP'
```

**Central sökning:**

```bash
loggsök ZON-UT-DROP
```

**Syfte:** Identifiera blockerade anslutningar och undersöka avsändare, destination och port.

**Verifiering:** Den 5 november hittades blockerad trafik mot TCP-port 12345 centralt över TLS.

### Fråga 4 – Har en viktig systemtjänst slutat fungera?

**Tidsspann:** Senaste 24 timmarna.

**Loggkällor:** Systemjournalen och `/var/log/messages`.

**Sökvillkor:** `failed`, `error`, `warning`, `rsyslog`.

**Kommandon:**

```bash
sudo journalctl --since "24 hours ago" -p warning --no-pager
sudo journalctl -u rsyslog --since "24 hours ago" --no-pager
```

**Syfte:** Upptäcka tjänstefel och störningar som kan påverka logginsamlingen.

**Tidigare observation:** Den 4 november rapporterade rsyslog både `suspended` och `resumed` för vidarebefordringen.

### Fråga 5 – Har ett oväntat schemalagt jobb körts?

**Tidsspann:** Senaste sju dagarna.

**Loggkälla:** `/var/log/cron`.

**Sökvillkor:** `CROND`, `CMD`, användarnamn och tidpunkt.

**Kommando:**

```bash
sudo grep -E 'CROND|CMD' /var/log/cron
```

**Syfte:** Identifiera oväntade schemalagda kommandon som skulle kunna användas för automatisering eller för att behålla åtkomst till systemet.

## 3. Urval av loggkällor

För central säkerhetsanalys prioriteras följande:

| Prioritet | Loggkälla | Motivering |
|---|---|---|
| Hög | SSH och autentisering | Upptäcka obehörig åtkomst |
| Hög | Auditd och sudo | Spåra administrativa aktiviteter |
| Hög | Brandväggsloggar | Identifiera blockerad trafik |
| Medel | Systemloggar | Upptäcka tjänstefel |
| Medel | Cron | Upptäcka oväntad automatisering |

## 4. Viktiga uppgifter i en logghändelse

Vid analys behöver vi kunna identifiera:

- Tidpunkt och tidszon.
- Serverns värdnamn.
- Användare eller audit-ID när det finns.
- Källadress och destinationsadress när det gäller nätverkstrafik.
- Vilken aktivitet som utfördes.
- Om aktiviteten lyckades, misslyckades eller blockerades.

## 5. Slutsats

De fem säkerhetsfrågorna täcker autentisering, administrativa aktiviteter, brandväggstrafik, tjänstefel och schemalagda jobb.

Tillsammans med loggkällekartan ger de en första strategi för vilka händelser som ska kunna upptäckas och utredas.

Kommandona är exempel på hur frågorna kan undersökas. De tidigare verifierade händelserna på elev-03 används som praktiska belägg, medan övriga sökningar är planerade analysmetoder.