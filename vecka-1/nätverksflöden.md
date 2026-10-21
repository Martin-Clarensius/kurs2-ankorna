## Filen: lagerkartan.pcap
## Trafikbaslinje

## Trafikbaslinje – TCP

| Källa (IP) | Mål (IP) | Källport | Målport |
| ---------- | -------- | -------- | ------- |
|172.xx.x.xx|172.xx.x.xx|37520     |9000     |
|172.xx.x.xx|172.xx.x.xx|42800     |80       |
|172.xx.x.xx|172.xx.x.xx|47830     |9000     |
|172.xx.x.xx|172.xx.x.xx|50536     |9000     |
|172.xx.x.xx|172.xx.x.xx|51076     |9000     |
|172.xx.x.xx|172.xx.x.xx|53077     |80       | 
|172.xx.x.xx|172.xx.x.xx|54306     |8080     |
|172.xx.x.xx|172.xx.x.xx|31064     |53       |

port 53  DNS, uppslagning av domännamn
port 8080 alternativ HTTP-port, till exempel för en utvecklingsserver eller proxy.
9000 är målporten, men vi vet inte vad tjänsten gör bara utifrån portnumret.
## Trafikbaslinje – UDP

| Källa (IP) | Mål (IP)  | Källport | Målport |
| ---------- | --------- | -------- | ------- |
|172.xx.x.xx |185.xx.xx.x|35303    |   53    |
|172.xx.x.xx |185.xx.xx.x|39310    |   53    |
|172.xx.x.xx |185.xx.xx.x|45432    |   53    |
|172.xx.x.xx |185.xx.xx.x|47701    |   53    |
|172.xx.x.xx |185.xx.xx.x|51889    |   53    |
|172.xx.x.xx |185.xx.xx.x|53913    |   53    |
|172.xx.x.xx |185.xx.xx.x|58034    |   53    |
|172.xx.x.xx |185.xx.xx.x|59740    |   53    |
port 53  DNS, uppslagning av domännamn


## Filen: avvikelsen.pcap
## Trafikbaslinje – TCP

| Källa (IP) | Mål (IP) | Källport | Målport |
| ---------- | -------- | -------- | ------- |
|172.xx.x.xx |172.xx.x.xx|37520    |9000     |

9000 är målporten, men vi vet inte vad tjänsten gör bara utifrån portnumret.