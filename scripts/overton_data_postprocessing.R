library(here)
library(dplyr)
library(lubridate)
library(readr)

overton <- read.csv(
    here(
        "data/processed/PRJNA1088471_processed.csv.gz"
    )
)
overton$mutation <- provoc::parse_mutations(overton$label)

# Other locations are airport/aircraft
toronto_wwtp_names <- c("AshbridgesBay", "HighlandCreek",
    "Humber", "NorthToronto", "P1", "P2", "Y1", "Y5", "Y6"
)
system.time(
    toronto_wwtps <- overton |>
        filter(location %in% toronto_wwtp_names) |>
        group_by(location, date, mutation) |>
        summarise(
            count = sum(count), coverage = sum(coverage),
            sra = sra[1], .groups = "drop"
        ) |>
        mutate(
            frequency = count / (coverage + 1)
        ) |>
        mutate(date = ymd(date))
)
head(toronto_wwtps)
write_csv(toronto_wwtps, here("data/processed/overton_toronto.csv.gz"))

highland <- overton |>
    filter(str_starts(location, "Highland")) |>
    mutate(
        mutation = parse_mutations(label),
        date = ymd(date)
    )  |>
    mutate(date_numeric = as.numeric(date)) |>
    group_by(mutation, date) |>
    summarise(
        count = sum(count), coverage = sum(coverage),
        sra = sra[1], .groups = "drop"
    ) |>
    mutate(
        frequency = count / (coverage + 1)
    )

head(highland)
write.csv(highland, here("data/processed/highland.csv"))
