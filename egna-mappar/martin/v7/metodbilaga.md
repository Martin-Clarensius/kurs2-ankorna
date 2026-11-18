# Metodbilaga – vecka 7 (workshop 2)

Ansvarig: elev-34 (Martin)
AI-verktyg: Claude
Datum: 2026-11-18

Metodbilagan beskriver hur jag använde AI-stöd för att ta fram ett utkast till härdningsrapporten för elev-34. Prompten och råsvaret är sparade oredigerade. Allt jag ändrade finns i rättelseloggen.

---

## 1. Underlag som matades in

Allt är utdata från min egen server elev-34, hämtat 2026-11-18 ca 11:37 (svensk tid). Inget värde maskerades, eftersom utdatan inte innehöll nycklar, lösenord, tokens, flaggor eller icke-publika adresser.

| Nr | Kommando / fil | Maskerat? |
|---|---|---|
| 1 | `sestatus` (utdrag) | Nej |
| 2 | `sudo semodule -l \| grep zonvakt` | Nej |
| 3 | `ps -eZ \| grep zonvakt` | Nej |
| 4 | `sudo semanage permissive -l \| grep zonvakt` (ingen utdata) | Nej |
| 5 | `sudo semanage fcontext -l -C` | Nej |
| 6 | `sudo semanage port -l \| grep zonvakt` | Nej |
| 7 | `sudo sesearch -A -s zonvakt_t -c tcp_socket -p name_bind` | Nej |
| 8 | `ls -Z /usr/local/bin/zonvakt /var/log/zonvakt/zonvakt.log /srv/zonwebb` | Nej |
| 9 | `sudo /usr/local/bin/verifiera-hardning; echo "slutkod $?"` | Nej |
| 10 | `zonvakt.fc` | Nej |
| 11 | `zonvakt.te` (utan kommentarsrader) | Nej |

Dessutom matade jag in en lista över mina genomförda åtgärder (U7.1–U7.6), se prompten nedan.

---

## 2. Prompt (ordagrant)

```text
Skriv ett utkast till en härdningsrapport för min server elev-34 (Rocky Linux, SELinux targeted). Numrera varje påstående (P1, P2, P3 …) så att jag kan döma dem ett i taget. Rapporten ska beskriva varje åtgärd, dess effekt och hur den verifierades.

Mina genomförda åtgärder (U7.1–U7.6):
1. SELinux i tvingande läge nu och efter omstart
2. /srv/zonwebb serveras av httpd med en bestående fcontext-regel
3. Tjänsten zonvakt körs under en egen tvingande policy (domänen zonvakt_t)
4. Porten 7534 har en egen porttyp (zonvakt_port_t) och zonvakt_t får bara binda den
5. Verifieringsskriptet /usr/local/bin/verifiera-hardning läser av tillståndet

Underlag (utdata från min server, inget maskerat – inga hemligheter fanns i utdatan):

$ sestatus
SELinux status: enabled
Loaded policy name: targeted
Current mode: enforcing
Mode from config file: enforcing
Policy MLS status: enabled
Policy deny_unknown status: allowed
Memory protection checking: actual (secure)
Max kernel policy version: 33

$ sudo semodule -l | grep zonvakt
zonvakt

$ ps -eZ | grep zonvakt
system_u:system_r:zonvakt_t:s0  2411 ?  00:00:00 zonvakt

$ sudo semanage permissive -l | grep zonvakt
(ingen utdata)

$ sudo semanage fcontext -l -C
/srv/zonwebb(/.*)?   all files   system_u:object_r:httpd_sys_content_t:s0

$ sudo semanage port -l | grep zonvakt
zonvakt_port_t   tcp   7534

$ sudo sesearch -A -s zonvakt_t -c tcp_socket -p name_bind
allow zonvakt_t zonvakt_port_t:tcp_socket name_bind;

$ ls -Z /usr/local/bin/zonvakt /var/log/zonvakt/zonvakt.log /srv/zonwebb
system_u:object_r:zonvakt_exec_t:s0 /usr/local/bin/zonvakt
system_u:object_r:zonvakt_log_t:s0 /var/log/zonvakt/zonvakt.log
/srv/zonwebb: unconfined_u:object_r:httpd_sys_content_t:s0 kvitto.txt

$ sudo /usr/local/bin/verifiera-hardning; echo "slutkod $?"
GÄLLER SELinux i tvingande läge nu (getenforce = Enforcing)
GÄLLER SELinux enforcing efter omstart (/etc/selinux/config)
GÄLLER zonvakt kör i egen domän zonvakt_t
GÄLLER zonvakt-domänen är inte permissiv
GÄLLER /srv/zonwebb har bestående fcontext-regel
slutkod 0

$ cat zonvakt.fc
/usr/local/bin/zonvakt -- gen_context(system_u:object_r:zonvakt_exec_t,s0)
/var/log/zonvakt(/.*)?    gen_context(system_u:object_r:zonvakt_log_t,s0)

$ grep -v '^#' zonvakt.te | grep .
policy_module(zonvakt, 1.0.0)
type zonvakt_t;
type zonvakt_exec_t;
init_daemon_domain(zonvakt_t, zonvakt_exec_t)
type zonvakt_log_t;
type zonvakt_port_t;
corenet_port(zonvakt_port_t)
logging_log_file(zonvakt_log_t)
allow zonvakt_t self:fifo_file rw_fifo_file_perms;
allow zonvakt_t self:unix_stream_socket create_stream_socket_perms;
manage_dirs_pattern(zonvakt_t, zonvakt_log_t, zonvakt_log_t)
manage_files_pattern(zonvakt_t, zonvakt_log_t, zonvakt_log_t)
manage_lnk_files_pattern(zonvakt_t, zonvakt_log_t, zonvakt_log_t)
logging_log_filetrans(zonvakt_t, zonvakt_log_t, { dir file lnk_file })
domain_use_interactive_fds(zonvakt_t)
files_read_etc_files(zonvakt_t)
miscfiles_read_localization(zonvakt_t)
allow zonvakt_t self:tcp_socket { accept bind create getattr listen read setopt write };
corenet_tcp_bind_generic_node(zonvakt_t)
allow zonvakt_t zonvakt_port_t:tcp_socket name_bind;
corecmd_mmap_bin_files(zonvakt_t)
auth_read_passwd_file(zonvakt_t)
sssd_read_public_files(zonvakt_t)
sssd_search_lib(zonvakt_t)
```

---

## 3. Råsvar (oredigerat)

```text
# Härdningsrapport – elev-34 (utkast)

## Sammanfattning
**P1.** Servern elev-34 kör Rocky Linux med SELinux i läget enforcing och policyn targeted. Fem åtgärder är genomförda: SELinux-läget, en bestående filkontext för `/srv/zonwebb`, tjänsten zonvakt under en egen policy, en egen porttyp för zonvakt och ett verifieringsskript.

## Åtgärd 1 – SELinux i tvingande läge, nu och efter omstart
**P2.** Åtgärd: SELinux står i läget Enforcing just nu, och `/etc/selinux/config` har `SELINUX=enforcing`.

**P3.** Effekt: överträdelser stoppas och loggas, även för processer som körs som root. Inget tillåts bara för att det loggas.

**P4.** Verifiering: `sestatus` visar `Current mode: enforcing` och `Mode from config file: enforcing`. Skriptet `verifiera-hardning` ger `GÄLLER` för båda kontrollerna.

**P5.** Läget består efter omstart, eftersom konfigurationsfilen är det som läses vid start.

## Åtgärd 2 – Bestående filkontext för /srv/zonwebb
**P6.** Åtgärd: en regel med `semanage fcontext` ger `/srv/zonwebb(/.*)?` typen `httpd_sys_content_t`.

**P7.** Effekt: httpd får läsa filerna i katalogen under tvingande läge. Eftersom regeln är sparad i policyn återställs typen inte av `restorecon` eller en relabel, vilket hade hänt med `chcon`.

**P8.** Verifiering: `semanage fcontext -l -C` visar regeln, och `ls -Z` visar att `kvitto.txt` har `httpd_sys_content_t`. Skriptet kontrollerar att regeln finns.

## Åtgärd 3 – zonvakt under en egen policy
**P9.** Åtgärd: zonvakt körs under en egen policymodul. Programfilen har typen `zonvakt_exec_t`, loggen har `zonvakt_log_t` och processen kör i domänen `zonvakt_t`.

**P10.** Verifiering: `semodule -l` visar modulen `zonvakt`, och `ps -eZ` visar `zonvakt_t` för processen (PID 2411).

**P11.** Domänen är inte permissiv: `semanage permissive -l` ger ingen träff för zonvakt, och raden `permissive zonvakt_t;` finns inte i `zonvakt.te`.

**P12.** Effekt: zonvakt begränsas till det policyn tillåter, och ett försök att skriva i `/etc` nekas även om tjänsten körs som root.

**P13.** Policyn är medvetet snävad: `files_manage_etc_files` och `corecmd_exec_bin` finns inte i `zonvakt.te`, så tjänsten får varken hantera filer i `/etc` eller köra godtyckliga program i `bin_t`.

## Åtgärd 4 – Egen porttyp för zonvakt
**P14.** Åtgärd: porten 7534 är märkt med den egna typen `zonvakt_port_t` via `semanage port`. Den generella regeln `corenet_tcp_bind_generic_port` är ersatt med `allow zonvakt_t zonvakt_port_t:tcp_socket name_bind;`.

**P15.** Effekt: zonvakt_t får bara binda port 7534, och tjänsten startar inte på någon annan port.

**P16.** Verifiering: `semanage port -l | grep zonvakt` visar `zonvakt_port_t tcp 7534`. `sesearch -A -s zonvakt_t -c tcp_socket -p name_bind` visar bara regeln för `zonvakt_port_t`.

## Åtgärd 5 – Verifieringsskript
**P17.** Åtgärd: `/usr/local/bin/verifiera-hardning` läser av tillståndet och ändrar ingenting. Det gör fem kontroller, skriver `GÄLLER` eller `GÄLLER INTE` för var och en och avslutar med kod 0 om allt gäller.

**P18.** Verifiering: körningen gav fem `GÄLLER` och `slutkod 0`, och skriptet fungerar efter omstart.

**P19.** Skriptet täcker åtgärd 1–3 (SELinux-läget, zonvakt_t, ej permissiv och fcontext-regeln) men inte porttypen i åtgärd 4.

## Slutsats
**P20.** Servern har SELinux verifierat i tvingande läge och minst en egen tjänst under en egen policy. Det begränsar skadan om zonvakt eller httpd skulle kapas.
```

---

## 4. Rättelselogg

En rad per ändrat påstående. Jag dömde alla 20 påståenden mot servern (belägg per påstående finns i `hardningsrapport.md`). 17 stämde oförändrade, och 3 rättades.

| Påst. nr | Påstående (kort) | Dom | Kommando som avgjorde | Faktiskt utfall | Feltyp | Ändrat till |
|---|---|---|---|---|---|---|
| P13 | "Tjänsten får varken hantera filer i `/etc` eller köra godtyckliga program i `bin_t`" | Fel (andra halvan) | `sudo sesearch -A -s zonvakt_t -t bin_t -c file` | `allow zonvakt_t bin_t:file { execute map };`. Tjänsten har alltså `execute` och `map` på `bin_t`. För `etc_t` finns bara läsrättigheter | Överdrift | "zonvakt_t får bara läsa i `/etc` och har `execute` och `map` på `bin_t`, vilket Python-tolken behöver" |
| P15 | "Tjänsten startar inte på någon annan port" | Ogrundat (delen "startar inte") | `sudo ausearch -m avc -c zonvakt -ts recent -i` efter `port=7600` | `avc: denied { name_bind } ... src=7600 ... tclass=tcp_socket permissive=0` och `bind success=no exit=EACCES`. `systemctl is-active` skrev dock `active` direkt efter omstarten, så "startar inte" är inte belagt | Överdrift | "På en annan port nekas `bind` av SELinux, så tjänsten kan inte lyssna där" |
| P10 | "`ps -eZ` visar `zonvakt_t` för processen (PID 2411)" | Stämmer, men PID:et var inaktuellt | `systemctl status zonvakt --no-pager` | `Main PID: 2998`, eftersom tjänsten startades om under porttestet | Inaktuellt | "PID 2411 vid körningen kl. 11:37, PID 2998 efter omstarten under porttestet" |

---

## 5. Utelämningslista

Det här matade jag medvetet inte in i AI:n. Orsakerna ska bekräftas av mig innan jag pushar.

- **CTF-flaggorna för U7.1–U7.6:** de är personliga, och studieguidens regel "Mata aldrig in" gäller.
- **Kvittots innehåll (`/srv/zonwebb/kvitto.txt`):** det är mitt personliga kvitto. Jag visade bara filnamnet och typen (`ls -Z`) och statuskoden från `curl`.
- **Lösenord, SSH-nycklar och lösenfras:** studieguidens regel "Mata aldrig in" gäller.
- **Övriga filer (nftables-regelverk, loggar, `audit.log`):** de hör inte till de fem åtgärderna i rapporten.
