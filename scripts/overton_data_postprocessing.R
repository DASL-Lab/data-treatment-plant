library(here)
library(dplyr)
library(lubridate)
library(readr)
library(ggplot2)

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

barcodes <- provoc::usher_barcodes()
toronto_wwtps |>
    filter(str_starts(location, "Y1")) |>
    group_by(location, mutation) |>
    mutate(
        lower_thresh = sum(frequency > 0.2) > 2,
        upper_thresh = mean(frequency < 0.9) > 0.2
    ) |>
    ungroup() |>
    filter(lower_thresh, upper_thresh) |>
    select(date, frequency, mutation) |>
    distinct() |>
    ggplot() +
    aes(x = date, y = frequency, group = mutation) +
    geom_smooth(se = FALSE, formula = y ~ x, method = "loess",
        colour = 1, alpha = 0.001) +
    ylim(c(0, 1))

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

highland |>
    group_by(location, mutation) |>
    mutate(
        lower_thresh = sum(frequency > 0.1) > 2,
        upper_thresh = sum(frequency < 0.9) > 2
    ) |>
    ungroup() |> 
    filter(lower_thresh, upper_thresh) |>
    ggplot() +
    aes(x = date, y = frequency, group = mutation) +
    geom_line()

head(highland)
write.csv(highland, here("data/processed/highland.csv"))
