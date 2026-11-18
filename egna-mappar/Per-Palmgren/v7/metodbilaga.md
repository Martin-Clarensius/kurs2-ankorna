# Metodbilaga – härdningsrapport elev-33

Bilaga till [hardningsrapport.md](hardningsrapport.md).

## Verktyg och arbetssätt

- **AI-verktyg:** Claude Code (modell Claude Opus 5.5) i VS Code, 2026-11-18.
- **Vad AI:n hade tillgång till:** filerna i teamets repo (läsrätt till hela repot och skrivrätt i arbetskopian) och det jag klistrade in från elev-33. AI:n hade **ingen** åtkomst till elev-33, jump eller Wazuh. Alla kommandon på servern körde jag själv.
- **Arbetsgång:**
  1. Jag gav AI:n en kamrats härdningslista som mall och bad om en lista för elev-33.
  2. AI:n gjorde ett utkast utifrån repot och markerade det som saknade belägg.
  3. Jag körde kommandon på elev-33 och klistrade in utdatan, en i taget.
  4. AI:n uppdaterade listan efter varje utdata och strök det som utdatan visade var fel eller redan avklarat.
  5. Därefter sammanställdes rapporten med en dom per påstående. Domen bygger bara på utdata från servern, inte på vad AI:n antog.

## Prompt

Första prompten, oförändrad. Kamratens lista var inklistrad. Hans radnummer avser hans egen `history`.

~~~~text
Behöver göra en härdnings lista mot min labb dator som speglar det som är gjort på min elev-33 dator.

Här är ett exempel som en kamrat har gjort.

BRANDVÄGG (nftables)
nftables används som paketfilter; firewalld kontrollerat (153, 325, 364, 725, 793)
Regeluppsättning i tabellen "inet zon" med kedjorna in/ut, laddas från/etc/sysconfig/nftables.conf (375–469, 798)
nftables aktiverat vid uppstart (289, 470, 799) – verifierat med omstart (932)
Utgående filtrering: established/related, DHCP, DNS endast mot tillåten
resolver, HTTPS tillåtet; SSH ut och främmande DNS blockeras (brandvaggstest)
Inkommande tcp/7529 (zonvakt, D9) tillåts endast från ADRESS-BORTTAGEN (795–798)
Utgående tcp/6514 (syslog över TLS) tillåten till loggservern (537, 596–606)
Säkra regeländringar: backup + automatisk rollback via systemd-run-timer
innan nya regler laddas (280–284, 466–468)
Syntaxkontroll med nft -c före laddning (274–315, 711)

LOGGNING
rsyslog skickar loggar till central loggserver över TLS med egen CA(labb-ca.pem, rättighet 644) (635, 669, 686)
Brandväggsloggning via rsyslog-regel 50-nftables.conf (305–308)
auditd aktiv (609, 621)

SELINUX
Webbinnehåll i /srv/zonwebb märkt httpd_sys_content_t med semanage
fcontext + restorecon (722–723)
Egen policymodul zonvakt (zonvakt.pp) installerad; programfil och loggkatalog
ommärkta med restorecon (754–756, 785)
Kontrollerat att zonvakt inte körs i permissive (771)
dontaudit-regler tillfälligt avstängda vid felsökning (semodule -DB) och
återställda (semodule -B) (779–782)
Tjänsten zonvakt aktiverad vid uppstart (741)

VERIFIERING
Verifieringsskript /usr/local/bin/verifiera-hardning (871)
Brandväggstest ~/brandvagg-test.sh (506)
Omstartstest för att bekräfta att härdningen överlever omstart (932)

ATT KONTROLLERA/STRYKA
SSH in begränsad till två adresser (261–262) – fanns i gamla "ip filter",
finns det kvar i "inet zon"?
Drop + logg av ADRESS-BORTTAGEN med prefix U4.2-DROP (322–323) – kvar?
~~~~

### Följdprompter

Efter den första prompten skickade jag bara utdata från elev-33 och korta instruktioner:

| Ordning | Vad jag skickade | Belägg i rapporten |
|---|---|---|
| 1 | "Kan du korrigera nu när jag klistrat in SELinux från min dator" och sedan "Nu har jag sparat den". Min egen tabell över SELinux- och brandväggsåtgärder låg då inklistrad i listfilen | P5, P7, P28a–c |
| 2 | `history \| grep -E 'nft\|nftables\|firewalld\|rsyslog\|audit\|ca.pem\|sshd\|reboot\|semanage\|restorecon\|getenforce'` | B10 |
| 3 | `sudo nft list ruleset` | B1 |
| 4 | `sudo cat /etc/sysconfig/nftables.conf` | B2 |
| 5 | `sudo cat /etc/nftables/zon.nft` | B3 |
| 6 | `sudo nft -c -f /etc/sysconfig/nftables.conf && echo SYNTAX-OK` | B4 |
| 7 | `ls -l /etc/rsyslog.d/ /etc/pki/rsyslog/ca.pem` | B6 |
| 8 | `sudo sshd -T \| grep -Ei 'passwordauthentication\|permitrootlogin'` | B9 |
| 9 | `history \| grep -E 'semodule\|checkmodule\|ps -eZ\|ausearch\|brandvagg\|testfall'` | B11 |
| 10 | `systemctl is-enabled` för nftables, firewalld, rsyslog och auditd | B5 |
| 11 | `sudo ls -ld /etc/pki/rsyslog && sudo ls -lZ /etc/pki/rsyslog/ca.pem` | B7 |
| 12 | `getent hosts log.sec.chas-lab.dev` | B8 |
| 13 | Uppdraget: härdningsrapport med dom och belägg, rättelselogg, metodbilaga, allt incheckat | – |

## Råsvar

AI:ns första svar, oförändrat. Det bestod av ett chattsvar och en fil (`hardningslista.md`, första versionen). Länkarna pekar på var filerna låg då.

### Chattsvar

~~~~text
Skrivet för: lärare och team som granskar elev-33.

Jag har gjort en härdningslista i [hardningslista.md](egna-mappar/Per-Palmgren/hardningslista.md). Den har samma upplägg som din kamrats: brandvägg, loggning, detektion och ett avsnitt med saker att kontrollera. Jag har inte committat något.

**Radnummer:** Kamratens siffror (t.ex. 375–469) är radnummer från `history` på datorn. Den historiken har jag inte, så varje punkt pekar i stället på en fil i repot som belägg. Det finns också en tom kolumn *hist* som du fyller i. Längst ner i filen finns kommandon att köra i ssh lab för att hitta numren och kontrollera det öppna. `history` skriver själv ut radnumren.

**Jag tog inte med** det som din dator inte har något belägg för: SELinux/zonvakt, rollback-timer, `nft -c` och verifieringsskript. Om du har gjort något av det får du lägga till det själv.

**Det här bör du kontrollera, eftersom det skiljer sig mellan filerna:**
- [zon.nft](egna-mappar/Per-Palmgren/brandvägg/cfg/zon.nft) är en äldre version. Den använder 514 i stället för 6514, saknar F6 och D7 och har en NTP-rad som inte går att ladda. Det är [nft-backup.nft](egna-mappar/Per-Palmgren/brandvägg/cfg/nft-backup.nft) som stämmer med v6-dokumentet.
- [60-brandvagg.conf](egna-mappar/Per-Palmgren/brandvägg/cfg/60-brandvagg.conf) skickar kärnloggen okrypterat på 514, men brandväggen blockerar 514. v6-dokumentet säger emot sig självt om det här: på ett ställe går kärnloggen via 514, på ett annat går allt via 6514.
- NTP och HTTPS ut får gå till alla adresser på eth0. DNS är däremot låst till två bestämda servrar.
~~~~

### Första versionen av filen

~~~~markdown
# Härdningslista – elev-33

Det som är gjort på elev-33 (10.40.2.99, management-zonen). Belägg är filer i repot. Kolumnen *hist* fylls i med radnummer ur `history` på elev-33.

## BRANDVÄGG (nftables)

| Åtgärd | Belägg | hist |
|---|---|---|
| nftables används som paketfilter. Tabellen `inet zon` med kedjorna `in` och `ut`, båda `policy drop` | [nft-backup.nft](brandvägg/cfg/nft-backup.nft) | ⟨ ⟩ |
| `flush ruleset` först i filen, så gamla tabeller (t.ex. `ip filter`) inte ligger kvar | [nft-backup.nft](brandvägg/cfg/nft-backup.nft) | ⟨ ⟩ |
| Definitioner för zoner och adresser (`$JUMP`, `$CTF`, `$LoggServ_IP`, Web/App/Data/Logg/Admin) | [nft-backup.nft](brandvägg/cfg/nft-backup.nft) | ⟨ ⟩ |
| **In:** established/related, `lo`, invalid droppas | [nft-backup.nft](brandvägg/cfg/nft-backup.nft) | ⟨ ⟩ |
| **In:** SSH 22 endast från jump 172.20.1.2 (D1) och ctf 172.20.1.10 (D2) | [nft-backup.nft](brandvägg/cfg/nft-backup.nft) | ⟨ ⟩ |
| **In:** DHCP-svar udp 67→68 på eth0–eth2 (D6) | [nft-backup.nft](brandvägg/cfg/nft-backup.nft) | ⟨ ⟩ |
| **Ut:** established/related, `lo` | [nft-backup.nft](brandvägg/cfg/nft-backup.nft) | ⟨ ⟩ |
| **Ut:** SSH 22 endast till Web/App/Data/Logg-zonerna (F6). SSH till Admin-zonen och till internet blockeras | [nft-backup.nft](brandvägg/cfg/nft-backup.nft), testfall F6a–d, F10h–i | ⟨ ⟩ |
| **Ut:** DNS 53 endast till 185.12.64.1/.2 (D3). Främmande DNS (8.8.8.8) blockeras | testfall D3a–c | ⟨ ⟩ |
| **Ut:** NTP udp 123 på eth0 (D4) | [nft-backup.nft](brandvägg/cfg/nft-backup.nft) | ⟨ ⟩ |
| **Ut:** DHCP-klient udp 68→67 (D6) | [nft-backup.nft](brandvägg/cfg/nft-backup.nft) | ⟨ ⟩ |
| **Ut:** HTTPS 443 på eth0 för dnf (D7). HTTP 80 blockeras | testfall D7a–b | ⟨ ⟩ |
| **Ut:** syslog över TLS tcp 6514 endast till loggservern 172.20.1.58 (D5). Okrypterad 514 borttagen | [nft-backup.nft](brandvägg/cfg/nft-backup.nft), [v6](v6/detektioner-och-playbooks.md#regelverket-på-elev-33-båda-lagren) | ⟨ ⟩ |
| Avvisad trafik loggas med rate limit 10/min, prefix `ZON-IN-DROP ` och `ZON-UT-DROP ` | [nft-backup.nft](brandvägg/cfg/nft-backup.nft) | ⟨ ⟩ |
| Brandväggstester mot flödestabellen | [testfall/](brandvägg/testfall/) | ⟨ ⟩ |
| nftables aktiverat vid uppstart | ⟨ ⟩ | ⟨ ⟩ |

## LOGGNING

| Åtgärd | Belägg | hist |
|---|---|---|
| rsyslog skickar alla loggar (`*.*`) till `log.sec.chas-lab.dev:6514` över TLS (gtls) | [90-tls-forward.conf](brandvägg/cfg/90-tls-forward.conf) | ⟨ ⟩ |
| Serverns certifikat kontrolleras mot CA `/etc/pki/rsyslog/ca.pem` och namnet (`x509/name`, `PermittedPeers`) | [90-tls-forward.conf](brandvägg/cfg/90-tls-forward.conf) | ⟨ ⟩ |
| Diskassisterad kö (`fwd_tls`, max 1 GB), sparas vid avstängning, oändliga återförsök var 10:e s | [90-tls-forward.conf](brandvägg/cfg/90-tls-forward.conf), [loggning.md](loggning.md) | ⟨ ⟩ |
| auditd aktiv med regel för root-kommandon, nyckel `root_cmd` | [loggning.md](loggning.md) | ⟨ ⟩ |
| auditd-poster går vidare till syslog via audisp-syslog (`active = yes`) | [loggning.md](loggning.md) | ⟨ ⟩ |
| auditd rotation: `max_log_file = 8`, `num_logs = 5`, `ROTATE` | [loggning.md](loggning.md) | ⟨ ⟩ |
| Loggfilerna ägs av `root:root`, rättighet `-rw-------` | [loggning.md](loggning.md) | – |
| Posterna verifierade på loggservern (`sparc6e7feb6`) | [loggning.md](loggning.md) | ⟨ ⟩ |

## DETEKTION (Wazuh)

| Åtgärd | Belägg |
|---|---|
| D1 `elev-33`: SSH-försök mot konton som inte finns (regel 5710) | [v6](v6/detektioner-och-playbooks.md) |
| D3 `elev-33-root-kommando`: kommandon som root (auditd `root_cmd`) | [v6](v6/detektioner-och-playbooks.md) |
| D4 `Misslyckad-sudo-elev-33`: misslyckad sudo (`pam_unix(sudo:auth)`) | [v6](v6/detektioner-och-playbooks.md) |
| D5 `elev-33-C2-becon-(T1071.001)`: C2-beacon | [v6](v6/detektioner-och-playbooks.md) |

## ATT KONTROLLERA / STRYKA

- **Vilken regelfil är laddad?** [zon.nft](brandvägg/cfg/zon.nft) är en äldre version: 514 i stället för 6514, ingen F6 eller D7, prefix `ZONE-UT-DROP` och en NTP-rad (`ntp dport 123 udp`) som inte går igenom `nft -c`. Jämför `sudo nft list ruleset` med `nft-backup.nft`. Stryk eller märk `zon.nft` som gammal.
- **`60-brandvagg.conf`** skickar `kern.*` okrypterat till 172.20.1.58:514, men 514 är stängd i `ut`. Finns filen kvar i `/etc/rsyslog.d/`? Då fylls kön `fwd_kern` utan att något skickas. v6-dokumentet säger på ett ställe att kärnloggen går via 514, på ett annat att allt går via 6514.
- **NTP och HTTPS ut** är öppna mot alla adresser på eth0, inte bara mot NTP-servern eller paketförråden. Mindre strikt än DNS-regeln.
- **`log.sec.chas-lab.dev` = 172.20.1.58?** rsyslog använder namnet, nftables adressen. Kontrollera med `getent hosts log.sec.chas-lab.dev`.
- **Rättigheter på `ca.pem`**: inte dokumenterade.
- **firewalld** avstängt och maskerat?
- **Omstartstest**: överlever regler, rsyslog och auditd en omstart?
- **sshd_config**: `PasswordAuthentication` och `PermitRootLogin` nämns i playbook D1, men värdena är inte dokumenterade.
- **Molnbrandväggen** `itsx26-elev-33` (lager 2): regler saknas i [v6](v6/detektioner-och-playbooks.md#regelverket-på-elev-33-båda-lagren).

## Kommandon för att fylla i listan (ssh lab)

```bash
history | grep -nE 'nft|nftables|firewalld|rsyslog|audit|ca.pem|sshd|reboot|semanage|restorecon|getenforce'
sudo nft list ruleset
systemctl is-enabled nftables firewalld rsyslog auditd
systemctl is-active nftables firewalld rsyslog auditd
ls -l /etc/rsyslog.d/ /etc/pki/rsyslog/ca.pem /etc/sysconfig/nftables.conf
sudo auditctl -l
sudo sshd -T | grep -Ei 'passwordauthentication|permitrootlogin'
getent hosts log.sec.chas-lab.dev
getenforce
last reboot | head -3
```
~~~~

### Vad i råsvaret som inte höll

| Påstående i råsvaret | Vad servern visade | Var det rättades |
|---|---|---|
| Reglerna och belägget ligger i `nft-backup.nft` | Den laddade filen är `/etc/nftables/zon.nft`. Den har två regler som saknas i `nft-backup.nft` (7533, 80) | B1, B3, rapporten R1 |
| `history \| grep -nE` ger radnumren | `-n` ger grep:s radnummer, inte historikens. Rättades innan kommandot kördes | Rapporten R5 |
| "Omstartstest: överlever regler en omstart?" (okänt) | Det var gjort, rad 912 och 962–970 | B10, P5 |
| SELinux, `nft -c` och verifieringsskript utelämnades som "utan belägg" | Allt fanns på servern | B4, B10, B11, P4, P28, P30 |
| "Finns `60-brandvagg.conf` kvar?" (öppen fråga) | Nej, borttagen rad 411 | B6, B11, rapporten R2 |

## Maskering

| Uppgift | Skickad till AI:n | Maskerad | Skäl |
|---|---|---|---|
| Interna IP-adresser (10.40.2.0/24, 172.20.1.x) och DNS-servrar 185.12.64.1/.2 | Ja | Nej | Labbnätets adressplan finns redan i teamets repo (vecka 2–4) och går inte att nå utifrån |
| Värdnamn (`elev-33`, `log.sec.chas-lab.dev`) | Ja | Nej | Står redan i repot. Behövs för att granska rsyslog-konfigurationen |
| Användarnamnet `student` | Ja, i historiken | Nej | Gemensamt labbkonto, inget personligt namn |
| Kamratens lista | Ja | Kamraten hade själv ersatt en adress med `ADRESS-BORTTAGEN`. Jag ändrade inget i den | – |
| Lösenord (sudo, SSH, Wazuh) | Nej | – | sudo-prompten syns i B5, men lösenordet skrevs aldrig in i AI:n |
| Privata nycklar, innehållet i `ca.pem`, tokens | Nej | – | Bara metadata om `ca.pem` (rättigheter, SELinux-typ) skickades, B7 |
| Loggposter med andra elevers data | Nej | – | Inga sådana skickades i det här arbetet |

Slutsats: ingen uppgift maskerades i det jag skickade, eftersom inget av det var hemligt utöver det som redan finns i teamets repo. Lösenord och nyckelmaterial skickades inte alls.
