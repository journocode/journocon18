# Crashkurs: Programmieren in R für Journalist*innen | Teil 3: Das Tidyverse
# ---------------------------------------------------------------------------

# install.packages("needs")
# library(needs)
needs(tidyverse, magrittr, rgdal)

## Das "tidy data"-Format
btw17 <- read.csv("btw17.csv")
btw17_tidy <- btw17 %>% gather(key=party, value=value, 7:12) # btw17 im "tidy data"-Format
btw17_tidy %>% spread(party, value) # und wieder im "wide"-Format

btw17_tidy$Wahlbeteiligung <- btw17_tidy$Wähler.Zweitstimmen/btw17_tidy$Wahlberechtigte.Zweitstimmen

## Verarbeiten und analysieren mit dplyr
# summarize
btw17_tidy %>% summarize(max(Wahlbeteiligung))
btw17_tidy %>% summarize(max = max(Wahlbeteiligung), min = min(Wahlbeteiligung))

# mutate
btw17_tidy %>% mutate(value_rel = value / Gültige.Zweitstimmen)

btw17_tidy %<>% mutate(value_rel = value / Gültige.Zweitstimmen)

# arrange
btw17_tidy %>% arrange(value_rel)
btw17_tidy %>% arrange(desc(value_rel)) %>% slice(1:3)

# group_by
btw17_tidy %>% group_by(party) %>% summarize(max = max(value_rel)) %>% arrange(desc(max))

# filter
btw17_tidy %>% filter(value_rel <= 0.05)

## Visualisieren mit ggplot2
plot <- btw17_tidy %>% group_by(party) %>% summarize(result = sum(value)/sum(Gültige.Zweitstimmen))

ggplot(plot, aes(x = party, y=result)) + geom_point()

ggplot(plot, aes(x = party, y=result)) + geom_bar(stat = "identity")
ggplot(plot, aes(x = reorder(party, -result), y=result)) + geom_bar(stat = "identity")









# Choropleth
shp <- readOGR("wahlkreise_small/wahlkreise_small.shp")