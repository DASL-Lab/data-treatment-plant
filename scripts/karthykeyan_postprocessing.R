library(here)
library(dplyr)
library(provoc)
library(lubridate)
library(tidyr)


karth_full <- read.csv(
    here("data/processed/PRJNA819090_processed.csv.gz"),
) |>
    mutate(
        mutation = parse_mutations(label),
        date = ymd(date)
    )
mut_thresh <- 30

karth <- karth_full |>
    group_by(date, location, mutation) |>
    summarise(
        count = sum(count), coverage = sum(coverage),
        sra = sra[1],
        .groups = "drop"
    ) |>
    mutate(frequency = ifelse(coverage == 0, 0, count / coverage)) |>
    group_by(mutation) |>
    mutate(
        thresh = sum(frequency > 0.1) > mut_thresh &
            sum(frequency < 0.9) > mut_thresh
    ) |>
    filter(thresh) |>
    ungroup() |>
    select(-thresh)
dim(karth)

san_diego_count <- karth |>
    filter(location == "San Diego (Point Loma)") |>
    select(count, date, mutation) |>
    arrange(date, mutation) |>
    pivot_wider(values_from = count, names_from = date) |>
    tibble::column_to_rownames("mutation")
dim(san_diego_count)
san_diego_depth <- karth |>
    filter(location == "San Diego (Point Loma)") |>
    select(coverage, date, mutation) |>
    arrange(date, mutation) |>
    pivot_wider(values_from = coverage, names_from = date) |>
    tibble::column_to_rownames("mutation")

ucsd_count <- karth |>
    filter(location == "UCSD Campus") |>
    select(count, date, mutation) |>
    arrange(date, mutation) |>
    pivot_wider(values_from = count, names_from = date) |>
    tibble::column_to_rownames("mutation")
ucsd_depth <- karth |>
    filter(location == "UCSD Campus") |>
    select(coverage, date, mutation) |>
    arrange(date, mutation) |>
    pivot_wider(values_from = coverage, names_from = date) |>
    tibble::column_to_rownames("mutation")

saveRDS(
    list(
        ucsd_count = ucsd_count,
        ucsd_depth = ucsd_depth),
    here("data/processed/karthykeyan_ucsd_wide.RDS")
)

saveRDS(
    list(
        san_diego_count = san_diego_count,
        san_diego_depth = san_diego_depth
    ),
    here("data/processed/karthykeyan_san_diego_wide.RDS")
)

saveRDS(
    list(karth = karth),
    here("data/processed/karthykeyan_coco.RDS")
)
