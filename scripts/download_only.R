library(here)
library(stringr)
library(dplyr)

prj <- "PRJNA1088471"

outdir <- here("data", "saved_fastq", prj)
if (!dir.exists(outdir)) dir.create(outdir, recursive = TRUE)

runfile <- here("data/runtables", paste0("SraRunTable_", prj, ".txt"))
runfile_split <- str_split_1(runfile, "/")
runfile_slug <- runfile_split[length(runfile_split)]
runfile_out <- str_replace(runfile_slug, ".txt", "_stats.txt")

runtable <- read.csv(runfile)
runtable$avg_depth <- NA
runtable$spots_read <- NA
runtable$reads_read <- NA
runtable$floor_50000 <- NA
runtable$mapped_50000 <- NA
runtable$mapped_perc <- NA
runtable$length_1 <- NA
runtable$length_2 <- NA

loop_times <- c()
t0 <- Sys.time()
for (i in seq_len(nrow(runtable))) {
	t1 <- Sys.time()
	cat("Run", i, "of", nrow(runtable), "\b. ")
	cat("Downloading. ")
	fasterq_dump <- system2(
		"fasterq-dump",
		c(runtable$Run[i], "--progress", "-Z", "--outdir", outdir),
		stdout = TRUE, stderr = TRUE
	)


	fasterq_dump <- paste(fasterq_dump, collapse = "\n")

	runtable$spots_read[i] <- str_extract(fasterq_dump, "spots read.*") |> 
		readr::parse_number()
	runtable$reads_read[i]  <- str_extract(fasterq_dump, "reads read.*") |>
		readr::parse_number()

	cat("Gzipping. ")
	system2("gzip", 
		c("-f", paste0(outdir, "/", runtable$Run[i], "_1.fastq")))
	system2("gzip", 
		c("-f", paste0(outdir, "/", runtable$Run[i], "_2.fastq")))


	runtable$length_1[i] <- paste(
		"gunzip -c", 
		paste0(outdir, "/", runtable$Run[i], "_1.fastq"),
		"| wc -l"
	) |>
		system(intern = TRUE) |>
		as.numeric()
	runtable$length_2[i] <- paste(
		"gunzip -c", 
		paste0(outdir, "/", runtable$Run[i], "_2.fastq"),
		"| wc -l"
	) |>
		system(intern = TRUE) |>
		as.numeric()

	cat("Minimapping. ")
	minimap2 <- system2(
		"python3",
		c(
			here("gromstolen/minimap2.py"),
			"-t", "12",
			"-p", runtable$Run[i],
			"-o", here("data/groutput"),
			"--nocut", "--replace", 
			"--ref", here("data/NC_045512.fa"),
			here(paste0(outdir, "/", runtable$Run[i], "_1.fastq.gz")),
			here(paste0(outdir, "/", runtable$Run[i], "_2.fastq.gz"))
		), 
		stdout = TRUE, stderr = TRUE
	)

	if (length(minimap2) != 0) {
		lastmap <- minimap2[which.max(sapply(minimap2, nchar))]
		lastmap <- str_remove(lastmap, "\033.*")
		lastmap <- lastmap |> str_split_1("\\\r")
		lastmap	<- lastmap[length(lastmap)]
		runtable$floor_50000[i] <- lastmap |> readr::parse_number()
		lastmap <- str_remove(lastmap, "[\\d.]+")
		runtable$mapped_50000[i] <- readr::parse_number(lastmap)
		lastmap <- str_remove(lastmap, "[\\d.]+")
		runtable$mapped_perc[i] <- readr::parse_number(lastmap)
	}
	coverage_file <- here("data", "groutput", 
		paste0(runtable$Run[i], ".coverage.csv"))
	coverage <- read.csv(coverage_file)

	runtable$avg_depth[i] <- mean(coverage$coverage)

	loop_times[i] <- difftime(Sys.time(), t1, units = "mins")
	loop_times_mean <- mean(loop_times, na.rm = TRUE)
	loops_left <- nrow(runtable) - i
	loop_pred <- loops_left * loop_times_mean
	cat("Done in ", loop_times[i], "mins. ")
	cat(
		"Predicted to finish in",
		round(loop_pred - sum(loop_times), 2),
		"mins."
	)
	cat("\n")
}
head(runtable)

write.csv(runtable,
	here("data/saved_fastq", runfile_out),
	row.names = FALSE
)


