# Härdningsrapport – ITSX26, vecka 7

**Namn:** Liibaan Abdulle  
**Datum:** 18 november 2026  
**Server:** elev-03

## 1. Syfte

Syftet med uppgiften var att kontrollera och verifiera säkerhetshärdningen på elev-03. Kontrollerna omfattade SELinux, brandvägg, tjänstens säkerhetskontext och loggning av privilegierade kommandon.

## 2. Genomförda kontroller

| Kontroll | Resultat | Verifiering |
|---|---|---|
| SELinux aktivt | GÄLLER | Enforcing |
| SELinux permanent konfigurerat | GÄLLER | SELINUX=enforcing |
| Brandväggens inkommande policy | GÄLLER | policy drop |
| Zonvaktens SELinux-kontext | GÄLLER | zonvakt_t |
| Permanent SELinux-regel | GÄLLER | semanage fcontext |
| Zonvakt inte permissive | GÄLLER | Ingen permissive-post |
| Auditregel för root-kommandon | GÄLLER | auditctl -l |

## 3. Verifiering

Verifieringsskriptet `/usr/local/bin/verifiera-hardning` kördes.

Resultatet visade sju godkända kontroller:

- SELinux är Enforcing.
- SELinux-konfigurationen är enforcing.
- Zonvakt körs i zonvakt_t.
- zonvakt_t är inte permissive.
- Permanent SELinux-regel finns.
- Brandväggens inkommande kedja har policy drop.
- Auditregeln för root-kommandon finns.

## 4. Granskning av begränsningar

Brandväggskontrollen verifierade den inkommande kedjan. Den bevisar inte att alla brandväggsregler, inklusive utgående trafik, är säkra.

Auditregeln omfattar execve-händelser där effektiv UID är 0 och audit UID är minst 1000 och inte -1. Den loggar alltså inte alla root-kommandon utan endast händelser som matchar dessa villkor.

## 5. Slutsats

De sju kontrollerna i verifieringsskriptet godkändes. Resultatet visar att de kontrollerade härdningsinställningarna är aktiva på elev-03.

Kontrollerna utgör inte en fullständig säkerhetsrevision av hela servern.

### Granskning och borttagning av odokumenterad regel för TCP-port 48132

Vid granskning av brandväggsreglerna hittades en regel för inkommande TCP-trafik från `172.20.1.203` till port `48132` på `eth1`. Regeln loggade matchande trafik med prefixet `ZON-IN-DROP`.

Regeln saknades i flödestabellen D1–D7 och det fanns ingen dokumenterad förklaring till dess syfte. Vid kontroll hittades ingen tjänst som lyssnade på port 48132. Ingen matchande loggpost hittades i den kontrollerade kerneljournalen vid undersökningstillfället.

Eftersom regeln saknade dokumenterat behov och inte kunde kopplas till ett definierat trafikflöde togs den bort från den aktiva konfigurationen.

Före ändringen skapades en säkerhetskopia:
`/etc/nftables/u41.nft.before-48132`

Syntaxen kontrollerades med `sudo nft -c -f /etc/nftables/u41.nft`. Därefter laddades konfigurationen med `sudo nft -f /etc/nftables/u41.nft`. En kontroll med `sudo nft list chain inet zon in` bekräftade att regeln inte längre fanns i den aktiva brandväggen.

Den generella loggningen av blockerad inkommande trafik behölls.
