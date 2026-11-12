# SOC-playbook – SSH Brute Force

**Kurs:** ITSX26 – Kurs 2, vecka 6  
**Team:** Ankorna  
**Ansvarig:** elev-03  
**Wazuh-regel:** 5712

## 1. Förberedelse (Preparation)

- Kontrollera att Wazuh tar emot autentiseringsloggar från berörda servrar.
- Kontrollera att rätt tidsintervall används i Discover.
- Säkerställ att loggarna innehåller tidpunkt, käll-IP och värdnamn.

## 2. Upptäckt och analys (Detection and Analysis)

1. Sök efter `rule.id: 5712` i Wazuh Discover.
2. Identifiera käll-IP, tidsstämpel och berörd server.
3. Sök efter samtliga autentiseringshändelser från samma `data.srcip` inom 10 minuter före och efter larmet.
4. Undersök antalet misslyckade inloggningar.
5. Kontrollera om samma IP-adress försökte logga in på flera användarkonton.
6. Sök efter lyckade inloggningar från samma IP-adress.
7. Upprepa sökningen utan värdfilter för att hitta andra berörda servrar.
8. Dokumentera observationer och slutsatser separat i triageloggen.

## 3. Begränsning, eliminering och återställning

**Eskalera om:**
- En lyckad inloggning följer efter upprepade misslyckade försök.
- Flera servrar eller användarkonton berörs.
- Det finns andra tecken på obehörig åtkomst.

Kontakta teamets incidentansvariga eller handledaren enligt överenskommen rutin.

Bifoga regel-ID, käll-IP, tidsstämplar, berörda servrar, loggposter och en kort motivering.

**Avfärda endast om:**
- Loggar och annan verifierbar dokumentation visar att aktiviteten var ett godkänt test.
- Beslutet kan motiveras med konkreta observationer.

## 4. Uppföljning (Post-Incident Activity)

- Dokumentera beslutet och underlaget i triageloggen.
- Kontrollera om detektionsregeln behöver justeras.
- Uppdatera playbooken efter återkoppling från teamet.
- Avsluta ärendet när åtgärderna har dokumenterats.

## Korstest

**Testad av:** Ej genomfört  
**Datum:** Ej ifyllt  
**Resultat:** Ej verifierat  
**Förbättringar:** Ej ifyllt
