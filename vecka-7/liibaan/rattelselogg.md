> **Dokumentationsdatum:** 2026-11-23 (senaste verifierade Git-uppdatering). Datumet anger dokumentversionen, inte säkert datum för själva AI-granskningen.

# Rättelselogg – AI-granskning

## 1. SELinux – permanent regel

AI-granskningen visar att en registrerad SELinux-regel för
/srv/zonwebb använder typen httpd_sys_content_t.

Rättelse:
En registrerad regel bevisar inte automatiskt att alla befintliga
filer har rätt aktiv SELinux-kontext.

## 2. Brandvägg

Felaktig slutsats:
Att inkommande policy drop innebär att hela brandväggen är säker.

Rättelse:
Den inkommande kedjan har policy drop. Detta bevisar inte att
utgående trafik eller hela brandväggskonfigurationen är säker.

## 3. Auditregeln

Felaktig slutsats:
Att auditregeln loggar alla root-kommandon.

Rättelse:
Regeln omfattar 64-bitars execve-händelser med:
- euid=0
- auid>=1000
- auid!=-1

Den loggar därför inte alla root-kommandon.

## 4. Slutsats

AI-granskningen hjälpte till att identifiera överdrivna
säkerhetspåståenden och skilja verifierade fakta från antaganden.

Rättelserna begränsar slutsatserna till det som faktiskt
har kontrollerats.

