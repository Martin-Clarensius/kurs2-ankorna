# Vecka 6 – Triagelogg

**Kurs:** ITSX26 – Infrastruktur och nätverksgrunder  
**Team:** Ankorna  
**Ansvarig:** elev-03

## Larm 1 – Misstänkt SSH brute force

**Datum och tid:** 2026-11-11 kl. 08:16:48.825 (enligt Wazuh Discover)  
**Wazuh-regel:** 5712  
**Käll-IP:** 10.40.2.199  
**Antal matchande larm:** 1

### 1. Vad hände? – Observation

I Wazuh Discover hittade jag ett larm med regel-ID 5712 och käll-IP 10.40.2.199.

Regel 5712 är kopplad till upprepade misslyckade SSH-inloggningsförsök och kan indikera ett brute force-angrepp.

Sökningen `rule.id: 5712 AND data.srcip: "10.40.2.199"` visade en matchande larmhändelse under det valda tidsintervallet på 24 timmar.

### 2. Vad berördes?

Käll-IP-adressen 10.40.2.199 identifierades i larmet.

Vilken server och vilka användarkonton som berördes behöver fortfarande verifieras genom att undersöka logghändelsen och söka efter relaterade händelser utan värdfilter.

### 3. Vad ska göras? – Slutsats och beslut

Larmet visar ett mönster som kan tyda på brute force, men det är ännu inte bekräftat om aktiviteten var ett verkligt angrepp eller ett planerat test.

**Beslut:** Under utredning.

Nästa steg är att kontrollera relaterade inloggningsförsök, berörda användarkonton och eventuella lyckade inloggningar från samma käll-IP.

Larmet ska inte avfärdas utan ett verifierbart skäl.

### Verifierbart underlag

- Wazuh Discover, regel-ID 5712.
- Käll-IP: 10.40.2.199.
- Tidsstämpel: 2026-11-11 08:16:48.825 enligt Discover.
- Antal matchande larm i sökningen: 1.
- Ytterligare logggranskning krävs för att fastställa slutsatsen.
