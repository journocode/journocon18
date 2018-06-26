# Crashkurs: Programmieren in R für Journalist*innen | Teil 3: Das Tidyverse
# ---------------------------------------------------------------------------

# install.packages("needs")
# library(needs)
needs(tidyverse, magrittr, rgdal) # Das Paket tidyverse enthält die Pakete tidyr, dplyr und ggplot2
# magrittr laden wir, damit wir vollen Zugriff auf die Funktionen der Magrittr-Pipe haben, die ich im Tutorial erklärt habe
# rgdal brauchen wir, um später die Shape-Datei zu laden
btw17 <- read.csv("btw17.csv") # Datensatz einlesen

## Das "tidy data"-Format
btw17_tidy <- btw17 %>% gather(key=party, value=value, 8:13) # btw17 im "tidy data"-Format
btw17_tidy %>% spread(party, value) # und wieder im "wide"-Format

## Verarbeiten und analysieren mit dplyr
btw17_tidy$Wahlbeteiligung <- btw17_tidy$Wähler.Zweitstimmen/btw17_tidy$Wahlberechtigte.Zweitstimmen # Wahlbeteiligung berechnen

# summarize
btw17_tidy %>% summarize(max(Wahlbeteiligung)) # Was ist die maximale Wahlbeteiligung gewesen?
# Wir können mit summarize auch mehrere Zusammenfassungen gleichzeitig machen
btw17_tidy %>% summarize(max = max(Wahlbeteiligung), min = min(Wahlbeteiligung), median = median(Wahlbeteiligung)) 

# mutate
btw17_tidy %>% mutate(value_rel = value / Gültige.Zweitstimmen) # eine neue Spalte erstellen
btw17_tidy %<>% mutate(value_rel = value / Gültige.Zweitstimmen) # Die Veränderung am Datensatz abspeichern. Du kannst mit View() überprüfen, ob es geklappt hat ;)

# arrange & slice
btw17_tidy %>% arrange(value_rel) # aufsteigend nach value_rel sortieren
btw17_tidy %>% arrange(desc(value_rel)) %>% slice(1:3) # absteigend sortieren und nur die ersten drei Zeilen zeigen

# group_by
# Eine Funktion nach Gruppen anwenden
btw17_tidy %>% group_by(party) %>% summarize(max = max(value_rel)) %>% arrange(desc(max))

# filter
btw17_tidy %>% filter(value_rel >= 0.05) # Zeige mir nur die Zeilen, bei denen das Ergebnis die 5%-Hürde geschafft hat.


## Visualisieren mit ggplot2
plot_data <- btw17_tidy %>% group_by(party) %>% summarize(result = sum(value)/sum(Gültige.Zweitstimmen))

# Dotchart
ggplot(plot_data, aes(x = party, y=result)) + 
  geom_point()

# Barchart
ggplot(plot_data, aes(x = party, y=result)) + 
  geom_bar(stat = "identity")

# Barchart absteigend sortieren mit der Funktion reorder
?reorder
ggplot(plot_data, aes(x = reorder(party, -result), y=result)) + 
  geom_bar(stat = "identity") 

# Barchart mit angepasster Beschriftung
ggplot(plot_data, aes(x = reorder(party, -result), y=result)) + 
  geom_bar(stat = "identity") +
  labs(title="Die Bundestagswahl",  # Grafik-Titel
     subtitle="Eine ggplot2-Grafik",  # Untertitel
     caption="Quelle: Bundeswahlleiter", # Beschreibung
     x="Partei", y="Ergebnis in %") + # Label für die Achsen
  scale_x_discrete(labels = c("Union", "SPD", "AfD", "FDP", "Linke", "Grüne")) # Vektor mit neuen Label-Namen


## Karte mit ggplot2
needs(broom) # Das Paket broom beinhaltet die Funktion tidy, mit der wir den Geodatensatz in ein Format bringen können, das gut mit ggplot2 zusammen passt
# Shapefile ohne tidy als Vergleich
shp <- readOGR("wahlkreise_small/wahlkreise_small.shp", "wahlkreise_small", stringsAsFactors=FALSE, encoding="latin1")
head(shp@data) # kleiner Ausschnitt der Daten in diesem Shapfeil
head(shp@polygons) # kleiner Ausschnitt der Polygone in diesem Shapefile

# tidy Shapefile
tidy_shp <- readOGR("wahlkreise_small/wahlkreise_small.shp", "wahlkreise_small", stringsAsFactors=FALSE, encoding="latin1") %>% # Shapefile laden
  tidy() # broom 
head(tidy_shp) # kleinen Ausschnitt der Daten ansehen

btw17_tidy %<>% mutate(id= Wkrnr-1) # Dem Datensatz eine ID-Spalte hinzufügen, die zu der vom Shapefile passt

tidy_shp <- merge(tidy_shp, btw17_tidy, by="id", all.y=T) # Über die ID Shapefile und Wahldaten zusammenführen
head(tidy_shp) # kleinen Ausschnitt der Daten ansehen

# Farbgradienten hinzufügen
tidy_shp$fill <- "pink" # erstmal eine Splate für die Farbe hinzufügen

tidy_shp[tidy_shp$party %in% "Sozialdemokratische.Partei.Deutschlands.Zweitstimmen",]$fill <- 
  colorRampPalette(c('#F0BAA5','#f40502'))(10)[as.numeric(cut(tidy_shp[tidy_shp$party %in% "Sozialdemokratische.Partei.Deutschlands.Zweitstimmen",]$value_rel, breaks = 10))]

tidy_shp[tidy_shp$party %in% "UNION.Zweitstimmen",]$fill <-
  colorRampPalette(c('#959595','#000000'))(10)[as.numeric(cut(tidy_shp[tidy_shp$party %in% "UNION.Zweitstimmen",]$value_rel, breaks=10))]

tidy_shp[tidy_shp$party %in% "Alternative.für.Deutschland.Zweitstimmen",]$fill <-
  colorRampPalette(c('#CEE9FF','#009de0'))(10)[as.numeric(cut(tidy_shp[tidy_shp$party %in% "Alternative.für.Deutschland.Zweitstimmen",]$value_rel, breaks=10))]

tidy_shp[tidy_shp$party %in% "DIE.LINKE.Zweitstimmen",]$fill <-
  colorRampPalette(c('#E0A7C3','#8b1b62'))(10)[as.numeric(cut(tidy_shp[tidy_shp$party %in% "DIE.LINKE.Zweitstimmen",]$value_rel, breaks=10))]

tidy_shp[tidy_shp$party %in% "Freie.Demokratische.Partei.Zweitstimmen",]$fill <-
  colorRampPalette(c('#FFFBD1','#feed01'))(10)[as.numeric(cut(tidy_shp[tidy_shp$party %in% "Freie.Demokratische.Partei.Zweitstimmen",]$value_rel, breaks=10))]

tidy_shp[tidy_shp$party %in% "BÜNDNIS.90.DIE.GRÜNEN.Zweitstimmen",]$fill <-
  colorRampPalette(c('#A4D78F','#42a62a'))(10)[as.numeric(cut(tidy_shp[tidy_shp$party %in% "BÜNDNIS.90.DIE.GRÜNEN.Zweitstimmen",]$value_rel, breaks=10))]


# Bis auf die Gewinner-Parteien alle Parteien aus dem Datensatz herausfiltern
tidy_shp %<>% group_by(id) %>% # Daten nach ID / Wahlkreis gruppieren
  filter(party %in% party[value %in% max(value, na.rm=T)]) %>% # dann jeden Wert rausfiltern, der nicht der Maximalwert je ID ist
  arrange(id,order)

# Karte erstellen mit ggplot
win <- ggplot(data=tidy_shp, aes(x=long, y=lat, group=group)) + # Initialisierung
  geom_polygon(aes(fill=fill), show.legend = T, size=0.2, color="white") + # Polygone plotten und nach Spalte "fill" einfärben
  scale_fill_identity() + # diese Funktion weißt das Polygon an, die Farben aus der Spalte fill zu verwenden
  theme_void() + # Achsen und Beschriftung entfernen
  coord_map() # Karte umprojezieren
win

# Abspeichern als JPEG
jpeg(file = "gewinnerkarte.jpg", bg="transparent", width=750, height=1010, units="px", quality=75)
win
dev.off()


# Übungsaufgaben: Lösungen
# ---------------------------------------------------------------------------
#1. Füge dem Datensatz eine Spalte hinzu, welche den Anteil Nichtwähler je Wahlkreis zeigt. 
btw17_tidy %>% mutate(Nichtwähler_rel = (Wahlberechtigte.Zweitstimmen - Wähler.Zweitstimmen)/Gültige.Zweitstimmen)

#2. Was war das Gesamtergebnis der Bundestagswahl?
btw17_tidy %>% group_by(party) %>% 
  summarize(result = (sum(value)/sum(Gültige.Zweitstimmen))*100) %>% 
  arrange(desc(result))

#3. In welchem Bundesland hat die FDP ihr bestes Gesamtergebnis geholt? Gemeint ist nicht das Bundesland, in dem der Wahlkreis mit dem höchsten Ergebnis liegt ;)
btw17_tidy %>% filter(party == "Freie.Demokratische.Partei.Zweitstimmen") %>% 
  group_by(Bundesland) %>% summarize(result = (sum(value)/sum(Gültige.Zweitstimmen))*100) %>% 
  arrange(desc(result))
