# First argument should be the location of the SRA Run Table.
echo $1
accessions=($(awk -F "," '{if (NR !=1) print $1}' ${1}))

# Initialize directories
mkdir -p data/fastq
mkdir -p groutput

for accession in ${accessions[@]}; do
    echo ""
    echo $1
    echo ${accession}
    # Check for duplicates
    # Since gzip'd, fasterq-dump doesn't know about existing files
    if [ `ls data/fastq | grep ${accession} | wc -w` = 0 ]; then
        if [ ! -f "groutput/${accession}.mapped.csv" ]; then
            if [ ! -f "groutput/${accession}.mapped.csv.gz" ]; then
                fasterq-dump ${accession} --progress --outdir "data/fastq/"
                gzip -vf data/fastq/${accession}*fastq
            fi
        fi
    fi
    
    echo "Running Minimap2"
    echo ${accession}
    if [ ! -f "groutput/${accession}.mapped.csv" ]; then
        if [ ! -f "groutput/${accession}.mapped.csv.gz" ]; then
            # Some fastqs include combined and two separate files.
            # Check the separate files first.
            if [ -f "data/fastq/${accession}_1.fastq.gz" ]; then
                echo python gromstolen/minimap2.py -t 2 -p ${accession} -o groutput --nocut --replace "data/fastq/${accession}_1.fastq.gz" "data/fastq/${accession}_2.fastq.gz"
                python gromstolen/minimap2.py -t 2 -p ${accession} -o groutput --nocut --replace "data/fastq/${accession}_1.fastq.gz" "data/fastq/${accession}_2.fastq.gz"
                echo "Done"
            elif [ -f "data/fastq/${accession}.fastq.gz" ]; then
                echo python gromstolen/minimap2.py -t 2 -p ${accession} -o groutput --nocut --replace "data/fastq/${accession}.fastq.gz"
                python gromstolen/minimap2.py -t 2 -p ${accession} -o groutput --nocut --replace "data/fastq/${accession}.fastq.gz"
                echo "Done"
            fi
        fi

        # If successful, remove the fastq file(s).
        if [ `ls groutput | grep ${accession} | wc -l` = 2 ]; then
            mfile=`ls groutput/${accession}*mapped.csv*`
            if (( `wc -l < $mfile` > 50 )); then
                echo "GromStole Successful, removing fastq"
                fastq_file=`ls data/fastq/${accession}*`
                rm $fastq_file
            else 
                echo `wc -l < $mfile`
                echo "Gromstole failed, keeping fastq but removing groutput."
                rm "$mfile"
                rm "${mfile/mapped/coverage}"
            fi
        fi
    fi
done



