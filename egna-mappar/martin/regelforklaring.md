# Regelförklaring – elev-34 (2026-11-17)

Utkast skrivet av Claude (AI) utifrån dagens chatt. Martin läser och godkänner innan det används.

Varje regel är förklarad med vad den gör, varför den finns och hur den kontrollerades. Det som inte är bestämt eller testat är markerat med ⟨…⟩ och ska fyllas i av Martin. Brandväggsreglerna finns också i listan i `portlista.md`.

## 1. Brandväggen (nftables, `/etc/sysconfig/nftables.conf`)

Grundidén är att allt som inte uttryckligen tillåts stoppas (policy drop). Tabellen heter `inet zon` och har två kedjor: `in` (inkommande) och `ut` (utgående).

### Grundregler i kedjan `in`
| Regel | Vad den gör | Varför |
|---|---|---|
| `ct state established,related accept` | Släpper in svar på trafik som servern själv startat och trafik som hör till en redan tillåten anslutning | Annars hade inga svar kommit tillbaka |
| `ct state invalid drop` | Stoppar paket som inte hör till någon giltig anslutning | ⟨egen motivering⟩ |
| `iif "lo" accept` | Tillåter trafik inne i servern själv (localhost) | Tjänster på servern pratar med varandra, och testet `nc 127.0.0.1` kräver det |
| Sista regeln: `limit rate 10/minute burst 5 log prefix "ZON-IN-DROP"` | Loggar stoppad inkommande trafik, högst 10 per minute | Skyddar loggen från att svämmas över. Därför loggas inte allt som stoppas |

### Inkommande flöden
| ID | Regel | Varför | Kontroll |
|---|---|---|---|
| D1 | SSH (tcp 22) från jump 172.20.1.2 | Så att jag kommer in på servern | Används varje gång jag loggar in via ssh jump |
| D2 | SSH (tcp 22) från ctf-servern 172.20.1.10 | ctf-servern ska kunna kontrollera uppgifterna | ⟨kontroll⟩ |
| D8 | tcp 80 från ctf-servern | U7.2: ctf-servern hämtar kvittot från webbservern | Uppgiften U7.2 klarades |
| D9 | tcp 7534 från ctf-servern | U7.3: ctf-servern ska nå zonvakt (port 7500 + elevnummer 34) | `echo hej \| nc -w2 127.0.0.1 7534` gav ok. Flaggan godkändes av ctf-servern |
| F6 | SSH (tcp 22) från management-zonen 10.40.2.96/28, via nätkortet eth2 | Flöde F6 i flödestabellen: management ska nå godkända servrar | Regeln syns i `nft list ruleset`. ⟨provad från en server i management, till exempel elev-29 eller elev-33? ange själv⟩ |

### Utgående flöden (kedjan `ut`)
| ID | Regel | Varför | Kontroll |
|---|---|---|---|
| D3 | DNS (port 53) till 185.12.64.1 och 185.12.64.2 | Servern ska kunna slå upp namn | ⟨egen motivering och kontroll⟩ |
| D6 | DHCP (udp 67) | Servern får sin adress via DHCP | ⟨egen motivering⟩ |
| D4 | NTP (udp 123) till 2.28.43.156 och 213.239.239.0/24 | Rätt klocka, vilket loggar och TLS-certifikat kräver | ⟨egen motivering och kontroll⟩ |
| F4 | tcp 6514 till loggservern 172.20.1.58 | Loggar skickas krypterade med TLS till den centrala loggservern. Port 514 används inte längre | Loggarna kommer fram i Wazuh ⟨bekräfta⟩ |
| D7 | tcp 443 till 146.75.122.132 (Rockys paketserver) | Paketuppdateringar. `sepolicy generate` kräver samma utgående trafik som `dnf` | `sudo dnf makecache` fungerade efter att regeln lagts till. Före regeln gav det timeout. Då blev kommandot bara stående och laddade |
| (sista regeln) | `limit rate 10/minute ... log prefix "ZONE-UT-DROP"` | Samma som i `in`: begränsad loggning av stoppad utgående trafik | |

### Molnbrandväggen hos Hetzner (`itsx26-elev-34`)
| Regel | Vad | Kommentar |
|---|---|---|
| 1 | ut, tcp 443, 0.0.0.0/0 (D7) | Bredare än nödvändigt. Beslut om den ska tas bort är inte fattat |
| 2 | ut, udp 123 (D4) | NTP |
| 3 | ut, tcp 443, 146.75.122.132/32 (D7 paket från Rocky) | Den smala regeln, tillagd 2026-11-17 |

Molnbrandväggen har inga inkommande regler, och trafik på det privata nätet 172.20.1.x passerar inte den. De inkommande reglerna finns därför bara i nftables.

## 2. SELinux-policyn för zonvakt (`/home/student/pol/zonvakt.te`)

Zonvakt är en tjänst som lyssnar på port 7534. Utan egen policy körde den som `unconfined_service_t`, vilket betyder att SELinux inte stoppade något. Jag byggde därför en egen policy så att tjänsten körs i domänen `zonvakt_t` och bara får göra det den behöver.

- `sepolicy generate --init -n zonvakt /usr/local/bin/zonvakt` skapade grunden: domänen `zonvakt_t`, filtypen `zonvakt_exec_t` för programmet och `zonvakt_log_t` för loggen.
- `make -f /usr/share/selinux/devel/Makefile zonvakt.pp` bygger policyn, `semodule -i` laddar den och `restorecon` sätter rätt etiketter på filerna.
- Tillagda rader i `zonvakt.te`:

| Rad | Vad den tillåter | Varför |
|---|---|---|
| `allow zonvakt_t self:tcp_socket { accept bind create getattr listen read setopt write };` | Tjänsten får skapa, binda, lyssna på och ta emot anslutningar och läsa och skriva på dem | Utan `read` och `write` kraschade tjänsten vid första anslutningen (`PermissionError`). Det syntes inte i loggen förrän jag stängde av dolda nekanden med `semodule -DB` |
| `corenet_tcp_bind_generic_node` och `corenet_tcp_bind_generic_port` | Binda till nätadress och port | Så att tjänsten kan lyssna på 7534 |
| `corecmd_mmap_bin_files` | Läsa in program i minnet | ⟨egen motivering, `audit2allow` föreslog den⟩ |
| `auth_read_passwd_file`, `sssd_read_public_files`, `sssd_search_lib` | Läsa användarinformation | Tjänsten slår upp användare ⟨bekräfta med `audit2allow`-utdatat⟩ |

- Jag tog medvetet inte med reglerna `corecmd_exec_bin`, `files_manage_etc_files` och `auth_etc_filetrans_shadow` som `audit2allow` föreslog. De gav för stora rättigheter, bland annat att ändra filer i `/etc`. Då hade överträdelsen inte stoppats.
- Resultat i Enforcing: `hej` fungerar och `overtrad` stoppas. Överträdelsen syns lokalt som AVC `denied { write } ... name=etc ... tclass=dir permissive=0` och i `zonvakt.log` som `'overtrad' -> nekad: Permission denied`.
- Kommandon jag använde för att läsa överträdelsen: `ausearch -m avc -c zonvakt -ts recent -i`, `audit2allow -R`, `ps -eZ`, `semanage permissive -l`.

## 3. Att kunna svara på muntligt
- Varför börjar brandväggen med att stoppa allt?
- Varför är D7 begränsad till en enda adress?
- Varför loggas stoppad trafik med högst 10 per minute?
- Varför fick jag inte med regeln som tillåter att ändra i `/etc`?
- Varför syntes inte nekandet i loggen först, och hur hittade jag det?
