# This finds the best parts of the best data on which to build models.
# Jahn takes about 10 minutes to load into memory
# (and crashes my Linux computer with only 8GB ram)

# I also create a version which has relevant variant information

library(here)
library(dplyr)
library(tidyr)
library(lubridate)
library(provoc)

system.time(
    jahn <- read.csv(here("data", "processed",
        "PRJEB44932_processed.csv.gz"))
) # 10 minutes or so.
jahn <- filter(jahn, !is.na(location))
jahn <- mutate(jahn, date = ymd(date))
jahn <- filter(jahn, (date > ymd("2021-02-01")) &
    (date <= ymd("2021-11-01")))

head(jahn)

jahnfo <- jahn %>% select(sra, date, location) %>% distinct()

if (FALSE) { # Choosing a date range when interactive
    library(ggplot2)
    jahnfo %>%
        ggplot() +
            aes(x = date, colour = location) +
            geom_density(linewidth = 2) +
            scale_x_date(date_breaks = "1 month") +
            theme(axis.text.x = element_text(angle = 90,
                vjust = 0.5, hjust = 1))
} # Added a filter statement for 2021-01-01 to 2021-11-01 above

sort(unique(jahnfo$date))

datloc <- table(jahnfo$date, jahnfo$location)
datloc[order(rownames(datloc)), ]

jahn$week <- week(jahn$date)

jahn2 <- jahn %>%
    group_by(week, location, label) %>%
    summarise(count = sum(count), coverage = sum(coverage),
        .groups = "drop") %>%
    mutate(frequency = count / coverage)

dim(jahn)
dim(jahn2)

write.csv(jahn2, here("data/processed/jahn_weekly.csv"))
