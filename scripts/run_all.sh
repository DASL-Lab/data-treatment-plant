# No shebang - this is more like a lab notebook.

# Finished runs:
bash scripts/treatment.sh data/runtables/SraRunTable_PRJEB65603.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA715712.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA741211.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA745177.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA750263.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA819090.txt
# In progress (taking multiple days):
bash scripts/treatment.sh data/runtables/SraRunTable_PRJEB44932.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA720687.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA735936.txt

rm -r data/fastq/reads_fastq # Remove ENA folder (full of empty folders)

# Effluent (all with the same freqmin)
Rscript scripts/effluent.R --freqmin 0.05 data/runtables/SraRunTable_PRJEB65603.txt,data/runtables/SraRunTable_PRJNA715712.txt,data/runtables/SraRunTable_PRJNA741211.txt,data/runtables/SraRunTable_PRJNA745177.txt,data/runtables/SraRunTable_PRJNA750263.txt,data/runtables/SraRunTable_PRJNA819090.txt,data/runtables/SraRunTable_PRJNA720687.txt
