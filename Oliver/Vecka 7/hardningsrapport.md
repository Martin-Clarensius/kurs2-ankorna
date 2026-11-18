# Härdningsrapport – labbserver Elev 29

**Datum:** 2026-11-18
**Underlag:** AI-utkast (se `rasvar.md`), granskat påstående för påstående mot servern. Domar och belägg finns i rättelseloggen i `metodbilaga.md`.
**Maskning:** Alla interna adresser är ersatta med `ADRESS-BORTTAGEN` och loggserverns namn med `LOGGSERVER-BORTTAGEN`.

Varje påstående har ett nummer (P = från AI-utkastet, N = nytt fynd vid granskningen), en dom och kommandot som avgjorde den.

---

## 1. Sammanfattning

Servern kör SELinux i tvingande läge med en egen policy för tjänsten zonvakt, och brandväggen nftables stoppar all trafik som inte uttryckligen är tillåten, både in och ut. Verifieringsskriptet ger 10 av 10 GÄLLER och brandväggstestet 9 PASS, 0 FAIL.

Granskningen hittade en allvarlig avvikelse: **den krypterade loggningen till den centrala loggservern fungerar inte**, eftersom brandväggen saknar en regel för tcp/6514. AI-utkastet påstod att den var på plats.

| Nr | Påstående | Dom | Belägg |
|---|---|---|---|
| P1 | SELinux är aktiverat, tvingande och kör policyn `targeted`. | Stämmer | `sestatus` |
| P2 | zonvakt körs i en egen domän, `zonvakt_t`, från en egen policymodul. | Stämmer | `ps -eZ`, `semodule -l` |
| P3 | nftables är igång och startar vid omstart. Brandväggstestet gav 9 PASS, 0 FAIL. | Stämmer | `verifiera-hardning`, `brandvagg-test.sh` |
| P4 | *(rättad)* TLS-loggningen till den centrala loggservern är konfigurerad men fungerar inte, eftersom brandväggen blockerar tcp/6514. | Fel i utkastet, rättad | `nft list chain inet zon ut`, `journalctl -u rsyslog` |

## 2. Utgångsläge (SELinux-status och läge)

| Nr | Påstående | Dom | Belägg |
|---|---|---|---|
| P5 | SELinux-status är `enabled`. | Stämmer | `sestatus` → `SELinux status: enabled` |
| P6 | Läget är `enforcing` både nu och i konfigurationsfilen, och ligger alltså kvar efter omstart. | Stämmer | `sestatus` → `Current mode` och `Mode from config file: enforcing` |
| P7 | Den laddade policyn är `targeted`. | Stämmer | `sestatus` → `Loaded policy name: targeted` |
| P8 | *(rättad)* MLS är aktiverat. Processerna har lägsta nivån `s0`, och flera tjänster (sshd, crond, udev, dbus) har intervallet `s0-s0:c0.c1023`. | Delvis fel i utkastet, rättad | `sestatus`, `ps -eZ` |
| P9 | `deny_unknown` står på `allowed`: behörigheter som policyn inte definierar tillåts. | Stämmer | `sestatus` |
| P10 | Minnesskyddskontrollen står på `actual (secure)`. | Stämmer | `sestatus` |

## 3. Genomförda härdningsåtgärder

### Brandvägg

| Nr | Påstående | Dom | Belägg |
|---|---|---|---|
| P11 | nftables använder tabellen `inet zon` med kedjorna `in` och `ut`, båda med `policy drop`. | Stämmer | `nft list chain inet zon in` / `ut` |
| P12 | nftables startar automatiskt vid uppstart. | Stämmer | `verifiera-hardning` → `GÄLLER: nftables startas vid omstart` |
| P13 | Utgående trafik är begränsad: svarstrafik, DHCP, DNS mot tillåten resolver och HTTPS släpps igenom; SSH ut och främmande DNS blockeras. | Stämmer | `brandvagg-test.sh` |
| P14 | Inkommande tcp/7529 (zonvakt) tillåts bara från en adress. | Stämmer | `nft list chain inet zon in` → `ip saddr ADRESS-BORTTAGEN tcp dport 7529 accept` |
| P15 | *(rättad)* Utgående tcp/6514 är **inte** tillåten. Bara tcp/514 till två loggservrar (D5, F4) är öppen. | Fel i utkastet, rättad | `nft list chain inet zon ut` |
| P16 | Regeländringar görs med backup, automatisk återställning via timer och syntaxkontroll (`nft -c`). | Stämmer | `history \| grep -E 'systemd-run\|nft -c'` |
| P36 | *(rättad)* SSH in tillåts bara från jump (D1), CTF (D2) och Management-nätet /28 (F6). | Fel i utkastet, rättad | `nft list chain inet zon in` |

### Loggning

| Nr | Påstående | Dom | Belägg |
|---|---|---|---|
| P17 | *(rättad)* rsyslog är konfigurerad för TLS (gtls, kontroll av mottagaren med x509/name och egen CA), men varje anslutningsförsök till tcp/6514 får `Connection timed out`. Loggarna köas lokalt (upp till 100 MB). | Fel i utkastet, rättad | `cat /etc/rsyslog.d/70-workshop2-tls.conf`, `journalctl -u rsyslog` |
| P18 | Brandväggen loggar stoppad trafik (`DB-IN-DROP`, `DB-UT-DROP`), högst 10 rader per minut. | Stämmer, med reservation (se N1) | `nft list chain inet zon in` / `ut` |
| P19 | auditd är igång. | Stämmer | `ps -eZ` → `auditd` i `auditd_t` |

### SELinux

| Nr | Påstående | Dom | Belägg |
|---|---|---|---|
| P20 | `/srv/zonwebb` har en bestående fcontext-regel `httpd_sys_content_t`, och `kvitto.txt` har den kontexten. | Stämmer | `verifiera-hardning` |
| P21 | En egen policymodul för zonvakt är installerad. | Stämmer | `semodule -l` → `zonvakt` |
| P22 | Domänen `zonvakt_t` är inte permissiv. | Stämmer | `verifiera-hardning` |
| P23 | dontaudit-reglerna är återställda efter felsökningen. | Stämmer | `sesearch --dontaudit \| wc -l` → `8539` |
| P24 | zonvakt startar automatiskt vid uppstart. | Stämmer | `systemctl is-enabled zonvakt` → `enabled` |

## 4. Verifiering

| Nr | Påstående | Dom | Belägg |
|---|---|---|---|
| P25 | SELinux är tvingande både nu och i konfigurationen. | Stämmer | `sestatus` |
| P26 | Modulen `zonvakt` finns bland de installerade modulerna. | Stämmer | `semodule -l` |
| P27 | Modulen `permissivedomains` är en standardmodul. Ingen modul av typen `permissive_<domän>` finns. | Stämmer | `semodule -l` |
| P28 | zonvakt (PID 1002) körs som `system_u:system_r:zonvakt_t:s0`. | Stämmer | `ps -eZ` |
| P29 | Webbservern körs i `httpd_t` (fem processer). | Stämmer | `ps -eZ` |
| P30 | Processer i `unconfined_t` finns bara i den inloggade användarens session. | Stämmer | `ps -eZ` |
| P31 | Inga processer körs i `unconfined_service_t`. | Stämmer | `ps -eZ` |
| P32 | zonvakt lyssnar på tcp/7529. | Stämmer | `verifiera-hardning` |
| P33 | Verifieringsskriptet ger 10 av 10 GÄLLER. | Stämmer | `verifiera-hardning` |
| P34 | Brandväggstestet ger 9 PASS, 0 FAIL. | Stämmer | `brandvagg-test.sh` |
| P35 | Verifieringsskriptet kontrollerar inte 7529-regeln, loggningen eller om zonvakt startar vid uppstart. | Stämmer | `verifiera-hardning` (listan över kontroller) |

## 5. Avvikelser och kvarstående risker

| Nr | Påstående | Dom | Belägg |
|---|---|---|---|
| A1 | **Krypterad central loggning fungerar inte.** rsyslog försöker nå loggservern på tcp/6514, men ut-kedjan har `policy drop` och ingen regel för 6514. Händelser från servern når inte loggservern, och om kön (100 MB) blir full förloras loggar. (Ersätter P37–P38 i utkastet.) | Belagd | `nft list chain inet zon ut`, `journalctl -u rsyslog` → `cannot connect to ADRESS-BORTTAGEN:6514 ... Connection timed out` |
| N1 | **Missvisande brandväggslogg.** Loggraden `DB-IN-DROP` ligger före D9-regeln (tcp/7529). Tillåten zonvakt-trafik loggas därför som "DROP" innan den släpps in. | Belagd | `nft list chain inet zon in` (ordningen på de två sista raderna) |
| N2 | **Radnummer i kommandohistoriken är inte stabila belägg.** Samma kommando hade ett annat nummer senare samma dag (465 → 442, 467 → 444), eftersom `history` tar bort de äldsta raderna. Härdningslistan har därför bytt till kommandon som belägg. | Belagd | `history \| grep -E 'systemd-run\|nft -c'` jämfört med tidigare utdrag |
| P39 | Del C i brandväggstestet räknar en misslyckad anslutning som PASS, vilket också kan bero på att målet var onåbart. | Stämmer | `brandvagg-test.sh` |
| P40 | `deny_unknown` står på `allowed`. Det är standard men innebär att odefinierade behörigheter tillåts. | Stämmer | `sestatus` |
| P42 | Underlaget omfattar inte SSH-konfigurationen, användare och sudo-rättigheter eller uppdateringsstatus. | Stämmer | Innehållet i inmatningspaketet |
| Ö1 | Det är inte kontrollerat om rsyslog också skickar loggar **okrypterat** på tcp/514 (som brandväggen tillåter). | Ogrundat, ej kontrollerat | – |

## 6. Rekommendationer

| Nr | Rekommendation | Varför |
|---|---|---|
| R1 | Lägg till en regel i ut-kedjan som tillåter tcp/6514 till loggservern, **ovanför** loggraden `DB-UT-DROP`, och spara den i `/etc/sysconfig/nftables.conf`. Använd backup och rollback-timer som tidigare. | Rättar A1 |
| R2 | Flytta D9-regeln (tcp/7529) ovanför loggraden `DB-IN-DROP`. | Rättar N1 |
| R3 | Utöka `verifiera-hardning` med kontroller av 7529-regeln, att rsyslog når loggservern på 6514 och `systemctl is-enabled zonvakt`. | P35: felet i A1 hade upptäckts automatiskt |
| R4 | Belägg åtgärder med kommando och utdata, inte med radnummer i historiken. | N2 |
| R5 | Kontrollera om loggar skickas okrypterat på tcp/514: `sudo grep -rn '514' /etc/rsyslog.conf /etc/rsyslog.d/`. | Ö1 |
