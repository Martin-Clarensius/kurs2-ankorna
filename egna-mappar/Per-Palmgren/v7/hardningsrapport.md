# Härdningsrapport – elev-33

**Server:** elev-33 (10.40.2.99), management-zonen, team Ankorna
**Granskad:** 2026-11-18
**Underlag:** utdata från servern i [belagg.md](belagg.md) (B1–B12), regelfilen [zon.nft](../brandvägg/cfg/zon.nft) och tidigare dokumentation i [loggning.md](../loggning.md) och [v6](../v6/detektioner-och-playbooks.md). Hur AI användes beskrivs i [metodbilaga.md](metodbilaga.md). Arbetslistan med alla radnummer ur historiken finns i [hardningslista.md](hardningslista.md).

## Domar

| Dom | Betydelse |
|---|---|
| **Stämmer** | Bekräftat med utdata från servern idag (B1–B9, B12) |
| **Stämmer (historik)** | Kommandot finns i historiken (B10–B11), men utdatan är inte med i rapporten |
| **Stämmer (v5)** | Bekräftat med utdata från servern vecka 5, dokumenterad i [loggning.md](../loggning.md). Inte kontrollerat igen idag |
| **Delvis** | Åtgärden finns, men den är svagare än påståendet |
| **Stämmer inte** | Utdatan visar motsatsen |
| **Ej verifierad** | Inget belägg |

## Sammanfattning

Av 33 påståenden stämmer 21 enligt utdata från servern idag, 4 enligt historiken och 2 enligt utdata från vecka 5. 3 stämmer delvis, 1 stämmer inte och 2 är inte verifierade. Den största bristen är att SSH tillåter lösenordsinloggning (P29). Fem fel är rättade, se [Rättelselogg](#rättelselogg).

## 1. Brandvägg (nftables)

| # | Påstående | Dom | Belägg |
|---|---|---|---|
| P1 | nftables är det enda paketfiltret. Regelsetet består av tabellen `inet zon` med kedjorna `in` och `ut` | Stämmer | B1: en tabell, `inet zon`. B5: `firewalld.service: No such file or directory` |
| P2 | Båda kedjorna har `policy drop` | Stämmer | B1: `hook input ... policy drop`, `hook output ... policy drop` |
| P3 | Reglerna laddas vid start från `/etc/nftables/zon.nft` | Stämmer | B2: `include "/etc/nftables/zon.nft"`. B5: nftables `enabled` |
| P4 | Startkonfigurationen är syntaktiskt korrekt | Stämmer | B4: `SYNTAX-OK` |
| P5 | Reglerna överlever omstart | Stämmer | B10: omstart rad 912 och 962, kontroll 967–970. B1 visar reglerna som lades till före omstarten (7533, 80) |
| P6 | In: SSH bara från jump 172.20.1.2 (D1) och ctf 172.20.1.10 (D2) | Stämmer | B1: `ip saddr 172.20.1.2 tcp dport 22 accept`, `ip saddr 172.20.1.10 tcp dport 22 accept`. Ingen annan regel för port 22 i `in` |
| P7 | In: zonvakt tcp/7533 och httpd tcp/80 bara från ctf 172.20.1.10 | Stämmer | B1: `ip saddr 172.20.1.10 tcp dport 7533 accept comment "zonvakt"`, `ip saddr 172.20.1.10 tcp dport 80 accept comment "F2 Httpd"`. Anmärkning: kommentaren "F2" stämmer inte med flödestabellen, se K3. Rättat 2026-11-23: kommentarerna är nu `"D9 zonvakt"` och `"D8 Httpd"` |
| P8 | In: DHCP-svar udp 67→68 (D6) | Stämmer | B1: `udp sport 67 udp dport 68 accept comment "D6 DHCP-svar"` |
| P9 | Ut: SSH bara till Web/App/Data/Logg-zonerna. Admin-zonen och internet blockeras (F6) | Stämmer | B1: `ip daddr { 10.40.2.0-10.40.2.95 } tcp dport 22 accept`. Admin-zonen 10.40.2.96/28 ligger utanför intervallet |
| P10 | Ut: DNS bara till 185.12.64.1 och .2. Främmande DNS blockeras (D3) | Stämmer | B1: `ip daddr { 185.12.64.1, 185.12.64.2 } ... th dport 53 accept`. Ingen annan regel för port 53 |
| P11 | Ut: NTP bara till tillåten tidsserver (D4) | Delvis | B1: `oifname "eth0" udp dport 123 accept`. Gäller alla adresser via eth0, se K4 |
| P12 | Ut: HTTPS bara för paketuppdateringar (D7). HTTP blockeras | Delvis | B1: `oifname "eth0" tcp dport 443 accept`. Gäller alla adresser via eth0, se K4. Ingen regel för port 80 ut, så HTTP blockeras. Rättat 2026-11-23: D7 gäller bara 146.75.122.132 (Rockys paketserver) |
| P13 | Ut: syslog över TLS tcp/6514 bara till loggservern. Ingen okrypterad 514 | Stämmer | B1: `ip daddr 172.20.1.58 tcp dport 6514 accept`. Ingen regel för 514 |
| P14 | Den tillfälliga regeln för tcp/80 till loggservern (för att hämta CA:n) är borta | Stämmer | B11: inlagd rad 348–349. B1: ingen regel med `dport 80` i `ut` |
| P15 | Avvisad trafik loggas med begränsning och prefix | Stämmer | B1: `limit rate 10/minute burst 5 packets log prefix "ZON-IN-DROP "` och `"ZON-UT-DROP "` |
| P16 | Brandväggen är testad mot flödestabellens testfall | Stämmer (historik) | B11: `./test.sh testfall.csv` rad 156 och 559. Testfallen finns i [testfall/](../brandvägg/testfall/) |

## 2. Loggning

| # | Påstående | Dom | Belägg |
|---|---|---|---|
| P17 | rsyslog och auditd startar vid uppstart | Stämmer | B5: `enabled`, `enabled` |
| P18 | rsyslog skickar alla loggar över TLS till `log.sec.chas-lab.dev:6514` | Stämmer | B6: `90-tls-forward.conf` finns i `/etc/rsyslog.d/`. Innehållet är [repots kopia](../brandvägg/cfg/90-tls-forward.conf), visad på servern rad 297 (B10) |
| P19 | Namnet i rsyslog och adressen i brandväggen pekar på samma server | Stämmer | B8: `172.20.1.58 log.sec.chas-lab.dev`. B1: D5-regeln gäller 172.20.1.58 |
| P20 | Ingen okrypterad vidarebefordran av loggar finns kvar | Stämmer | B6: bara `21-cloudinit.conf` och `90-tls-forward.conf`. B11: `60-brandvagg.conf` togs bort rad 411 |
| P21 | CA-filen kan bara ändras av root och har rätt SELinux-typ | Stämmer | B7: katalogen `drwx------ root root`, `ca.pem` `-rw-r--r-- root root ... cert_t` |
| P22 | CA:n hämtades från loggservern och TLS-anslutningen verifierades | Stämmer (historik) | B10: hämtning rad 351 och 361, fingeravtryck 352, `openssl s_client` 355 |
| P23 | TLS-modulen för rsyslog är installerad | Stämmer (historik) | B10: `rpm -q rsyslog-gnutls` och `lmnsd_gtls.so` rad 587–588 och 596–597 |
| P24 | auditd loggar root-kommandon med nyckeln `root_cmd` | Stämmer (historik) | B10: `auditctl -l` rad 87, 103–104, 289, 517, 657. B11: `ausearch -k root_cmd` 109–110. Monitorn D3 larmade 2026-11-16 ([v6](../v6/detektioner-och-playbooks.md)) |
| P25 | auditd roterar loggen (`max_log_file = 8`, `num_logs = 5`, `ROTATE`). Loggfilerna ägs av root med `-rw-------` | Stämmer (v5) | [loggning.md](../loggning.md), avsnitt 1 och 3 |
| P26 | Loggarna når loggservern | Stämmer (v5) | [loggning.md](../loggning.md): `sparc6e7feb6` hittad med loggsök. Monitorerna D1, D3, D4 och D5 larmar på poster från elev-33 ([v6](../v6/detektioner-och-playbooks.md)) |
| P27 | Loggkedjan fungerar efter omstart (TLS-anslutning uppe, `root_cmd` laddad) | Ej verifierad | P17 visar bara att tjänsterna startar. Kontrolleras med `sudo auditctl -l \| grep root_cmd` och `ss -tn dst 172.20.1.58:6514` efter nästa omstart |

## 3. SELinux

| # | Påstående | Dom | Belägg |
|---|---|---|---|
| P28a | SELinux är i läge Enforcing, även efter omstart | Stämmer | B12: `GÄLLER: SELinux är i tvingande läge`. B10: `getenforce` rad 677, 751, 963 (efter omstart) och 1060. Skriptet kontrollerar `Enforcing` (rad 894) |
| P28b | zonvakt kör i en egen tvingande domän `zonvakt_t`, inte permissive | Stämmer | B12: `GÄLLER: Modulen zonvakt är laddad i policyn`, `GÄLLER: Domänen zonvakt_t är inte permissiv`. B11: `semodule -i zonvakt.pp` rad 844, 871, 950. `semodule -l \| grep zonvakt` 845. `ps -eZ \| grep zonvakt` 965 (efter omstart) och 1062. B10: kontrollen mot permissive rad 900. Utdata sparad i `~/ai-mapp/Verifierad/` (rad 1002–1014), inte i repot |
| P28c | `/srv/zonwebb` är märkt `httpd_sys_content_t` med en bestående regel | Stämmer | B12: `GÄLLER: /srv/zonwebb har bestående regel och kontexten httpd_sys_content_t`. B10: `semanage fcontext -a` rad 765, `restorecon` 766, 769 och 791. Skriptet kontrollerar regeln (rad 903) |

## 4. SSH

| # | Påstående | Dom | Belägg |
|---|---|---|---|
| P29 | SSH är härdat: ingen lösenordsinloggning och ingen root-inloggning | Stämmer inte | B9: `passwordauthentication yes`, `permitrootlogin without-password`. Root kan bara logga in med nyckel, men vanliga konton kan logga in med lösenord. Idag skyddar bara brandväggen (P6). Se K1 |

## 5. Verifiering

| # | Påstående | Dom | Belägg |
|---|---|---|---|
| P30 | `/usr/local/bin/verifiera-hardning` kontrollerar Enforcing, permissive, filkontext och brandväggsregeln för zonvakt | Delvis | B12: alla fem kontroller ger `GÄLLER`. B10: kontrollerna rad 894–908. Kontroll 5 (`grep -q '172.20.1.10'`) lyckas också på D2-regeln (SSH från ctf, B1), så den upptäcker inte om regeln för 7533 saknas. Se K2 |
| P31 | Molnbrandväggen `itsx26-elev-33` stämmer med nftables | Ej verifierad | Regler saknas i [v6](../v6/detektioner-och-playbooks.md#regelverket-på-elev-33-båda-lagren). Kontrolleras med `moln status` i ssh jump |

## Rättelselogg

| # | Fel | Hur det upptäcktes | Rättelse | Belägg |
|---|---|---|---|---|
| R1 | Repots `brandvägg/cfg/zon.nft` var en gammal version: tcp/514 i stället för 6514, ingen F6 eller D7, prefixet `ZONE-UT-DROP` och NTP-raden `ntp dport 123 udp`, som inte går att ladda. Filen hette likadant som regelfilen på servern | Regelsetet på servern (B1) jämfördes med repot | Repots `zon.nft` ersatt med serverns `/etc/nftables/zon.nft` (B3) | B1, B3, commit med denna rapport |
| R2 | v6-dokumentet sa att kärnloggen också skickas okrypterat på tcp/514 till 172.20.1.58 med `60-brandvagg.conf` | `/etc/rsyslog.d/` innehåller inte filen (B6), den togs bort på rad 411 (B11), och brandväggen har ingen regel för 514 (B1) | v6 rättat på två ställen: [Hur loggarna når loggservern](../v6/detektioner-och-playbooks.md) och D2:s loggkälla. Repots `60-brandvagg.conf` har fått en kommentar om att den inte används | B1, B6, B11 |
| R3 | v6 hade ett okontrollerat värde för D2: prefixet var antingen `ZONE-UT-DROP` eller `ZON-UT-DROP ` | Regelsetet på servern (B1) | Prefixet `ZON-UT-DROP ` (med mellanslag) är infört i v6 | B1 |
| R4 | Kontroll 5 i `verifiera-hardning` sökte i `inet filter input`. Efter omstart fanns den kedjan inte, så kontrollen misslyckades trots att regeln fanns | Omstartstestet: rad 967 gav ingen träff | Rättat på servern med `sed` till `nft list ruleset` (rad 973), kontrollerat rad 974. Kvarstående svaghet: se K2 | B10 |
| R5 | AI-utkastet till härdningslistan sa att reglerna står i `/etc/sysconfig/nftables.conf`. Utkastet föreslog också `history \| grep -n`, som ger grep:s radnummer och inte historikens | Utdatan B2 visar bara en `include`. Kommandoförslaget granskades innan det kördes | Rapporten anger `/etc/nftables/zon.nft` (P3). Kommandot ändrades till `history \| grep -E` innan det kördes | B2, [metodbilaga.md](metodbilaga.md) |

## Kvarstående brister och åtgärder

| # | Brist | Åtgärd | Ansvarig |
|---|---|---|---|
| K1 | SSH tillåter lösenordsinloggning (P29) | `PasswordAuthentication no` och `PermitRootLogin no` i en fil under `/etc/ssh/sshd_config.d/`. Kontrollera först nyckelinloggning via jump och att CTF-kontrollen (D2) inte använder lösenord. Kör `sshd -t` och håll en session öppen medan du testar | elev-33 |
| K2 | Kontroll 5 i `verifiera-hardning` är för bred (P30) | Sök efter `172.20.1.10 tcp dport 7533` i stället för bara adressen | elev-33 |
| K3 | Regeln för tcp/80 hade kommentaren `"F2 Httpd"` och stod som "provisorisk" i `zon.nft`. F2 i flödestabellen är webb → app på tcp 80. 8080 var bara en tillfällig testkörning med `nc -lk 8080` | **Åtgärdat 2026-11-23:** regeln är kvar och heter `"D8 Httpd"` enligt flödestabellen (D8: webbkvitto från ctf, tcp 80). Zonvaktsregeln heter `"D9 zonvakt"` och loggregeln `"F4 Logg till loggserver TLS"` (tidigare D5). Rättat på servern och i repot | elev-33 |
| K4 | NTP och HTTPS ut är tillåtna mot alla adresser via eth0 (P11, P12) | **HTTPS åtgärdat 2026-11-23:** D7 gäller bara 146.75.122.132 (Rockys paketserver), enligt flödestabellen. Kvar: begränsa NTP till kända servrar, eller skriv in undantaget i flödestabellen | elev-33 |
| K5 | Loggkedjan är inte testad efter omstart (P27) | Kör kommandona under P27 efter nästa omstart | elev-33 |
| K6 | Molnbrandväggen är inte dokumenterad (P31) | `moln status` i ssh jump | elev-33 |
