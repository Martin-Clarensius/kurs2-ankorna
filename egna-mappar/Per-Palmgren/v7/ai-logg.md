# AI-logg – milstolpe 7 (härdningsrapport)

**Ansvarig:** elev-33 (Per Palmgren)
**AI-verktyg:** Claude Code (Claude Opus 5.5) i VS Code
**Datum:** 2026-11-18

## Hur jag har använt AI

AI:n har använts för att sätta ihop en härdningslista ur mitt repo, föreslå kontrollkommandon och skriva rapporten utifrån utdata som jag klistrade in. AI:n hade ingen åtkomst till elev-33. Alla kommandon på servern har jag kört själv, och varje dom i rapporten bygger på utdata från servern ([belagg.md](belagg.md)). Promptar, råsvar och maskering finns i [metodbilaga.md](metodbilaga.md).

## Loggen

### 1. Härdningslista med en kamrats lista som mall

- **Prompt:** "Behöver göra en härdnings lista mot min labb dator som speglar det som är gjort på min elev-33 dator." Kamratens lista var inklistrad (hela texten finns i metodbilagan).
- **AI:ns svar:** Ett utkast byggt på filerna i repot (`nft-backup.nft`, `90-tls-forward.conf`, `loggning.md`, v6). Kolumnen för radnummer i historiken var tom, och AI:n listade avvikelser mellan filerna (gammal `zon.nft`, `60-brandvagg.conf` med tcp 514).
- **Rättelse / min kontroll:** Utkastet saknade det som inte fanns i repot: SELinux, zonvakt, verifieringsskriptet och omstartstestet. Kommandoförslaget `history | grep -nE` hade gett grep:s radnummer i stället för historikens, och det rättades innan jag körde det.

### 2. SELinux och zonvakt

- **Prompt:** "Kan du korrigera nu när jag klistrat in SELinux från min dator", och sedan "Nu har jag sparat den".
- **AI:ns svar:** Första gången hittade AI:n ingenting, eftersom texten låg i en osparad flik. När filen var sparad fördelade AI:n min tabell på avsnitten brandvägg, SELinux och verifiering. Den lade också till kontrollpunkter: i vilken tabell reglerna för 7533 och 80 ligger, och var skriptet finns.
- **Rättelse / min kontroll:** Innehållet var mitt eget. AI:n ordnade bara om det.

### 3. Radnummer ur historiken

- **Prompt:** Utdata från `history | grep -E '...'` (två körningar, B10 och B11).
- **AI:ns svar:** Fyllde i radnummer för varje åtgärd. Den hittade två saker jag inte hade tänkt på: den tillfälliga regeln för tcp/80 till loggservern (rad 348–349), som aldrig togs bort med något kommando, och att kontroll 5 i skriptet rättades efter omstarten (rad 967, 973).
- **Rättelse / min kontroll:** Den tillfälliga regeln kontrollerades i punkt 4.

### 4. Det laddade regelsetet och regelfilen

- **Prompt:** Utdata från `sudo nft list ruleset`, `cat /etc/sysconfig/nftables.conf` och `cat /etc/nftables/zon.nft` (B1–B3).
- **AI:ns svar:** Bekräftade att reglerna för 7533 och 80 ligger i `inet zon` och att den tillfälliga regeln för port 80 är borta. Den påpekade att kommentaren `"F2 Httpd"` inte stämmer med flödestabellen och att kontroll 5 (`grep -q '172.20.1.10'`) också träffar SSH-regeln från ctf. Repots gamla `zon.nft` ersattes med serverns.
- **Rättelse / min kontroll:** AI:n hade påstått att reglerna står i `/etc/sysconfig/nftables.conf`. B2 visade att filen bara innehåller `include "/etc/nftables/zon.nft"`. Det står som R5 i rättelseloggen.

### 5. Kontroller på servern

- **Prompt:** Utdata en i taget från `nft -c`, `ls -l /etc/rsyslog.d/`, `sshd -T`, `systemctl is-enabled`, `ls -lZ` på `ca.pem` och `getent hosts` (B4–B9).
- **AI:ns svar:** Uppdaterade listan efter varje utdata och strök det som var avklarat. Den visade att `60-brandvagg.conf` inte längre finns på servern, att firewalld inte är installerat och att SSH tillåter lösenordsinloggning.
- **Rättelse / min kontroll:** AI:ns förslag `systemctl is-enabled nftables firewalld rsyslog auditd` avbröts vid firewalld, så rsyslog och auditd fick köras om. Två gånger skickade jag bara kommandot utan utdata. Då frågade AI:n efter utdatan i stället för att gissa.

### 6. Rapport, metodbilaga och incheckning

- **Prompt:** "Detta ska vara gjort idag En härdningsrapport där varje påstående har en dom och ett belägg från din server, plus en rättelselogg med minst ett rättat fel. En metodbilaga med prompt, råsvar och vad du maskerade. Allt incheckat i teamets repo."
- **AI:ns svar:** Skrev [hardningsrapport.md](hardningsrapport.md) (33 påståenden med dom, R1–R5, K1–K6), [belagg.md](belagg.md) och [metodbilaga.md](metodbilaga.md). Rättade v6 (tcp 514 och loggprefixet) och märkte `60-brandvagg.conf` som oanvänd. Committade och pushade till `palmgren`.
- **Rättelse / min kontroll:** Påståenden som bara stöds av ett kommando i historiken fick domen "Stämmer (historik)", inte "Stämmer". ⟨Kontrollera maskeringsavsnittet i metodbilagan.⟩

### 7. Brister K1 och K2

- **Prompt:** Frågan vad som återstår, och sedan utdata från `sudo ./verifiera-hardning` (B12).
- **AI:ns svar:** Gav steg för att stänga av lösenordsinloggning i SSH utan att låsa ute mig: kontrollera hur CTF loggar in, testa nyckel via jump, lägga filen `01-hardning.conf` före cloud-inits fil och ha en reservsession öppen. För kontroll 5 föreslog AI:n ett snävare grep-mönster och ett negativt test. B12 gjorde att SELinux-punkterna kunde ändras till "Stämmer".
- **Rättelse / min kontroll:** AI:n påpekade att B12 inte visar om kontroll 5 är ändrad, eftersom etiketten är densamma. ⟨Resultat för K1 och K2 när de är gjorda.⟩

## Reflektion

AI:n var användbar för att ordna material, föreslå kontroller och strukturera rapporten. Men den hade fel flera gånger, och jag upptäckte det bara genom att kontrollera mot serverns utdata. Radnumren från history | grep -nE var fel, eftersom grep räknade sina egna rader. AI:n påstod också att reglerna låg i /etc/sysconfig/nftables.conf, men filen innehöll bara en include-rad. Det blev rättelse R5.

Det lärde mig att inte lita på ett påstående om en fil förrän jag sett filens innehåll. Förslag från AI:n körde jag bara efter att jag själv förstått dem, och när AI:n saknade utdata frågade den efter den i stället för att gissa, vilket gjorde det enklare att lita på slutsatserna.

Därför har påståenden som bara stöds av historiken fått domen "Stämmer (historik)" och inte "Stämmer". Det är en medveten gräns, och jag hellre redovisar den än överdriver hur säkra resultaten är.

Nästa gång skulle jag skriva ner vad jag förväntar mig av varje kommando innan jag kör det. Det hade fångat både radnummerfelet och R5 tidigare.
