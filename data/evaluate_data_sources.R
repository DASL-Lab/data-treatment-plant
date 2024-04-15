library(dplyr)
library(here)
library(ggplot2)
theme_set(theme_bw())
library(lubridate)

load_prj <- function(prj) {
    read.csv(here("data", "runtables",
        paste0("SraRunTable_", prj, ".txt")))
}
rm_ones <- function(prj_df) {
    ones <- apply(prj_df, 2, function(x) length(unique(x))) == 1
    ones[names(prj_df) == "BioProject"] <- FALSE
    prj_df <- prj_df[!ones]
    prj_df
}

diff_dates <- function(df, col = "wwtp", plot = TRUE) {
    tmp <- bind_rows(lapply(unique(df[, col]), function(x) {
        n <- sum(df[, col] == x)
        thisdate <- ymd(df$Collection_Date[df[, col] == x])
        tmp <- data.frame(
            wwtp = x,
            diffs = as.numeric(diff(sort(ymd(thisdate)))),
            date_low = sort(thisdate)[1:(n - 1)],
            date_high = sort(thisdate)[2:n]
        )
        tmp$mean_date <- as.Date(
            as.numeric(as.Date(tmp$date_low)) / 2 +
                as.numeric(as.Date(tmp$date_high)) / 2,
            origin = "1970-01-01")
        tmp
    }))

    if (plot) {
        plot(x = as.Date(df$Collection_Date), 
            y = as.numeric(as.factor(df[, col])), pch = "|",
            ylab = col, xlab = "Collection_Date", yaxt = "n",
            cex = 2)
        yticks <- unique(as.numeric(as.factor(df[, col])))
        axis(2, at = yticks, labels = sort(levels(as.factor(df[, col]))))
        text(x = tmp[, "mean_date"],
            y = as.numeric(as.factor(tmp[, "wwtp"])),
            labels = tmp[, "diffs"])
        return(invisible())
    } else {
        return(tmp)
    }
}

table_regularity <- function(dates, wwtps, mindays = 1) {
    t1 <- table(wwtps, dates)
    t1 <- t1[, order(colnames(t1))]
    ismin <- apply(t1, 2, function(x) sum(x > 0) >= mindays)
    t1 <- t1[, ismin]
    colnames(t1) <- c(0, diff(as.numeric(ymd(colnames(t1)))))
    t1
}

baaijens <- load_prj("PRJNA741211")
names(baaijens)
baaijens <- rm_ones(baaijens)
names(baaijens)
head(baaijens[order(baaijens$Sample.Name), ])
# Using y=Bases is arbitrary, it just puts the points at different heights
    # Also tells me if there are differences in sampling.
ggplot(baaijens) +
    aes(x = ymd(Collection_Date), y = Bases,
        colour = substr(Sample.Name, 1, 2)) +
    geom_point() +
    geom_line()
# Conclusion: it's just one WWTP

jahn <- load_prj("PRJEB44932") |> rm_ones()
names(jahn)
head(jahn)
unique(jahn$geographic_location_.region_and_locality.)
range(jahn$Collection_Date)
diff_dates(jahn, "geographic_location_.region_and_locality.")
table_regularity(jahn$Collection_Date,
    jahn$geographic_location_.region_and_locality., 3)

karthykeyan <- load_prj("PRJNA819090") |> rm_ones()
head(karthykeyan)
unique(karthykeyan$geo_loc_name)
range(karthykeyan$Collection_Date)
ggplot(karthykeyan) +
    aes(x = ymd(Collection_Date), y = Bases, colour = geo_loc_name) +
    geom_point()
ggplot(karthykeyan) +
    aes(x = ymd(Collection_Date), fill = geo_loc_name) +
    geom_histogram(alpha = 0.5, position = "identity")
# Some overlap in March-Oct
with(karthykeyan,
    table(Collection_Date, gsub("USA: California\\\\, ", "", geo_loc_name)))
diff_dates(karthykeyan, "geo_loc_name")
table_regularity(karthykeyan$Collection_Date, 
    gsub("USA: California\\\\, ", "", karthykeyan$geo_loc_name), 2)

khan <- load_prj("PRJNA772783") |> rm_ones()
head(khan)
table(khan$geo_loc_name)
table(khan$ww_surv_target_1)
table(khan$geo_loc_name, khan$ww_surv_target_1) # CoV-2 in Reno only.
table(khan$ww_population)
sort(unique(khan$Sample.Name))
khan2 <- filter(khan, ww_surv_target_1 == "SARS-CoV-2")
table(substr(khan$Sample.Name, 0, 2))
khan$Sample.Name[startsWith(khan$Sample.Name, "ScWW")] %>%
    substr(0, 5) %>%
    table()

liu <- load_prj("PRJNA764181") |> rm_ones()
head(liu)
unique(liu$Assay.Type)

ramuta <- load_prj("PRJNA811594") |> rm_ones()
head(ramuta)
ramuta$Sample.Name

rasmussen <- load_prj("PRJEB65603") |> rm_ones()
head(rasmussen)
rasmussen$latlon <- paste(rasmussen$geographic_location_.latitude.,
    rasmussen$geographic_location_.longitude., sep = "_")
table(rasmussen$latlon)
length(unique(rasmussen$latlon))
rasmussen <- rasmussen %>%
    mutate(wwtp = paste(geographic_location_.latitude.,
            geographic_location_.longitude., sep = "_"))
diff_dates(rasmussen, "wwtp")
table_regularity(rasmussen$Collection_Date,
    rasmussen$wwtp)

rios <- load_prj("PRJNA750263") |> rm_ones()
head(rios)
rios <- rios %>%
    tidyr::separate(Sample.Name,
        into = c("location", "month", "letter", "PAE", "barcode"),
        sep = " / ")
length(unique(rios$location))
rios_loc_table <- table(rios$location)
keep <- names(rios_loc_table)[rios_loc_table > 2]
diff_dates(rios[rios$location %in% keep, ], "location")


rothman <- load_prj("PRJNA729801") |> rm_ones()
head(rothman)
rothman <- rothman %>%
    tidyr::separate(Sample.Name,
        into = c("WWTP", "month", "day", "year", "enriched", "other"),
        sep = "_")
table(rothman$WWTP)
ggplot(rothman[rothman$WWTP != "JW", ]) +
    aes(x = ymd(Collection_Date), fill = WWTP) +
    geom_density(alpha = 0.3)
diff_dates(rothman, "WWTP")
table_regularity(rothman$Collection_Date, rothman$WWTP, 2)

rouchka <- load_prj("PRJNA735936") |> rm_ones()
head(rouchka)
table(rouchka$ww_surv_target_1)
table(rouchka$purpose_of_ww_sequencing)
table(rouchka$ww_population)
table(rouchka$ww_sample_type)
diff_dates(rouchka, "ww_population")
table_regularity(rouchka$Collection_Date, rouchka$ww_population)

smyth <- load_prj("PRJNA715712") |> rm_ones()
head(smyth)
table(smyth$wwtp)
ggplot(smyth) +
    aes(x = ymd(Collection_Date), fill = wwtp) +
    geom_density()
table(smyth$geo_loc_name..run.)
table(smyth$geo_loc_name)
df1 <- smyth %>% filter(wwtp %in% c("BB", "CI", "OB", "OH", "TI", "WI"))
table(df1$wwtp)
diff_dates(df1)
datetable <- table(df1$wwtp, df1$Collection_Date)

dfdates <- apply(datetable, 2, function(x) any(x > 0))
ddt <- datetable[, dfdates]
ddt <- ddt[, order(colnames(ddt))]
colnames(ddt) <- c(0, diff(as.numeric(ymd(colnames(ddt)))))
ddt

swift <- load_prj("PRJNA745177") |> rm_ones()
head(swift)
diff_dates(swift, "ww_population")

layton <- load_prj("PRJNA720687") |> rm_ones()
head(layton)
# The next line is unreadable but works.
sapply(strsplit(layton$Sample.Name, "-"), `[`, 2) |> table()
# Unsure what Inf is.
# Are Bayfront and BayfronttPS the same location?
