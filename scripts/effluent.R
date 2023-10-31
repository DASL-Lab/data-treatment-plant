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
            select(sra = Run,
                date = Collection_Date,
                sample_name = Sample.Name,
                ww_population,
                location = geo_loc_name,
                avg_spot_len = AvgSpotLen,
                bases = Bases,
                bioproject = BioProject) %>%
            mutate(
                location = sapply(location,
                    function(x) strsplit(x, split = ", ")[[1]][2]),
                ww_population = as.numeric(gsub(",", "", ww_population))
                )
    } else if (prj == "PRJNA819090") {
        runtable <- runtable %>%
            mutate(location = sapply(geo_loc_name,
                function(x) strsplit(x, ", ")[[1]][2])) %>%
            select(sra = Run,
                date = Collection_Date,
                sample_name = Sample.Name,
                location,
                isolation_source = Isolation_Source,
                avg_spot_len = AvgSpotLen,
                bases = Bases,
                bioproject = BioProject
                )
    } else if (prj == "PRJNA715712") {
        runtable <- runtable %>%
            select(sra = Run,
                location = wwtp,
                sample_name = Sample.Name,
                avg_spot_len = AvgSpotLen,
                bases = Bases,
                bioproject = BioProject,
                date = Collection_Date
            ) %>%
            # Errant files, added manually from out.log
            filter(sra != "SRR18583185") %>% # fastq has 20 lines
            filter(sra != "SRR18583239") # fastq has 24 lines
    } else if (prj == "PRJEB65603") {
        runtable <- runtable %>%
            mutate(location = sapply(Sample_Name,
                function(x) strsplit(x, "_")[[1]][1])) %>%
            select(sra = Run,
                avg_spot_len = AvgSpotLen,
                sample_name = Sample.Name,
                bases = Bases,
                bioproject = BioProject,
                location,
                lat = geographic_location_.latitude.,
                lon = geographic_location_.longitude.,
                date = Collection_Date)
    } else if (prj == "PRJNA735936") {
        runtable <- runtable %>%
            mutate(location = as.numeric(factor(ww_population))) %>%
            select(sra = Run,
                avg_spot_len = AvgSpotLen,
                sample_name = Sample.Name,
                bases = Bases,
                bioproject = BioProject,
                location,
                type = ww_sample_type,
                ww_population,
                date = Collection_Date)
    } else if (prj == "PRJNA750263") {
        runtable <- runtable %>%
            mutate(location = sapply(Sample.Name,
                function(x) strsplit(x, " / ")[[1]][1])) %>%
            select(sra = Run,
                avg_spot_len = AvgSpotLen,
                sample_name = Sample.Name,
                bases = Bases,
                bioproject = BioProject,
                lat_lon = Lat_Lon,
                location,
                date = Collection_Date)
    } else if (prj == "PRJNA741211") {
        runtable <- runtable %>%
            select(sra = Run,
                avg_spot_len = AvgSpotLen,
                sample_name = Sample.Name,
                bases = Bases,
                bioproject = BioProject,
                date = Collection_Date,
                sample_name = Sample.Name)
    } else if (prj == "PRJNA720687") {
        runtable <- runtable %>%
            mutate(location = sapply(Sample.Name, function(x)
                strsplit(x, "-")[[1]][2])) %>%
            select(sra = Run,
                avg_spot_len = AvgSpotLen,
                sample_name = Sample.Name,
                bases = Bases,
                bioproject = BioProject,
                date = Collection_Date,
                location)
    } else if (prj == "PRJEB44932") {
        runtable <- runtable %>%
            mutate(location = sapply(
                runtable$geographic_location_.region_and_locality.,
                function(x) strsplit(x, " - ")[[1]][2])) %>%
            select(sra = Run,
                avg_spot_len = AvgSpotLen,
                bases = Bases,
                bioproject = BioProject,
                date = Collection_Date,
                sample_name = Sample.Name,
                location,
                lat = geographic_location_.latitude.,
                lon = geographic_location_.longitude.)
    } else if (prj == "PRJNA735936") {
        runtable <- runtable %>%
            select(sra = Run,
                avg_spot_len = AvgSpotLen,
                bases = Bases,
                bioproject = BioProject,
                date = Collection_Date,
                sample_name = Sample.Name,
                instrument = Instrument,
                lat_lon = Lat_Lon,
                organism = Organism,
                population = ww_population,
                sample_type = ww_sample_type
            )
    } else if (prj == "PRJNA796340") {
        runtable <- runtable %>%
            select(
                sra = Run,
                avg_spot_len = AvgSpotLen,
                bases = Bases,
                bioproject = BioProject,
                date = Collection_Date,
                sample_name = Sample.Name,
                wwtp = geo_loc_name,
                population = ww_population
            )
    } else if (prj == "PRJEB48206") {
        runtable <- runtable %>%
            select(
                sra = Run,
                avg_spot_len = AvgSpotLen,
                bases = Bases,
                bioproject = BioProject,
                date = Collection_Date,
                sample_name = Sample.Name,
                wwtp = geographic_location_.region_and_locality.
            )
    } else if (prj == "PRJNA788395") {
        runtable <- runtable %>%
            filter(ww_sample_type == "composite") %>%
            mutate(city = gsub("Canada:Quebec\\\\,", "",
                geo_loc_name)) %>%
            select(
                sra = Run,
                avg_spot_len = AvgSpotLen,
                bases = Bases,
                bioproject = BioProject,
                date = Collection_Date,
                sample_name = Sample.Name,
                population = ww_population,
                city
            )
    } else if (prj == "PRJEB55313") {
        runtable <- runtable %>%
            filter(Instrument == "Illumina NovaSeq 6000") %>%
            select(
                sra = Run,
                avg_spot_len = AvgSpotLen,
                bases = Bases,
                bioproject = BioProject,
                date = Collection_Date,
                sample_name = Sample.Name,
                lat_lon
            )
    } else {
        stop("I don't know how to deal with this BioProject yet.")
    }
    return(runtable)
}

# Mutations with coverage less than 10 are removed
    # IMPORTANT: They may be re-added later with a count of 0
    # This is a compromise for memory managment.
get_mfiles <- function(runtable) {
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
        m <- m[m$coverage > 10, ]
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
        cat(paste0(". Done. ", length(bad_files), " files skipped:\n"))
        cat(paste0("\t", paste0(bad_files, collapse = ", ")))
    }
    cat("\n")
    return(coco)
}

rm_badmuts <- function(coco, freqmin) {
    cat(paste0(
            "Removing mutations that never had a frequency > ",
            freqmin, ". "))
    badmuts <- coco %>%
        select(label, frequency) %>%
        group_by(label) %>%
        summarise(keep = any(frequency > freqmin))

    cat(paste0(100 * round(1 - mean(badmuts$keep), 4),
        "% of mutations removed.\n"))

    coco <- left_join(coco, badmuts, by = "label") %>%
        filter(keep) %>%
        select(-keep) %>%
        rename(sra = run)
    return(coco)
}

# If a mutation had a coverage of 0 but it had a high frequency elsewhere,
# this is where it will be added back in with a count of 0.
add_missing_mutations <- function(coco) {

    cat("Use coverage files to ensure all samples have all mutations - including 0s.\n")
    allmuts <- coco %>%
        select(position, label) %>%
        distinct()

    my_sra <- unique(coco$sra)
    mi_list <- vector(mode = "list", length = length(my_sra))
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
            mi$mutation <- NULL

            mi_list[[i]] <- rbind(mi, missings)
        }
    }
    cat(". Done.\n")
    fullcoco <- bind_rows(mi_list)
    return(fullcoco)
}


###########################################################
#### Run program                                       ####
###########################################################

# Argument Parsing
p <- arg_parser("Process GromStole output for BioProjects (variant agnostic).",
    hide.opts = TRUE)
p <- add_argument(p, "--freqmin", type = "numeric", default = 0.1,
    help = "Mutation must have a frequency of -f in at least one sample.")
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
    allcoco <- get_mfiles(runtable)
    allcoco <- rm_badmuts(allcoco, freqmin = argv$freqmin)
    allcoco <- add_missing_mutations(allcoco)

    cat("Cleaning up. ")
    allcoco <- left_join(allcoco, runtable, by = "sra")

    dir.create(here("data", "processed"),
        showWarnings = FALSE) # Ensure the directory exists
    # Write directly to a compressed file.
    write.csv(x = allcoco,
        file = gzfile(here("data", "processed",
            paste0(prj, "_processed.csv.gz"))),
        row.names = FALSE)

    cat(paste0("Done. \n", nrow(allcoco), " lines written to ",
        prj, "_processed.csv.gz\n"))
}
