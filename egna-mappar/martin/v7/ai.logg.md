# AI-logg – vecka 7

Ansvarig: elev-34
AI-verktyg: Claude

## Hur jag har använt AI

⟨fylls i i slutet av veckan⟩

---

## Loggen

Varje dags avsnitt är ett utkast skrivet av Claude (AI) utifrån dagens chatt, som jag granskar och godkänner innan det sparas i repot.

Tiderna är svensk tid. "Prompt" är vad jag frågade, "AI:ns svar" är en kort sammanfattning av svaret, och "Rättelse / min kontroll" är vad jag gjorde med svaret.

### 2026-11-16 (måndag)

Utkast skrivet av Claude (AI) utifrån dagens chatt.

#### 1. U7.2 Kvittot – brandväggen (flöde D8)
- **Prompt (13:40):** Jag klistrade in svaret från `kontrollera U7.2` och bad om hjälp att lösa uppgiften.
- **AI:ns svar:** AI gav stegen för kvittot, Alias-filen i httpd och en bestående fcontext-regel. Om brandväggen föreslog AI först `firewall-cmd`.
- **Rättelse (13:44):** När AI läste studieguiden för vecka 7 visade det sig att servern använder nftables (vecka 4), inte firewalld, och att ctf-servern 172.20.1.10 måste släppas in på tcp/80. AI hade missat det i första svaret.
- **Min kontroll:** Jag listade regelverket med `sudo nft -a list chain inet zon in` och lade in regeln före loggraden `ZON-IN-DROP`. AI föreslog numret D8 i stället för D5, eftersom D5 tidigare användes för ett annat flöde. Efter regeln gav `kontrollera U7.2` flaggan (14:51).

#### 2. Onödigt steg i AI:ns förslag
- **AI:ns svar (13:51):** AI skrev att kvittofilen skulle få `chmod 644`.
- **Rättelse (13:54):** Jag påpekade att kontrollen inte kräver något om filrättigheter. AI bekräftade att steget inte står i studieguiden. Filen fick `-rw-r--r--` automatiskt.

#### 3. D8 skulle tåla en omstart
- **Prompt (14:52):** `/etc/sysconfig/nftables.conf` gick inte att läsa.
- **AI:ns svar:** Filen kräver `sudo`. Tjänsten nftables är `enabled` och läser den filen vid start, så D8 måste skrivas in där.
- **Min kontroll:** Jag tog en säkerhetskopia (`nftables.conf.fore-d8`), skrev det aktuella regelverket till filen och kontrollerade med `sudo nft -c -f` (Syntax OK) och `grep D8`.

#### 4. Portlista
- **Prompt (14:58):** Jag bad om hjälp att skriva en egen lista över mina regler, nuvarande och borttagna, och varför jag har dem.
- **AI:ns svar:** AI skrev `egna-mappar/martin/portlista.md` utifrån regelverket i nftables, säkerhetskopian och molnbrandväggen. Syftet för varje regel togs från kommentarerna i regelverket, och punkter som AI inte visste lämnades att fylla i.

---

## Reflektion

⟨fylls i i slutet av veckan⟩
