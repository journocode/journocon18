# Crashkurs: Programmieren in R für Journalist*innen | Teil 2: Grundvokabeln
# -------------------------------------------------------------------------- 

# Kommentar
5 # Zahl
sum(5,4) # Funktion
x # Variablenname, den wir aber noch nicht vergeben haben. Deshalb sagt uns R, dass sie nicht zu finden ist.
Text ohne Auskommentierung, den R als Code behandelt und versucht, auszuführen. Das führt dazu, dass die R-Konsole meckert. 
"string, also Zeichen, die als Text interpretiert werden"

## Basics ##
# R als Taschenrechner benutzen
5 + 2 # Addition
7 - 4 # Substraktion
6*8 # Multiplikation
9/3 # Division
(9-3)*8 # Es gelten die ganz normalen Regeln der Mathematik ;)

# Logische Vergleiche
5 == 2 # Ist 5 das gleiche wie 2?
5 == 5 # Ist 5 das gleiche wie 5?
5 > 2 # Ist 5 größer als 2?
5 >= 2 # Ist 5 größer oder gleich 2?

# Zuweisungen
x <- 3 # Mit dem Pfeilsymbol "x" den Wert 3 zuordnen
y = 5 # Das gleiche geht auch mit dem Gleichheitszeichen

# Du kannst nun mit y und x rechnen:
x + y
xy <- x+y

# Wir können auch Strings zuweisen
text_1 <- "R"
text_2 <- "is awesome!"
paste(text_1, text_2) # paste() setzt Strings zusammen und speichert sie wieder als String
paste("Das Ergebnis von", x, "plus", y, "ist", x+y)

var_1 <- 3 # funktioniert!
var-1 <- 3 # funktioniert nicht!


## Funktionen und Pakete ##
# Ein paar basic Funktionen
?sum() # Hilfeseite aufrufen
c(3,6,5) # Zahlen zu Vektoren verbinden
mean(c(1,5,8,3,22,122)) # arithmetisches Mittel
median(c(1,5,8,3,22)) # Median
round(3.525312, 2) # Zahl runden auf zwei Nachkommastellen. P.S.: Dezimalzahlen werden in R mit Punkten getrennt!!

# Pakete mit Zusatzfunktionen laden
needs(tidyverse) # Wenn du needs noch nicht installiert hast, gibt dir R hier einen Fehler, weil es die Funktion nicht kennt
install.packages("needs") # Funktion installieren (Internetverbindung notwendig!)
library(needs) # Funktion laden
needs(tidyverse) # Funktion benutzen

# Eigene Funktion schreiben
myfunction <- function(x,y){
  return(paste("Das Ergebnis von", x, "plus", y, "ist", x+y))
}

myfunction(1,5)
myfunction(-5,4)
myfunction(2,"string") # Fehler, da x+y hier nicht berechnet werden kann

myfunction2 <- function(x,y){
  ifelse(x>y, return(x), return(y)) # Bedingter Output
}

myfunction2(3,4)
myfunction2(4,3)

## Daten ##
# Vektoren
vec <- c(1,2,3,4,5)
vec2 <- 6:10 # Vektor aus allen Zahlen zwischen der ersten und der zweiten in Einer-Schritten
strnum <- c("eins","zwei",3) # sobald Strings in einem Vektor vorkommen, werden auch die vorkommenden Zahlen als Strings gespeichert

# Datensätze
df <- data.frame(col1 = vec, col2 = vec2, col3 = c("a", "b", "c", "d", "e")) # Alle Spalten müssen die gleiche Länge haben!
df # Datensatz in Konsole anzeigen
View(df) # Datensatz als filter- und sortierbare Tabelle öffnen

df[1] # nimmt nur die erste Spalte
df[1:2] # nimmt nur die ersten beiden Spalten
df[c(1,3)] # nimmt nur die erste und dritte Spalte

df[1,] # nimmt nur die erste Zeile
df[1,3] # erste Zeile, dritte Spalte

df[1] + df[2] # Mit Spalten rechnen

df$col1 # eine Spalte mit dem Namen ansprechen mit dem $-Operator
df$neu <- df$col1 + df$col2 # neue Spalte kreieren

sum(df[1])
sum(df$col1)

mean(df$col1)
median(df$col1)

# Datensatz speichern und einlesen
?write.csv
write.csv(df, "test.csv")
write.csv(df, "test2.csv", row.names = F) # was unterscheidet die beiden Dateien?

# Datensätze einlesen
?read.csv
btw17 <- read.csv("btw17.csv")
View(btw17)

needs(rgdal) # mit der Funktion readOGR vom Paket rgdal können wir Geodaten einlesen
shp <- readOGR("wahlkreise_small/wahlkreise_small.shp") # Shapefile laden
plot(shp) # Übersichtsplot