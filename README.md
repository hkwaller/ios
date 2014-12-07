
SPUDDIFY
===


Readme for Spuddify
av Hannes Waller
walhan12@student.westerdals.no



Appen spiller av sanger fra Spotifys web API. Det er mulig å søke etter nye sanger, legge disse til i en playlist for å så spille av dem.
Det går an å slette sanger fra playlisten.

Den virker på iPad og iPhone å vil tilpasse seg de ulike typene.




EXTENSION
---
Det er laget en today extension som viser sist spilte sang, dette vises ved hjelp av UserDefaults



ANIMASJONER
---

Det er noen forskjellige animasjoner i appen.

1) Når siste sang i en playlist slettes blir tableView animert vekk åt venstre
Berørte filer: 	PlaylistViewController.swift rad 149-157

2) På playlist- og searchview blir celler animert in ved scrolling eller når nye celler er hentet
Berørte filer: 	SearchViewController.swift rad 169-175
PlaylistViewControoller.swift rad 166-172

3) Loading view på searchview controller har animasjon på tekst når den kommer in, dette er ikke helt
lett å se da søk som regel går veldig kjappt
Berørte filer: 	SearchViewController.swift rad 206-210




BIBLIOTEKER
---

- SwiftyJSON - For hantering av JSON på en god måte
- Reachability - Sjekker om internett er tilgjengelig, slik at ingen funksjoner kjøres som er beroende av            internett
- SCLAlertview - For å vise finere Alertviews en iOS innebyggde