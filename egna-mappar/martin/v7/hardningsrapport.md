# Härdningsrapport – elev-34

Ansvarig: elev-34 (Martin)
Datum: 2026-11-18
Server: elev-34, Rocky Linux 9.8, SELinux targeted
Status: AI-utkastet är dömt påstående för påstående mot servern och rättat. Det oredigerade råsvaret, rättelseloggen och utelämningslistan finns i `metodbilaga.md`.

Så läser du rapporten: varje påstående har en **dom** (stämmer, fel eller ogrundat) och ett **belägg**, alltså kommandot och utdatan från min server som avgjorde. Påståenden som jag rättade är markerade (rättat). Servern visar tid i UTC.

## Sammanfattning
**P1.** Servern elev-34 kör Rocky Linux med SELinux i läget enforcing och policyn targeted. Fem åtgärder är genomförda: SELinux-läget, en bestående filkontext för `/srv/zonwebb`, tjänsten zonvakt under en egen policy, en egen porttyp för zonvakt och ett verifieringsskript.
- **Dom:** stämmer
- **Belägg:** `head -3 /etc/os-release` ger `NAME="Rocky Linux"` och `VERSION="9.8 (Blue Onyx)"`. `sestatus` ger `Current mode: enforcing` och `Loaded policy name: targeted`. Varje åtgärd belägges under P2–P19.

## Åtgärd 1 – SELinux i tvingande läge, nu och efter omstart
**P2.** Åtgärd: SELinux står i läget Enforcing just nu, och `/etc/selinux/config` har `SELINUX=enforcing`.
- **Dom:** stämmer
- **Belägg:** `getenforce` ger `Enforcing`. `grep ^SELINUX= /etc/selinux/config` ger `SELINUX=enforcing`.

**P3.** Effekt: överträdelser stoppas och loggas, även för processer som körs som root. Inget tillåts bara för att det loggas.
- **Dom:** stämmer
- **Belägg:** se P12. En process som kör som root nekades att skriva i `/etc`, och AVC-raden har `permissive=0`.

**P4.** Verifiering: `sestatus` visar `Current mode: enforcing` och `Mode from config file: enforcing`. Skriptet `verifiera-hardning` ger `GÄLLER` för båda kontrollerna.
- **Dom:** stämmer
- **Belägg:** `sestatus` ger båda raderna. `sudo /usr/local/bin/verifiera-hardning` ger `GÄLLER SELinux i tvingande läge nu (getenforce = Enforcing)` och `GÄLLER SELinux enforcing efter omstart (/etc/selinux/config)`.

**P5.** Läget består efter omstart, eftersom konfigurationsfilen är det som läses vid start.
- **Dom:** stämmer
- **Belägg:** `who -b` ger `system boot 2026-11-18 08:15`. Efter den starten ger `getenforce` `Enforcing`, och konfigurationsfilen har `SELINUX=enforcing`.

## Åtgärd 2 – Bestående filkontext för /srv/zonwebb
**P6.** Åtgärd: en regel med `semanage fcontext` ger `/srv/zonwebb(/.*)?` typen `httpd_sys_content_t`.
- **Dom:** stämmer
- **Belägg:** `sudo semanage fcontext -l -C` ger `/srv/zonwebb(/.*)?  all files  system_u:object_r:httpd_sys_content_t:s0`.

**P7.** Effekt: httpd får läsa filerna i katalogen under tvingande läge. Eftersom regeln är sparad i policyn återställs typen inte av `restorecon` eller en relabel, vilket hade hänt med `chcon`.
- **Dom:** stämmer
- **Belägg:** `curl -sI http://127.0.0.1/zon/kvitto.txt | head -1` ger `HTTP/1.1 200 OK`. `sudo restorecon -Rnv /srv/zonwebb` (torrkörning) skriver ingenting, alltså skulle `restorecon` inte ändra något.

**P8.** Verifiering: `semanage fcontext -l -C` visar regeln, och `ls -Z` visar att `kvitto.txt` har `httpd_sys_content_t`. Skriptet kontrollerar att regeln finns.
- **Dom:** stämmer
- **Belägg:** `ls -Z /srv/zonwebb` ger `unconfined_u:object_r:httpd_sys_content_t:s0 kvitto.txt`. Skriptet ger `GÄLLER /srv/zonwebb har bestående fcontext-regel`.

## Åtgärd 3 – zonvakt under en egen policy
**P9.** Åtgärd: zonvakt körs under en egen policymodul. Programfilen har typen `zonvakt_exec_t`, loggen har `zonvakt_log_t` och processen kör i domänen `zonvakt_t`.
- **Dom:** stämmer
- **Belägg:** `ls -Z /usr/local/bin/zonvakt /var/log/zonvakt/zonvakt.log` ger `zonvakt_exec_t` respektive `zonvakt_log_t`. `ps -eZ | grep zonvakt` ger `system_u:system_r:zonvakt_t:s0`.

**P10.** (rättat) Verifiering: `semodule -l` visar modulen `zonvakt`, och `ps -eZ` visar `zonvakt_t` för processen. Vid körningen kl. 11:37 hade processen PID 2411. Tjänsten startades om under porttestet och har sedan PID 2998.
- **Dom:** stämmer, men PID-numret var inaktuellt (se rättelseloggen)
- **Belägg:** `sudo semodule -l | grep zonvakt` ger `zonvakt`. `systemctl status zonvakt` ger `Main PID: 2998 (zonvakt)`.

**P11.** Domänen är inte permissiv: `semanage permissive -l` ger ingen träff för zonvakt, och raden `permissive zonvakt_t;` finns inte i `zonvakt.te`.
- **Dom:** stämmer
- **Belägg:** `sudo semanage permissive -l | grep zonvakt` ger ingen utdata. `grep -v '^#' zonvakt.te | grep .` innehåller ingen `permissive`-rad.

**P12.** Effekt: zonvakt begränsas till det policyn tillåter, och ett försök att skriva i `/etc` nekas även om tjänsten körs som root.
- **Dom:** stämmer
- **Belägg:** `ps -eo user,pid,label,comm | grep zonvakt` ger `root 2411 system_u:system_r:zonvakt_t:s0 zonvakt`. `echo overtrad | nc -w2 127.0.0.1 7534` ger `zonvakt elev-34 nekad: Permission denied`. `ausearch -m avc -c zonvakt -ts recent -i` ger `avc: denied { write } for pid=2411 comm=zonvakt name=etc ... tcontext=system_u:object_r:etc_t:s0 tclass=dir permissive=0` och `syscall=openat success=no exit=EACCES`.

**P13.** (rättat) Policyn är medvetet snävad: zonvakt_t får bara läsa i `/etc` (`etc_t`) och har inga rättigheter att skapa eller skriva där, och `files_manage_etc_files` och `corecmd_exec_bin` finns inte i `zonvakt.te`. Tjänsten har dock `execute` och `map` på filer i `bin_t` (via `corecmd_mmap_bin_files`), vilket Python-tolken behöver.
- **Dom:** första delen stämmer, men andra delen i utkastet ("får inte köra program i `bin_t`") var **fel** (se rättelseloggen)
- **Belägg:** `sudo sesearch -A -s zonvakt_t -t etc_t -c file` ger bara `{ getattr ioctl lock open read }` och `map`. `sudo sesearch -A -s zonvakt_t -t etc_t -c dir` ger bara `{ getattr open search }` och `{ ioctl lock read }`. `sudo sesearch -A -s zonvakt_t -t bin_t -c file` ger `allow zonvakt_t bin_t:file { execute map };`.

## Åtgärd 4 – Egen porttyp för zonvakt
**P14.** Åtgärd: porten 7534 är märkt med den egna typen `zonvakt_port_t` via `semanage port`. Den generella regeln `corenet_tcp_bind_generic_port` är ersatt med `allow zonvakt_t zonvakt_port_t:tcp_socket name_bind;`.
- **Dom:** stämmer
- **Belägg:** `sudo semanage port -l | grep zonvakt` ger `zonvakt_port_t tcp 7534`. `zonvakt.te` innehåller `allow zonvakt_t zonvakt_port_t:tcp_socket name_bind;` och ingen `corenet_tcp_bind_generic_port`-rad.

**P15.** (rättat) Effekt: zonvakt_t får bara binda port 7534. På en annan port nekas `bind` av SELinux, så tjänsten kan inte lyssna där.
- **Dom:** stämmer, men "tjänsten startar inte" i utkastet var ogrundat (se rättelseloggen)
- **Belägg:** efter att jag satt `port=7600` i `/etc/zonvakt/zonvakt.conf` och startat om ger `ausearch -m avc -c zonvakt -ts recent -i` `avc: denied { name_bind } for pid=2976 comm=zonvakt src=7600 ... tcontext=system_u:object_r:jboss_management_port_t:s0 tclass=tcp_socket permissive=0` och `syscall=bind success=no exit=EACCES`. Med `port=7534` igen: `ss -ltn` ger `LISTEN 0.0.0.0:7534`, och `echo hej | nc -w2 127.0.0.1 7534` ger `zonvakt elev-34 ok`.

**P16.** Verifiering: `semanage port -l | grep zonvakt` visar `zonvakt_port_t tcp 7534`. `sesearch -A -s zonvakt_t -c tcp_socket -p name_bind` visar bara regeln för `zonvakt_port_t`.
- **Dom:** stämmer
- **Belägg:** båda kommandona gav exakt de raderna: `zonvakt_port_t tcp 7534` respektive `allow zonvakt_t zonvakt_port_t:tcp_socket name_bind;`.

## Åtgärd 5 – Verifieringsskript
**P17.** Åtgärd: `/usr/local/bin/verifiera-hardning` läser av tillståndet och ändrar ingenting. Det gör fem kontroller, skriver `GÄLLER` eller `GÄLLER INTE` för var och en och avslutar med kod 0 om allt gäller.
- **Dom:** stämmer
- **Belägg:** `sudo cat /usr/local/bin/verifiera-hardning` visar fem `kontroll`-anrop som bara läser av (`getenforce`, `grep`, `ps -eZ`, `semanage permissive -l`, `semanage fcontext -l -C`). Funktionen skriver `GÄLLER` eller `GÄLLER INTE` och sätter `rc=1` vid fel, och skriptet slutar med `exit $rc`.

**P18.** Verifiering: körningen gav fem `GÄLLER` och `slutkod 0`, och skriptet fungerar efter omstart.
- **Dom:** stämmer
- **Belägg:** `ls -l --time-style=full-iso /usr/local/bin/verifiera-hardning` ger `2026-11-18 08:14:33 +0000`, före starten enligt `who -b` (`system boot 2026-11-18 08:15`). Körningen efter starten (`sudo /usr/local/bin/verifiera-hardning; echo "slutkod $?"`) gav fem `GÄLLER` och `slutkod 0`. `ctf-status` visar `U7.5 LÖST 2026-11-18`.

**P19.** Skriptet täcker åtgärd 1–3 (SELinux-läget, zonvakt_t, ej permissiv och fcontext-regeln) men inte porttypen i åtgärd 4.
- **Dom:** stämmer
- **Belägg:** skriptets fem kontroller (se P17) gäller läget nu, läget efter omstart, domänen `zonvakt_t`, att domänen inte är permissiv och fcontext-regeln. Ingen kontroll gäller `zonvakt_port_t`.

## Slutsats
**P20.** Servern har SELinux verifierat i tvingande läge och minst en egen tjänst under en egen policy. Det begränsar skadan om zonvakt eller httpd skulle kapas.
- **Dom:** stämmer
- **Belägg:** se P2–P19. `ps -eZ | grep httpd | head -2` ger `system_u:system_r:httpd_t:s0` för båda processerna, så httpd körs i sin egen domän.
