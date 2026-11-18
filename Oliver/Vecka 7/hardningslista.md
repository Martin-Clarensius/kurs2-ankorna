# Härdningslista – labbserver Elev 29

## Hur listan ska läsas

| Spalt | Betyder |
|---|---|
| **Åtgärd** | Vad som gjorts på servern |
| **Enkelt förklarat** | Vad det betyder och varför det gör servern säkrare |
| **Belägg** | Kommandot som visar att åtgärden finns på servern just nu |
| **Status** | ✅ fungerar enligt belägget · ⚠️ avvikelse, se härdningsrapporten |

Senast kontrollerad: 2026-11-18. Alla adresser är ersatta med `ADRESS-BORTTAGEN`.

---

## 1. Brandvägg (nftables)

| # | Åtgärd | Enkelt förklarat | Belägg | Status |
|---|---|---|---|---|
| 1 | nftables används som paketfilter | Brandväggen är grinden som bestämmer vilken nätverkstrafik som får komma in och ut. | `systemctl is-active nftables` | ✅ |
| 2 | Reglerna ligger i tabellen `inet zon` med kedjorna `in` och `ut`, båda med `policy drop` | Allt som inte uttryckligen är tillåtet stoppas, både in och ut. | `sudo nft list chain inet zon in` / `ut` | ✅ |
| 3 | nftables startar automatiskt | Brandväggen slås på av sig själv när servern startar, så att den aldrig står oskyddad efter en omstart. | `systemctl is-enabled nftables` | ✅ |
| 4 | SSH in bara från jump, CTF och Management-nätet (/28) | Bara tre utvalda källor får logga in med SSH. Alla andra stoppas. | `sudo nft list chain inet zon in` (D1, D2, F6) | ✅ |
| 5 | Port 7529 (zonvakt) öppen bara för en adress | Bara en utvald dator får ansluta till zonvakt. | `sudo nft list chain inet zon in` (D9) | ✅ |
| 6 | Utgående trafik är begränsad | Servern får bara prata ut på det den behöver: svar på egen trafik, DHCP, DNS mot godkänd server och HTTPS. SSH ut och DNS mot främmande servrar stoppas. | `bash ~/brandvagg-test.sh` (9 PASS) | ✅ |
| 7 | Loggtrafik ut på tcp/514 till två loggservrar (D5, F4) | Servern får skicka loggar till lärarens och klassens loggserver. | `sudo nft list chain inet zon ut` | ✅ |
| 8 | Utgående tcp/6514 (krypterad loggning) | **Saknas.** Det finns ingen regel som tillåter port 6514, så de krypterade loggarna stoppas av brandväggen. | `sudo nft list chain inet zon ut` | ⚠️ |
| 9 | Säkerhetsnät vid regeländringar | Innan nya regler laddas sparas en kopia, och en timer återställer automatiskt efter 2 minuter. Om en regel låser ute admin rättar det sig självt. | `history \| grep -E 'systemd-run\|nft -c'` | ✅ |
| 10 | Reglerna provläses innan de laddas | `nft -c` hittar skrivfel utan att aktivera något. | `history \| grep 'nft -c'` | ✅ |

## 2. Loggning

| # | Åtgärd | Enkelt förklarat | Belägg | Status |
|---|---|---|---|---|
| 11 | rsyslog konfigurerad för krypterad loggning (TLS) till central loggserver | Loggarna ska skickas krypterat och mottagaren kontrolleras med en egen CA (`labb-ca.pem`). **Konfigurationen är rätt, men anslutningen blockeras** (se 8). Loggarna köas på disken, upp till 100 MB. | `sudo cat /etc/rsyslog.d/70-workshop2-tls.conf`, `sudo journalctl -u rsyslog \| grep 6514` | ⚠️ |
| 12 | Brandväggen loggar stoppad trafik | När brandväggen säger nej skrivs det upp (max 10 rader/minut). | `sudo nft list chain inet zon in` / `ut` (`DB-IN-DROP`, `DB-UT-DROP`) | ✅ |
| 13 | auditd är igång | auditd är serverns "övervakningskamera": den skriver upp säkerhetshändelser, till exempel när SELinux nekar något. | `ps -eZ \| grep auditd` | ✅ |

## 3. SELinux

| # | Åtgärd | Enkelt förklarat | Belägg | Status |
|---|---|---|---|---|
| 14 | SELinux i tvingande läge, även efter omstart | SELinux stoppar på riktigt det som inte är tillåtet, och läget ligger kvar efter en omstart. | `sestatus` | ✅ |
| 15 | Webbmappen `/srv/zonwebb` har rätt etikett | Webbservern får bara läsa filer märkta `httpd_sys_content_t`. Regeln är bestående. | `sudo /usr/local/bin/verifiera-hardning` | ✅ |
| 16 | Egen SELinux-policy för zonvakt | zonvakt har en egen regelbok som säger exakt vad tjänsten får göra, och inget mer. | `sudo semodule -l \| grep zonvakt`, `ps -eZ \| grep zonvakt` | ✅ |
| 17 | zonvakt körs inte i permissive | SELinux stoppar zonvakt på riktigt om den bryter mot reglerna. | `sudo /usr/local/bin/verifiera-hardning` | ✅ |
| 18 | dontaudit-regler återställda efter felsökning | Dolda nekanden visades tillfälligt (`semodule -DB`) och döljs igen (`semodule -B`). | `sudo sesearch --dontaudit \| wc -l` (8539) | ✅ |
| 19 | zonvakt startar automatiskt | Tjänsten slås på av sig själv vid omstart. | `systemctl is-enabled zonvakt` | ✅ |

## 4. Verifiering

| # | Åtgärd | Enkelt förklarat | Belägg | Status |
|---|---|---|---|---|
| 20 | Verifieringsskript `verifiera-hardning` | Ett eget skript som kontrollerar härdningen och svarar GÄLLER eller GÄLLER INTE (10/10 GÄLLER). | `sudo /usr/local/bin/verifiera-hardning` | ✅ |
| 21 | Brandväggstest `brandvagg-test.sh` | Testar att rätt trafik släpps igenom och fel trafik stoppas (9 PASS, 0 FAIL). | `bash ~/brandvagg-test.sh` | ✅ |
