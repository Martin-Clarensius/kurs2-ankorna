# Spårbarhet – Team Ankorna, vecka 4

| Regel | Trafik | Status | Bevis |
|---|---|---|---|
| F1 | Internet → Webb TCP 443 | Konfigurerad | Molnbrandvägg och nftables; HTTPS-test återstår |
| F2 | Webb → Application | Väntar | IP och port behöver bekräftas |
| F3 | Application → Databas | Väntar | Teamverifiering |
| F4 | Servrar → Loggserver | Delvis | Utgående TCP 514 finns på elev-03 |
| F5 | Jump → Management | Väntar | Teamverifiering |
| F6 | Management → Servrar | Väntar | Teamverifiering |
| F7 | Internet → Databas | Väntar | Teamverifiering |
| F8 | Internet → Management | Väntar | Teamverifiering |
| F9 | Webb → Databas TCP 5432 | Testad | Timeout och ZON-UT-DROP |
| F10 | Otillåten TCP 8080 | Testad | Timeout och ZON-UT-DROP |
| D1 | SSH från jump | Verifierad | SSH till elev-03 fungerar |
| D2 | SSH från CTF | Konfigurerad | nftables-regel finns |
| D3 | DNS TCP/UDP 53 | Konfigurerad | nftables-regler finns |
| D4 | NTP UDP 123 | Konfigurerad | nftables-regel finns |
| D5 | Logg TCP 514 | Konfigurerad | nftables-regel finns |
| D6 | DHCP UDP 67 | Konfigurerad | nftables-regel finns |
| D7 | Uppdateringar TCP 443 | Konfigurerad | nftables-regel finns |

Statusen avser kontroller på elev-03 om inget annat anges.
Konfigurerad betyder inte att trafiktest är godkänt.
F9 och F10 testades mot 10.40.2.65, en obekräftad testadress.
