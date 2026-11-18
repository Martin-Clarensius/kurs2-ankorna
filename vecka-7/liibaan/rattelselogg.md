# Rättelselogg – AI-granskning vecka 7

## 1. Granskning av SELinux

AI-granskningen bekräftade att SELinux är i Enforcing-läge enligt kommandot getenforce och konfigurationsfilen.

## 2. Granskning av Zonvakt

AI-granskningen identifierade att Zonvakt körs i domänen zonvakt_t. Domänen är inte särskilt satt i permissive-läge.

## 3. Granskning av permanent SELinux-regel

Regeln för /srv/zonwebb finns registrerad med typen httpd_sys_content_t.

En registrerad regel bevisar inte automatiskt att alla befintliga filer har rätt aktiv kontext.

## 4. Granskning av brandväggen

Den inkommande kedjan har policy drop. Detta bevisar inte att utgående trafik eller hela brandväggskonfigurationen är säker.

## 5. Granskning av auditregeln

Auditregeln omfattar 64-bitars execve-händelser med euid=0, auid>=1000 och auid!=-1.

Den loggar därför inte alla root-kommandon.

## 6. Slutsats

AI-granskningen hjälpte till att skilja verifierade resultat från antaganden och överdrivna säkerhetspåståenden. Dokumentationen har avgränsats till de kontroller som faktiskt genomfördes.
