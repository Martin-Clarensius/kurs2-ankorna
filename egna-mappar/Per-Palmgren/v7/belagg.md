# Belägg från elev-33

Råutdata från elev-33 (10.40.2.99), körda i ssh lab 2026-11-18 och inklistrade oförändrade. Rapporten [hardningsrapport.md](hardningsrapport.md) hänvisar hit med B-nummer.

## B1 – `sudo nft list ruleset`

Sparad som egen fil: [nft-ruleset-elev-33.nft](nft-ruleset-elev-33.nft). Den sista `}` saknades i inklistringen och är tillagd där.

## B2 – `sudo cat /etc/sysconfig/nftables.conf`

```
# Uncomment the include statement here to load the default config sample
# in /etc/nftables for nftables service.

#include "/etc/nftables/main.nft"

# To customize, either edit the samples in /etc/nftables, append further
# commands to the end of this file or overwrite it after first service
# start by calling: 'nft list ruleset >/etc/sysconfig/nftables.conf'.
include "/etc/nftables/zon.nft"
```

## B3 – `sudo cat /etc/nftables/zon.nft`

Sparad oförändrad som [brandvägg/cfg/zon.nft](../brandvägg/cfg/zon.nft).

## B4 – syntaxkontroll

```
$ sudo nft -c -f /etc/sysconfig/nftables.conf && echo SYNTAX-OK
SYNTAX-OK
```

## B5 – tjänster vid uppstart

```
$ sudo systemctl is-enabled nftables firewalld rsyslog auditd
enabled
Failed to get unit file state for firewalld.service: No such file or directory

$ systemctl is-enabled rsyslog auditd
enabled
enabled
```

`systemctl` slutar skriva ut efter den enhet som saknas, därför kördes rsyslog och auditd igen.

## B6 – `ls -l /etc/rsyslog.d/ /etc/pki/rsyslog/ca.pem` (utan sudo)

```
ls: cannot access '/etc/pki/rsyslog/ca.pem': Permission denied
/etc/rsyslog.d/:
total 8
-rw-r--r--. 1 root root 255 Jun 23 23:34 21-cloudinit.conf
-rw-r--r--. 1 root root 597 Nov  3 13:04 90-tls-forward.conf
```

## B7 – CA-filen

```
$ sudo ls -ld /etc/pki/rsyslog && sudo ls -lZ /etc/pki/rsyslog/ca.pem
drwx------. 2 root root 4096 Nov  3 07:28 /etc/pki/rsyslog
-rw-r--r--. 1 root root unconfined_u:object_r:cert_t:s0 1472 Nov  3 07:28 /etc/pki/rsyslog/ca.pem
```

## B8 – namnuppslagning

```
$ getent hosts log.sec.chas-lab.dev
172.20.1.58     log.sec.chas-lab.dev
```

## B9 – SSH

```
$ sudo sshd -T | grep -Ei 'passwordauthentication|permitrootlogin'
permitrootlogin without-password
passwordauthentication yes
```

## B10 – historik, brandvägg, loggning och SELinux

```
history | grep -E 'nft|nftables|firewalld|rsyslog|audit|ca.pem|sshd|reboot|semanage|restorecon|getenforce'
   82  sudo systemctl restart rsyslog
   85  sudo tail -n 3 /var/log/audit/audit.log | grep sparc6e7feb6
   86  sudo audit ctl -l
   87  sudo auditctl -l
   88  sudo ls -l /etc/audit/rules.d/
   90  cat /etc/logrotate.d/audit
   92  grep -i rotate /etc/audit/auditd.conf
   93  sudo grep -i rotate /etc/audit/auditd.conf
   94  grep -iE 'active|remote_server|queue|network_failure' /etc/audit/plugins.d/au-remote.conf
   95  sudo grep -iE 'active|remote_server|queue|network_failure' /etc/audit/plugins.d/au-remote.conf
   96  grep -r forward /etc/rsyslog.d/
   97  journalctl --disk-usage och ls -l /var/log/audit/
   98  journalctl --disk-usage ls -l /var/log/audit/
  100   ls -l /var/log/audit/
  101  sudo ls -l /var/log/audit/
  103  sudo auditctl -l | grep root_cmd
  104  sudo auditctl -l
  107  sudo ls -l /etc/audit/audit.rules /ettc/audit/rules.d
  108  sudo ls -l /etc/audit/audit.rules /etc/audit/rules.d
  111  ls -l /var/log/audit/
  112  sudo ls -l /var/log/audit/
  113  sudo grep -E 'num_logs|max_log_file|max_log_file_action' /etc/audit/auditd.conf
  114  sudo grep -E 'queue|network_failure|overflow' /etc/audit/audisp-remote.conf
  115  cat /etc/logrotate.d/audit 2>/dev/null
  116  ls -l /var/log/audit
  117  sudo ls -l /var/log/audit
  118  sudo grep -E 'Option|Modul|Include' /etc/rsyslog.conf 2>/dev/null
  122  sudo grep -nE '^(active|remote_server|port|transport)' /etc/audit/plugins.d/au-remote.conf /etc/audit/audisp-remote.conf
  123  sudo ls -l /var/log/audit/
  124  sudo head -n 1 /var/log/audit/audit.log
  125   sudo grep -inE 'module|include|imfile|@@?' /etc/rsyslog.conf /etc/rsyslog.d/*
  128  cd /etc/audit
  129  sudocd /etc/audit
  130  sudo cd /etc/audit
  170  sudo grep -rn 'CAFile\|tragret=\|port=' /etc/rsyslog.d
  229  cd rsyslog/
  258  cd audit/
  289  sudo auditctl -l | grep root_cmd
  290  grep -i active /etc/audit/pliugins.d/au-remote.conf
  292  sudo nft list ruleset
  295  sudo grep -rn "6514\|172.20.1.58" /etc/rsyslog.conf /etc/rsyslog.d/
  296  sudo grep -rn -i "audit" /etc/rsyslog.conf /etc/rsyslog.d/
  297  sudo cat /etc/rsyslog.d/90-tls-forward.conf
  298  cd /etc/rsyslog.d/
  300  touch 91-audit-forward.conf
  301  sudo touch 91-audit-forward.conf
  302  sudo nano 91-audit-forward.conf
  303  sudo rsyslogd -N1
  304  sudo systemctl restart rsyslog
  305  ps -ef | grep "auditd
  306  ps -ef | grep "auditd"
  307  sudo grep -i active /etc/audit/plugins.d/au-remote.conf
  310  cat 91-audit-forward.conf
  311  sudo rm -r 91-audit-forward.conf
  312  sudo rsyslogd -N1
  313  sudo systemctl restart rsyslog
  345  sudo nft list tables
  346  sudo nft list table inet zone
  347  sudo nft list table inet zon
  348  sudo nft insert rule inet zon ut ip daddr 172.20.1.58 tcp dport 80 accept comment "TEMP hamta CA"
  349  sudo nft insert rule inet zon ut ip daddr 172.20.1.58 tcp dport 80 accept
  350  sudo nft list ruleset
  351  sudo curl -fsS -o /etc/pki/rsyslog/ca.pem http://log.sec.chas-lab.dev/ca.pem
  352  openssl x509 -in /etc/pki/rsyslog/ca.pem -noout -subject -fingerprint -sha256
  355  sudo openssl s_client -connect log.sec.chas-lab.dev:6514 -severname log.sec.chas-lab.dev -CAfile /etc/pki/rsyslog/ca.pem </dev/null 2>/dev/null | grep 'Verify return'
  361  sudo curl -fsS -o /etc/pki/rsyslog/ca.pem http://log.sec.chas-lab.dev/ca.pem && echo OK
  368  cd /etc/rsyslog.d
  370  sudo tee /etc/rsyslog.d/90-tls-forward.conf >/dev/null <<'EOF'
  373    DefaultNetstreamDriverCAFile="/etc/pki/rsyslog/ca.pem"
  392  sudo rsylogd -N1 && systemctl restart rsyslog
  393  sudo rsyslogd -N1 && systemctl restart rsyslog
  396  service rsyslog status
  405  cd /etc/rsyslog.d
  424  mv zon.nft cfg/
  437  mv nft-backup.nft cfg/
  445  cp zon.nft ~/brandvägg/cfg
  449  rm -r zon.nft
  451  mv nft.pcap pcaps/
  460  cd /etc/rsyslog.d
  487  journalctl -u rsyslog --since "2 min ago"
  488  journalctl -u rsyslog --since "10 min ago"
  503  journalctl -u rsyslog --since "2 hours ago"
  515  udo auditctl -l och ls -l /etc/audit/rules.d/
  516  sudo auditctl -l och ls -l /etc/audit/rules.d/
  517  sudo auditctl -l
  518  ls -l /etc/audit/rules.d/
  519  sudo ls -l /etc/audit/rules.d/
  520  cd /etc/audit
  581  cd rsyslog/
  587  rpm -q rsyslog-gnutls
  588  ls -l /usr/lib64/rsyslog/lmnsd_gtls.so
  589  journalctl -u rsyslog --since "2026-11-03 09:35" --until "2026-11-03 13:15" --no-pager | grep -iv "resumed" | grep -i "tls\|gtls\|connect\|refused\|timed\|error\|certificate"
  590  ls -l --time-style=full-iso /etc/rsyslog.d/90-tls-forward.conf /etc/rsyslog.conf
  596  rpm -q rsyslog-gnutls
  597  ls -l /usr/lib64/rsyslog/lmnsd_gtls.so
  598  journalctl -u rsyslog --since "2026-11-03 09:35" --until "2026-11-03 13:15" --no-pager | grep -iv "resumed" | grep -i "tls\|gtls\|connect\|refused\|timed\|error\|certificate"
  599  ls -l --time-style=full-iso /etc/rsyslog.d/90-tls-forward.conf /etc/rsyslog.conf
  613  sudo journalctl _COMM=sshd --since "30 min ago" | tail -20
  614  systemctl status sshd ssh 2>/dev/null
  615  sudo journalctl _COMM=sshd --since "30 min ago" | tail -20
  616  sudo journalctl -u sshd --since "2 hours ago" | grep -iE "failed|invalid" | tail -20
  617  sudo journalctl SYSLOG_IDENTIFIER=sshd-session --since "2 hours ago" | grep -iE "failed|invalid" | tail -20
  630  sudo journalctl -u rsyslog
  631  sudo journalctl -u rsyslog "suspended"
  632  sudo journalctl -u rsyslog | grep "suspended"
  635  sudo nft list ruleset
  653  cd /etc/nftables/
  657  sudo auditctl -l | grep root_cmd
  663   sudo auditctl -l | grep root_cmd
  677  getenforce
  700  semanage fcontext -a -t httpd_sys_content_t "/srv/zonwebb(/.*)?"
  709  cd audit
  751  getenforce
  760  which sepolicy sesearch semanage
  764  sudo semanage fcontext -l | head -3
  765  sudo semanage fcontext -a -t httpd_sys_content_t "/srv/zonwebb(/.*)?"
  766  sudo restorecon -Rv /srv/zonwebb
  769  sudo restorecon -Rv /srv/zonwebb
  779  semanage port -l
  791  sudo restorecon -Rv /srv/zonwebb
  841  sudo restorecon -Rv /usr/local/bin/zonvakt /var/log/zonvakt
  846  sudo restorecon -Rv /usr/local/bin/zonvakt /var/log/zonvakt
  894  [ "$(getenforce 2>/dev/null)" = "Enforcing" ]
  900  ! sudo -n semanage permissive -l 2>/dev/null | grep -q 'zonvakt_t'
  903  sudo -n semanage fcontext -l -C 2>/dev/null | grep -q '/srv/zonwebb' \
  906  # 5. nftables-regel för 172.20.1.10
  907  sudo -n nft list chain inet filter input 2>/dev/null | grep -q '172.20.1.10'
  908  check $? "nftables släpper in 172.20.1.10"
  912  sudo systemctl reboot
  962  sudo systemctl reboot
  963  getenforce
  967  sudo nft list chain inet filter input | grep 172.20.1.10
  969  sudo nft list ruleset | grep -q '172.20.1.10'
  970  sudo nft list ruleset | grep -q '172.20.1.10'; echo "exit=$?"
  973  sudo sed -i 's/nft list chain inet filter input/nft list ruleset/' /usr/local/bin/verifiera-hardning
  974  grep -n "nft list" /usr/local/bin/verifiera-hardning
 1060  getenforce
 1081  history | grep -E 'nft|nftables|firewalld|rsyslog|audit|ca.pem|sshd|reboot|semanage|restorecon|getenforce'
```

## B11 – historik, SELinux-modul, tester och ausearch

```
history | grep -E 'semodule|checkmodule|ps -eZ|ausearch|brandvagg|testfall'
  109  sudo ausearch -k root_cmd -i | grep sparc6e7feb6
  110  sudo ausearch -k root_cmd -i | tail -n 5
  121  sudo ausearch -a 9381 -i | grep -E 'SYSCALL|auid'
  126  ausearch -a 9381
  127  sudo ausearch -a 9381
  141  mv testfall-ut/ testfall
  156  ./test.sh testfall.csv
  159  cat testfall_admin.csv
  161  cat testfall_floden.csv
  163  cd testfall-ut/
  165  cat testfall.csv
  398  cat 60-brandvagg.conf
  407  cp 60-brandvagg.conf ~/home/student/brandvägg
  408  cp 60-brandvagg.conf /home/student/brandvägg
  410  rm -r 60-brandvagg.conf
  411  sudo rm -r 60-brandvagg.conf
  419  mv 60-brandvagg.conf cfg/
  427  mv testfall_*.csv testfall-ut/
  429  cd testfall
  430  cd testfall-ut/
  435  mv testfall.csv testfall-ut/
  439  mv test.sh testfall-ut/
  441  cd testfall-ut/
  538  cd testfall/
  541  cat testfall_floden.csv
  542  cat testfall_admin.csv m
  543  cat testfall_admin.csv
  544  cd testfall.csv
  545  cat testfall.csv
  555  cd testfall/
  558  cat testfall.csv
  559  ./test.sh testfall.csv
  733  sudo ausearch -m avc -ts recent -i
  734  sudo ausearch -m avc
  737  sudo ausearch -m avc -c httpd -ts recent -i
  738  sudo ausearch -m avc -ts recent -i
  776  ps -eZ
  777  ps -eZ | grep "zonvakt"
  778  ps -eZ | grep "zon"
  824  ps -eZ | grep zonvakt
  827  ps -eZ | grep zonvakt
  843  ps -eZ | grep zonvakt
  844  sudo semodule -i zonvakt.pp
  845  sudo semodule -l | grep zonvakt
  848  ps -eZ | grep zonvakt
  850  ps -eZ | grep zonvakt
  854  sudo ausearch -m avc -c zonvakt -i
  871  sudo semodule -i zonvakt.pp
  874  ps -eZ | grep zonvakt
  897  sudo -n semodule -l 2>/dev/null | grep -q '^zonvakt'
  930  ps -eZ | grep zonvakt
  941  sudo ausearch -m avc,user_avc -ts recent -i | tail -30
  950  sudo semodule -i zonvakt.pp
  953  ps -eZ | grep zonvakt
  960  sudo ausearch -m avc -c zonvakt -ts recent -i | tail -20
  965  ps -eZ | grep zonvakt
 1002  sudo semodule -l>~/ai-mapp/Verfierad/semodule.txt
 1003  ps -eZ  > ~/ai-mapp/Verifierad/ps-eZ.txt
 1004  ps -eZ>~/ai-mapp/Verifierad/ps-eZ.txt
 1010  cat semodule.txt
 1014  ps -eZ >ps-eZ.txt
 1062  ps -eZ | grep zonvakt
 1090  history | grep -E 'semodule|checkmodule|ps -eZ|ausearch|brandvagg|testfall'
```
