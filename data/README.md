# Data Provenance

The bibliography for the following sources can be found in `open_data_sources.bib`. Bold names indicate the existense of a completed reanalysis using `provoc`, whereas strikethrough means I cannot complete the reanalysis (see notes).


| Source            | PRJ               | WWTPs / Runs   |  Notes | ProVoC/Temp/Spat Usefulness |
|-------------------| ------------------| ---------------|--------|----------------------|
| [**Honda**](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0317076) | DB19812   | 2 / 21  | | 4/4/1 |
| Jahn              | EB44932           | 6 / 1,823      |  Exact latlon, many obs., spatio-temporal | |
| **Izquierdo-Lara**| EB48206           | 10? / 698      | ST | 10/3/6 |
| **Gurol**         | EB61810           | 10 / 217       | Lat/lon, approx 20 times each | 4/5/7 |
| **Rasmussen**     | EB65603           | 48 / 116       | Spatial, 4 time points | 6/2/10 |
| **Garcia**        | EB76651           | 4 / 214        | Many T, few S | 1/2/2 |
| **Smyth**         | NA715712          | 5-8 / 311      | Extra WWTPS with poor sampling | 5/7/3 |
| **Layton**        | NA719837          | 5 / 116        | 5 WWTPs must remain anon. | 7/8/1 (one good location) |
| Unknown           | NA720687          | ???            | ??? |  |
| **Lin**           | NA731975          | 5 / 106        | Evaluating primer sets. | 6/6/2 |
| **Rouchka**       | NA735936          | 17? / 1,040    | Mutliple purposes, composite and grab samples | 7/8/2 (unknown locations, but many) |
| [**Baaijens**](https://doi.org/10.1186/s13059-022-02805-9)                             | NA741211, NA759260| 1 / 59         | Generally poor results - possible data treatment errors? | 2/2/0 |
| **Swift**         | NA745177          | 2 / 30         | Great for examples | 2/2/0 (possible date parsing issue?) |
| [Gregory](https://doi.org/10.1371/journal.ppat.1010636)                                | NA748354 | | | |
| **Rios**          | NA750263          | 31? / 118      | Few time points, many WWTP | 5/4/7 (sparse time, good space) |
| [Baaijens](https://doi.org/10.1186/s13059-022-02805-9)                                 | NA759260          | ???            | Second part of Baaijens study | |
| **Khan**          | NA772783          | ? / 161        | Some SARS-CoV-0,1,3, uncertain WWTPs | 5/3/3 (inconsistent sampling) |
| **N'Guessan**     | NA788395          | 584(3) / 936   | Many WWTPs with sparse sampling, 3 zones | 3/2/2 |
| **Sapoval**       | NA796340          | 23 / 256       | Spatial? | 8/2/6 |
| **Ramuta**        | NA811594          | ? / 25         | Uncertain WWTPs | 5/6/1 (sparse time, but means quick computation) |
| **Karthykeyan**   | NA819090          | 2 / 711        | Locs have different dates | 7/9/2 (esp. one location) |
| [Fontenele](https://www.sciencedirect.com/science/article/pii/S004896972301478X)       | NA847239 | | | |
| **Agrawal**       | NA856091          | 15 / 118       | Study combines WWTPs to see temporal trend | 10/2/2 |
| [**Tryndyak**](https://www.nature.com/articles/s41597-025-05100-x)                     | NA865728  | 5 / 270 | Long time scale | 7/6/6 |
| [**Pramanik**](https://pubs.acs.org/doi/full/10.1021/envhealth.5c00048)                | NA896334  | 1 / 191 | Temporal | 7/8/0 |
| **Tierney**       | NA946141          | 36 / 688       | Mostly Spatial, paper has detailed lineage info | 7/7/7 (uncertain locations) |
| **Merrett**       | NA992940          | ? / 412        | Many WWTPs, not much T. | 4/5/5 |
| [**Conway**](https://www.nature.com/articles/s41598-025-03771-5)                       | NA1027333 | 1+ / 17 | Some one-off WWTPs, one main one | 2/4/0 |
| Ellman            | NA1027858         | 58? / 869      | Used for NMF paper, no T. | |
| [Moon](https://www.medrxiv.org/content/10.1101/2024.02.15.24302811v1)                  | NA1031245          | ??? / ???      | Meant to test lineage callers, **no T** | |
| **Liponnen**      | NA1042787         | 1 / 15         | | 8/6/0 (one loc, sparse-ish sampling) |
| **Overton**       | NA1088471         | 13 / 1373      | Lots of S and T | 6/8/8 |
| **Matra**         | NA1110039         | 23 / ~700      | Lots of S and T | 7/8/8 |
| **Kellingray**    | NA1141947         | 1 / ???        | ??? | 4/7/0 |
| **Afonso**        | NA1212683         | 3 / ???        | ??? | 9/8/3 |
| **Opeyemi**       | NA1238906         | 2 / ???        | Comparison of Auto and passive samplers (overton) | 6/8/0 |
| ~~Brunner~~       | ~~EB55313~~       | 460 / 23,536   | `effluent.R` fails (memory issue) | |
| ~~Crits-Christoph~~ | ~~NA661613~~    | 1 / 18         | `minimiap2.py` fails | |
| ~~Rothman~~       | ~~NA729801~~      | 8-9 / 363      | `minimap2.py` fails. | |
| ~~Liu~~           | ~~NA764181~~      | ? / 10,147     | Clinical rather than ww | |

TODO: 

- [PRJEB44141](https://www.nature.com/articles/s41598-022-06625-6)
    - Only looks at Alpha and Beta; but 9000 samples??
- [PRJNA662596](https://www.sciencedirect.com/science/article/pii/S0043135421009040)
    - Many lineages, looks like one or two samples from each state
- [ ] [PRJNA912560,PRJNA736964,PRJNA789814](https://academic.oup.com/gigascience/article/doi/10.1093/gigascience/giae051/7730001)
    - One of the bioprojects is synthetic, two are real data
    - **Explicitly about how choosing the lineage definition matrix affects the results**
    - Will likely do later
- [PRJNA922726](https://www.nature.com/articles/s41598-023-44500-0)
    - Good exploration of lineages, proportions plotted over time; poor metadata but manageable if I use ww population.
- [PRJNA931732](https://link.springer.com/article/10.1007/s11356-023-30709-z)
    - Many locations in India, lots of plots over time

- [x] [PRJEB67638](https://pmc.ncbi.nlm.nih.gov/articles/PMC10655203/)
- [x] [PRJNA765031](https://www.mdpi.com/2073-4441/13/21/3018)
    - Various lineages, plotted over time in the paper
- [x] [PRJNA941107](https://www.nature.com/articles/s41467-023-41369-5)
    - Lots of locations, but aggregated for a plot over time.
- [ ] [PRJNA827160](https://www.sciencedirect.com/science/article/pii/S0048969722060302?casa_token=kg42tqD8nx8AAAAA:DUiC4wirP_8dnvXnmdEj7fQBDMoxXr4KlLYA0inAjeCx0ZqviNDwGw5ah_t93H2MHmS6qKWGJNo)
    - Comparison of COJAC and Freyja
- [ ] [PRJNA931732](https://www.sciencedirect.com/science/article/pii/S0048969724069900?casa_token=0fuv0LpR24UAAAAA:FNdc1ujuObohfmXYtCIQk3BH-YgkCI23gJHk4WbHpAAwpRveHI0TcAiQc0q6NAIuQ-9sa6sMoVA)
    - Long time scale
- [ ] [ PRJNA887942](https://www.nature.com/articles/s41467-023-43047-y)
    - Focused on delta, looks at individual mutations
- [ ] [No PRJ](https://www.cell.com/heliyon/fulltext/S2405-8440(24)03483-2)
    - Genetic diversity
- https://www.nature.com/articles/s41467-024-48334-w
- https://journals.plos.org/plospathogens/article?id=10.1371/journal.ppat.1012850



Brief lit review:

- Baaijens et al. (2022): [PRJNA741211](https://www.ncbi.nlm.nih.gov/Traces/study/?acc=SRP332940&o=acc_s%3Aa)
    - 59 runs, one WWTP with regular sampling.
    - Used to estimate abundances with Freyja.
- Jahn et al. (2021): [PRJEB44932](https://www.ncbi.nlm.nih.gov/Traces/study/?query_key=12&WebEnv=MCID_650c44d372c3f35ccb6b4374&o=acc_s%3Aa)
    - 1,823 runs
    - 6 unique WWTPs sampled from 2020-07-09 to 2021-11-30 (irregularly, and on different dates for different WWTPs)
    - "We collected a total of 122 samples from three Swiss wastewater treatment plants (WWTPs) located in Zurich, Lausanne and an alpine ski resort between July 2020 and February 2021 (Supplementary Figure 1A). These samples include a close-meshed time-series for Zurich and Lausanne between December 2020 and mid-February 2021."
- Karthykeyan et al. (2022): [PRJNA819090](https://www.ncbi.nlm.nih.gov/Traces/study/?WebEnv=MCID_650c44d372c3f35ccb6b4374&query_key=15&GALAXY_URL=https%3A%2F%2Fusegalaxy.org%2Ftool_runner%3Ftool_id%3Dsra_source)
    - 711 SRA experiments
    - 2 sampling locations (UCSD Campus and San Diego (Point Loma)) collected from 2020-11-24 to 2022-02-07, but the sampling dates for the two locations don't overlap much (some overlap in March-Oct).
    - "The sensitivity of detection of SARS-CoV-2 viral RNA in wastewater by the high-throughput pipeline (i.e., to determine whether individual buildings yield sufficient wastewater signal for high-resolution spatial studies) was established by routinely monitoring the SARS-CoV-2 signatures in the wastewater of a large San Diego hospital building housing active coronavirus disease 2019 (COVID-19) patients (7). This site was used as a positive control to test correlations with caseload on a daily basis. Sewage samples were collected daily for a period of 12 weeks during which time the hospital’s caseload (specific to COVID-19 patients) varied between 2 and 26. SARS-CoV-2 viral gene copies correlated with the daily hospital caseload (r = 0.75; see Fig. S1 in the supplemental material), suggesting that the wastewater data could at least be used to identify the peaks. SARS-CoV-2 viral RNA was detected in wastewater on all days sampled. Furthermore, the high-throughput protocol has been used as a part of an on-campus wastewater surveillance for the last few months where data from 70 autosamplers covering individual buildings are sampled and analyzed on a daily basis."
- Khan et al. (2023): [PRJNA772783](https://www.ncbi.nlm.nih.gov/Traces/study/?query_key=17&WebEnv=MCID_650c44d372c3f35ccb6b4374&o=acc_s%3Aa)
    - 161 runs, but some were for SARS-CoV-0, 1, and 3.
    - Multiple WWTPs, but the data make it difficult to decipher which is which.
        - I have determined that "ScWW34May" is an observation from WW3 on May 4th. ScWW1-5 have 10 or 11 observations each. There are 7 other names that are not ScWW, and I can't tell what they correspond to in the paper.
- Layton et al. (202*): [PRJNA719837](https://www.ncbi.nlm.nih.gov/Traces/study/?WebEnv=MCID_65145c8f166d7028a84f6ecb&query_key=8&GALAXY_URL=https%3A%2F%2Fusegalaxy.org%2Ftool_runner%3Ftool_id)
    - 116 Runs
- Lin et al. (2021): [PRJNA731975](https://www.ncbi.nlm.nih.gov/Traces/study/?query_key=19&WebEnv=MCID_650c44d372c3f35ccb6b4374&o=acc_s%3Aa)
    - 106 runs
    - "We sequenced a total of 96 wastewater samples collected between 7 February and 18 April 2021 across five municipal WWTPs in Vancouver, Canada"
        - I reached out to the author and the five WWTPs must remain anonymous.
    - In this paper, the authors' goal was to assess the different multiplex tiling PCR sequencing approaches, specifically comparing the Swift Bioscience amplicon scheme, the Artic protocol, and the Freed/midnight scheme (150, 400, and 1,200 base pair amplicons, respectively). The authors conclude that the Artic protocol struck a balance between dropout due to degredation (and thus longer amplicons were unable to be read) and identification of SNPs (which needs many more reads to cover the full genome). Based on this conclusion, I chose to use only the samples based on the amplicons from the Artic protocol. As in their study, the results of my study are results about the method, not necessarily results about the study area.
- Liu et al. (2023): [PRJNA764181](https://www.ncbi.nlm.nih.gov/Traces/study/?query_key=21&WebEnv=MCID_650c44d372c3f35ccb6b4374&o=acc_s%3Aa)
    - 10,147 runs!
    - I believe these are clinical samples - most sequences inclde the host gender and age; none appear to be from WWTPs.
- Ramuta et al. (2023): [PRJNA811594](https://www.ncbi.nlm.nih.gov/Traces/study/?query_key=23&WebEnv=MCID_650c44d372c3f35ccb6b4374&o=acc_s%3Aa)
    - 25 runs
    - WWTP names are difficult to decipher
- Rasmussen et al. (2023): [PRJEB65603](https://www.ncbi.nlm.nih.gov/Traces/study/?query_key=25&WebEnv=MCID_650c44d372c3f35ccb6b4374&o=acc_s%3Aa)
    - 116 runs
        - Accessions found in ENA. Minimap2 is only mapping ~20% of the reads (unsure why).
    - 28 different WWTPs, but only 4 observations from each
        - Exact coordinates of WWTPs
- Rios et al. (2021): [PRJNA750263](https://www.ncbi.nlm.nih.gov/Traces/study/?query_key=27&WebEnv=MCID_650c44d372c3f35ccb6b4374&o=acc_s%3Aa)
    - 118 runs
    - 31 different WWTPs, 1-6 observations at each
    - "Fourteen sampling sites were equipped with automatic sampling devices (Sigma SD900, Hach Company, Loveland, Colorado). The instruments were calibrated to perform twelve samplings per hour for 24 hours."
    - Collected Oct 2020 to Mar 2021
- Rothman et al. (2021): [PRJNA729801](https://www.ncbi.nlm.nih.gov/Traces/study/?query_key=29&WebEnv=MCID_650c44d372c3f35ccb6b4374&o=acc_s%3Aa)
    - 363 SRA experiments
        - minimap2 failed for most runs - unsure why
    - 8 or 9 WWTPs, between 4 and 110 samples each, collected mpstly between Aug 2020 to Jan 2021, with some WWTPs sampled until Aug 2021
    - "We collected 94 1-liter 24-h composite influent wastewater samples at seven WTPs across Southern California between August 2020 and January 2021"
- Rouchka et al. (2021) and Westcott et al. (2022): [PRJNA735936](https://www.ncbi.nlm.nih.gov/Traces/study/?query_key=31&WebEnv=MCID_650c44d372c3f35ccb6b4374&o=acc_s%3Aa)
    - 1,040 runs
    - Some runs dedicated to searching for diversity of mutations across entire genome, others dedicated to variant detection
    - Potentially 17 WWTPs (based on unique values of `ww_population`), but not clearly labelled. Either 41 or 57 observations for each WWTP, which probably means regular sampling.
    - Some composite, some grab samples
    - Paper claims five WWTPs in Louisville Ky, sampled for 28 weeks
- Smyth et al. (2021): [PRJNA715712](https://www.ncbi.nlm.nih.gov/Traces/study/?query_key=33&WebEnv=MCID_650c44d372c3f35ccb6b4374&o=acc_s%3Aa)
    - 311 runs
    - 8 WWTPs, one of which is blank and sampled at different times, one is labelled NY* with 5 observations, the rest looking good with 33-37 observations each, all sampled at approximately the same times.
        - If only BB, OB, OH, TI, and WI are used, there will probably be some good nuggets to extract.
    - Some fun typos in "geo_loc_name..run."
    - Focused exclusively on the receptor binding domain (spike protein), so mutations won't be generally applicable.
- Swift et al. (2021): [PRJNA745177](https://www.ncbi.nlm.nih.gov/Traces/study/?query_key=35&WebEnv=MCID_650c44d372c3f35ccb6b4374&o=acc_s%3Aa)
    - 30 runs
    - Two sampling locations, sampled irregularly from Jun 2020 to Jan 2021.
    - I suggest this as example data to ensure you can run this on your computer.
    - The paper from this study focused on comparing mutations in the spike protein between waste water samples and GISAID samples, focusing on the spike protein. The variants they used and their own analysis of GISAID data for these variants are shown in the paper, which is convenient for me. After analysing them myself, I found that their data are conveniently available in the [Supplemental Data](https://data.mendeley.com/datasets/ng8kd9wszx/1), including frequencies of each mutation they found. This study covers two WWTPs: Columbia, whose catchment covers the entirety of Columbia, South Carolina as well as much of Richland County, and the Rock Hill WWTP catchment area covers all of Rock Hill, South Carolina as well as much of York county (exact catchment areas are not publically available). These two cities are approximately 110km (69mi) away from each other by road. Rock Hill is approximately three quarters of the way from Columbia, South Carolina to Charlotte, North Carolina, and therefore there is likely significant travel between these two cities. The study covered two separate sampling periods - July of 2020 and January of 2021. July of 2020 had too few observations from the Rock Hill WWTP, but January had sufficient data from both WWTPs for analysis. The sampling dates do not match up 1-1 for these two locations, so modifications to my proposed model will be necessary.

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
