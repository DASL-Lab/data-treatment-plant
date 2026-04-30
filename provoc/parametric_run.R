library(here)
library(stringr)

force <- FALSE

all_processed <- list.files(
  here("data", "processed"),
  pattern = "\\.csv\\.gz$",
  full.names = TRUE
)
prjs <- str_extract(all_processed, "PRJNA\\d+") |> unique()
prjs <- prjs[!is.na(prjs)] |> sort()

for (prj in prjs) {
  outfile <- paste0(prj, ".pdf")
  outfile2 <- here("provoc", outfile)
  cat(paste("\nProcessing", prj, "\n"))

  if ((file.exists(outfile) || file.exists(outfile2)) && !force) {
    cat("File exists. Skipping.\n")
    next
  }
  
  tryCatch({
    quarto::quarto_render(
      input = "provoc/parametric_output.qmd",
      output_format = "pdf",
      output_file = outfile,
      execute_params = list(prj = prj)
    )
  }, error = function(e) {
    write(paste("\n\n\n\n\n\n\n\n\n\n\nError:", e), file = "provoc/paramtric_run_errors.log", append = TRUE)
    e
  })
}
