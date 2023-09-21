# Data Provenance

Swift2021 refers to Bioproject PRJNA745177.
The paper from this study focused on comparing mutations in the spike protein between waste water samples and GISAID samples, focusing on the spike protein.
The variants they used and their own analysis of GISAID data for these variants are shown in the paper, which is convenient for me.
After analysing them myself, I found that their data are conveniently available in the [Supplemental Data](https://data.mendeley.com/datasets/ng8kd9wszx/1), including frequencies of each mutation they found.
This study covers two WWTPs: Columbia, whose catchment covers the entirety of Columbia, South Carolina as well as much of Richland County, and the Rock Hill WWTP catchment area covers all of Rock Hill, South Carolina as well as much of York county (exact catchment areas are not publically available).
These two cities are approximately 110km (69mi) away from each other by road.
Rock Hill is approximately three quarters of the way from Columbia, South Carolina to Charlotte, North Carolina, and therefore there is likely significant travel between these two cities.
The study covered two separate sampling periods - July of 2020 and January of 2021.
July of 2020 had too few observations from the Rock Hill WWTP, but January had sufficient data from both WWTPs for analysis.
The sampling dates do not match up 1-1 for these two locations, so modifications to my proposed model will be necessary.

Lin2021 refers to Bioproject PRJNA731975.
In this paper, the authors' goal was to assess the different multiplex tiling PCR sequencing approaches, specifically comparing the Swift Bioscience amplicon scheme, the Artic protocol, and the Freed/midnight scheme (150, 400, and 1,200 base pair amplicons, respectively).
The authors conclude that the Artic protocol struck a balance between dropout due to degredation (and thus longer amplicons were unable to be read) and identification of SNPs (which needs many more reads to cover the full genome).
Based on this conclusion, I chose to use only the samples based on the amplicons from the Artic protocol.
As in their study, the results of my study are results about the method, not necessarily results about the study area.


The above SRA Run Info files were downloaded from NCBI SRA on August 16th, 2022, and these files are available in the data folder.
These files are all that is required to build the data base for analysis.

In addition, I have data for Rothman et al. (2021) and Jahn et al. (2021).
The data from Jahn et al. were originally collected by Karthykeyan et al. (2021) and have been used in several other publications (Jahn, Karthikeyan (2022), Rouchka, )

Run `download_and_process_*.sh` to download and process all of the fastq files for each author.
This will download about 74GB of data and will take several hours, depending on your internet connection and processing power.
It also runs `extract_metadata.R` to create `*_metadata.csv` files.
Processing is handled by `minimap2` and a custom python script written by Art Poon and his lab members as part of [GromStole](https://github.com/PoonLab/gromstole).
Processed files are dumped into the `groutput` folder, which may need to be created prior to running.


# Data Summary and Links

The bibliography for the following can be found in `open_data_sources.bib`.

- Baaijens et al. (2022): [PRJNA741211](https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA741211)
    - Used to estimate abundances with Freyja.
- Jahn et al. (2021): [PRJEB44932](https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJEB44932)
    - 1,823 SRA experiments
    - "We collected a total of 122 samples from three Swiss wastewater treatment plants (WWTPs) located in Zurich, Lausanne and an alpine ski resort between July 2020 and February 2021 (Supplementary Figure 1A). These samples include a close-meshed time-series for Zurich and Lausanne between December 2020 and mid-February 2021."
- Karthykeyan et al. (2022): [PRJNA819090](https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA819090)
    - 711 SRA experiments
    - "The sensitivity of detection of SARS-CoV-2 viral RNA in wastewater by the high-throughput pipeline (i.e., to determine whether individual buildings yield sufficient wastewater signal for high-resolution spatial studies) was established by routinely monitoring the SARS-CoV-2 signatures in the wastewater of a large San Diego hospital building housing active coronavirus disease 2019 (COVID-19) patients (7). This site was used as a positive control to test correlations with caseload on a daily basis. Sewage samples were collected daily for a period of 12 weeks during which time the hospital’s caseload (specific to COVID-19 patients) varied between 2 and 26. SARS-CoV-2 viral gene copies correlated with the daily hospital caseload (r = 0.75; see Fig. S1 in the supplemental material), suggesting that the wastewater data could at least be used to identify the peaks. SARS-CoV-2 viral RNA was detected in wastewater on all days sampled. Furthermore, the high-throughput protocol has been used as a part of an on-campus wastewater surveillance for the last few months where data from 70 autosamplers covering individual buildings are sampled and analyzed on a daily basis."
- Khan et al. (2023): [PRJNA772783](https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA772783)
- Lin et al. (2021): [PRJNA731975](https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA731975)
    - 106 SRA experiments
    - "We sequenced a total of 96 wastewater samples collected between 7 February and 18 April 2021 across five municipal WWTPs in Vancouver, Canada"
        - I reached out to the author and the five WWTPs must remain anonymous.
- Liu et al. (2023): [PRJNA764181](https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA764181)
- Ramuta et al. (2023): [PRJNA811594](https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA811594)
- Rasmussen et al. (2023): [PRJEB65603](https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJEB65603)
- Rios et al. (2021): [PRJNA750263](https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA750263)
    - 118 SRA experiments
    - "Fourteen sampling sites were equipped with automatic sampling devices (Sigma SD900, Hach Company, Loveland, Colorado). The instruments were calibrated to perform twelve samplings per hour for 24 hours."
    - Collected Oct 2020 to Mar 2021
- Rothman et al. (2021): [PRJNA729801](https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA729801)
    - 363 SRA experiments
    - "We collected 94 1-liter 24-h composite influent wastewater samples at seven WTPs across Southern California between August 2020 and January 2021"
- Rouchka et al. (2021): [PRJNA735936](https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA735936)
    - Five WWTPs in Louisville Ky, sampled for 28 weeks
- Smyth et al. (2021): [PRJNA715712](https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA715712)
    - 311 SRA experiments
    - "Wastewater was collected 160 from 14 NYC wastewater treatment plants...", appears to be 2 time points.
    - Focused exclusively on the receptor binding domain (spike protein).
- Swift et al. (2021): [PRJNA745177](https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA745177)
    - I suggest this for example data.
- Westcott et al. (2022): [PRJNA735936](https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA735936)
    - 30 SRA experiments
    - Columbia and Rock Hill, South Carolina, irregular sampling.

```r
smyth_variants <- list(
    "B.1.427" = c("aa:S:L452R"), 
    "B.1.429" = c("aa:S:L452R"), 
    "B.1.526" = c("aa:S:S477N"), 
    "B.1.1.7" = c("aa:S:E484K", "aa:S:S494P", "aa:S:N501Y"), 
    "P.1" = c("aa:S:E484K", "aa:S:N501Y"), 
    "P.2" = c("aa:S:E484K"), 
    "B.1.525" = c("aa:S:E484K"), 
    "B.1.526" = c("aa:S:E484K"), 
    "B.1.351" = c("aa:S:N501Y", "aa:S:E484K")
    )
```
