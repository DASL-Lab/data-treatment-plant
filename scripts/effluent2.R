"
Given a runtable, this will gather all of the mutation counts and coverages,
filter out mutations that are below a minimum coverage, and remove mutations
that are below a minimum frequency. It will then add back in mutations that
were removed due to low coverage, but have a high frequency. It will also
ensure that all samples have all mutations, and then write the results to a
compressed file.

This is a re-factoring of the effluent.R script to avoid large if-else blocks.

Arguments:
--freqmin: Minimum frequency of a mutation to be considered.
--min_coverage: Minimum coverage of a mutation to be considered.
--beep: Play a beep when completed. Requires the beepr package.

Usage:
Rscript effluent2.R --freqmin 0.1 --min_coverage 40 --beep \
    data/runtables/SraRunTable_PRJNA745177.txt

"

library(dplyr)
library(stringr)
library(tidyr)

loc_zones <- data.frame(
    location = c(
        "Dproad, Botanical garden, Aundh, Pune", # Zone 1
        "Pune-Mumbai Highway Aundh-Sanghvi, Pune",
        "Baner-Balewadi, Pune",
        "Baner-Mahalunge, Pune",
        "Jai bhavani nagar, Pashan, Pune",
        "Someshwarwadi, Pune",
        "Dapodi-Old Sangvi Bridge, Pune", # Zone 2
        "Harris Bridge, Dapodi, Pune",
        "Phugewadi-Dapodi, Sai Service, Pune",
        "Vishrantwadi, Shantinagar, Pune",
        "Karveroad Kothrud, Pune", #Zone 3
        "Kothrud Bus depot, Pune",
        "Sanjeevan Hospital Kothrud, Pune",
        "Warje Mumbai-Banglore Highway, Pune",
        "Dattawadi, under Rajaram Bridge, Pune",
        "Vitthalwadi hingne, Sinhagad road, Pune",
        "Kalewadi Adarshnagar, Pune", # Zone 4
        "Kasarwadi pimple gurav road, Pune",
        "Pimple gurav, 60 ft ring road, Pune",
        "Rahatni, new DP road, Pune",
        "Shastrinagar, Pimpri, Pune",
        "Wolf Colony, Pimpri, Pune",
        "Chinchwad, Adityabirla Hospital, Pune",
        "RTO Office Yerwada, Pune", # Zone 5
        "Shivajinagar Chaturshrungi, Pune",
        "Shivajinagar Junabazaar, Pune",
        "Shivajinagar Vaidhawadi, Pune"
    ),
    zone = rep(1:5, times = c(5, 5, 6, 7, 4))
)

fix_location <- function(df, loc_column, pattern, replacement) {
    df |>
        mutate(
            location := str_replace_all({{ loc_column }}, pattern, replacement)
        )
}
split_location <- function(df, loc_column, pattern, i) {
    df |>
        mutate(location := str_split_i({{ loc_column }}, pattern, i))
}

prj_transformations <- list(
    PRJNA745177 = function(df) {
        df |>
            filter(Replicate != 2 | is.na(Replicate)) |>
            split_location(geo_loc_name, ", ", 2) |>
            mutate(
                ww_population = as.numeric(gsub(",", "", ww_population))
            )
    },
    PRJNA819090 = function(df) {
        df |> split_location(geo_loc_name, ", ", 2)
    },
    PRJNA715712 = function(df) {
        df |>
            rename(location = wwtp) |>
            filter(!Run %in% c("SRR18583185", "SRR18583239"))
    },
    PRJEB65603 = function(df) {
        df |>
            split_location(Sample_Name, "_", 1) |>
            rename(
                lat = geographic_location_.latitude.,
                lon = geographic_location_.longitude.
            )
    },
    PRJNA735936 = function(df) {
        df |>
            mutate(location = as.numeric(factor(ww_population))) |>
            rename(sample_type = ww_sample_type)
    },
    PRJNA750263 = function(df) {
        df |>
            split_location(Sample.Name, " / ", 1) |>
            rename(lat_lon = Lat_Lon)
    },
    PRJNA741211 = function(df) df,
    PRJNA720687 = function(df) {
        df |> split_location(Sample.Name, "-", 2)
    },
    PRJEB44932 = function(df) {
        df |>
            rename(
                lat = geographic_location_.latitude.,
                lon = geographic_location_.longitude.,
                location = geographic_location_.region_and_locality.
            ) |>
            split_location(location, " - ", 2)
    },
    PRJNA796340 = function(df) rename(df, location = geo_loc_name),
    PRJEB48206 = function(df) {
        rename(df, location = geographic_location_.region_and_locality.)
    },
    PRJNA788395 = function(df) {
        df |>
            filter(ww_sample_type == "composite") |>
            fix_location(geo_loc_name, "Canada:Quebec\\\\,", "")
    },
    PRJEB55313 = function(df) {
        df |>
            tidyr::separate_wider_regex(
                lat_lon,
                patterns = c(
                    lat = "[\\d\\.+]+", " ",
                    lat_N = "\\w", " ",
                    lon = "[\\d\\.+]+", " ",
                    lon_E = "\\w"
                ),
                cols_remove = FALSE
            ) |>
            mutate(
                lat = as.numeric(lat) * ifelse(lat_N == "N", 1, -1),
                lon = as.numeric(lon) * ifelse(lon_E == "E", 1, -1)
            )
    },
    PRJNA1042787 = function(df) df,
    PRJNA1027858 = function(df) rename(df, wwtp = isolation_source),
    PRJNA759260 = function(df) rename(df, location = geo_loc_name),
    PRJEB48985 = function(df) {
        rename(df,
            ww_population = population_size_of_the_catchment_area,
            location = name_of_the_sampling_site,
            lat = geographic_location_.latitude.,
            lon = geographic_location_.longitude.
        )
    },
    PRJNA811594 = function(df) {
        df |>
            fix_location(Isolate, "ENV/USA/", "") |>
            split_location(location, "-", 1)
    },
    PRJNA731975 = function(df) rename(df, location = "wwtp"),
    PRJNA772783 = function(df) {
        df |>
            split_location(Sample.Name, "\\d", 1) |>
            split_location(location, "-", 1)
    },
    PRJNA1110039 = function(df) {
        aux_info <- read.csv("data/PRJNA1110039_supp.csv") |>
            rename(
                location = SampleID, lat = Latitude, lon = Longitude,
                city = CitiesSurveyed, zone = Zone
            )
        df |>
            split_location(Library.Name, "\\d", 1) |>
            left_join(aux_info, by = "location")
    },
    PRJNA1088471 = function(df) {
        ash <- c("AshbridgeBay", "Ashbridges", "AshbridgesBay")
        high <- c("Highland", "HighlandCR", "HighlandCreek")
        df |>
            fix_location(Sample.Name, "(-|\\d{2,})", "") |>
            mutate(location = ifelse(location %in% ash, "AshbridgesBay",
                    ifelse(location %in% high, "HighlandCreek", location))) |>
            mutate(zone = case_when(
                location %in% c(
                    "Humber", "AshbridgesBay", "HighlandCreek", "NorthToronto"
                ) ~ "Toronto",
                location %in% c("As", "At") ~ "Pooled Aircraft Sewage",
                location %in% c("A1", "A3") ~ "Airport Terminal 1 and 3",
                location %in% c("P1", "P2") ~ "Peel",
                location %in% c("Y1", "Y5", "Y6") ~ "York",
                TRUE ~ "Devan Missed One"
            ))
    },
    PRJNA856091 = function(df) fix_location(df, Sample.Name, "_.*", ""),
    PRJNA992940 = function(df) rename(df, location = isolation_source),
    PRJNA1067101 = function(df) {
        df |>
            fix_location(geo_loc_name, "(India: |\\, Maharashtra|\\\\)", "") |>
            left_join(loc_zones, by = "location")
    },
    PRJEB61810 = function(df) {
        rename(df,
            location = name_of_the_sampling_site,
            lat = geographic_location_.latitude.,
            lon = geographic_location_.longitude.,
            ww_population = population_size_of_the_catchment_area
        )
    },
    PRJNA946141 = function(df) {
        df |>
            rename(zone = ww_sample_site, sample_type = ww_sample_type) |>
            split_location(Sample.Name, "-|(50)", 1) |>
            filter(!str_detect(Sample.Name, "rep"),
                str_detect(BioSampleModel, "wastewater"))
    },
    PRJEB76651 = function(df) {
        df |>
            rename(Sample_Name = Sample.Name) |>
            split_location(sample_name, "_", 2) |>
            rename(Collection_Date = collection_date, Sample.Name = sample_name)
    },
    PRJNA1238906 = function(df) {
        mutate(df, location = str_sub(Sample.Name, 1, 2))
    },
    PRJNA1212683 = function(df) {
        fix_location(df, geo_loc_name, "Luxembourg: ", "")
    },
    PRJNA1141947 = function(df) {
        fix_location(df, geo_loc_name, "United Kingdom: ", "")
    },
    PRJDB19812 = function(df) {
        fix_location(df, geo_loc_name, "(^.*, )|( city)", "")
    },
    PRJNA1027333 = function(df) fix_location(df, geo_loc_name, "USA: ", ""),
    PRJNA865728 = function(df) fix_location(df, geo_loc_name, "USA: ", ""),
    PRJNA896334 = function(df) fix_location(df, geo_loc_name, "Pune", ""),
    PRJNA847239 = function(df) fix_location(df, geo_loc_name, "USA: ", ""),
    PRJNA748354 = function(df) split_location(df, Library.Name, "_", 3),
    PRJEB67638 = function(df) {
        rename(df,
            location = name_of_the_sampling_site,
            lat = geographic_location_.latitude.,
            lon = geographic_location_.longitude.
        )
    },
    PRJNA765031 = function(df) rename(df, location = geo_loc_name),
    PRJNA941107 = function(df) rename(df, location = geo_loc_name)
)

# Main function
get_runtable <- function(prj, runtable) {
    if (!prj %in% names(prj_transformations)) {
        stop("I don't know how to deal with this BioProject yet.")
    }

    runtable <- prj_transformations[[prj]](runtable)

    # Common post-processing
    runtable <- rename(runtable,
        sra = Run,
        date = Collection_Date,
        sample_name = Sample.Name,
        avg_spot_len = AvgSpotLen,
        bases = Bases,
        bioproject = BioProject
    )

    runtable <- select(runtable,
        sra, date, sample_name, avg_spot_len, bases, bioproject,
        any_of(c("location", "lat", "lon", "lat_lon", "city",
                "ww_population", "organism", "sample_type", "zone"))
    )

    runtable
}


# Mutations with coverage less than 10 are removed
# IMPORTANT: They may be re-added later with a count of 0
# This is a compromise for memory managment.
get_mfiles <- function(runtable, min_coverage) {
    cat("Gathering all mapped files.\n")
    bad_files <- c()
    mfile_list <- vector(mode = "list", length = nrow(runtable))
    for (i in seq_along(runtable$sra)) {
        cat(paste0("\r", i, "/", nrow(runtable)))
        mname <- here("data", "groutput",
            paste0("", runtable$sra[i], ".mapped.csv.gz"))
        if (!file.exists(mname)) {
            mname <- gsub(".gz", "", mname)
            if (!file.exists(mname)) {
                bad_files <- c(bad_files, runtable$sra[i])
                next
            }
        }
        m <- read.csv(mname)
        m <- m[m$coverage >= min_coverage, ]
        if (nrow(m) < 10) {
            bad_files <- c(bad_files, runtable$sra[i])
            next
        }
        m$count <- round(m$frequency * m$coverage, 0)
        m$run <- runtable$sra[i]

        mfile_list[[i]] <- m
    }
    coco <- bind_rows(mfile_list)
    if (length(bad_files) > 0) {
        cat(paste0(". Done. ",
                nrow(coco), " mutations with at least ",
                min_coverage, " coverage.\n",
                length(bad_files), " files skipped:\n"))
        cat(paste0("\t", paste0(bad_files, collapse = ", ")))
    } else {
        cat(paste0(". Done. ",
                nrow(coco), " mutations with at least ",
                min_coverage, " coverage."))
    }
    cat("\n")
    coco
}

rm_badmuts <- function(coco, freqmin) {
    cat(paste0(
        "Removing mutations that never had a frequency > ",
        freqmin, ". "))
    tmp <- aggregate(coco$frequency,
        by = list(coco$label), FUN = max)
    badmuts <- tmp[tmp[, 2] < freqmin, 1]

    starting_muts <- length(unique(coco$label))
    coco <- filter(coco, !label %in% badmuts)
    ending_muts <- length(unique(coco$label))

    cat(paste0("Done. ",
            100 * round(1 - ending_muts / starting_muts, 4),
            "% of mutations removed.\n"))
    if ("run" %in% colnames(coco)) {
        coco <- rename(coco, sra = run)
    }
    coco
}

# If a mutation had a coverage of 0 but it had a high frequency elsewhere,
# this is where it will be added back in with a count of 0.
add_missing_mutations <- function(coco) {

    cat("Using coverage files to ensure all samples have all mutations (including counts of 0 or coverages below min_coverage).\n")
    allmuts <- coco %>%
        select(position, label) %>%
        distinct()

    my_sra <- unique(coco$sra)
    missing_list <- vector(mode = "list", length = length(my_sra))
    for (i in seq_along(my_sra)) {
        cat(paste0("\r", i, "/", length(my_sra)))
        this_sra <- which(coco$sra == my_sra[i])
        mi <- coco[this_sra, ]

        if (any(!allmuts$label %in% mi$label)) {
            cfile <- here("data", "groutput",
                paste0(my_sra[i], ".coverage.csv.gz"))
            if (!file.exists(cfile)) {
                cfile <- here("data", "groutput",
                    paste0(my_sra[i], ".coverage.csv"))
            }
            c <- read.csv(cfile)
            missings <- anti_join(allmuts, mi, by = "label")
            missings$count <- 0
            missings <- left_join(missings, c, by = "position")
            missings$frequency <- missings$count / (missings$coverage + 1)
            missings$sra <- mi$sra[1]

            missing_list[[i]] <- missings
        }
    }
    all_missings <- bind_rows(missing_list)
    coco <- bind_rows(coco, all_missings)
    coco <- arrange(coco, sra, label)

    cat(". Done.\n")
    coco
}

























###########################################################
#### Run program                                       ####
###########################################################
suppressPackageStartupMessages({
    library(here)
    library(dplyr)
    library(stringr)
    library(lubridate)
    library(argparser)
})
# Argument Parsing
p <- arg_parser("Process GromStole output for BioProjects (variant agnostic).",
    hide.opts = TRUE)
p <- add_argument(p, "--freqmin", type = "numeric", default = 0.1,
    help = "Mutation must have a frequency of -f in at least one sample.")
p <- add_argument(p, "--min_coverage", type = "numeric", default = 40,
    help = "Mutation must have a min coverage of -m in at least one sample.")
p <- add_argument(p, "--parse_mutations", flag = TRUE,
    help = "Parse mutations into aa format.")
p <- add_argument(p, "--beep", flag = TRUE,
    help = "Play a beep when completed. Requires the beepr package.")
p <- add_argument(p, "BioProject", nargs = Inf,
    default = "data/runtables/SraRunTable_PRJNA745177.txt",
    help = "Path to the SraRunTable.txt file.")
argv <- parse_args(p)
if (grepl(",", argv$BioProject))
    argv$BioProject <- strsplit(argv$BioProject, ",")[[1]]

if (FALSE) {
    argv <- list(BioProject = "data/runtables/SraRunTable_PRJEB44932.txt",
        beep = TRUE, parse_mutations = FALSE,
        freqmin = 0.1, min_coverage = 40)
}

for (i in seq_along(argv$BioProject)) {
    if (!file.exists(argv$BioProject[i])) {
        warning(paste0(argv$BioProject[i], " not found."))
        next
    }
    runtable <- read.csv(argv$BioProject[i])
    prj <- runtable$BioProject[[1]]
    cat(paste0("\nStarting BioProject ", prj, "\n"))
    runtable <- get_runtable(prj, runtable)
    if (!prj %in% c("PRJEB55313", "PRJEB44932")) {
        allcoco <- get_mfiles(runtable, argv$min_coverage)
        allcoco <- rm_badmuts(allcoco, freqmin = argv$freqmin)
        allcoco <- add_missing_mutations(allcoco)
        if (argv$parse) {
            cat("Adding aa mutation names using provoc::parse_mutations().\n")
            allcoco$mutation <- parse_mutations(allcoco$label)
        }

        cat("Cleaning up and writing to disk. ")
        allcoco <- left_join(allcoco, runtable, by = "sra")
    } else {
        cat("BioProject", prj, "detected, splitting by location.\n")
        if (prj == "PRJEB44932") {
            loc_col <- "location"
        } else {
            loc_col <- "lat_lon"
        }
        locs <- unique(runtable[, loc_col])
        locs <- locs[!is.na(locs)]
        if (exists("allcoco")) rm("allcoco")
        for (loc in locs) {
            cat(paste0("Location ", which(locs == loc),
                    " of ", length(locs), "\n"))
            sometable <- runtable[runtable[, loc_col] == loc, ]
            sometable <- sometable[complete.cases(sometable), ]
            if (nrow(sometable) < 3) {
                cat("Location", loc, "had less than 3 samples.\n")
                next
            }
            somecoco <- get_mfiles(sometable, argv$min_coverage)
            somecoco <- rm_badmuts(somecoco,
                freqmin = argv$freqmin)

            if (!exists("allcoco")) {
                allcoco <- somecoco
            } else {
                allcoco <- bind_rows(allcoco, somecoco)
                print(nrow(allcoco))
            }
            cat("\n")
        }
        allcoco <- add_missing_mutations(allcoco)

        cat("\nCleaning up and writing to disk. ")
        allcoco <- left_join(allcoco, runtable, by = "sra")
    }

    dir.create(here("data", "processed"),
        showWarnings = FALSE) # Ensure the directory exists
    # Write directly to a compressed file.
    write.csv(x = allcoco,
        file = gzfile(here("data", "processed",
                paste0(prj, "_processed.csv.gz"))),
        row.names = FALSE)

    cat(paste0("Done. \n", nrow(allcoco), " lines written to ",
            prj, "_processed.csv.gz\n\n"))
    if ("beepr" %in% rownames(installed.packages())) {
        beepr::beep(10)
        Sys.sleep(0.5)
    }
}
