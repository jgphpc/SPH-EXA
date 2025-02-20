#!/bin/bash

NSYS=/capstor/scratch/cscs/piccinal/daint/nvidia/nsight-systems-2025.1.1/bin/nsys
SQLT=/capstor/scratch/cscs/piccinal/daint/nvidia/nsight-systems-2025.1.1/target-linux-sbsa-armv8/sqlite3

for ii in ascent*.nsys-rep ;do $NSYS export -t sqlite -f on ./$ii ;e $ii; done

for ii in *.sqlite ;do
    echo 'nsec|deviceId|bytes|memKind|memoryOperationType' > $ii.csv;
    $SQLT -readonly $ii -cmd 'select start,deviceId,bytes,memKind,memoryOperationType from CUDA_GPU_MEMORY_USAGE_EVENTS' '.exit' >> $ii.csv
    echo $ii
done

for ii in ascent*.csv ;do
    grep -v nsec $ii |awk -F\| 'BEGIN{s=0}{if ($5==0) s=s+$3; else s=s-$3;print s;}' > $ii.csv
    echo $ii
done
# wc -l ascent*.csv.csv
paste ascent-*.csv.csv > ascent-.csv
paste ascent+*.csv.csv > ascent+.csv
#
echo -e "g0-\tg1-\tg2-\tg3-\tg0+\tg1+\tg2+\tg3+" > ascent.csv
paste ascent-.csv ascent+.csv >> ascent.csv

# no: because not same number of rows|samples: paste _ascent*.csv.csv > _ascent.tsv


