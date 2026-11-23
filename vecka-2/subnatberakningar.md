# Subnätsberäkningar – Team Ankorna

## 1. Utgångspunkt

Adressutrymme: 10.40.2.0/24

Ett /24-nät innehåller 256 adresser.
Nätet delas upp i fem subnät.

## 2. Beräkningsmetod

/27:
- Subnätmask: 255.255.255.224
- Blockstorlek: 32 adresser
- Användbara värdadresser: 30

/28:
- Subnätmask: 255.255.255.240
- Blockstorlek: 16 adresser
- Användbara värdadresser: 14

Formel:
Antal adresser = 2 upphöjt till antal värdbitar.
Användbara adresser = totalt antal adresser minus 2.
De två adresserna är nätadress och broadcastadress.

## 3. Teamets fem subnät

### Webb / DMZ
- Nätadress: 10.40.2.0/27
- Mask: 255.255.255.224
- Broadcast: 10.40.2.31
- Användbara adresser: 10.40.2.1–10.40.2.30
- Teamets serveradresser: 10.40.2.2–10.40.2.24
- Reserverat för tillväxt: 10.40.2.25–10.40.2.30

### Applikation
- Nätadress: 10.40.2.32/27
- Mask: 255.255.255.224
- Broadcast: 10.40.2.63
- Användbara adresser: 10.40.2.33–10.40.2.62
- Teamets serveradresser: 10.40.2.34–10.40.2.56
- Reserverat för tillväxt: 10.40.2.57–10.40.2.62

### Databas
- Nätadress: 10.40.2.64/28
- Mask: 255.255.255.240
- Broadcast: 10.40.2.79
- Användbara adresser: 10.40.2.65–10.40.2.78
- Teamets serveradresser: 10.40.2.66–10.40.2.74
- Reserverat för tillväxt: 10.40.2.75–10.40.2.78

### Logg / övervakning
- Nätadress: 10.40.2.80/28
- Mask: 255.255.255.240
- Broadcast: 10.40.2.95
- Användbara adresser: 10.40.2.81–10.40.2.94
- Teamets serveradresser: 10.40.2.82–10.40.2.90
- Reserverat för tillväxt: 10.40.2.91–10.40.2.94

### Management / admin
- Nätadress: 10.40.2.96/28
- Mask: 255.255.255.240
- Broadcast: 10.40.2.111
- Användbara adresser: 10.40.2.97–10.40.2.110
- Teamets serveradresser: 10.40.2.98–10.40.2.106
- Reserverat för tillväxt: 10.40.2.107–10.40.2.110

## 4. Kontroll av blockstorlekar

- 10.40.2.0/27 omfattar .0–.31.
- 10.40.2.32/27 omfattar .32–.63.
- 10.40.2.64/28 omfattar .64–.79.
- 10.40.2.80/28 omfattar .80–.95.
- 10.40.2.96/28 omfattar .96–.111.

Subnäten överlappar inte varandra.

## 5. Viktiga begränsningar

Adressplanen anger att 10.40.2.1 är reserverad som gateway för hela nätet.

Adressplanen förklarar inte särskilt varför vissa första användbara adresser, exempelvis .33, .65, .81 och .97, inte ingår i server- eller tillväxtintervallen. Dessa adresser ska inte tilldelas utan bekräftelse från teamet.

## Slutsats

Teamets fem subnät har kontrollerats med hjälp av prefix, subnätmask, blockstorlek, nätadress och broadcastadress.

Beräkningarna visar hur adressutrymmet 10.40.2.0/24 har delats upp i två /27-nät och tre /28-nät.
