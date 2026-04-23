runtables <- list.files("data/runtables") |>
    gsub(".*(PRJ\\w+\\d+).*", "\\1", x = _)
procs <- list.files("data/processed") |>
    gsub(".*(PRJ\\w+\\d+).*", "\\1", x = _)
too_big <- c("PRJEB48985", "PRJEB55313", "PRJNA729801", "PRJNA748354", "PRJNA764181", "PRJNA946141", "PRJNA957477", "PRJNA850375")

setdiff(runtables, procs) |> setdiff(too_big) |> sort()
