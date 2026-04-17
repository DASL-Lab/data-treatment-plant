runtables <- list.files("data/runtables") |>
    gsub(".*(PRJ\\w+\\d+).*", "\\1", x = _)
procs <- list.files("data/processed") |>
    gsub(".*(PRJ\\w+\\d+).*", "\\1", x = _)

setdiff(runtables, procs) |> sort()
