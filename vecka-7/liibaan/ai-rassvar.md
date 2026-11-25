> **Dokumentationsdatum:** 2026-11-23 (senaste verifierade Git-uppdatering). Datumet anger dokumentversionen, inte säkert datum för själva AI-granskningen.

# AI-granskning av härdningskontroller – elev-03

## 1. SELinux – Enforcing

**Verifierat:** Kommandot `getenforce` gav resultatet `Enforcing`. Konfigurationsfilen `/etc/selinux/config` visade `SELINUX=enforcing`.

**Bedömning:** SELinux är aktivt i Enforcing-läge och konfigurationen anger enforcing som permanent läge.

## 2. Zonvaktens SELinux-domän

**Verifierat:** Kommandot `ps -eZ` visade att Zonvakt körs i domänen `zonvakt_t`. Kontrollen av permissive-listan visade ingen post för `zonvakt_t`.

**Bedömning:** Zonvakt körs i den avsedda domänen och domänen är inte särskilt satt i permissive-läge.

**Begränsning:** Detta bevisar inte att alla SELinux-policyregler för tjänsten är korrekta.

## 3. Permanent SELinux-regel

**Verifierat:** Kommandot `semanage fcontext -l -C` visade följande regel:

`/srv/zonwebb(/.*)? all files system_u:object_r:httpd_sys_content_t:s0`

**Bedömning:** En permanent SELinux-regel finns för sökvägen `/srv/zonwebb` och anger typen `httpd_sys_content_t`.

**Begränsning:** Att regeln finns bevisar inte automatiskt att alla befintliga filer har rätt aktiv SELinux-kontext. Det behöver kontrolleras separat.

## 4. Brandväggens inkommande policy

**Verifierat:** Kommandot `nft list chain inet zon in` visade att den inkommande kedjan har policyn `drop`.

**Bedömning:** Trafik som når kedjan och inte tillåts av någon regel blockeras enligt standardpolicyn.

**Begränsning:** Kontrollen bevisar inte att hela brandväggen är säker. Utgående trafik och övriga kedjor har inte verifierats genom denna kontroll.

## 5. Auditregel för privilegierade kommandon

**Verifierat:** Auditregeln är:

`-a always,exit -F arch=b64 -S execve -F euid=0 -F auid>=1000 -F auid!=-1 -F key rootkommando`

**Bedömning:** Regeln loggar 64-bitars execve-händelser där effektiv UID är 0, audit UID är minst 1000 och audit UID inte är -1.

**Begränsning:** Regeln loggar inte alla root-kommandon. Den omfattar endast händelser som matchar samtliga villkor.

## 6. Samlad bedömning

Verifieringsskriptet rapporterade sju godkända kontroller.

Resultaten ger stöd för att SELinux är i Enforcing-läge, att Zonvakt körs i domänen `zonvakt_t`, att en permanent SELinux-regel finns, att den kontrollerade inkommande brandväggskedjan har policyn `drop` och att en auditregel för vissa privilegierade kommandon är aktiv.

Kontrollerna utgör inte en fullständig säkerhetsrevision.

## 7. Slutsats

De genomförda kontrollerna visar att flera viktiga härdningsinställningar är aktiva på elev-03. Slutsatserna bör begränsas till det som faktiskt har verifierats. Ytterligare granskning krävs för att bedöma hela brandväggskonfigurationen, samtliga SELinux-regler och den fullständiga loggningen av privilegierade aktiviteter.
