suppressPackageStartupMessages({
    library(here)
    library(dplyr)
    library(lubridate)
})

# Rscript scripts/effluent.R --freqmin 0.1 PRJNA745177
# Bioproject accession should be at the end
# Assumes you've renamed runtables to SraRunTable_[prj].txt

args <- commandArgs(trailingOnly = TRUE)
freqmin <- as.numeric(args[which(args == "--freqmin") + 1])
prj <- args[length(args)]
if (!length(prj)) prj <- "PRJNA745177"

runtable <- read.csv(here("data", "runtables",
    paste0("SraRunTable_", prj, ".txt")))

# The columns selected in runtable will be kept in the output
cat("Load and process runtable.\n")
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
            avg_spot_len = AvgSpotLen,
            bases = Bases,
            bioproject = BioProject,
            date = Collection_Date
        ) %>%
        # Errant files, added manually from out.log
        filter(sra != "SRR18583185") %>% # fastq has 20 lines
        filter(sra != "SRR18583239") # fastq has 24 lines
} else {
    stop("I don't know how to deal with this BioProject yet.")
}

cat("Gather all mapped files.\n")
# Mutations with coverage less than 10 are removed
    # IMPORTANT: They may be re-added later with a count of 0
    # This is a compromise for memory managment.
for (i in seq_along(runtable$sra)) {
    cat(paste0("\b\b\b\b\b\b\b\b\b", i, "/", nrow(runtable)))
    mname <- here("data", "groutput",
        paste0("", runtable$sra[i], ".mapped.csv.gz"))
    if (!file.exists(mname)) {
        mname <- gsub(".gz", "", mname)
    }
    m <- read.csv(here("data", "groutput",
        paste0("", runtable$sra[i], ".mapped.csv.gz")))
    m <- m[m$coverage > 10, ]
    m$count <- round(m$frequency * m$coverage, 0)
    m$run <- runtable$sra[i]

    if (i == 1) {
        coco <- m
    } else {
        coco <- rbind(coco, m)
    }
}

cat("\nRemove mutations which never achieved a frequency > 0.1\n")
badmuts <- coco %>%
    select(mutation, frequency) %>%
    group_by(mutation) %>%
    summarise(keep = any(frequency > freqmin))

coco <- left_join(coco, badmuts, by = "mutation") %>%
    filter(keep) %>%
    select(-keep) %>%
    rename(sra = run)

cat("Ensure all sra's have all mutations - including 0s.\n")
allmuts <- coco %>%
    select(position, label, mutation) %>%
    distinct()

# If a mutation had a coverage of 0 but it had a high frequency elsewhere,
# this is where it will be added back in with a count of 0.
my_sra <- unique(coco$sra)
for (i in seq_along(my_sra)) {
    this_sra <- which(coco$sra == my_sra[i])
    mi <- coco[this_sra, ]

    if (any(!allmuts$label %in% mi$label)) {
        c <- read.csv(here("data", "groutput",
            paste0(my_sra[i], ".coverage.csv.gz")))
        missings <- anti_join(allmuts, mi, by = "mutation")
        missings$count <- 0
        missings <- left_join(missings, c, by = "position")
        mi <- bind_rows(mi, missings)
    }

    if (i == 1) {
        fullcoco <- mi
    } else {
        fullcoco <- bind_rows(fullcoco, mi)
    }
}

cat("Clean up.\n")
fullcoco <- left_join(fullcoco, runtable, by = "sra")

dir.create(here("data", "processed"),
    showWarnings = FALSE) # Ensure the directory exists
# Write directly to a compressed file.
write.csv(x = fullcoco,
    file = gzfile(here("data", "processed",
        paste0(prj, "_processed.csv.gz"))),
    row.names = FALSE)

cat("Done.")