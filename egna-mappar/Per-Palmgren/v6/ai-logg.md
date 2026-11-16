# AI-logg – milstolpe 6 (detektioner och playbooks)

**Ansvarig:** elev-33 (Per Palmgren)
**AI-verktyg:** Claude i VsCode

## Hur jag har använt AI

AI har använts för att ta fram strukturen för inlämningen och förslag på sökningar och monitor-frågor. Alla kommandon har jag kört själv, alla monitorer har jag byggt själv i Wazuh, och alla siffror och värden i dokumentationen kommer från min egen miljö.

## Loggen

### 1. Mall för inlämningen

- **Prompt (2026-11-12):**Granska min inlämning mot övriga i teamet om den återspeglar mitt arbete kring v6 i teamet. se över helheten i teamets repo, för att återge vad jag behöver justera. 

- **AI:ns svar:** AI läste teamets vecka 6-filer (Martins `v6/` och Liibaans `vecka-6/`) och mina egna filer (`loggning.md`, `brandvägg/cfg/`), och skapade en mall med D1–D5, triagelogg och AI-logg. Mätvärden lämnades som ⟨…⟩ att fylla i.

- **Min kontroll:** AI anpassade mallen till min miljö: elev-33, auditd-nyckeln `root_cmd` (inte `rootcmd` som hos Martin), loggprefixen `ZON-IN-DROP`/`ZON-UT-DROP`, och att D7 (tcp 443 ut) redan är öppen hos mig. ⟨Bekräfta mot `sudo nft list ruleset` och `sudo auditctl -l`.⟩

### 2. ⟨nästa⟩
- **Prompt:** ⟨…⟩
- **AI:ns svar:** ⟨…⟩
- **Rättelse / min kontroll:** ⟨…⟩

## Reflektion

⟨…⟩
