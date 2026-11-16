# Triagelogg – milstolpe 6

**Ansvarig:** elev-33 (Per Palmgren)

En post per larm. Observation och slutsats hålls i skilda fält. Tider är svensk tid (CET) om inte UTC anges.

## Post 1 – D1 SSH brute force

| Fält | Innehåll |
|---|---|
| Larm (monitor) | `elev-33`, trigger `Susp SSH` (D1) |
| Larmets starttid | 2026-11-12 11:12 svensk tid (slut 11:16) |
| Observationer (det som syns i loggen) | ⟨n poster med regel ⟨id⟩ i `wazuh-alerts-*` från `data.srcip: ⟨ip⟩` kl. ⟨…⟩. Användarnamn i `data.srcuser`: ⟨…⟩. Sökning efter lyckad inloggning `data.srcip: ⟨ip⟩ and rule.id: (5715 or 40112)` gav ⟨n⟩ träffar.⟩ |
| Slutsats | ⟨…⟩ |
| Berört (värd, konto, tjänst) | Värd elev-33, tjänst sshd, ⟨konton⟩ |
| Beslut (avfärda / eskalera) | ⟨…⟩ |
| Granskbart skäl | ⟨t.ex. källan 172.20.1.10 är ctf-servern (flöde D2) och tiden stämmer med `kontrollera U6.2 start` kl. ⟨…⟩ UTC⟩ |
| Åtgärd | ⟨…⟩ |
| Triagerat av / tid | elev-33, ⟨datum⟩ |

## Post 2 – D2 Zonöverträdelse

| Fält | Innehåll |
|---|---|
| Larm (monitor) | `elev-33 zonöverträdelse`, trigger `zonöverträdelse` |
| Larmets starttid | ⟨…⟩ |
| Observationer | ⟨Poster i `wazuh-archives-*` med prefix `ZON-UT-DROP`, `DST=⟨…⟩`, `DPT=⟨…⟩`, från elev-33.⟩ |
| Slutsats | ⟨Utgående anslutning som inte finns i flödestabellen, stoppad av kedjan `ut`.⟩ |
| Berört | Värd elev-33. ⟨Ingen trafik gick ut.⟩ |
| Beslut | ⟨…⟩ |
| Granskbart skäl | ⟨Eget test `timeout 3 bash -c 'echo > /dev/tcp/1.1.1.1/8080'` kl. ⟨…⟩ UTC.⟩ |
| Åtgärd | ⟨…⟩ |
| Triagerat av / tid | elev-33, ⟨datum⟩ |

## Post 3 – D3 Root-kommando

| Fält | Innehåll |
|---|---|
| Larm (monitor) | `elev-33 root-kommando`, trigger `root-kommando` |
| Larmets starttid | ⟨…⟩ |
| Observationer | ⟨auditd-post med nyckeln `root_cmd`, `auid=⟨…⟩`, `exe=⟨…⟩`.⟩ |
| Slutsats | ⟨Kontot ⟨…⟩ körde ⟨…⟩ som root via sudo.⟩ |
| Berört | Värd elev-33, konto ⟨…⟩ |
| Beslut | ⟨…⟩ |
| Granskbart skäl | ⟨Eget test `sudo id` kl. ⟨…⟩ UTC, utdata `uid=0(root)`.⟩ |
| Åtgärd | ⟨…⟩ |
| Triagerat av / tid | elev-33, ⟨datum⟩ |

## Post 4 – D4 Misslyckad sudo

| Fält | Innehåll |
|---|---|
| Larm (monitor) | `elev-33 misslyckad sudo`, trigger `misslyckad-sudo` |
| Larmets starttid | ⟨…⟩ |
| Observationer | ⟨n poster `pam_unix(sudo:auth): authentication failure` för kontot ⟨…⟩ kl. ⟨…⟩ UTC. Lyckad sudo kl. ⟨…⟩ gav inget larm.⟩ |
| Slutsats | ⟨…⟩ |
| Berört | Värd elev-33, konto ⟨…⟩, tjänst sudo |
| Beslut | ⟨…⟩ |
| Granskbart skäl | ⟨Eget test `echo fel \| sudo -S -k true` kl. ⟨…⟩ UTC.⟩ |
| Åtgärd | ⟨…⟩ |
| Triagerat av / tid | elev-33, ⟨datum⟩ |

## Post 5 – D5 Beaconing (om U6.5 genomförs)

| Fält | Innehåll |
|---|---|
| Larm (monitor) | `elev-33-C2-becon-(T1071.001)`, trigger `Becon c2` (D5) |
| Larmets starttid | 2026-11-12 14:29 svensk tid (slut 14:31) |
| Observationer | ⟨…⟩ |
| Slutsats | ⟨…⟩ |
| Berört | ⟨…⟩ |
| Beslut | ⟨Avfärda (övning). I skarp drift: eskalera om målet inte är godkänt.⟩ |
| Granskbart skäl | ⟨Framkallat av `kontrollera U6.5 start` kl. ⟨…⟩.⟩ |
| Åtgärd | ⟨…⟩ |
| Triagerat av / tid | elev-33, ⟨datum⟩ |
