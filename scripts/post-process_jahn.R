# This finds the best parts of the best data on which to build models.
# Jahn takes about 10 minutes to load into memory
# (and crashes my Linux computer with 8GB ram)

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

if (FALSE) { # Choosing a date range when interactive
    library(ggplot2)
    jahnfo %>%
        ggplot() +
            aes(x = date, colour = location) +
            geom_density(linewidth = 2) +
            scale_x_date(date_breaks = "1 month") +
            theme(axis.text.x = element_text(angle = 90,
                vjust = 0.5, hjust = 1))
} # Added a filter statement for 2021-02-01 to 2021-11-01 above

jahn2 <- jahn %>%
    mutate(week = week(date)) %>%
    group_by(week, location, label) %>%
    summarise(count = sum(count), coverage = sum(coverage),
        .groups = "drop") %>%
    mutate(frequency = ifelse(coverage == 0, 0, count / coverage))

maxes <- aggregate(jahn2$frequency,
    by = list(label = jahn2$label),
    FUN = max, na.rm = TRUE)
bad_muts <- maxes$label[maxes$x < 0.05]
jahn2 <- filter(jahn2, !label %in% bad_muts)

write.csv(jahn2, here("data/processed/jahn_weekly.csv"))

# ProVoC-ify
jahn2$mutation <- provoc::parse_mutations(jahn2$label)
varmat <- filter_varmat(path = "../../constellations", return_df = TRUE)
jahn2 <- left_join(jahn2, varmat, by = "mutation")

# Only mutations with known lineages
jahneage <- jahn2[!is.na(jahn2$B.1.1.7), ]

write.csv(jahneage, file = "data/processed/jahn_weekly_variants.csv")
