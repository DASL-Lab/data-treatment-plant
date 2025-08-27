library(dplyr)
library(stringr)
library(tidyr)

loc_zones <- data.frame(
    location = c(
        "Dproad, Botanical garden, Aundh, Pune", # Zone 1
        "Pune-Mumbai Highway Aundh-Sanghvi, Pune",
        "Baner-Balewadi, Pune",
        "Baner-Mahalunge, Pune",
        "Jai bhavani nagar, Pashan, Pune",
        "Someshwarwadi, Pune",
        "Dapodi-Old Sangvi Bridge, Pune", # Zone 2
        "Harris Bridge, Dapodi, Pune",
        "Phugewadi-Dapodi, Sai Service, Pune",
        "Vishrantwadi, Shantinagar, Pune",
        "Karveroad Kothrud, Pune", #Zone 3
        "Kothrud Bus depot, Pune",
        "Sanjeevan Hospital Kothrud, Pune",
        "Warje Mumbai-Banglore Highway, Pune",
        "Dattawadi, under Rajaram Bridge, Pune",
        "Vitthalwadi hingne, Sinhagad road, Pune",
        "Kalewadi Adarshnagar, Pune", # Zone 4
        "Kasarwadi pimple gurav road, Pune",
        "Pimple gurav, 60 ft ring road, Pune",
        "Rahatni, new DP road, Pune",
        "Shastrinagar, Pimpri, Pune",
        "Wolf Colony, Pimpri, Pune",
        "Chinchwad, Adityabirla Hospital, Pune",
        "RTO Office Yerwada, Pune", # Zone 5
        "Shivajinagar Chaturshrungi, Pune",
        "Shivajinagar Junabazaar, Pune",
        "Shivajinagar Vaidhawadi, Pune"
    ),
    zone = rep(1:5, times = c(5, 5, 6, 7, 4))
)

fix_location <- function(df, loc_column, pattern, replacement) {
    df |>
        mutate(location = str_replace_all(loc_column, pattern, replacement))
}
split_location <- function(df, loc_column, pattern, i) {
    df |>
        mutate(location = str_split_i(loc_column, pattern, i))
}

prj_transformations <- list(
    PRJNA745177 = function(df) {
        df |>
            filter(Replicate != 2 | is.na(Replicate)) |>
            split_location(geo_loc_name, ", ", 2) |>
            mutate(
                ww_population = as.numeric(gsub(",", "", ww_population))
            )
    },
    PRJNA819090 = function(df) {
        df |> split_location(geo_loc_name, ", ", 2)
    },
    PRJNA715712 = function(df) {
        df |>
            rename(location = wwtp) |>
            filter(!Run %in% c("SRR18583185", "SRR18583239"))
    },
    PRJEB65603 = function(df) {
        df |>
            split_location(Sample_Name, "_", 1) |>
            rename(
                lat = geographic_location_.latitude.,
                lon = geographic_location_.longitude.
            )
    },
    PRJNA735936 = function(df) {
        df |>
            mutate(location = as.numeric(factor(ww_population))) |>
            rename(sample_type = ww_sample_type)
    },
    PRJNA750263 = function(df) {
        df |>
            split_location(Sample.Name, " / ", 1) |>
            rename(lat_lon = Lat_Lon)
    },
    PRJNA741211 = function(df) df,
    PRJNA720687 = function(df) {
        df |> split_location(Sample.Name, "-", 2)
    },
    PRJEB44932 = function(df) {
        df |>
            rename(
                lat = geographic_location_.latitude.,
                lon = geographic_location_.longitude.,
                location = geographic_location_.region_and_locality.
            ) |>
            split_location(location, " - ", 2)
    },
    PRJNA796340 = function(df) rename(df, location = geo_loc_name),
    PRJEB48206 = function(df) {
        rename(df, location = geographic_location_.region_and_locality.)
    },
    PRJNA788395 = function(df) {
        df |>
            filter(ww_sample_type == "composite") |>
            fix_location(geo_loc_name, "Canada:Quebec\\\\,", "")
    },
    PRJEB55313 = function(df) {
        df |>
            tidyr::separate_wider_regex(
                lat_lon,
                patterns = c(
                    lat = "[\\d\\.+]+", " ",
                    lat_N = "\\w", " ",
                    lon = "[\\d\\.+]+", " ",
                    lon_E = "\\w"
                ),
                cols_remove = FALSE
            ) |>
            mutate(
                lat = as.numeric(lat) * ifelse(lat_N == "N", 1, -1),
                lon = as.numeric(lon) * ifelse(lon_E == "E", 1, -1)
            )
    },
    PRJNA1042787 = function(df) df,
    PRJNA1027858 = function(df) rename(df, wwtp = isolation_source),
    PRJNA759260 = function(df) rename(df, location = geo_loc_name),
    PRJEB48985 = function(df) {
        rename(df,
            ww_population = population_size_of_the_catchment_area,
            location = name_of_the_sampling_site,
            lat = geographic_location_.latitude.,
            lon = geographic_location_.longitude.
        )
    },
    PRJNA811594 = function(df) {
        df |>
            fix_location(Isolate, "ENV/USA/", "") |>
            split_location(location, "-", 1)
    },
    PRJNA731975 = function(df) rename(df, location = "wwtp"),
    PRJNA772783 = function(df) {
        df |>
            split_location(Sample.Name, "\\d", 1) |>
            split_location(location, "-", 1)
    },
    PRJNA1110039 = function(df) {
        aux_info <- read.csv("data/PRJNA1110039_supp.csv") |>
            rename(
                location = SampleID, lat = Latitude, lon = Longitude,
                city = CitiesSurveyed, zone = Zone
            )
        df |>
            split_location(Library.Name, "\\d", 1) |>
            left_join(aux_info, by = "location")
    },
    PRJNA1088471 = function(df) {
        ash <- c("AshbridgeBay", "Ashbridges", "AshbridgesBay")
        high <- c("Highland", "HighlandCR", "HighlandCreek")
        df |>
            fix_location(Sample.Name, "(-|\\d{2,})", "") |>
            mutate(location = ifelse(location %in% ash, "AshbridgesBay",
                    ifelse(location %in% high, "HighlandCreek", location))) |>
            mutate(zone = case_when(
                location %in% c(
                    "Humber", "AshbridgesBay", "HighlandCreek", "NorthToronto"
                ) ~ "Toronto",
                location %in% c("As", "At") ~ "Pooled Aircraft Sewage",
                location %in% c("A1", "A3") ~ "Airport Terminal 1 and 3",
                location %in% c("P1", "P2") ~ "Peel",
                location %in% c("Y1", "Y5", "Y6") ~ "York",
                TRUE ~ "Devan Missed One"
            ))
    },
    PRJNA856091 = function(df) fix_location(df, Sample.Name, "_.*", ""),
    PRJNA992940 = function(df) rename(df, location = isolation_source),
    PRJNA1067101 = function(df) {
        df |>
            fix_location(geo_loc_name, "(India: |\\, Maharashtra|\\\\)", "") |>
            left_join(loc_zones, by = "location")
    },
    PRJEB61810 = function(df) {
        rename(df,
            location = name_of_the_sampling_site,
            lat = geographic_location_.latitude.,
            lon = geographic_location_.longitude.,
            ww_population = population_size_of_the_catchment_area
        )
    },
    PRJNA946141 = function(df) {
        df |>
            rename(zone = ww_sample_site, sample_type = ww_sample_type) |>
            split_location(Sample.Name, "-|(50)", 1) |>
            filter(!str_detect(Sample.Name, "rep"),
                str_detect(BioSampleModel, "wastewater"))
    },
    PRJEB76651 = function(df) {
        df |>
            rename(Sample_Name = Sample.Name) |>
            split_location(sample_name, "_", 2) |>
            rename(Collection_Date = collection_date, Sample.Name = sample_name)
    },
    PRJNA1238906 = function(df) {
        mutate(df, location = str_sub(Sample.Name, 1, 2))
    },
    PRJNA1212683 = function(df) {
        fix_location(df, geo_loc_name, "Luxembourg: ", "")
    },
    PRJNA1141947 = function(df) {
        fix_location(df, geo_loc_name, "United Kingdom: ", "")
    },
    PRJDB19812 = function(df) {
        fix_location(df, geo_loc_name, "(^.*, )|( city)", "")
    },
    PRJNA1027333 = function(df) fix_location(df, geo_loc_name, "USA: ", ""),
    PRJNA865728 = function(df) fix_location(df, geo_loc_name, "USA: ", ""),
    PRJNA896334 = function(df) fix_location(df, geo_loc_name, "Pune", ""),
    PRJNA847239 = function(df) fix_location(df, geo_loc_name, "USA: ", ""),
    PRJNA748354 = function(df) split_location(df, Library.Name, "_", 3),
    PRJEB67638 = function(df) {
        rename(df,
            location = name_of_the_sampling_site,
            lat = geographic_location_.latitude.,
            lon = geographic_location_.longitude.
        )
    },
    PRJNA765031 = function(df) rename(df, location = geo_loc_name),
    PRJNA941107 = function(df) rename(df, location = geo_loc_name)
)

# Main function
get_runtable <- function(prj, runtable) {
    if (!prj %in% names(prj_transformations)) {
        stop("I don't know how to deal with this BioProject yet.")
    }

    runtable <- prj_transformations[[prj]](runtable)

    # Common post-processing
    runtable <- rename(runtable,
        sra = Run,
        date = Collection_Date,
        sample_name = Sample.Name,
        avg_spot_len = AvgSpotLen,
        bases = Bases,
        bioproject = BioProject
    )

    runtable <- select(runtable,
        sra, date, sample_name, avg_spot_len, bases, bioproject,
        any_of(c("location", "lat", "lon", "lat_lon", "city",
                "ww_population", "organism", "sample_type", "zone"))
    )

    runtable
}
