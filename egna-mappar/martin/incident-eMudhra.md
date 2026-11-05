## Inledning 
Veckan kring den 20 oktober 2026 uppdagades två olika säkerhetshändelser. Den ena gäller komprometterade CA-certifikat från eMudhra, den andra två rapporterade sårbarheter i PHP. Händelserna hör inte ihop, men de visar två olika sätt att hantera ett allvarligt säkerhetsproblem och är därför användbara att jämföra.

## Händelse 1: PHP-sårbarheter (CVE-2026-109618 och CVE-2026-109619)
Säkerhetsföretaget watchTowr publicerade den 20 oktober en FAQ om två rapporterade sårbarheter för fjärrkörning av kod (RCE) i PHP. Uppgifterna kommer från en läcka på sociala medier inför ett säkerhetsmeddelande som väntas den 22 oktober kl. 18:00 CEST. Läckan är inte bekräftad av PHP:s utvecklare. Det finns ännu ingen officiell säkerhetsrapport, ingen CVSS-poäng och ingen patch. Enligt rapporten påverkas alla versioner från PHP 5 och framåt, men det är inte verifierat. Den 21 oktober hade inget utnyttjande i det fria rapporterats.

### Tidslinje, PHP
- Före 20 oktober 2026: uppgifterna läcker på sociala medier.
- 20 oktober 2026: watchTowr publicerar sin FAQ.
- 21 oktober 2026: inget utnyttjande rapporterat, inte med i CISA:s KEV-lista.
- 22 oktober 2026: officiellt meddelande väntas.

## Risker
Risken är att en angripare kan köra egen kod på en server som kör PHP och ta kontroll över den. Det hotar hela CIA-triaden: konfidentialitet (stöld av data och lösenord), integritet (ändrade filer, webbshells) och tillgänglighet (utpressningsprogram, nedstängda tjänster). PHP används i många webbplatser och interna verktyg som nås från internet, så spridningen kan bli stor. Att uppgifterna blivit kända före en patch är extra allvarligt, eftersom angripare kan hinna före försvararna. Eftersom ingen patch finns bör organisationer följa PHP:s officiella kanaler, inventera alla system som kör PHP, undvika att agera på obekräftade rapporter och förbereda en snabb uppdateringsprocess. Under tiden kan skadan begränsas med minskade behörigheter, nätverkssegmentering, loggning, säkerhetskopior och en brandvägg för webbapplikationer.

## Händelse 2: eMudhra-incidenten
De privata nycklarna till åtta mellanliggande CA-certifikat från eMudhra visade sig vara komprometterade eftersom de genererats felaktigt, vilket gör att vem som helst kan räkna ut dem utifrån certifikaten. Certifikaten skapades i april 2025, så bristen kan ha funnits i ungefär 18 månader. De kedjar till rötter som många system litar på, bland annat emSign Root TLS CA - G3 och AAA Certificate Services. En angripare med nycklarna kan utge sig för vilken webbplats som helst och göra man-in-the-middle-attacker, vilket främst hotar konfidentialitet och integritet. Webbläsare som kräver Certificate Transparency bedöms ha varit skyddade, eftersom inga CT-loggposter finns. Klienter utan CT och revokeringskontroll, som curl, skript, IoT-enheter och interna verktyg, är mest utsatta.

### Tidslinje, eMudhra
- April 2025: certifikaten skapas med felaktiga nycklar.
- 17 oktober 2026: forskaren rapporterar felet. Firefox och Chrome blockerar certifikaten.
- 19 oktober 2026: Apple blockerar dem, och trust stores informeras.
- 20 oktober 2026: Microsoft blockerar dem, och händelsen offentliggörs.

## Hantering och jämförelse
Vid eMudhra användes samordnad avslöjning (coordinated disclosure). Felet rapporterades privat, webbläsarna blockerade certifikaten innan allmänheten fick veta, och skyddet fanns på plats vid offentliggörandet. Revokering räckte dock inte, eftersom många klienter aldrig kontrollerar den, så uppdaterade trust stores behövs. Vid PHP har informationen i stället läckt före ett officiellt meddelande och före en patch, vilket ger försvararna mindre tid och en osäkerhet kring vad som faktiskt gäller.

## Lärdomar
- Förtroendekedjan är en single point of failure: en enda dålig CA kan underminera hela modellen.
- Svag nyckelgenerering är ett kritiskt fel som kryptering inte kan kompensera för.
- CT-loggar fungerade som skyddsnät och begränsade skadan i webbläsare.
- Patchhantering och uppdaterade trust stores är avgörande även utanför webbläsare.
- Samordnad avslöjning ger försvararna försprång, medan läckor före patch gynnar angripare.
- Inventering av vilka system man kör gör det möjligt att reagera snabbt i båda fallen.

### Källor
- watchTowr, "Frequently Asked Questions About PHP Remote Code Execution (CVE-2026-109618 & CVE-2026-109619)", https://watchtowr.com/intelligence/php-cve-2026-109618-faq/ (hämtad 21 oktober 2026)
- eMudhra Intermediate CA Compromise, https://emudhra.we-have-a-problem.com (hämtad 21 oktober 2026)