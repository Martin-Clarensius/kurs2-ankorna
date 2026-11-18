# Utkast: Härdningsrapport – labbserver (Elev 29)

*Utkast skrivet av AI-assistent utifrån det maskerade inmatningspaketet. Varje påstående är numrerat och har sin källa inom hakparentes. Påståenden som bara bygger på historikrader i härdningslistan markeras som **ej belagt i utdata**.*

---

## 1. Sammanfattning

- **P1.** SELinux är aktiverat och körs i tvingande läge (enforcing) med policyn `targeted`. [sestatus]
- **P2.** Tjänsten zonvakt körs i en egen SELinux-domän, `zonvakt_t`, som kommer från en egen policymodul. [ps-eZ, semodule, verifiering]
- **P3.** Paketfiltret nftables är igång och startar vid omstart. Brandväggstestet gav 9 PASS och 0 FAIL. [verifiering, brandvaggstest]
- **P4.** Flera åtgärder i härdningslistan, bland annat krypterad loggning, port 6514 och begränsningen av port 7529, har bara historikrader som belägg och bekräftas inte av utdata i paketet. [hardningslista]

## 2. Utgångsläge (SELinux-status och läge)

- **P5.** SELinux-status är `enabled`. [sestatus: "SELinux status: enabled"]
- **P6.** Det aktuella läget är `enforcing`, och läget i konfigurationsfilen är också `enforcing`. Det tvingande läget ligger alltså kvar efter en omstart. [sestatus: "Current mode", "Mode from config file"; verifiering rad 1–2]
- **P7.** Den laddade policyn är `targeted`. [sestatus: "Loaded policy name"]
- **P8.** MLS är aktiverat i policyn, och de listade processerna körs på nivån `s0`. [sestatus: "Policy MLS status"; ps-eZ]
- **P9.** `deny_unknown` står på `allowed`. Det betyder att behörigheter och objektklasser som policyn inte definierar tillåts i stället för att nekas. [sestatus]
- **P10.** Minnesskyddskontrollen står på `actual (secure)`. [sestatus]

## 3. Genomförda härdningsåtgärder (utifrån härdningslistan)

### Brandvägg

- **P11.** nftables används som paketfilter med tabellen `inet zon` och kedjorna `in` och `ut`. [hardningslista 1–2; brandvaggstest A: "nftables-tabellen 'zon' laddad"]
- **P12.** nftables startar automatiskt vid uppstart. [hardningslista 3; verifiering rad 9; brandvaggstest A]
- **P13.** Utgående trafik är begränsad. Svarstrafik, DHCP, DNS mot tillåten resolver och HTTPS släpps igenom, medan SSH ut och DNS mot främmande resolver blockeras. [hardningslista 4; brandvaggstest A–C]
- **P14.** Inkommande tcp/7529 (zonvakt) tillåts bara från en adress (ADRESS-BORTTAGEN). [hardningslista 5] **Ej belagt i utdata**: paketet innehåller ingen utskrift av brandväggsreglerna.
- **P15.** Utgående tcp/6514 är tillåten till en central loggserver. [hardningslista 6] **Ej belagt i utdata.**
- **P16.** Regeländringar har gjorts med backup, automatisk återställning via timer och syntaxkontroll (`nft -c`). [hardningslista 7–8] **Ej belagt i utdata**: det är en arbetsmetod och inte ett tillstånd.

### Loggning

- **P17.** rsyslog skickar loggar krypterat (TLS) till en central loggserver och kontrollerar den med en egen CA. [hardningslista 9] Processen `rsyslogd` körs i domänen `syslogd_t` [ps-eZ], men **TLS, mottagare och CA är ej belagda i utdata**.
- **P18.** Brandväggen loggar stoppad trafik. [hardningslista 10] **Ej belagt i utdata.**
- **P19.** auditd är igång. [hardningslista 11; ps-eZ: `auditd` i `auditd_t`, PID 599]

### SELinux

- **P20.** Det finns en bestående fcontext-regel som märker `/srv/zonwebb` som `httpd_sys_content_t`, och filen `kvitto.txt` har den kontexten. [hardningslista 12; verifiering rad 7–8]
- **P21.** En egen policymodul för zonvakt är installerad. [hardningslista 13; semodule: `zonvakt`; verifiering rad 3]
- **P22.** Domänen `zonvakt_t` är inte permissiv. [hardningslista 14; verifiering rad 4]
- **P23.** dontaudit-reglerna stängdes av tillfälligt vid felsökning och återställdes sedan. [hardningslista 15] **Ej belagt i utdata.**
- **P24.** zonvakt startar automatiskt vid uppstart. [hardningslista 16] **Ej belagt i utdata**: ps-eZ visar att tjänsten körs, men inte att den är aktiverad för uppstart.

## 4. Verifiering

- **P25.** `sestatus` bekräftar att SELinux är aktiverat och tvingande både nu och i konfigurationen. [sestatus]
- **P26.** `semodule -l` listar modulen `zonvakt`. [semodule]
- **P27.** `semodule -l` listar också `permissivedomains`. Det är en standardmodul och betyder inte i sig att någon domän är permissiv. Ingen modul av typen `permissive_<domän>` finns i listan. [semodule]
- **P28.** Processen zonvakt (PID 1002) körs som `system_u:system_r:zonvakt_t:s0`. [ps-eZ; verifiering rad 5]
- **P29.** Webbservern körs i domänen `httpd_t` (fem httpd-processer). [ps-eZ]
- **P30.** Processer i `unconfined_t` finns bara i den inloggade användarens session (`systemd`, `sshd-session`, `bash`, `ps`), vilket är förväntat med policyn `targeted`. [ps-eZ]
- **P31.** Inga processer körs i `unconfined_service_t`. [ps-eZ]
- **P32.** zonvakt lyssnar på tcp/7529. [verifiering rad 6]
- **P33.** Verifieringsskriptet gav 10 av 10 GÄLLER. [verifiering]
- **P34.** Brandväggstestet gav 9 PASS och 0 FAIL. [brandvaggstest]
- **P35.** Verifieringsskriptet kontrollerar inte brandväggsregeln för tcp/7529, loggningen eller om zonvakt är aktiverad vid uppstart. [verifiering: listan över kontroller]

## 5. Avvikelser och kvarstående risker

- **P36.** Två punkter i härdningslistan är markerade som okontrollerade: SSH in begränsad till två adresser, och drop med loggning av en adress med prefixet `U4.2-DROP`. Deras status är okänd. [hardningslista, "Att kontrollera"]
- **P37.** Att tcp/7529 bara öppnats för en adress är inte belagt. Eftersom zonvakt lyssnar på porten [verifiering rad 6] blir tjänsten nåbar för fler än avsett om regeln saknas. [hardningslista 5]
- **P38.** Krypterad central loggning och brandväggsloggning är inte belagda i utdata. [P17, P18]
- **P39.** Del C i brandväggstestet räknar en misslyckad anslutning som PASS. Ett PASS kan därför också bero på att målet inte gick att nå av andra orsaker. [brandvaggstest C]
- **P40.** `deny_unknown` står på `allowed`. Det är vanligt som standard, men det innebär att odefinierade behörigheter tillåts. [sestatus]
- **P41.** Härdningslistans belägg är radnummer i kommandohistoriken. De visar att kommandona skrevs, inte serverns nuvarande tillstånd. [hardningslista]
- **P42.** Underlaget saknar uppgifter om SSH-konfigurationen, användare och sudo-rättigheter, och uppdateringsstatus. Rapporten kan därför inte uttala sig om dem. [hela paketet]

## 6. Rekommendationer

- **P43.** Belägg begränsningen av tcp/7529 med utdata från `sudo nft list chain inet zon in`.
- **P44.** Belägg den utgående loggningen med `sudo nft list chain inet zon ut` och `sudo grep -ri 6514 /etc/rsyslog.conf /etc/rsyslog.d/`.
- **P45.** Kontrollera och avsluta de två öppna punkterna i härdningslistan. Antingen finns reglerna kvar och ska föras in, eller så ska de strykas.
- **P46.** Belägg att zonvakt startar vid uppstart med `systemctl is-enabled zonvakt`.
- **P47.** Utöka verifieringsskriptet med kontroller av 7529-regeln, loggningen och att zonvakt är aktiverad vid uppstart.
- **P48.** Om setools finns installerat: belägg att dontaudit-reglerna är återställda, till exempel med `sudo sesearch --dontaudit | head`.
