# Härdningslista – labbserver Elev 29

## Hur listan ska läsas

| Spalt | Betyder |
|---|---|
| **Åtgärd** | Vad som gjorts på servern |
| **Enkelt förklarat** | Vad det betyder och varför det gör servern säkrare |
| **Bevis** | Var åtgärden syns: radnummer i kommandohistoriken (`history`) eller namnet på ett test |

**Om siffrorna i Bevis:** kommandot `history` numrerar allt som skrivits i terminalen. Rad 722 är alltså det 722:a kommandot. Siffrorna visar var i historiken åtgärden finns, så att den går att kontrollera i efterhand. Kör `history | grep '^ *722 '` för att se ett enskilt kommando.

---

## 1. Brandvägg (nftables)

| # | Åtgärd | Enkelt förklarat | Bevis |
|---|---|---|---|
| 1 | nftables används som paketfilter | Brandväggen är grinden som bestämmer vilken nätverkstrafik som får komma in och ut. firewalld har kontrollerats så att två brandväggar inte krockar. | 153, 325, 364, 725, 793 |
| 2 | Reglerna ligger i tabellen `inet zon` med kedjorna `in` och `ut` | Alla regler är samlade på ett ställe: en lista för trafik in och en för trafik ut. De sparas i `/etc/sysconfig/nftables.conf`. | 375–469, 798 |
| 3 | nftables startar automatiskt | Brandväggen slås på av sig själv när servern startar, så att den aldrig står oskyddad efter en omstart. Testat med en riktig omstart. | 289, 470, 799, 932 |
| 4 | Utgående trafik är begränsad | Servern får bara prata ut på det den behöver: svar på egen trafik, DHCP, DNS mot godkänd server och HTTPS. SSH ut och DNS mot främmande servrar stoppas. | Brandväggstest (9 PASS) |
| 5 | Port 7529 (zonvakt) öppen bara för en adress | Bara en utvald dator (ADRESS-BORTTAGEN) får ansluta till zonvakt. Alla andra stoppas. | 795–798 |
| 6 | Port 6514 ut tillåten till loggservern | Servern får skicka sina loggar krypterat till den centrala loggservern. | 537, 596–606 |
| 7 | Säkerhetsnät vid regeländringar | Innan nya regler laddas sparas en kopia, och en timer återställer automatiskt efter 2 minuter. Om en regel låser ute admin rättar det sig självt. | 280–284, 466–468 |
| 8 | Reglerna kontrolleras innan de laddas | `nft -c` provläser reglerna och hittar skrivfel utan att aktivera något. | 274–315, 711 |

## 2. Loggning

| # | Åtgärd | Enkelt förklarat | Bevis |
|---|---|---|---|
| 9 | Loggar skickas krypterat till en central loggserver | Händelser sparas även på en annan server. En inkräktare kan inte sudda ut sina spår genom att bara radera loggarna lokalt. Kopplingen är krypterad (TLS) och kontrolleras med en egen CA (`labb-ca.pem`). | 635, 669, 686 |
| 10 | Brandväggen loggar stoppad trafik | När brandväggen säger nej skrivs det upp, så att det syns om någon försöker ta sig in. | 305–308 |
| 11 | auditd är igång | auditd är serverns "övervakningskamera": den skriver upp säkerhetshändelser, till exempel när SELinux nekar något. | 609, 621 |

## 3. SELinux

| # | Åtgärd | Enkelt förklarat | Bevis |
|---|---|---|---|
| 12 | Webbmappen `/srv/zonwebb` har rätt etikett | SELinux sätter en etikett på varje fil. Webbservern får bara läsa filer märkta `httpd_sys_content_t`, så mappen märktes rätt med `semanage fcontext` och `restorecon`. | 722–723 |
| 13 | Egen SELinux-policy för zonvakt | zonvakt har fått en egen regelbok (`zonvakt.pp`) som säger exakt vad tjänsten får göra, och inget mer. Programfilen och loggmappen fick rätt etiketter. | 754–756, 785 |
| 14 | zonvakt körs inte i permissive | Permissive betyder att SELinux bara skriver upp överträdelser utan att stoppa dem. Det är kontrollerat att zonvakt verkligen stoppas om den bryter mot reglerna. | 771 |
| 15 | Dolda nekanden visades tillfälligt vid felsökning | Vissa nekanden loggas normalt inte (dontaudit). De slogs på tillfälligt för att hitta fel (`semodule -DB`) och stängdes av igen efteråt (`semodule -B`). | 779–782 |
| 16 | zonvakt startar automatiskt | Tjänsten slås på av sig själv vid omstart. | 741 |

## 4. Verifiering

| # | Åtgärd | Enkelt förklarat | Bevis |
|---|---|---|---|
| 17 | Verifieringsskript `verifiera-hardning` | Ett eget skript som kontrollerar härdningen och svarar GÄLLER eller GÄLLER INTE för varje punkt. | 871 |
| 18 | Brandväggstest `brandvagg-test.sh` | Testar att rätt trafik släpps igenom och fel trafik stoppas. Svarar PASS eller FAIL. | 506 |
| 19 | Omstartstest | Servern startades om för att visa att allt fortfarande fungerar efteråt. | 932 |

---

## Att kontrollera innan inlämning

| Kontroll | Varför | Status |
|---|---|---|
| SSH in begränsad till två adresser (261–262) | Regeln låg i den gamla tabellen `ip filter`. Finns den kvar i `inet zon`? Kör `sudo nft list chain inet zon in`. | ☐ |
| Drop + logg av ADRESS-BORTTAGEN med prefix `U4.2-DROP` (322–323) | Samma fråga: finns regeln kvar? | ☐ |
