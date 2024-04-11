# No shebang - this is more like a lab notebook.
# Running from start to finish would take about two weeks.


# Finished runs:
bash scripts/treatment.sh data/runtables/SraRunTable_PRJEB65603.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA715712.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA741211.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA745177.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA750263.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA819090.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA720687.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJEB44932.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA735936.txt
# Running
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA788395.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA796340.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA759260.txt
#bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA661613.txt # minimap2.py failed.
bash scripts/treatment.sh data/runtables/SraRunTable_PRJEB48206.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJEB55313.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJEB48985.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA1042787.txt

rm -r data/fastq/reads_fastq # Remove ENA folder (full of empty folders)

# Effluent (all with the same freqmin)
Rscript scripts/effluent.R --freqmin 0.05 data/runtables/SraRunTable_PRJEB65603.txt,data/runtables/SraRunTable_PRJNA715712.txt,data/runtables/SraRunTable_PRJNA741211.txt,data/runtables/SraRunTable_PRJNA745177.txt,data/runtables/SraRunTable_PRJNA750263.txt,data/runtables/SraRunTable_PRJNA819090.txt,data/runtables/SraRunTable_PRJNA720687.txt,data/runtables/SraRunTable_PRJNA720687.txt,data/runtables/SraRunTable_PRJEB44932.txt,data/runtables/SraRunTable_PRJNA735936.txt,data/runtables/SraRunTable_PRJNA796340.txt,data/runtables/SraRunTable_PRJEB48206.txt,data/runtables/SraRunTable_PRJNA788395.txt
