# Metodbilaga – härdningsrapport, labbserver Elev 29

**AI-assistent:** Claude (Anthropic), via claude.ai
**Datum:** 2026-11-18

---

## 1. Underlag som matades in

### I prompten (det AI-utkastet bygger på)

| Underlag | Källa (kommando/fil) | Maskerat? |
|---|---|---|
| Härdningslista | `hardningslista.md` | Ja, adresser ersatta för hand |
| SELinux-status | `sestatus` | Ja, sed-skript (inget behövde bytas) |
| Installerade policymoduler | `sudo semodule -l` | Ja, sed-skript (inget behövde bytas) |
| Processer med SELinux-etiketter | `ps -eZ` | Ja, sed-skript (inget behövde bytas) |
| Verifieringsskriptets utdata | `sudo /usr/local/bin/verifiera-hardning` | Ja, sed-skript (inget behövde bytas) |
| Brandväggstest | `bash ~/brandvagg-test.sh` | Ja, sed-skript (inget behövde bytas) |

### Under arbetet i övrigt (samma AI-assistent, samma dag)

| Underlag | Syfte | Maskerat? |
|---|---|---|
| Utdrag ur kommandohistoriken (`history \| grep ...`) | Ta fram härdningslistan | **Nej**, se avvikelser i avsnitt 5 |
| `sudo nft list chain inet zon in` | Döma P14, P36, P37 | Ja |
| `sudo nft list chain inet zon ut \| grep -E '6514\|log'` | Döma P15, P18 | **Nej**, se avvikelser i avsnitt 5 |
| rsyslog-konfiguration och journal | Döma P17 | Ja (adress), loggserverns namn syntes |
| `systemctl is-enabled zonvakt`, `sesearch`, `history` | Döma P16, P23, P24 | Innehöll inga adresser |

**Om härdningslistan:** Listan togs fram tillsammans med AI-assistenten, som föreslog punkterna utifrån kommandohistoriken. Två av felen som granskningen hittade (P15 och P36) kom från listan och fördes vidare in i AI-utkastet. Listan är rättad efter granskningen.

---

## 2. Prompt

Prompten finns oredigerad i **`prompt.txt`** (696 rader). Den består av instruktionen nedan följd av inmatningspaketet, alltså de sex maskerade filerna i avsnitt 1.

```
Du är en assistent som hjälper en IT-säkerhetsstudent. Nedan finns ett
inmatningspaket från en härdad Linux-labbserver med SELinux. Känsliga
värden är maskerade med platshållare som LÖSENORD-BORTTAGET och
ADRESS-BORTTAGEN; behandla dem som okända och gissa inte värdena.

Skriv ett UTKAST till en härdningsrapport på svenska med rubrikerna:
1. Sammanfattning
2. Utgångsläge (SELinux-status och läge)
3. Genomförda härdningsåtgärder (utifrån härdningslistan)
4. Verifiering (vad utdata från sestatus, semodule -l, ps -eZ och
   verifieringsskriptet visar)
5. Avvikelser och kvarstående risker
6. Rekommendationer

Numrera varje påstående (P1, P2, P3 ...). Hänvisa till vilket utdrag
varje påstående bygger på. Om underlaget inte räcker för en slutsats,
skriv det i stället för att gissa.

--- INMATNINGSPAKET ---
[sex maskerade filer, se prompt.txt]
```

---

## 3. Råsvar

AI-assistentens svar finns oredigerat i **`rasvar.md`**: 48 numrerade påståenden (P1–P48) under de sex rubrikerna. Det är inte ändrat. Alla rättelser finns i den färdiga rapporten (`hardningsrapport.md`) och i rättelseloggen nedan.

---

## 4. Rättelselogg

**Domar:** Stämmer = belägget bekräftar påståendet · Fel = belägget motsäger påståendet · Delvis fel = en del stämmer inte · Inaktuell = påståendet gäller inte längre efter granskningen · Ogrundat = inget belägg.

| Påst. | Dom | Kommando som avgjorde | Utdata (utdrag) | Rättelse |
|---|---|---|---|---|
| P1 | Stämmer | `sestatus` | `SELinux status: enabled`, `Current mode: enforcing`, `Loaded policy name: targeted` | – |
| P2 | Stämmer | `ps -eZ`, `sudo semodule -l` | `system_u:system_r:zonvakt_t:s0 1002 ... zonvakt`; `zonvakt` | – |
| P3 | Stämmer | `sudo verifiera-hardning`, `bash brandvagg-test.sh` | `GÄLLER: nftables är igång just nu`; `RESULTAT: 9 PASS, 0 FAIL` | – |
| **P4** | **Fel** | Se P15 och P17 | – | TLS-loggningen är konfigurerad men fungerar inte; brandväggen blockerar tcp/6514. |
| P5 | Stämmer | `sestatus` | `SELinux status: enabled` | – |
| P6 | Stämmer | `sestatus` | `Current mode: enforcing`, `Mode from config file: enforcing` | – |
| P7 | Stämmer | `sestatus` | `Loaded policy name: targeted` | – |
| **P8** | **Delvis fel** | `ps -eZ` | `system_u:system_r:sshd_t:s0-s0:c0.c1023 991 ... sshd` | Processerna har lägsta nivån s0; flera har intervallet s0-s0:c0.c1023. |
| P9 | Stämmer | `sestatus` | `Policy deny_unknown status: allowed` | – |
| P10 | Stämmer | `sestatus` | `Memory protection checking: actual (secure)` | – |
| P11 | Stämmer | `sudo nft list chain inet zon in` / `ut` | `chain in { ... policy drop;`, `chain ut { ... policy drop;` | – |
| P12 | Stämmer | `sudo verifiera-hardning` | `GÄLLER: nftables startas vid omstart` | – |
| P13 | Stämmer | `bash brandvagg-test.sh` | `[PASS] HTTPS (443) ut fungerar`, `[PASS] SSH (22) ut blockerat` | – |
| P14 | Stämmer | `sudo nft list chain inet zon in` | `ip saddr ADRESS-BORTTAGEN tcp dport 7529 accept`; `policy drop` | – |
| **P15** | **Fel** | `sudo nft list chain inet zon ut` | `policy drop`; bara `tcp dport 514 accept` (D5, F4), ingen regel för 6514 | Utgående tcp/6514 är inte tillåten. |
| P16 | Stämmer | `history \| grep -E 'systemd-run\|nft -c'` | `nft -c -f ~/db-firewall.nft`; `systemd-run --on-active=120 --unit=fw-rollback ...` | – |
| **P17** | **Fel** | `sudo cat /etc/rsyslog.d/70-workshop2-tls.conf`; `sudo journalctl -u rsyslog --since today` | `StreamDriver="gtls"`, `port="6514"`; `cannot connect to ADRESS-BORTTAGEN:6514 ... Connection timed out` | TLS är konfigurerat men anslutningen blockeras; loggarna köas lokalt. |
| P18 | Stämmer, med reservation | `sudo nft list chain inet zon in` / `ut` | `log prefix "DB-IN-DROP "`, `log prefix "DB-UT-DROP "`, `limit rate 10/minute` | Reservation: in-loggen fångar även tillåten 7529-trafik (N1). |
| P19 | Stämmer | `ps -eZ` | `system_u:system_r:auditd_t:s0 599 ... auditd` | – |
| P20 | Stämmer | `sudo verifiera-hardning` | `GÄLLER: Bestående fcontext-regel: /srv/zonwebb -> httpd_sys_content_t` | – |
| P21 | Stämmer | `sudo semodule -l` | `zonvakt` | – |
| P22 | Stämmer | `sudo verifiera-hardning` | `GÄLLER: Domänen zonvakt_t är inte permissiv` | – |
| P23 | Stämmer | `sudo sesearch --dontaudit \| wc -l` | `8539` | – |
| P24 | Stämmer | `systemctl is-enabled zonvakt` | `enabled` | – |
| P25 | Stämmer | `sestatus` | `Current mode: enforcing`, `Mode from config file: enforcing` | – |
| P26 | Stämmer | `sudo semodule -l` | `zonvakt` | – |
| P27 | Stämmer | `sudo semodule -l` | `permissivedomains`; ingen `permissive_...`-modul | – |
| P28 | Stämmer | `ps -eZ` | `system_u:system_r:zonvakt_t:s0 1002` | – |
| P29 | Stämmer | `ps -eZ` | `httpd_t` för PID 708, 748, 749, 750, 751 | – |
| P30 | Stämmer | `ps -eZ` | `unconfined_t` bara för PID 6070, 6081, 6082, 6123 (användarens session) | – |
| P31 | Stämmer | `ps -eZ` | Inget `unconfined_service_t` | – |
| P32 | Stämmer | `sudo verifiera-hardning` | `GÄLLER: zonvakt lyssnar på tcp/7529` | – |
| P33 | Stämmer | `sudo verifiera-hardning` | 10 rader `GÄLLER`, ingen `GÄLLER INTE` | – |
| P34 | Stämmer | `bash brandvagg-test.sh` | `RESULTAT: 9 PASS, 0 FAIL` | – |
| P35 | Stämmer | `sudo verifiera-hardning` | Listan över kontroller saknar 7529-regel, loggning och `is-enabled zonvakt` | – |
| **P36** | **Fel** | `sudo nft list chain inet zon in` | `D1 SSH fran jump`, `D2 SSH fran CTF`, `ADRESS-BORTTAGEN/28 ... F6 SSH fran Management`; ingen `U4.2-DROP` | SSH från jump, CTF och Management-nätet /28. U4.2-punkten struken. |
| P37 | Inaktuell | `sudo nft list chain inet zon in` | 7529-regeln finns (se P14) | Risken bortfaller; struken. |
| **P38** | **Fel** | Se P15, P17, P18 | – | Brandväggsloggning finns; TLS-loggningen misslyckas (avvikelse A1). |
| P39 | Stämmer | `bash brandvagg-test.sh` | `C. ... (malet lyssnar, sa block = bevis)` | – |
| P40 | Stämmer | `sestatus` | `Policy deny_unknown status: allowed` | – |
| P41 | Stämmer, förstärkt | `history \| grep -E 'systemd-run\|nft -c'` | Samma kommandon hade nummer 442/444, tidigare samma dag 465/467 | Radnumren är dessutom inte stabila (N2). |
| P42 | Stämmer | Innehållet i inmatningspaketet | Ingen SSH-konfiguration, användarlista eller uppdateringsstatus | – |
| P43 | Rekommendation, genomförd | `sudo nft list chain inet zon in` | – | Ledde till P14, P36 och N1 |
| P44 | Rekommendation, genomförd | `nft list chain inet zon ut`, `grep -rn 6514 /etc/rsyslog.d/` | – | Ledde till P15 och P17 |
| P45 | Rekommendation, genomförd | `sudo nft list chain inet zon in` | – | Öppna punkter avgjorda (P36) |
| P46 | Rekommendation, genomförd | `systemctl is-enabled zonvakt` | `enabled` | – |
| P47 | Rekommendation, kvarstår | – | – | Se R3 i rapporten |
| P48 | Rekommendation, genomförd | `sudo sesearch --dontaudit \| wc -l` | `8539` | – |

**Nya fynd vid granskningen** (fanns inte i utkastet):

| Nr | Fynd | Kommando | Utdata (utdrag) |
|---|---|---|---|
| N1 | Loggraden `DB-IN-DROP` ligger före D9-regeln, så tillåten 7529-trafik loggas som DROP | `sudo nft list chain inet zon in` | `... log prefix "DB-IN-DROP " level info` följt av `... tcp dport 7529 accept comment "D9 ..."` |
| N2 | Radnummer i historiken flyttar sig och duger inte som belägg | `history \| grep -E 'systemd-run\|nft -c'` | 442/444 nu, 465/467 tidigare samma dag |

**Summering:** 48 påståenden. 6 fel eller delvis fel (P4, P8, P15, P17, P36, P38), 1 inaktuellt (P37), 2 nya fynd (N1, N2). Övriga stämmer eller är genomförda rekommendationer.

---

## 5. Utelämningslista

| Typ av uppgift | Ersatt med | Hur | Varför |
|---|---|---|---|
| Interna IP-adresser och nät (10.x, 172.16–31.x, 192.168.x) | `ADRESS-BORTTAGEN` | sed-skript, och för hand i härdningslistan | Inte publika adresser |
| Lösenord (`password=`, `lösenord=` ...) | `LÖSENORD-BORTTAGET` | sed-skript (inga träffar) | Hemliga uppgifter |
| Tokens, API-nycklar, secrets | `TOKEN-BORTTAGEN` | sed-skript (inga träffar) | Hemliga uppgifter |
| Privata nycklar | `NYCKEL-BORTTAGEN` | sed-skript (inga träffar) | Hemliga uppgifter |
| Loggserverns DNS-namn | `LOGGSERVER-BORTTAGEN` | För hand i rapporten | Skolans interna server |
| Värdnamn (`elev-29`) | [Behölls / maskerades – fyll i parets beslut] | | |

**Kontroll efter maskering:**
- `wc -l ra/* maskerat/*`: samma antal rader före och efter, så inga rader togs bort.
- `diff ra/ maskerat/`: inga skillnader. Utdragen innehöll inga adresser eller hemligheter, och härdningslistan var redan maskerad för hand.
- `grep -nEi 'pass|token|key|secret|flag|IP-mönster' maskerat/*`: bara ofarliga träffar (`[PASS]` och modulnamn som `keystone` och `passenger`).

**Avvikelser från regeln "Mata aldrig in":**
1. Utdrag ur kommandohistoriken skickades till AI-assistenten med interna adresser omaskerade. Inga lösenord fanns med.
2. Utdata från `sudo nft list chain inet zon ut` skickades omaskerad (två interna adresser), eftersom AI-assistentens föreslagna kommando saknade maskning på den raden. Upptäcktes direkt, och resten av arbetet maskerades.
3. Loggserverns DNS-namn syntes i rsyslog-konfigurationen som skickades till AI-assistenten.
4. [Lägg till eller stryk: CTF-flaggan i U7.4 skickades omaskerad till AI-assistenten samma dag, i en annan uppgift.]

**Lärdom:** Maskningen bör sitta i *varje* kommando vars utdata ska till en AI, inte bara i paketet. Ett sätt är att lägga tvättreglerna i en variabel (`M='...'`) och alltid avsluta med `| sed -E "$M"`.
