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

## 5. Egen upptäckt av AI-fel – U7.4 (2026-11-17)

**AI:s felaktiga förslag:**

AI föreslog audit-ID 3921 och flaggan `brunn-gavel-turbin-jaguar`. När jag testade förslaget fick jag svaret `Fel flagga för U7.4`.

**Min egen kontroll:**

Jag undersökte audit-ID 2687 med `ausearch` på elev-03.

**Resultat från servern:**

- Proctitle: `--zon park --lage balkong`
- AVC: `name=klot-gata`
- `tcontext=tmp_t`
- `permissive=0`

**Min rättelse:**

Efter fortsatt kontroll skickade jag in flaggan `turbin-jaguar-brunn-gavel`. Servern bekräftade:

`Rätt! U7.4 är registrerad för elev-03.`

**Lärdom:**

AI:s förslag var felaktigt. Jag kontrollerade auditloggen själv, jämförde resultatet och rättade förslaget innan jag fick rätt flagga.
