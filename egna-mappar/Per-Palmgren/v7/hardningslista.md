# Härdningslista – elev-33

Det som är gjort på elev-33 (10.40.2.99, management-zonen). Belägg är filer i repot. Siffrorna i kolumnen *hist* är radnummer ur `history` på elev-33.

## BRANDVÄGG (nftables)

Regelfil: [zon.nft](../brandvägg/cfg/zon.nft), kopia av `/etc/nftables/zon.nft` på elev-33 (2026-11-18). Laddat regelset: [nft-ruleset-elev-33.nft](nft-ruleset-elev-33.nft) (`sudo nft list ruleset`, samma dag). De stämmer överens. [nft-backup.nft](../brandvägg/cfg/nft-backup.nft) är den tidigare versionen, utan reglerna för 7533 och 80.

| Åtgärd | Belägg | hist |
|---|---|---|
| nftables används som paketfilter. En tabell, `inet zon`, med kedjorna `in` och `ut`, båda `policy drop` | [regelset](nft-ruleset-elev-33.nft) | 292, 345–347, 635 |
| `flush ruleset` först i regelfilen, så gamla tabeller (t.ex. `ip filter`) inte ligger kvar | [zon.nft](../brandvägg/cfg/zon.nft) | – |
| Namngivna adresser och zoner (`$JUMP`, `$CTF`, `$LoggServ_IP`, Web/App/Data/Logg/Admin) i stället för siffror i reglerna | [zon.nft](../brandvägg/cfg/zon.nft) | – |
| **In:** established/related och `lo` släpps in, invalid droppas | [regelset](nft-ruleset-elev-33.nft) | 292, 635 |
| **In:** SSH 22 endast från jump 172.20.1.2 (D1) och ctf 172.20.1.10 (D2) | [regelset](nft-ruleset-elev-33.nft) | 292, 635 |
| **In:** zonvakt tcp/7533 och httpd tcp/80 endast från ctf 172.20.1.10 | [regelset](nft-ruleset-elev-33.nft), `verifiera-hardning` kontroll 5 | 906–908, 967–970 |
| **In:** DHCP-svar udp 67→68 på eth0–eth2 (D6) | [regelset](nft-ruleset-elev-33.nft) | 292, 635 |
| **Ut:** established/related, `lo` | [regelset](nft-ruleset-elev-33.nft) | 292, 635 |
| **Ut:** SSH 22 endast till 10.40.2.0–10.40.2.95, alltså Web/App/Data/Logg-zonerna (F6). Admin-zonen (.96/28) och internet blockeras | [regelset](nft-ruleset-elev-33.nft), testfall F6a–d, F10h–i | 292, 635 |
| **Ut:** DNS 53 endast till 185.12.64.1/.2 (D3). Främmande DNS (8.8.8.8) blockeras | [regelset](nft-ruleset-elev-33.nft), testfall D3a–c | 292, 635 |
| **Ut:** NTP udp 123 på eth0 (D4) | [regelset](nft-ruleset-elev-33.nft) | 292, 635 |
| **Ut:** DHCP-klient udp 68→67 (D6) | [regelset](nft-ruleset-elev-33.nft) | 292, 635 |
| **Ut:** HTTPS 443 på eth0 för dnf (D7). HTTP 80 blockeras | [regelset](nft-ruleset-elev-33.nft), testfall D7a–b | 292, 635 |
| **Ut:** syslog över TLS tcp 6514 endast till loggservern 172.20.1.58 (D5). Ingen regel för okrypterad 514 | [regelset](nft-ruleset-elev-33.nft) | 292, 635 |
| Den tillfälliga regeln för tcp/80 till loggservern, som behövdes för att hämta CA:n, finns inte kvar | [regelset](nft-ruleset-elev-33.nft) | 348–349 (inlagd), 912 (omstart) |
| Avvisad trafik loggas med rate limit 10/min (burst 5), prefix `ZON-IN-DROP ` och `ZON-UT-DROP ` | [regelset](nft-ruleset-elev-33.nft) | 292, 635 |
| Regelsetet laddas vid start. `/etc/sysconfig/nftables.conf` (som nftables-tjänsten läser) innehåller bara `include "/etc/nftables/zon.nft"`. Reglerna står alltså i `/etc/nftables/zon.nft`. Tillfälliga regler (`nft insert`) försvann vid omstart, så allt ska ligga i den filen | `cat /etc/sysconfig/nftables.conf`, omstart, sedan `nft list ruleset` och `verifiera-hardning` | 653, 912, 962, 967–970 |
| Syntaxkontroll av hela startkonfigurationen (`nftables.conf` + `zon.nft`) med `nft -c -f /etc/sysconfig/nftables.conf` gav `SYNTAX-OK`. Reglerna laddas alltså vid nästa omstart | Utdata 2026-11-18 | kört 2026-11-18 |
| nftables-tjänsten är aktiverad vid start (`enabled`). firewalld är inte installerat, så ingen annan brandvägg kan skriva över reglerna | `systemctl is-enabled` 2026-11-18 | – |
| Brandväggstester mot flödestabellen med `test.sh testfall.csv` | [testfall/](../brandvägg/testfall/) | 156, 559 |

## LOGGNING

| Åtgärd | Belägg | hist |
|---|---|---|
| rsyslog skickar alla loggar (`*.*`) till `log.sec.chas-lab.dev:6514` över TLS (gtls). Syntax kontrollerad med `rsyslogd -N1` före omstart | [90-tls-forward.conf](../brandvägg/cfg/90-tls-forward.conf) | 295–297, 370–393 |
| TLS-modulen installerad (`rsyslog-gnutls`, `lmnsd_gtls.so`) | – | 587–588, 596–597 |
| rsyslog och auditd aktiverade vid start (`enabled`) | `systemctl is-enabled` 2026-11-18 | – |
| `log.sec.chas-lab.dev` (namnet i rsyslog) slås upp till 172.20.1.58 (adressen i brandväggsregel D5) | `getent hosts` 2026-11-18 | – |
| CA hämtad från loggservern till `/etc/pki/rsyslog/ca.pem`, fingeravtryck kontrollerat och TLS-anslutningen verifierad med `openssl s_client` | – | 351–355, 361 |
| Serverns certifikat kontrolleras mot CA:n och namnet (`x509/name`, `PermittedPeers`) | [90-tls-forward.conf](../brandvägg/cfg/90-tls-forward.conf) | 370–373 |
| Diskassisterad kö (`fwd_tls`, max 1 GB), sparas vid avstängning, oändliga återförsök var 10:e s | [90-tls-forward.conf](../brandvägg/cfg/90-tls-forward.conf), [loggning.md](../loggning.md) | 370 |
| Felsökning av anslutningen till loggservern (timeout 2026-11-03, `suspended`) | [loggning.md](../loggning.md) | 487–503, 589, 598, 630–632 |
| auditd aktiv med regel för root-kommandon, nyckel `root_cmd` | [loggning.md](../loggning.md) | 87, 103–104, 109–110, 289, 517–519, 657 |
| auditd-poster går vidare till syslog via audisp. `au-remote` kontrollerad | [loggning.md](../loggning.md) | 94–95, 122, 307 |
| auditd rotation: `max_log_file = 8`, `num_logs = 5`, `ROTATE` | [loggning.md](../loggning.md) | 92–93, 113 |
| Loggfilerna ägs av `root:root`, rättighet `-rw-------` | [loggning.md](../loggning.md) | 100–101, 111–112 |
| Posterna verifierade lokalt (`sparc6e7feb6`) och på loggservern med loggsök | [loggning.md](../loggning.md) | 85 |
| `/etc/rsyslog.d/` innehåller bara `21-cloudinit.conf` och `90-tls-forward.conf` (`root:root`, `-rw-r--r--`). Den okrypterade `60-brandvagg.conf` (kern.* till tcp/514) sparades undan och togs bort | `ls -l /etc/rsyslog.d/` 2026-11-18 | 398, 408, 411 |
| CA-filen skyddad: katalogen `/etc/pki/rsyslog` är `drwx------ root root`, så bara root kommer åt den. `ca.pem` är `-rw-r--r-- root root` med SELinux-typen `cert_t`, som rsyslog får läsa. Bara root kan byta ut CA:n | `sudo ls -ld` och `ls -lZ` 2026-11-18 | 351, 361 (hämtad) |
| En extra regel `91-audit-forward.conf` provades och togs bort ⟨varför?⟩ | – | 300–313 |

## SELINUX

| Åtgärd | Varför | Verifierat med | hist |
|---|---|---|---|
| SELinux i läge Enforcing, även efter omstart | Grundkrav för att policyn ska verka | `getenforce`, `verifiera-hardning` | 677, 751, 894, 963, 1060 |
| Egen tvingande policymodul för zonvakt (domän `zonvakt_t`). Raden som satte domänen i permissive är borttagen. Programfil och loggkatalog ommärkta med `restorecon` | Tjänsten kör som root. Utan egen domän hamnade den i `unconfined_service_t` och kunde skriva i `/etc`. Det visade `overtrad`, som skapade `/etc/zonvakt-otillaten` | `verifiera-hardning` (modulen laddad, inte permissive), `ps -eZ` visar `zonvakt_t`, `ausearch` visar nekad skrivning mot `etc_t`. `hej` fungerar fortfarande | Installerad med `semodule -i`: 844, 871, 950. Laddad: 845, 897. Ommärkt: 841, 846. Inte permissive: 900. Domän `ps -eZ`: 777, 824–850, 874, 930, 953, 965, 1062. Nekanden `ausearch`: 854, 941, 960 |
| `/srv/zonwebb` märkt `httpd_sys_content_t` med `semanage fcontext` + `restorecon` | Kvittot gav 403 trots rätt Unix-rättigheter, eftersom katalogen hade `var_t`. `chcon` hade försvunnit vid nästa relabel | `verifiera-hardning` (regel och kontext), `curl` mot `127.0.0.1/zon/kvitto.txt` ger 200 | Felsökning av 403 (`ausearch -m avc -c httpd`): 733–738. Regel och märkning: 765–766, 769, 791. Kontroll: 903 |

## VERIFIERING

| Åtgärd | hist |
|---|---|
| Verifieringsskript `/usr/local/bin/verifiera-hardning`: Enforcing, zonvakt inte permissive, filkontext för `/srv/zonwebb`, brandväggsregel för 172.20.1.10 | 894–908 |
| Omstartstest: SELinux och brandväggsregler kontrollerade efter omstart | 912, 962–970 |
| Belägg sparade till fil: `semodule -l` och `ps -eZ` i `~/ai-mapp/Verifierad/` | 1002–1014 |
| Kontroll 5 i skriptet rättad efter omstarten: sökte i `inet filter input`, som inte finns (regeln ligger i `inet zon`). Söker nu i hela `nft list ruleset` | 967, 973–974 |

## DETEKTION (Wazuh)

| Åtgärd | Belägg |
|---|---|
| D1 `elev-33`: SSH-försök mot konton som inte finns (regel 5710) | [v6](../v6/detektioner-och-playbooks.md) |
| D3 `elev-33-root-kommando`: kommandon som root (auditd `root_cmd`) | [v6](../v6/detektioner-och-playbooks.md) |
| D4 `Misslyckad-sudo-elev-33`: misslyckad sudo (`pam_unix(sudo:auth)`) | [v6](../v6/detektioner-och-playbooks.md) |
| D5 `elev-33-C2-becon-(T1071.001)`: C2-beacon | [v6](../v6/detektioner-och-playbooks.md) |

## ATT KONTROLLERA / STRYKA

- ~~**Kommentaren `"F2 Httpd"`** på regeln för tcp/80 stämmer inte med flödestabellen.~~ **Åtgärdat 2026-11-23:** regeln är kvar och heter `"D8 Httpd"` (D8 i flödestabellen). F2 är webb → app på tcp 80. 8080 var bara en tillfällig testkörning med `nc -lk 8080`.
- **Kontroll 5 är för bred.** `nft list ruleset | grep -q '172.20.1.10'` lyckas redan på D2-regeln (SSH från ctf), även om reglerna för 7533 och 80 saknas. Sök hellre efter `172.20.1.10 tcp dport 7533`.
- **NTP och HTTPS ut** är öppna mot alla adresser på eth0, inte bara mot NTP-servern eller paketförråden. Mindre strikt än DNS-regeln. **HTTPS åtgärdat 2026-11-23:** D7 gäller bara 146.75.122.132. NTP kvarstår.
- **Omstartstest för loggning**: SELinux och brandväggen är testade efter omstart (962–970), och rsyslog och auditd startar vid uppstart (`enabled`). Det som inte är visat efter omstart är att TLS-anslutningen till loggservern kommer upp och att regeln `root_cmd` laddas. Kontrollera efter nästa omstart med `sudo auditctl -l | grep root_cmd` och `ss -tn dst 172.20.1.58:6514`.
- **SSH är inte härdat** (`sshd -T`, 2026-11-18): `permitrootlogin without-password` betyder att root kan logga in med nyckel men inte med lösenord. `passwordauthentication yes` betyder att vanliga konton kan logga in med lösenord. Det som skyddar idag är bara att nftables släpper in SSH från jump och ctf. Förslag: `PasswordAuthentication no` och `PermitRootLogin no` i en fil under `/etc/ssh/sshd_config.d/`. Kontrollera först att nyckelinloggning via jump fungerar och att CTF-kontrollen (D2) inte kräver lösenord. Kör `sshd -t` och håll en session öppen medan du testar, så att du inte låser ute dig. Gör du det inte: skriv varför under en egen rubrik om undantag.
- **Molnbrandväggen** `itsx26-elev-33` (lager 2): regler saknas i [v6](../v6/detektioner-och-playbooks.md#regelverket-på-elev-33-båda-lagren).

## Kommandon för det som är kvar (ssh lab)

```bash
# Efter nästa omstart
sudo auditctl -l | grep root_cmd
ss -tn dst 172.20.1.58:6514

# Molnbrandväggen (i ssh jump)
moln status
```                                    