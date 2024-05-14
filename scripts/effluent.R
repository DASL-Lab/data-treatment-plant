suppressPackageStartupMessages({
    library(here)
    library(dplyr)
    library(lubridate)
    library(argparser)
})

# The columns selected in runtable will be kept in the output
get_runtable <- function(prj) {
    
    if (prj == "PRJNA745177") {
        runtable <- filter(runtable, Replicate != 2 | is.na(Replicate)) %>%
            rename(location = geo_loc_name) %>%
            mutate(
                location = sapply(location,
                    function(x) strsplit(x, split = ", ")[[1]][2]),
                ww_population = as.numeric(gsub(",", "", ww_population))
            )
    } else if (prj == "PRJNA819090") {
        runtable <- runtable %>%
            mutate(location = sapply(geo_loc_name,
                    function(x) strsplit(x, ", ")[[1]][2]))
    } else if (prj == "PRJNA715712") {
        runtable <- runtable %>%
            rename(location = wwtp) %>%
            # Errant files, added manually from out.log
            filter(Run != "SRR18583185") %>% # fastq has 20 lines
            filter(Run != "SRR18583239") # fastq has 24 lines
    } else if (prj == "PRJEB65603") {
        runtable <- runtable %>%
            mutate(location = sapply(Sample_Name,
                    function(x) strsplit(x, "_")[[1]][1])) %>%
            rename(lat = geographic_location_.latitude.,
                lon = geographic_location_.longitude.)
    } else if (prj == "PRJNA735936") {
        runtable <- runtable %>%
            mutate(location = as.numeric(factor(ww_population))) %>%
            rename(sample_type = ww_sample_type)
    } else if (prj == "PRJNA750263") {
        runtable <- runtable %>%
            mutate(location = sapply(Sample.Name,
                    function(x) strsplit(x, " / ")[[1]][1])) %>%
            rename(lat_lon = Lat_Lon)
    } else if (prj == "PRJNA741211") {
        runtable <- runtable
    } else if (prj == "PRJNA720687") {
        runtable <- runtable %>%
            mutate(location = sapply(Sample.Name, 
                    function(x) strsplit(x, "-")[[1]][2]))
    } else if (prj == "PRJEB44932") {
        runtable <- runtable %>%
            mutate(location = sapply(
                runtable$geographic_location_.region_and_locality.,
                function(x) strsplit(x, " - ")[[1]][2])) %>%
            rename(lat = geographic_location_.latitude.,
                lon = geographic_location_.longitude.)
    } else if (prj == "PRJNA735936") {
        runtable <- runtable %>%
            rename(instrument = Instrument,
                lat_lon = Lat_Lon,
                organism = Organism,
                sample_type = ww_sample_type
            )
    } else if (prj == "PRJNA796340") {
        runtable <- rename(runtable, location = geo_loc_name)
    } else if (prj == "PRJEB48206") {
        runtable <- rename(runtable,
            location = geographic_location_.region_and_locality.)
    } else if (prj == "PRJNA788395") {
        runtable <- runtable %>%
            filter(ww_sample_type == "composite") %>%
            mutate(location = gsub("Canada:Quebec\\\\,", "",
                    geo_loc_name))
    } else if (prj == "PRJEB55313") {
        runtable <- runtable %>%
            filter(Instrument == "Illumina NovaSeq 6000")
    } else if (prj == "PRJNA1042787") {
        runtable <- runtable
    } else if (prj == "PRJNA1027858") {
        runtable <- rename(runtable, wwtp = isolation_source)
    } else if (prj == "PRJNA759260") {
        runtable %>% rename(location = geo_loc_name)
    } else if (prj == "PRJEB48985") {
        runtable %>% rename(
            ww_population = population_size_of_the_catchment_area,
            location = name_of_the_sampling_site,
            lat = geographic_location_.latitude.,
            lon = geographic_location_.longitude.
        )
    } else {
        stop("I don't know how to deal with this BioProject yet.")
    }
    runtable <- rename(runtable,
        sra = Run,
        date = Collection_Date,
        sample_name = Sample.Name,
        avg_spot_len = AvgSpotLen,
        bases = Bases,
        bioproject = BioProject)
    runtable <- select(runtable,
        sra, date, sample_name, avg_spot_len, bases, bioproject,
        any_of(c("location", "lat", "lon", "lat_lon", "city",
                "ww_population", "organism", "sample_type")))
    return(runtable)
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
                nrow(coco), " lines with at least ",
                min_coverage, " coverage.\n",
                length(bad_files), " files skipped:\n"))
        cat(paste0("\t", paste0(bad_files, collapse = ", ")))
    } else {
        cat(paste0(". Done. ",
                nrow(coco), " lines with at least ",
                min_coverage, " coverage."))
    }
    cat("\n")
    return(coco)
}

rm_badmuts <- function(coco, freqmin) {
    cat(paste0(
        "Removing mutations that never had a frequency > ",
        freqmin, ". "))
    tmp <- aggregate(coco$frequency,
        by = list(coco$label), FUN = max)
    badmuts <- tmp[tmp[, 2] < freqmin, 1]
    starting_muts <- nrow(coco)

    coco <- coco[!coco$label %in% badmuts, ]
    coco <- rename(coco, sra = run)

    cat(paste0("Done. ", 100 * round(1 - length(badmuts) / starting_muts, 4),
            "% of mutations removed.\n"))
    return(coco)
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
    return(coco)
}


###########################################################
#### Run program                                       ####
###########################################################

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

for (i in seq_along(argv$BioProject)) {
    if (!file.exists(argv$BioProject[i])) {
        warning(paste0(argv$BioProject[i], " not found."))
        next
    }
    runtable <- read.csv(argv$BioProject[i])
    prj <- runtable$BioProject[[1]]
    cat(paste0("\nStarting BioProject ", prj, "\n"))
    runtable <- get_runtable(prj)
    if (prj != "PRJEB55313") {
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
        cat("BioProject, ", prj, " detected, splitting by location.\n")
        locs <- unique(runtable$lat_lon)
        for (loc in locs) {
            cat(paste0("\r", "Location ", which(locs == loc),
                    " of ", length(locs)))
            sometable <- runtable[runtable$lat_lon == loc, ]
            somecoco <- get_mfiles(sometable, argv$min_coverage)
            somecoco <- rm_badmuts(somecoco, freqmin = argv$freqmin)
            somecoco <- add_missing_mutations(somecoco)

            if (loc == locs[1]) {
                allcoco <- somecoco
            } else {
                allcoco <- bind_rows(allcoco, somecoco)
            }
        }

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
