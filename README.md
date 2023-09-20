# Data Treatment Plant

This repository contains my data processing pipeline for wastewater sequences, specifically for sequences deposited in the NCBI SRA. *Please feel free to help me streamline this process.*

**Dependencies**:

- [cutadapt](https://cutadapt.readthedocs.io/en/stable/)
- [minimap2](https://github.com/lh3/minimap2) (available through `apt` and `brew`, among other)
- Python
- R
- sratools

The `SraRunTable`s can be acquired from NCBI's Run Selector. 

## Stage 1: Sequence Processing

The `treatment.sh` bash script takes the location of the SRA runtable file as the first argument.

- Search through all SRA runtables for accession numbers.
- Use `fasterq-dump` (from `sratools`) to download the file associated with an accession number.
    - Files can be up to 10GB in size, so this is necessarily slow.
    - ~~Files are immediately `gzip`'d.~~
- Use the `minimap2.py` script from `GromStole` (depends on `minimap2`)
    - Has hard coded defaults that may not be appropriate to your study. The output below demonstrates the exact arguments.
    - Data are processed into two files:
        - `[SRA].mapped.csv` includes every mutation along with the number of reads containing that mutation and the number of times any read contained that position on the genome.
        - `[SRA].coverage.csv` is the coverage map for the whole genome.
- If `minimap2.py` is successful, the fastq files are deleted to save disk space.
    - If not, the fastq file is retained (I suggest manually `gzip`ing). Re-running the script will check for pre-existing results and pre-existing fastq files and skip downloading so you can try again. 
        - However, most errors are due to problems with the download, so removing the fastq might solve the problem.
- The output will be placed in the "groutput" folder. 

After processing, I usually `gzip` all the files in the groutput folder. R and Python will both load gzipped files just fine and it saves a lot of disk space.

## Stage 2: Output

The `effluent.R` script processes the data according to my particular needs:

- Gather all relevant output files (the treatment step dumps everything into the same folder).
    - Include relevant information, such as the location and date of each sample.
- Find all mutations that had *both* a frequency higher than 10% and a coverage higher than 30 *in at least one sample*.
    - I want to keep the count and coverage of, say, a mutation that had 1 observation in 2 reads if that mutations had 400 observations in 500 reads in another sample. 
- Output all mutations into a single (`gzip`'d) csv file.

# Example Run

I have chosen bioproject PRJNA745177 as an example since the files are relatively small. These data were analysed in [Swift CL, Isanovic M, Correa Velez KE, Norman RS. Community-level SARS-CoV-2 sequence diversity revealed by wastewater sampling. *Sci Total Environ.* 2021 Dec 20;801:149691. doi: 10.1016/j.scitotenv.2021.149691](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8372435/).

Navigate to [https://www.ncbi.nlm.nih.gov/Traces/study/?acc=SRP327683&o=acc_s%3Aa](https://www.ncbi.nlm.nih.gov/Traces/study/?acc=SRP327683&o=acc_s%3Aa) and select "Metadata" under Download. Move the file into an appropriate location. 

```sh
bash scripts/treatment.sh exampledata/SraRunTablePRJNA745177.txt
gzip groutput/*
```

```
exampledata/SraRunTablePRJNA745177.txt

exampledata/SraRunTablePRJNA745177.txt
SRR15090099
lookup :|-------------------------------------------------- 100%   
merge  : 
join   :|-------------------------------------------------- 100%   
concat :|-------------------------------------------------- 100%   
spots read      : 30,593
reads read      : 30,593
reads written   : 30,593
data/fastq/SRR15090099.fastq:      61.3% -- replaced with data/fastq/SRR15090099.fastq.gz
Running Minimap2
SRR15090099
python gromstolen/minimap2.py -t 2 -p SRR15090099 -o groutput --nocut --replace data/fastq/SRR15090099.fastq.gz
Done
GromStole Successful, removing fastq

exampledata/SraRunTablePRJNA745177.txt
SRR15090100
lookup :|-------------------------------------------------- 100%   
merge  : 
join   :|-------------------------------------------------- 100%   
concat :|-------------------------------------------------- 100%   
spots read      : 5,829
...

--- Output manually trunctated; takes about 5-10 minutes for this small example ---
```

In the output above, we see that `minimap2.py` is being run on two threads without using `cutadapt`, and the output is put in the `groutput` folder (replacing existing files if the filename already exists). 
