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




# Weekly totals ---------------------------------
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
jahn2$mutation <- provoc::parse_mutations(jahn2$label)

write.csv(jahn2, here("data/processed/jahn_weekly.csv"))




# ProVoC-ify ------------------------------------
varmat <- astronomize() |>
    filter_lineages(c("B.1.617.2", "B.1.1.7", "B.1.351", "P.1"))
jahn3 <- provoc::fuse(jahn2, varmat)

# Only mutations with known lineages
jahn3 <- jahn3[!is.na(jahn3$lin_B.1.1.7), ]

write.csv(jahn3, file = "data/processed/jahn_weekly_variants.csv")




# ProVoC-ify 2: Usher ---------------------------
varmat <- usher_barcodes(write = FALSE) |>
    filter_lineages(c("B.1.617.2", "B.1.1.7", "B.1.351", "P.1"))
jahn3 <- provoc::fuse(jahn2, varmat)

# Only mutations with known lineages
jahn3 <- jahn3[!is.na(jahn3$lin_B.1.1.7), ]

write.csv(jahn3, file = "data/processed/jahn_weekly_variants.csv")




# Wide (for matrix factorization) ---------------
good_muts <- tapply(jahn$frequency, jahn$label, max)
good_mut_names <- names(good_muts[good_muts >= 0.20])
length(good_mut_names)
jahn4 <- jahn[jahn$label %in% good_mut_names, ]
jahn4$mutation <- provoc::parse_mutations(jahn4$label)
dim(jahn4)

unique(table(jahn4$sra)) # Expect one value (length(good_mut_names))
jahn4 <- jahn4 %>% arrange(sra, mutation)

jahn_wides <- lapply(X = unique(jahn4$location), function(loc) {
    loc_temp <- jahn4[jahn4$location == loc, ]
    sapply(X = unique(loc_temp$sra),
        FUN = function(sra) {
            sra_temp <- loc_temp[loc_temp$sra == sra,
                c("frequency", "mutation")]
            res <- sra_temp[, "frequency"]
            names(res) <- sra_temp[, "mutation"]
            res
        })
})
dim(jahn_wides[[1]])
rownames(jahn_wides[[1]]) |> head()
colnames(jahn_wides[[1]]) |> head()

jahn_meta <- jahn4 %>%
    select(sra, date, location) %>%
    distinct() %>%
    as.data.frame()
attr(jahn_wides, "metadata") <- jahn_meta

saveRDS(jahn_wides,
    file = here("data", "processed", "jahn_wide_list_attributes.RDS"))
