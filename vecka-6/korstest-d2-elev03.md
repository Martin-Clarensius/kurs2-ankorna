# Korstest – D2 Zonöverträdelse

**Testare:** elev-03  
**Playbookansvarig:** elev-34 (Martin)  
**Datum:** 2026-11-16  
**Resultat:** Godkänt korstest av larm och triage

## Observationer

Jag följde Martins D2-playbook i Wazuh.

- Monitorn `elev-34 zonöverträdelse (zon-ut-drop)` var aktiverad.
- Larmet startade 2026-11-12 kl. 10:34 och avslutades kl. 10:39.
- Jag sökte i `wazuh-archives-*` och hittade två loggposter.
- Loggarna visade blockerad TCP-trafik från `167.233.215.66` till `1.1.1.1:8080`.
- Trafiken saknade tillåtelse i de granskade flödesreglerna.
- Martin bekräftade att han själv körde testet.

## Slutsats

Larmet orsakades av ett godkänt test. Händelsen avfärdas som förväntad testaktivitet.

Playbookens instruktioner för att hitta larmet, analysera loggarna och fatta ett triagebeslut fungerade.

Ingen ytterligare inneslutning behövdes eftersom trafiken redan hade blockerats av brandväggen.

**Begränsning:** Processens identitet verifierades inte separat genom processloggar.

**Slutresultat:** Godkänt korstest av D2-playbookens larm- och triagedel.
