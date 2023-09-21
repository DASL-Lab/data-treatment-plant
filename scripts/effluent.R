library(here)
library(dplyr)
library(lubridate)

# Rscript effluent.R --quiet --freqmin 0.1 PRJNA745177
# "--quiet" can go anywhere
# Bioproject accession should be at the end

args <- commandArgs(trailingOnly = TRUE)
verbose <- TRUE
if ("--quiet" %in% args) {
    verbose <- FALSE
    args <- args[-which(args == "--quiet")]
}

freqmin <- 0.05
if ("--freqmin" %in% args) {
    freqmin <- as.numeric(args[which(args == "--freqmin") + 1])
}

prj <- args[length(args)]
if (!length(prj)) prj <- "PRJNA745177"

runtable <- read.csv(here("data", "runtables", 
    paste0("SraRunTable_", prj, ".txt")))

# The rows selected in runtable will be kept in the effluent
if (prj == "PRJNA745177") {
    runtable <- filter(runtable, Replicate != 2 | is.na(Replicate)) %>%
        select(sra = Run,
            date = Collection_Date,
            sample_name = Sample.Name,
            ww_population,
            location = geo_loc_name,
            avg_spot_len = AvgSpotLen,
            bases = Bases
            ) %>%
        mutate(
            location = sapply(location,
                function(x) strsplit(x, split = ", ")[[1]][2]),
            ww_population = as.numeric(gsub(",", "", ww_population))
            )
}

# Gather the actual sample data
for (i in seq_along(runtable$sra)) {
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

coco_backup <- coco
coco <- coco_backup

# Remove mutations which never achieved a frequency >0.1
badmuts <- coco %>%
    select(mutation, frequency) %>%
    group_by(mutation) %>%
    summarise(keep = any(frequency > freqmin))

coco <- left_join(coco, badmuts, by = "mutation") %>%
    filter(keep) %>%
    select(-keep) %>%
    rename(sra = run)

# Ensure all sra's have all mutations - including 0s.
allmuts <- coco %>%
    select(position, label, mutation) %>%
    distinct()

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

# Put it all together
fullcoco <- left_join(fullcoco, runtable, by = "sra")

dir.create(here("data", "processed"), 
    showWarnings = FALSE)
write.csv(x = fullcoco, 
    file = gzfile(here("data", "processed",
        paste0(prj, "_processed.csv.gz"))),
    row.names = FALSE)
