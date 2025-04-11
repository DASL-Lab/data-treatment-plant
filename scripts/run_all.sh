# No shebang - this is more like a lab notebook.
# Running from start to finish would take about two-three weeks.

# Finished runs sorted by PRJ
bash scripts/treatment.sh data/runtables/SraRunTable_PRJEB44932.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJEB48206.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJEB61810.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJEB65603.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJEB76651.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA715712.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA720687.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA731975.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA735936.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA741211.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA745177.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA750263.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA759260.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA772783.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA788395.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA796340.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA811594.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA819090.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA856091.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA946141.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA992940.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA1027858.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA1042787.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA1067101.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA1088471.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA1110039.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA1141947.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA1212683.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA1238906.txt


# Unknown runtimes (Long or not yet processed)
#bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA661613.txt # minimap2.py failed.
bash scripts/treatment.sh data/runtables/SraRunTable_PRJEB55313.txt # Downloaded, not processed (memory issues).
bash scripts/treatment.sh data/runtables/SraRunTable_PRJEB48985.txt
bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA719837.txt

rm -r data/fastq/reads_fastq # Remove ENA folder (full of empty folders)




# Effluent (all with the same freqmin)
# Ordered approximately by runtime (low to high)
Rscript scripts/effluent.R --freqmin 0.1 --min_coverage 40 --beep data/runtables/SraRunTable_PRJNA1042787.txt,data/runtables/SraRunTable_PRJNA811594.txt,data/runtables/SraRunTable_PRJNA719837.txt,data/runtables/SraRunTable_PRJNA759260.txt,data/runtables/SraRunTable_PRJNA992940.txt,txt,data/runtables/SraRunTable_PRJNA741211.txt,data/runtables/SraRunTable_PRJNA745177.txt,data/runtables/SraRunTable_PRJNA715712.txt,data/runtables/SraRunTable_PRJEB65603.txt,data/runtables/SraRunTable_PRJNA720687.txt,data/runtables/SraRunTable_PRJNA1067101.txt,data/runtables/SraRunTable_PRJNA796340.txt,data/runtables/SraRunTable_PRJNA750263.txt,data/runtables/SraRunTable_PRJEB61810.txt,data/runtables/SraRunTable_PRJNA788395.txt,data/runtables/SraRunTable_PRJNA1110039.txt,data/runtables/SraRunTable_PRJNA819090.txt,data/runtables/SraRunTable_PRJEB48206.txt,data/runtables/SraRunTable_PRJNA1088471.txt,data/runtables/SraRunTable_PRJNA735936.txt,data/runtables/SraRunTable_PRJEB76651.txt
# These ones take longer (or were added later)
Rscript scripts/effluent.R --freqmin 0.1 --min_coverage 40 --beep data/runtables/SraRunTable_PRJNA731975.txt
Rscript scripts/effluent.R --freqmin 0.1 --min_coverage 40 --beep data/runtables/SraRunTable_PRJNA856091.txt
Rscript scripts/effluent.R --freqmin 0.1 --min_coverage 40 --beep data/runtables/SraRunTable_PRJNA772783.txt
Rscript scripts/effluent.R --freqmin 0.1 --min_coverage 40 --beep data/runtables/SraRunTable_PRJEB48985.txt
Rscript scripts/effluent.R --freqmin 0.1 --min_coverage 40 --beep data/runtables/SraRunTable_PRJNA1027858.txt
Rscript scripts/effluent.R --freqmin 0.1 --min_coverage 40 --beep data/runtables/SraRunTable_PRJEB44932.txt
Rscript scripts/effluent.R --freqmin 0.1 --min_coverage 40 --beep data/runtables/SraRunTable_PRJEB55313.txt
Rscript scripts/effluent.R --freqmin 0.1 --min_coverage 40 --beep data/runtables/SraRunTable_PRJNA946141.txt
Rscript scripts/effluent.R --freqmin 0.1 --min_coverage 40 --beep data/runtables/SraRunTable_PRJNA1238906.txt,data/runtables/SraRunTable_PRJNA1212683.txt,data/runtables/SraRunTable_PRJNA1141947.txt
