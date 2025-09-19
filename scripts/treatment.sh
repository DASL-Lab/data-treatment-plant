# First argument should be the location of the SRA Run Table.

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
    if [ `ls data/fastq | grep ${accession} | wc -w` = 0 ]; then
        if [ ! -f "data/groutput/${accession}.mapped.csv" ]; then
            if [ ! -f "data/groutput/${accession}.mapped.csv.gz" ]; then
                fasterq-dump ${accession} --progress --outdir "data/fastq/"
            fi
        fi
    fi
    # If no file, perhaps it's in the ENA?
    if [ `ls data/fastq | grep ${accession} | wc -w` = 0 ]; then
        if [ ! -f "data/groutput/${accession}.mapped.csv" ]; then
            if [ ! -f "data/groutput/${accession}.mapped.csv.gz" ]; then
                echo "fasterq-dump appears to have failed. Trying ENA."
                java -jar data/ENA/ena-file-downloader.jar --accessions=$accession --location=data/fastq --format=READS_FASTQ --protocol=FTP
                mv data/fastq/reads_fastq/*/* data/fastq/
                # Repeat counter info since ENA has a lot of output
                echo ${accession}
                echo $COUNTER
                wc -l $1
            fi
        fi
    fi
    
    if [ ! -f "data/groutput/${accession}.mapped.csv" ]; then
        if [ ! -f "data/groutput/${accession}.mapped.csv.gz" ]; then
        	echo "Running minimap2.py"
            # Some fastqs are combined, some are two separate files.
            # Check the separate files first.
            # Also check for gzipped files
            if [ -f "data/fastq/${accession}_1.fastq" ]; then
                echo python gromstolen/minimap2.py -t 12 -p ${accession} -o data/groutput --nocut --replace "data/fastq/${accession}_1.fastq" "data/fastq/${accession}_2.fastq"
                python gromstolen/minimap2.py -t 12 -p ${accession} -o data/groutput --nocut --replace "data/fastq/${accession}_1.fastq" "data/fastq/${accession}_2.fastq"
                echo "Done"
            elif [ -f "data/fastq/${accession}.fastq" ]; then
                echo python gromstolen/minimap2.py -t 12 -p ${accession} -o data/groutput --nocut --replace "data/fastq/${accession}.fastq"
                python gromstolen/minimap2.py -t 12 -p ${accession} -o data/groutput --nocut --replace "data/fastq/${accession}.fastq"
                echo "Done"
            elif [ -f "data/fastq/${accession}_1.fastq.gz" ]; then
                echo python gromstolen/minimap2.py -t 12 -p ${accession} -o data/groutput --nocut --replace "data/fastq/${accession}_1.fastq.gz" "data/fastq/${accession}_2.fastq.gz"
                python gromstolen/minimap2.py -t 12 -p ${accession} -o data/groutput --nocut --replace "data/fastq/${accession}_1.fastq.gz" "data/fastq/${accession}_2.fastq.gz"
                echo "Done"
            elif [ -f "data/fastq/${accession}.fastq.gz" ]; then
                echo python gromstolen/minimap2.py -t 12 -p ${accession} -o data/groutput --nocut --replace "data/fastq/${accession}.fastq.gz"
                python gromstolen/minimap2.py -t 12 -p ${accession} -o data/groutput --nocut --replace "data/fastq/${accession}.fastq.gz"
                echo "Done"
            fi
        fi

        # If successful, remove the fastq file(s).
        if [ "$(ls data/groutput/${accession}* 2>/dev/null | wc -l)" = 2 ]; then
            mfile=$(echo data/groutput/${accession}*mapped.csv*)
            if [ "$(wc -l < "$mfile")" -gt 50 ]; then
                echo "Minimap2 Successful, removing fastq if it exists"
                for fastq_file in data/fastq/${accession}*; do
                	if [ -f "fastq_file" ]; then
	                    rm "$fastq_file"
	                fi
                done
            else 
                wc -l < $mfile
                echo "Minimap2 failed, keeping fastq but removing data/groutput."
                echo "Minimap2 failed on $accession in $1. Line count:" >> out.log
                if [ -f "data/fastq/${accession}_1.fastq" ]; then
                    wc -l "data/fastq/${accession}_1.fastq" >> out.log
                    wc -l "data/fastq/${accession}_2.fastq" >> out.log
                elif [ -f "data/fastq/${accession}.fastq" ]; then
                    wc -l "data/fastq/${accession}.fastq" >> out.log
                elif [ -f "data/fastq/${accession}_1.fastq.gz" ]; then
                    wc -l "data/fastq/${accession}_1.fastq.gz" >> out.log
                    wc -l "data/fastq/${accession}_2.fastq.gz" >> out.log
                elif [ -f "data/fastq/${accession}.fastq.gz" ]; then
                    wc -l "data/fastq/${accession}.fastq.gz" >> out.log
                fi 
                if [ -f "$mfile" ]; then
	                rm "$mfile"
	            fi
	            if [ -f "${mfile/mapped/coverage}" ]; then
	                rm "${mfile/mapped/coverage}"
	            fi
                echo "Currently working on a large database, removing fastq anyway."
                fastq_file=`ls data/fastq/${accession}*`
                if [ -f "$fastq_file" ]; then
	                rm "$fastq_file"
	            fi
            fi
        fi
    fi
done

#for file in data/fastq/*.fastq; do
#  [ -f "$file" ] || continue
#  gzip "$file"
#done

#for file in data/groutput/*.csv; do
#  [ -f "$file" ] || continue
#  gzip "$file"
#done
