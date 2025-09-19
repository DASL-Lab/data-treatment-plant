# No shebang - this is more like a lab notebook.
# Running from start to finish would take about two-three weeks at least.

run_treatment() {
    echo "Running $1"
    bash scripts/treatment.sh data/runtables/SraRunTable_$1.txt 
    Rscript scripts/effluent.R --freqmin 0.1 --min_coverage 40 --beep \
        data/runtables/SraRunTable_$1.txt
}

# Finished runs sorted by PRJ
run_treatment PRJDB19812
run_treatment PRJEB44932
run_treatment PRJEB48206
##run_treatment PRJEB48985 # Too big or all errors
run_treatment PRJEB61810
run_treatment PRJEB65603
run_treatment PRJEB67638
run_treatment PRJEB76651
run_treatment PRJNA661613
run_treatment PRJNA715712
run_treatment PRJNA719837
run_treatment PRJNA720687
###run_treatment PRJNA729801 # Too big or all errors
run_treatment PRJNA731975
run_treatment PRJNA735936
run_treatment PRJNA741211
run_treatment PRJNA745177
###run_treatment PRJNA748354 # Too big or all errors
run_treatment PRJNA750263
run_treatment PRJNA759260
###run_treatment PRJNA764181 # Too big or all errors
run_treatment PRJNA765031
run_treatment PRJNA772783
run_treatment PRJNA788395
run_treatment PRJNA796340
run_treatment PRJNA811594
run_treatment PRJNA819090
run_treatment PRJNA847239
run_treatment PRJNA856091
run_treatment PRJNA865728
run_treatment PRJNA896334
run_treatment PRJNA941107
###run_treatment PRJNA946141 # Too big or all errors
run_treatment PRJNA992940
run_treatment PRJNA1027333
run_treatment PRJNA1027858
run_treatment PRJNA1031245
run_treatment PRJNA1042787
run_treatment PRJNA1067101
run_treatment PRJNA1088471
run_treatment PRJNA1110039
run_treatment PRJNA1141947
run_treatment PRJNA1212683
run_treatment PRJNA1238906

# Unknown runtimes (Long or not yet processed)
#bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA661613.txt # minimap2.py failed.
#bash scripts/treatment.sh data/runtables/SraRunTable_PRJEB55313.txt # Downloaded, not processed (memory issues).
#bash scripts/treatment.sh data/runtables/SraRunTable_PRJEB48985.txt
#bash scripts/treatment.sh data/runtables/SraRunTable_PRJNA719837.txt

ena_fastq = "data/fastq/reads_fastq"
if [ -e "$ena_fastq" ]; then
	rm -r "$ena_fastq" # Remove ENA folder (full of empty folders)
fi
