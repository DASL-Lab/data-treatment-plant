# First argument should be the location of the SRA Run Table.

set -euo pipefail


echo $1
accessions=($(awk -F "," '{if (NR !=1) print $1}' ${1}))

# Initialize directories
mkdir -p data/fastq
mkdir -p data/groutput

COUNTER=1
for accession in ${accessions[@]}; do
    echo ""
    echo ${accession}
    echo $COUNTER
    wc -l $1
    COUNTER=$((COUNTER+1))
    # Check for duplicates
    # Since gzip'd, fasterq-dump doesn't know about existing files
    fastq_files=(data/fastq/${accession}*)
    has_fastq=false

    for f in "${fastq_files[@]}"; do
        if [ -f "$f" ]; then
            has_fastq=true
            break
        fi
    done

    mapped_csv="data/groutput/${accession}.mapped.csv"
    mapped_csv_gz="${mapped_csv}.gz"

    if [ "$has_fastq" = false ] && [ ! -f "$mapped_csv" ] && [ ! -f "$mapped_csv_gz" ]; then
        fasterq-dump "$accession" --progress --outdir "data/fastq/"

        has_fastq=false
        for f in data/fastq/${accession}*; do
            if [ -f "$f" ]; then
                has_fastq=true
                break
            fi
        done

        if [ "$has_fastq" = false ]; then
            echo "fasterq-dump failed. Trying ENA."
            java -jar data/ENA/ena-file-downloader.jar \
                --accessions=$accession \
                --location=data/fastq \
                --format=READS_FASTQ \
                --protocol=FTP
            if compgen -G "data/fastq/reads_fastq/*/*" > dev/null; then
                mv data/fastq/reads_fastq/*/* data/fastq
            fi
        
            echo "$accession"
            echo "$COUNTER"
            wc -l "$1"
        fi
    fi
    
    echo "Running Minimap2 for $accession"
    if [ ! -f "$mapped_csv" ] && [ ! -f "$mapped_csv_gz" ]; then

        fastq_base="data/fastq/${accession}"
        run_cmd=()

        if [ -f "${fastq_base}_1.fastq" ] && [ -f "${fastq_base}_2.fastq" ]; then
            run_cmd=(python gromstolen/minimap2.py -t 12 -p "$accession" -o data/groutput --nocut --replace "${fastq_base}_1.fastq" "${fastq_base}_2.fastq")
        elif [ -f "${fastq_base}.fastq" ]; then
            run_cmd=(python gromstolen/minimap2.py -t 12 -p "$accession" -o data/groutput --nocut --replace "${fastq_base}.fastq")
        elif [ -f "${fastq_base}_1.fastq.gz" ] && [ -f "${fastq_base}_2.fastq.gz" ]; then
            run_cmd=(python gromstolen/minimap2.py -t 12 -p "$accession" -o data/groutput --nocut --replace "${fastq_base}_1.fastq.gz" "${fastq_base}_2.fastq.gz")
        elif [ -f "${fastq_base}.fastq.gz" ]; then
            run_cmd=(python gromstolen/minimap2.py -t 12 -p "$accession" -o data/groutput --nocut --replace "${fastq_base}.fastq.gz")
        fi

        if [ "${#run_cmd[@]}" -gt 0 ]; then
            echo "Running: ${run_cmd[*]}"
            "${run_cmd[@]}"


        # Check if Minimap2 was successful by file count and line count
        output_files=(data/groutput/${accession}*mapped.csv*)
        if [ "${#output_files[@]}" -eq 2 ]; then
            mfile="${output_files[0]}"
            if [ "$(wc -l < "$mfile")" -gt 50 ]; then
                echo "Minimap2 Successful, removing FASTQ files for $accession"
                for fq in data/fastq/${accession}*; do
                    [ -f "$fq" ] && rm "$fq"
                done
            else
                echo "Minimap2 output file has fewer than 50 lines:"
                wc -l < "$mfile"
                echo "Minimap2 failed, keeping fastq but removing groutput for $accession"

                echo "Minimap2 failed on $accession in $1. Line count:" >> out.log

                if [ -f "${fastq_base}_1.fastq" ]; then
                    wc -l "${fastq_base}_1.fastq" >> out.log
                    wc -l "${fastq_base}_2.fastq" >> out.log
                elif [ -f "${fastq_base}.fastq" ]; then
                    wc -l "${fastq_base}.fastq" >> out.log
                elif [ -f "${fastq_base}_1.fastq.gz" ]; then
                    wc -l "${fastq_base}_1.fastq.gz" >> out.log
                    wc -l "${fastq_base}_2.fastq.gz" >> out.log
                elif [ -f "${fastq_base}.fastq.gz" ]; then
                    wc -l "${fastq_base}.fastq.gz" >> out.log
                fi

                # Clean up groutput files
                rm -f "$mfile"
                coverage_file="${mfile/mapped/coverage}"
                [ -f "$coverage_file" ] && rm "$coverage_file"

                echo "Currently working on a large database, removing fastq anyway."
                for fq in data/fastq/${accession}*; do
                    [ -f "$fq" ] && rm "$fq"
                done
            fi
        fi
    fi



done

for file in data/fastq/*.fastq; do
  [ -f "$file" ] || continue
  gzip "$file"
done

for file in data/groutput/*.csv; do
  [ -f "$file" ] || continue
  gzip "$file"
done
