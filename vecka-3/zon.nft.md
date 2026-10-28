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

        ip saddr 172.20.1.2  tcp dport 22 accept comment "D1 SSH från jump"
        ip saddr 172.20.1.10 tcp dport 22 accept comment "D2 kontroll från ctf"
        ip saddr 172.20.1.2 icmp type echo-request accept comment "F1 ping från jump"
        tcp dport 22820 reject with tcp reset comment "F2 avvisa 22820 för alla"
        ip saddr 172.20.1.10 tcp dport 27585 accept comment "F3 intern port från ctf"
        # F-rader inkommande: fylls på när flödestabellen är klar

        limit rate 10/minute log prefix "ZON-IN-DROP " level info
    }

    chain ut {
        type filter hook output priority 0; policy drop;

        ct state established,related accept
        oif "lo" accept

        ip daddr { 185.12.64.1, 185.12.64.2 } meta l4proto { tcp, udp } th dport 53 accept comment "D3 DNS"
        oifname "eth0" udp dport 123 accept comment "D4 tidssynk chrony"
        ip daddr 172.20.1.58 tcp dport 514 accept comment "D5 logg till log"
        oifname "eth0" ip daddr 172.31.1.1 udp sport 68 udp dport 67 accept comment "D6 DHCP eth0"
        oifname "eth1" ip daddr 172.20.0.1 udp sport 68 udp dport 67 accept comment "D6 DHCP eth1"
        oifname "eth2" ip daddr 10.40.2.1  udp sport 68 udp dport 67 accept comment "D6 DHCP eth2"
        oifname "eth0" tcp dport 443 accept comment "D7 paketuppdateringar dnf"

        # F-rader utgående: fylls på när flödestabellen är klar

        limit rate 10/minute log prefix "ZON-UT-DROP " level info
    }
}