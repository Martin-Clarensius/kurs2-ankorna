# Vecka 6 – Brusmätning

**Kurs:** ITSX26 – Infrastruktur och nätverksgrunder  
**Team:** Ankorna  
**Ansvarig:** elev-03

## Detektion – SSH brute force

**Wazuh-regel:** 5712  
**Antal larm:** 4  
**Källa:** Wazuh Discover och CTF U6.3

### 1. Observation

Jag undersökte regel 5712 i Wazuh Discover och räknade hur många larm regeln genererade under den aktuella kontrollperioden.

Resultatet blev 4 larm. Antalet verifierades genom kommandot `kontrollera U6.3 4`, som gav ett godkänt resultat.

### 2. Analys av brus

Fyra larm innebär att en SOC-analytiker kan behöva undersöka upp till fyra larmhändelser under perioden.

Antalet visar däremot inte om larmen är verkliga angrepp eller legitima tester. För att bedöma brusnivån behöver vi undersöka varje larm och jämföra med normal aktivitet.

### 3. Slutsats

Regel 5712 genererade 4 larm under kontrollperioden.

Innan vi ändrar ett tröskelvärde behöver vi undersöka hur larmen är fördelade över tid och om de representerar verkliga hot eller förväntad aktivitet.

**Status:** Antalet verifierat. Bedömning av falsklarm återstår.
