suppressPackageStartupMessages({
    library(lubridate)
    library(dplyr)
    library(ggplot2)
    library(stringr)
    theme_set(theme_bw())
    library(patchwork)
    library(provoc)
    library(yaml)
    library(here)
})

force <- FALSE

processed <- list.files("data/processed", pattern = "*.csv.gz", full.names = TRUE)
if (!exists("usher")) usher <- usher_barcodes(here("provoc"))
yamls <- read_yaml("data/data_sources.yml")

pdf("provoc-all.pdf", width=10, height =14)
for (i in seq_along(processed)) {
    cat("loop", i, "of", length(processed), "\n")

    dir.create("provoc/model_runs")
    this_bioproj <- str_match(processed[i], ".*(PRJ\\w+\\d+).*")[, 2]
    cat("Bioproject:", this_bioproj, "\n")
    file_path <- paste0("provoc/model_runs/", this_bioproj, ".RDS")
    if (file.exists(file_path) | force) {
        cat("Previous run exists; skipping.\n\n")
        next
    }

    p1 <- read.csv(processed[i])
    p1$mutation <- parse_mutations(p1$label)
    cat("Data loaded and mutations parsed.\n")

    yaml_index <- which(unlist(lapply(yamls, function(x) x$bioproject == p1$bioproject[1])))[1]
    cat("Author:", names(yaml_index), "\n")
    this_yml <- yamls[[yaml_index]]


    gg_coverage <- ggplot(p1) +
        aes(x = position, y = coverage) +
        geom_boxplot() +
        #geom_point() +
        scale_y_log10() +
        theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
        labs(x = "Position", y = "Read Depth")
    if ("date" %in% names(p1) && !is.na(ymd(p1$date[1]))) {
        if ("location" %in% names(p1)) {
            gg_coverage <- gg_coverage + facet_wrap(~ location)
        } else if ("city" %in% names(p1)) {
            gg_coverage <- gg_coverage + facet_wrap(~ city)
        } else if ("ww_population" %in% names(p1)) {
            gg_coverage <- gg_coverage + facet_wrap(~ factor(ww_population))
        }
    }

    lineages_to_check <- intersect(rownames(usher), this_yml$lineages_in_paper)
    this_usher <- usher |> filter_lineages(lineages_to_check)

    if(!file.exists(file_path)) {
        provoc_res <- tryCatch(
            provoc(count / coverage ~ .,
                by = "sra",
                lineage_defs = this_usher,
                data = p1
            ),
            error = function(e) e
        )
        if (inherits(provoc_res, "error")){
            print(provoc_res)
            cat("ProVoC failed, moving on.\n\n")
            next
        } else {
            saveRDS(provoc_res, file_path)
            cat("ProVoC complete, results saved.\n")
        }
    } else {
        provoc_res <- readRDS(file_path)
        cat("ProVoC results loaded from previous run.\n")
    }

    if ("date" %in% names(provoc_res) && !is.na(ymd(provoc_res$date[1]))) {
        provoc_res <- provoc_res |>
            mutate(date = ymd(date))
        if ("location" %in% names(provoc_res)) {
            gg_prov <- provoc_res |>
                autoplot(date_col = "date") +
                geom_smooth(method = "loess", formula = "y ~ x", se = FALSE) +
                facet_wrap(~ location)
        } else if ("city" %in% names(provoc_res)) {
            gg_prov <- provoc_res |>
                autoplot(date_col = "date") +
                geom_smooth(method = "loess", formula = "y ~ x", se = FALSE) +
                facet_wrap(~ city)
        } else if ("ww_population" %in% names(provoc_res)) {
            gg_prov <- provoc_res |>
                autoplot(date_col = "date") +
                geom_smooth(method = "loess", formula = "y ~ x", se = FALSE) +
                facet_wrap(~ factor(ww_population))
        }
    } else {
        gg_prov <- autoplot(provoc_res)
    }

    print(
        gg_coverage / gg_prov +
            plot_annotation(
                title = paste0(p1$bioproject, " - ", names(yamls)[yaml_index]),
                theme = theme(plot.title = element_text(hjust = 0.5))
            )
    )
    cat("Done.\n\n")
}

dev.off()
dev.cur()