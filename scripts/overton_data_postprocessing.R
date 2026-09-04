library(here)
library(dplyr)
library(lubridate)
library(readr)
library(ggplot2)
library(stringr)

barcodes <- provoc::usher_barcodes()

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
            frequency = count / ifelse(coverage == 0, 1, coverage)
        ) |>
        mutate(date = ymd(date)) |>
        mutate(
            date = if_else(
                date < ymd("2021-01-01"),
                date + years(3),
                date
            )
        )
)
head(toronto_wwtps)
write_csv(toronto_wwtps, here("data/processed/overton_toronto.csv.gz"))
rm(overton)


toronto_filtered <- toronto_wwtps |>
    group_by(mutation) |>
    mutate(
        lower_thresh = sum(frequency > 0.25) > 5,
        upper_thresh = sum(frequency < 0.75) > 5
    ) |>
    ungroup() |>
    filter(lower_thresh, upper_thresh) |>
    select(-lower_thresh, -upper_thresh)
head(toronto_filtered)
length(unique(toronto_filtered$mutation))
ggplot(toronto_filtered) +
    aes(x = date, y = frequency, group = mutation, colour = mutation) +
    geom_line() +
    #geom_smooth(se = FALSE, formula = y ~ x, method = "loess",
    #    alpha = 0.001, span = 1/10) +
    ylim(c(0, 1)) +
    theme(legend.position = "none")

write_csv(toronto_filtered, here("data/processed/overton_toronto_filtered.csv.gz"))


toronto_weekly <- toronto_wwtps |>
    mutate(epiweek = paste0(year(date), "-", sprintf("%02d", epiweek(date)))) |>
    group_by(mutation, epiweek, location) |>
    summarise(
        count = sum(count), coverage = sum(coverage), 
        date = min(date),
        .groups = "drop"
    ) |>
    mutate(frequency = count / ifelse(coverage == 0, 1, coverage)) |>
    group_by(mutation) |>
    mutate(
        lower_thresh = sum(frequency > 0.25) > 5,
        upper_thresh = sum(frequency < 075) > 5
    ) |>
    ungroup() |>
    filter(lower_thresh, upper_thresh) |>
    select(-lower_thresh, -upper_thresh) |>
    group_by(epiweek) |>
    mutate(date = min(date)) |>
    ungroup()
ggplot(toronto_weekly) +
    aes(x = date, y = frequency, group = mutation, colour = mutation) +
    geom_line() +
    #geom_smooth(se = FALSE, formula = y ~ x, method = "loess",
    #    alpha = 0.001, span = 1/10) +
    ylim(c(0, 1)) +
    theme(legend.position = "none")
dim(toronto_weekly); length(unique(toronto_weekly$mutation))
length(unique(toronto_weekly$date))
head(toronto_weekly)
write_csv(toronto_weekly, here("data/processed/overton_weekly.csv.gz"))


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
