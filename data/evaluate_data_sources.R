library(dplyr)
library(here)
library(ggplot2)
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

baaijens <- load_prj("PRJNA741211")
names(baaijens)
baaijens <- rm_ones(baaijens)
names(baaijens)
head(baaijens[order(baaijens$Sample.Name), ])
# No idea which samples correspond to different WWTPs

jahn <- load_prj("PRJEB44932") |> rm_ones()
names(jahn)
head(jahn)
unique(jahn$geographic_location_.region_and_locality.)
range(jahn$Collection_Date)

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

khan <- load_prj("PRJNA772783") |> rm_ones()
head(khan)
unique(khan$geo_loc_name)
unique(khan$ww_surv_target_1)
unique(khan$ww_population)
sort(unique(khan$Sample.Name))

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

rios <- load_prj("PRJNA750263") |> rm_ones()
head(rios)
rios %>%
    tidyr::separate(Sample.Name,
        into = c("location", "month", "letter", "PAE", "barcode"),
        sep = " / ") %>%
    pull(location) %>%
    unique() %>%
    length()

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

rouchka <- load_prj("PRJNA735936") |> rm_ones()
head(rouchka)
table(rouchka$ww_surv_target_1)
table(rouchka$purpose_of_ww_sequencing)
table(rouchka$ww_population)
table(rouchka$ww_sample_type)

smyth <- load_prj("PRJNA715712") |> rm_ones()
head(smyth)
table(smyth$wwtp)
ggplot(smyth) +
    aes(x = ymd(Collection_Date), fill = wwtp) +
    geom_density()
table(smyth$geo_loc_name..run.)
table(smyth$geo_loc_name)

swift <- load_prj("PRJNA745177") |> rm_ones()
head(swift)
