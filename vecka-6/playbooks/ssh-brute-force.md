# SOC-playbook – SSH Brute Force

**Kurs:** ITSX26 – Kurs 2, vecka 6  
**Team:** Ankorna  
**Ansvarig:** elev-03  
**Wazuh-regel:** 5712  
**Relaterad regel:** 40112

## 1. Förberedelse (Preparation)

- Kontrollera att Wazuh tar emot autentiseringsloggar från berörda servrar.
- Kontrollera att rätt tidsintervall och tidszon används i Wazuh Discover.
- Säkerställ att loggarna innehåller tidpunkt, käll-IP, värdnamn och användarkonto när uppgifterna finns tillgängliga.
- Kontrollera att SSH-tjänsten (`sshd`) fungerar och att logginsamlingen är aktiv.
- Identifiera kända legitima källor, exempelvis jump-servern `172.20.1.2` och CTF-servern `172.20.1.10`, när dessa är relevanta för den undersökta miljön.
- Säkerställ att teamets kontaktväg för incidenteskalering är känd.

## 2. Upptäckt och analys (Detection and Analysis)

### Steg 1 – Identifiera larmet

1. Öppna Wazuh Discover.
2. Sök efter `rule.id: 5712`.
3. Identifiera larmets tidsstämpel, käll-IP och berörd server.
4. Kontrollera hur många larm som har genererats under den valda perioden.
5. Dokumentera observationerna i triageloggen.

### Steg 2 – Undersök SSH-inloggningarna

6. Sök efter samtliga autentiseringshändelser från samma `data.srcip` inom 10 minuter före och efter larmet.
7. Undersök antalet misslyckade SSH-inloggningar.
8. Kontrollera om samma IP-adress försökte logga in på flera användarkonton.
9. Sök efter lyckade inloggningar från samma IP-adress.
10. Kontrollera om en lyckad inloggning använde lösenord eller `publickey`.
11. Dokumentera användarkonto, käll-IP, tidsstämpel och autentiseringsmetod.

### Steg 3 – Kontrollera relaterade larm

12. Sök efter regel `40112` för att undersöka om upprepade misslyckade autentiseringar följdes av en lyckad inloggning.
13. Jämför händelsernas tidsordning och kontrollera om de verkligen hör ihop.
14. Jämför resultaten med dokumenterade CTF-tester och kända legitima källor.
15. En lyckad SSH-nyckelinloggning från CTF-servern är inte i sig bevis för att ett lösenord har gissats.
16. Upprepa sökningen utan värdfilter för att identifiera andra berörda servrar.

### Steg 4 – Bedöm larmet

Besvara följande frågor:

- **Vad hände?** Vilka inloggningsförsök syns i loggarna?
- **Vad berördes?** Vilka servrar, användarkonton och tjänster påverkades?
- **Vad ska göras?** Ska larmet avfärdas, undersökas vidare eller eskaleras?

Dokumentera observationer och slutsatser i separata fält i triageloggen.

## 3. Begränsning, eliminering och återställning (Containment, Eradication and Recovery)

### Eskalera om

- En lyckad inloggning följer efter upprepade misslyckade försök och inte kan förklaras som ett godkänt test eller annan verifierad legitim aktivitet.
- Flera servrar eller användarkonton berörs av misstänkt aktivitet.
- Käll-IP-adressen är okänd och det finns tecken på obehörig åtkomst.
- Loggarna visar misstänkta kommandon eller andra aktiviteter efter en inloggning.

### Eskaleringsrutin

1. Kontakta teamets incidentansvariga eller handledaren enligt överenskommen rutin.
2. Dokumentera varför händelsen behöver eskaleras.
3. Bifoga följande underlag:
   - Wazuh-regel-ID.
   - Käll-IP och berörda servrar.
   - Tidsstämplar och tidszon.
   - Berörda användarkonton.
   - Relevanta loggposter.
   - Resultat från sökningar efter lyckade inloggningar.
4. Dokumentera vem som tog emot eskaleringen och när.

### Begränsning och återställning

Om incidentansvarig bekräftar att åtgärder behövs:

1. Bedöm om käll-IP-adressen ska blockeras i brandväggen.
2. Kontrollera befintliga regler i `nftables` och molnbrandväggen.
3. Ändra inte brandväggsregler utan godkännande och en säker återställningsplan.
4. Vid misstänkt kontokompromettering: undersök aktiva sessioner och begränsa kontots åtkomst enligt incidentrutinen.
5. Kontrollera SSH-konfigurationen, inklusive `PasswordAuthentication` och `PermitRootLogin`.
6. Verifiera att legitima anslutningar fortfarande fungerar efter eventuella åtgärder.

### Avfärda endast om

- Loggar och annan verifierbar dokumentation visar att aktiviteten var ett godkänt test eller annan förväntad aktivitet.
- Käll-IP, tidpunkt och autentiseringsmetod stämmer med den dokumenterade förklaringen.
- Eventuella lyckade inloggningar har undersökts.
- Beslutet kan motiveras med konkreta observationer.

Ett antagande om att aktiviteten var ofarlig är inte tillräckligt.

## 4. Uppföljning (Post-Incident Activity)

1. Dokumentera slutligt beslut och bevis i triageloggen.
2. Kontrollera om detektionsregeln behöver justeras.
3. Undersök om larmet var ett verkligt hot eller ett falskt positivt larm.
4. Om tröskelvärdet ändras, genomför en ny brusmätning.
5. Uppdatera playbooken efter återkoppling från teamet.
6. Dokumentera eventuella förbättringar av loggning, övervakning och incidenthantering.
7. Avsluta ärendet först när beslut och åtgärder är dokumenterade.

## 5. Brusmätning – U6.3

**Wazuh-regel:** 5712  
**Antal larm:** 4  
**Verifiering:** `kontrollera U6.3 4`  
**Resultat:** Godkänt den 12 november 2026.

### Observation

Regel 5712 genererade fyra larm under CTF-uppgiftens kontrollperiod.

### Slutsats

Fyra larm innebär att en analytiker kan behöva granska upp till fyra larmhändelser.

Det är ännu inte fastställt hur många som är falskt positiva. Innan tröskelvärdet ändras behöver larmen jämföras med normal trafik och dokumenterade tester.

**Status:** Antalet verifierat. Bedömning av falsklarm återstår.

## 6. Bevismaterial

Följande skärmbilder finns i projektet:

- `vecka-6/evidence/U6.2-discover-elev03.png`
- `vecka-6/evidence/U6.2-ssh-bruteforce.png`

Skärmbilderna visar Wazuh-detektionen och ett observerat larm.

Den detaljerade undersökningen dokumenteras i:

`vecka-6/triagelogg.md`

## 7. Korstest

**Testad av:** Ej genomfört  
**Datum:** Ej ifyllt  
**Resultat:** Ej verifierat  
**Förbättringar:** Ej ifyllt

### Instruktioner till testaren

1. Framkalla eller välj en ny SSH-larmhändelse i den godkända labbmiljön.
2. Följ playbookens instruktioner utan hjälp från författaren.
3. Identifiera käll-IP, berörd server och eventuella användarkonton.
4. Kontrollera om lyckade inloggningar förekommer.
5. Bedöm om larmet ska avfärdas eller eskaleras.
6. Dokumentera vilka instruktioner som fungerade och vilka som behöver förbättras.

Korstestet ska dokumenteras först när det faktiskt har genomförts.

## 8. Sammanfattning

Denna playbook beskriver hur teamet ska upptäcka, undersöka och hantera misstänkta SSH brute force-händelser med hjälp av Wazuh.

Målet är att varje larm ska kunna hanteras på ett konsekvent, spårbart och granskbart sätt.

**Status:** Playbook dokumenterad. Korstest och slutlig triagebedömning återstår.