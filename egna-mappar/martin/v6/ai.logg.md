# AI-logg – milstolpe 6 (detektioner och playbooks)
 
Ansvarig: elev-34
Datum: 2026-11-12 (och U6.5 tidigare samma dag)
AI-verktyg: Claude (och en tidigare AI-chatt, "Ledare", för händelse 1–2 och U6.5)
 
## Hur jag har använt AI
 
Jag har använt AI som en studiekamrat att bolla idéer med när jag fastnade, och som stöd för att strukturera dokumentationen. Alla kommandon har jag kört själv, alla monitorer har jag byggt själv i Wazuh, och alla siffror och värden i dokumentationen kommer från min egen miljö. När AI:ns förslag inte stämde med det jag såg i loggen eller terminalen har jag gått på det jag själv såg.
 
Hela konversationen finns sparad ⟨länk eller fil⟩.
 
---
 
## Loggen
 
Tiderna är svensk tid. "Prompt" är vad jag frågade, "AI:ns svar" är en kort sammanfattning av svaret, och "Rättelse / min kontroll" är vad jag gjorde med svaret.
 
### 1. Komma igång med uppgiften
- **Prompt (10:20):** Jag bad om hjälp att skriva playbook och nedbrytning.
- **AI:ns svar:** AI gissade inte hur uppgiften såg ut. Den frågade efter uppgiftstexten först.
- **Min kontroll:** Jag skickade zonuppdraget och studieguiden för vecka 6. Därefter tog AI fram en mall utifrån kraven (loggkälla, fält, värden, gränsfall, brus i timmar, playbook i NIST:s fyra faser).
### 2. Vilka kommandon behövs
- **Prompt (10:24):** "kan du hjälpa mig att skriva vilka kommandon du behöver för att skriva en komplett inlämning"
- **AI:ns svar:** En lista med sökningar i Wazuh och kommandon på servern.
- **Min kontroll:** Jag bad AI att alltid skriva ut om ett kommando ska köras i **ssh jump** eller **ssh lab**, eftersom jag har två terminaler. Det gjorde det lättare för mig att inte blanda ihop dem.
### 3. Brusmätning
- **Prompt (10:31):** Jag skickade mina egna mätningar för de fyra detektionerna (15,5 h).
- **AI:ns svar:** AI påpekade att 0 träffar inte bevisar att en regel fungerar, och att varje detektion behöver ett framkallat larm.
- **Min kontroll:** Jag framkallade alla händelser och såg larmen gå.
### 4. Loggprefixet i nftables
- **AI:ns svar (tidigare):** AI skrev att loggprefixet var `ZONE-UT-DROPIN`.
- **Rättelse (10:34):** När jag listade reglerna med `sudo nft list ruleset` såg jag att prefixet är `ZONE-UT-DROP`. `IN=` sitter bara ihop med det i loggraden. Dokumentationen rättades.
### 5. Framkalla misslyckad sudo (D4)
- **Prompt (10:35):** Jag försökte skriva fel lösenord, men skrev rätt av vana två gånger.
- **AI:ns svar:** Ett kommando som alltid ger fel lösenord: `echo fel | sudo -S -k true`.
- **Min kontroll:** Jag körde det och fick `1 incorrect password attempt`. Larmet kom 10:37.
### 6. D1 larmade inte (det största felet)
- **AI:ns svar (10:41):** AI gissade att monitorn filtrerade på `agent.name`, som alltid är `log`.
- **Rättelse (11:06):** Jag öppnade monitorn (Edit) och tog en skärmdump. Felet var i stället `location is *elev-34*`. `is` kräver exakt match, så stjärnorna tolkades bokstavligt. Jag ändrade till `location contains elev-34`.
- **Resultat:** D1 larmade 11:12 efter ett nytt test. Det här lärde jag mig mest av i dag.
### 7. Fel terminal
- **Vad som hände (11:14):** Jag körde `sudo id` i ssh jump i stället för ssh lab och fick "not allowed".
- **AI:ns svar:** AI förklarade skillnaden mellan prompterna och att det inte förstörde något.
- **Min kontroll:** Jag körde om i ssh lab. Larmet för D3 kom 11:15.
### 8. Fel tidsfönster för normaltrafiken
- **Vad som hände (11:18):** Jag sökte 08:00–09:00 i stället för 08:06–08:37.
- **AI:ns svar:** AI bad mig bekräfta siffran för D1 i exakt fönster i stället för att räkna på det fel fönstret.
- **Min kontroll:** Jag sökte igen, och 307 träffar bekräftades.
### 9. ATT&CK-tekniker
- **AI:ns svar:** AI föreslog T1571 för D2 och T1548.003 för D3 och D4.
- **Mitt beslut:** Jag valde bort förslagen eftersom ATT&CK inte krävs för milstolpe 6. Jag behöll T1110 för D1 (studieguiden) och T1071.001 för D5 (krav i U6.5). Senare såg jag att Wazuh själv märker regel 5503 (D4) med T1110.001.
### 10. Larmet för D3 kl. 10:29
- **AI:ns svar:** AI undrade om larmet kunde komma från ctf-serverns root-inloggning.
- **Rättelse (11:59):** Monitorns fråga kräver `auid=1000`, så larmet kom från mitt eget konto `student` och inte från ctf-servern.
### 11. Flöde D7 (paketuppdateringar)
- **AI:ns svar (12:01):** AI rekommenderade att öppna D7 i nftables mot en enda adress (146.75.122.132), eftersom alla tidigare blockeringar gick dit.
- **Rättelse (12:10):** Jag testade det. Det visade sig att adressen bara var spegellistan. dnf försökte sedan nå 11 andra adresser på 3 minuter, och alla blockerades. AI:ns rekommendation höll alltså inte.
- **Min åtgärd:** Jag tog bort den tillfälliga regeln och dokumenterade resultatet och tre alternativ som teamet får besluta om.
### 12. U6.5 (egen detektion, tidigare under dagen)
- **Prompt:** Jag hittade inte rätt ATT&CK-teknik själv på attack.mitre.org.
- **AI:ns svar:** T1071.001 Web Protocols, eftersom trafiken gick över HTTPS och taktiken var Command and Control. T1029 valdes bort eftersom den hör till Exfiltration.
- **Min kontroll:** Jag byggde monitorn själv, och kontrollen godkände den.

---
 
## Reflektion
 
AI hjälpte mig framför allt att komma vidare när jag fastnade och att få ordning på dokumentationen. Men flera av AI:ns gissningar var fel (punkt 4, 6, 10 och 11), och det var när jag själv tittade i Wazuh eller terminalen som jag hittade de riktiga svaren. Det viktigaste jag lärde mig är att alltid kontrollera förslag mot det som faktiskt syns i loggen innan jag ändrar något.