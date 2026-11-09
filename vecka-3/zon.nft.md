#!/usr/sbin/nft -f
flush ruleset


# ---------- Zondefinitioner (byt namn när zontabellen är klar) ----------
define GW      = 10.40.2.1
define JUMP    = 172.20.1.2
define MIN_IP  = 10.40.2.99

define WebServ   = 10.40.2.0/27
define AppServ   = 10.40.2.32/27
define DataServ   = 10.40.2.64/28
define LoggServ   = 10.40.2.80/28
define AdminServ   = 10.40.2.96/28   


table inet zon {
  chain in {
        type filter hook input priority 0; policy drop;

        ct state established,related accept
        ct state invalid drop
        iif "lo" accept
        # Driftsregler för SSH och kontroll från CTF
        ip saddr 172.20.1.2 tcp dport 22 accept comment"D1 SSH fran jump"
        ip saddr 172.20.1.10 tcp dport 22 accept comment"D2 kontroll från ctf"
        ip saddr 2.28.43.156 ntp dport 123 udp accept comment "D4 NTP"
        # Rader ur flödestabellen, en regel per rad. att fylla på med fler regler när flödestabellen är klar
        limit rate 10/minute log prefix "ZON-IN-DROP" level info
        }
  chain ut {
        type filter hook output priority 0; policy drop;
        ct state established,related accept
        oif "lo" accept
        ip daddr {185.12.64.1,185.12.64.2} meta l4proto {tcp,udp} th dport 53 accept comment "D3 DNS"
        ip daddr 172.20.1.58 tcp dport 514 accept comment "D5 logg till log"
        udp sport 68 udp dport 67 accept comment "D6 DHCP-förnyelse"
        # Fler rader för utgående riktning fyllas på när flödestabellen är klar
        limit rate 10/minute log prefix "ZONE-UT-DROP" level info
        }

}