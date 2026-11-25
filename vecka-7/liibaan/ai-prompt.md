> **Dokumentationsdatum:** 2026-11-23 (senaste verifierade Git-uppdatering). Datumet anger dokumentversionen, inte säkert datum för själva AI-granskningen.

Granska följande härdningskontroller för en Linux-server med SELinux och nftables.

Kontrollera särskilt:
1. Om SELinux verkligen är i Enforcing-läge.
2. Om Zonvakt körs i rätt SELinux-domän.
3. Om den permanenta SELinux-regeln är korrekt beskriven.
4. Vad brandväggens inkommande policy drop bevisar och inte bevisar.
5. Vad auditregeln för execve med euid=0, auid>=1000 och auid!=-1 faktiskt loggar.

Skilj mellan verifierade fakta och sådant som inte går att avgöra från uppgifterna. Hitta eventuella överdrifter eller felaktiga slutsatser och föreslå precisa formuleringar.
