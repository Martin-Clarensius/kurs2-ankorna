# Milstolpe 1 – Trafikbaslinje: analys och belägg

## Syfte
Analysera normal trafik i labbmiljön med hjälp av tcpdump.
Undersöka SSH, DNS och HTTP samt dokumentera användning,
paketantal, TCP/IP-lager och belägg.

## 1. SSH – Fjärranslutning

- Fångstfil: ssh-baslinje.pcap
- Datum: 2026-10-08
- Tid: 08:39:46 UTC
- Antal paket: 221
- Protokoll: SSH över TCP
- Port: 22
- Klient: 172.20.1.2
- Server: 172.20.1.103

### Analys
SSH används för säker fjärranslutning till servern.
TCP-paket med data och ACK-bekräftelser observerades.
Det visar en aktiv SSH-anslutning.

### TCP/IP-lager
- Applikationslager: SSH
- Transportlager: TCP
- Internetlager: IP
- Nätverksåtkomst: Ethernet

## 2. DNS – Namnuppslagning

- Fångstfil: dns-baslinje.pcap
- Datum: 2026-10-08
- Tid: 08:52:20 UTC
- Antal paket: 4
- Protokoll: DNS över UDP
- Port: 53
- Klient: 2.28.98.141
- DNS-server: 185.12.64.2

### Analys
DNS används för att översätta domännamn till IP-adresser.

Två frågor skickades till DNS-servern:
- A-fråga för IPv4-adresser
- AAAA-fråga för IPv6-adresser

DNS-servern svarade på båda frågorna.

### TCP/IP-lager
- Applikationslager: DNS
- Transportlager: UDP
- Internetlager: IP
- Nätverksåtkomst: Ethernet

## 3. HTTP – Webbtrafik

- Fångstfil: http-baslinje.pcap
- Datum: 2026-10-08
- Tid: 09:01:39 UTC
- Antal paket: 10
- Protokoll: HTTP över TCP
- Port: 80
- Klient och server: 2.28.98.141
- Interface: lo (loopback)

### Analys
HTTP används för kommunikation med en webbserver.

En HEAD-förfrågan skickades.
Servern svarade med HTTP/1.1 200 OK.
TCP-anslutningen avslutades med FIN-paket.

### TCP/IP-lager
- Applikationslager: HTTP
- Transportlager: TCP
- Internetlager: IP
- Nätverksåtkomst: Loopback

## 4. Frekvens och trafikmängd

- SSH: 221 paket
- DNS: 4 paket, två frågor och två svar
- HTTP: 10 paket

Paketantalet gäller endast de undersökta fångsterna.
Det visar inte hur ofta trafiken förekommer över längre tid.

## 5. Kommandon och belägg

Följande kommandon användes för att analysera fångsterna:

sudo tcpdump -nn -tttt -r ssh-baslinje.pcap -c 3
sudo tcpdump -nn -tttt -r dns-baslinje.pcap
sudo tcpdump -nn -tttt -r http-baslinje.pcap

Fångstfilerna finns kvar på labbservern.
De laddas inte upp till GitHub.

## 6. Slutsats

Tre trafikfångster analyserades: SSH, DNS och HTTP.

SSH visade aktiv fjärrkommunikation.
DNS visade namnuppslagning med frågor och svar.
HTTP visade en lyckad HEAD-förfrågan med status 200 OK.

Ingen tydlig avvikelse observerades i de undersökta fångsterna.
