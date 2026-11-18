# Metodbilaga – Härdning vecka 7

## 1. Genomförande

Arbetet genomfördes genom att kontrollera säkerhetsinställningar på servern elev-03.

Följande verktyg och kommandon användes:

- `getenforce` – kontrollerade SELinux-läget.
- `grep` – kontrollerade SELinux-konfigurationen.
- `nft` – kontrollerade brandväggens inkommande policy.
- `ps -eZ` – kontrollerade Zonvaktens SELinux-kontext.
- `semanage fcontext` – kontrollerade permanenta SELinux-regler.
- `auditctl -l` – kontrollerade aktiva auditregler.
- `verifiera-hardning` – körde automatiserade verifieringar.

## 2. Verifiering

Verifieringsskriptet kördes på elev-03. Samtliga sju kontroller rapporterade GÄLLER.

## 3. Avgränsningar

Kontrollerna omfattade de inställningar som anges i härdningsrapporten. De utgör inte en fullständig säkerhetsrevision av servern.

Brandväggskontrollen verifierade den inkommande kedjans policy. Auditregeln omfattar endast händelser som matchar dess angivna villkor.

## 4. Slutsats

Metoden kombinerade manuella kommandokontroller med ett automatiserat verifieringsskript. Resultaten dokumenterades för att göra kontrollerna spårbara.
