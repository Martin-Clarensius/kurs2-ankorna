#!/bin/bash
# verifiera-hardning – läser av tillståndet och ändrar ingenting.
# Skriver GÄLLER eller GÄLLER INTE per kontroll och avslutar med 0 om allt gäller.
# Kopia av /usr/local/bin/verifiera-hardning på elev-34. Kör med: sudo /usr/local/bin/verifiera-hardning; echo "slutkod $?"
rc=0
kontroll() {
  if bash -c "$2" >/dev/null 2>&1; then
    printf 'GÄLLER %s\n' "$1"
  else
    printf 'GÄLLER INTE %s\n' "$1"
    rc=1
  fi
}
kontroll "SELinux i tvingande läge nu (getenforce = Enforcing)" '[ "$(getenforce)" = Enforcing ]'
kontroll "SELinux enforcing efter omstart (/etc/selinux/config)" 'grep -qx "SELINUX=enforcing" /etc/selinux/config'
kontroll "zonvakt kör i egen domän zonvakt_t" 'ps -eZ | grep -v grep | grep -q "zonvakt_t.*zonvakt"'
kontroll "zonvakt-domänen är inte permissiv" '! semanage permissive -l | grep -qw zonvakt_t'
kontroll "/srv/zonwebb har bestående fcontext-regel" 'semanage fcontext -l -C | grep -q "^/srv/zonwebb"'
exit $rc
