#!/bin/bash

# for dd in cn32-size* ;do cd $dd ; ./nsys.slm.sh.res1.sh 1 ;cd ..;done
# for dd in cn32-size* ;do cd $dd ; ./nsys.slm.sh.res1.sh 2 ;cd ..;done \
# |sort -t, -nk 2 |awk -F, '{printf "%s,",$3}'

part=$1
NSYS=/capstor/scratch/cscs/piccinal/daint/nvidia/nsight-systems-2025.1.1/bin/nsys
SQLT=/capstor/scratch/cscs/piccinal/daint/nvidia/nsight-systems-2025.1.1/target-linux-sbsa-armv8/sqlite3

if [ $part = "1" ] ;then

# nsys-rep2sqlite:    
for ii in ascent*.nsys-rep ;do $NSYS export -t sqlite -f on ./$ii ;echo $ii; done

# sqlite2csv:
for ii in *.sqlite ;do
    echo 'nsec|deviceId|bytes|memKind|memoryOperationType' > $ii.csv;
    $SQLT -readonly $ii -cmd 'select start,deviceId,bytes,memKind,memoryOperationType from CUDA_GPU_MEMORY_USAGE_EVENTS' '.exit' >> $ii.csv
    echo $ii
done

# incremental memory usage:
for ii in ascent*.csv ;do
    grep -v nsec $ii |awk -F\| 'BEGIN{s=0}{if ($5==0) s=s+$3; else s=s-$3;print s;}' > $ii.csv
    echo $ii
done
# wc -l ascent*.csv.csv
fi

if [ $part = "2" ] ;then
# find for largest bytes in ascent+ and ascent-
    max_with=`for ii in ascent+*.csv.csv ;do sort -nk1 $ii |tail -1 ;done |sort -nk1 |tail -1`
    max_without=`for ii in ascent-*.csv.csv ;do sort -nk1 $ii |tail -1 ;done |sort -nk1 |tail -1`
    max_MB=`echo $max_with $max_without |awk '{print ($1-$2)/1e6}'`
    dd=`pwd`
    cn=`basename $dd |cut -d- -f1 |tr -d [a-z]`
    cubeside=`basename $dd |cut -d- -f2 |tr -d [a-z]`
    echo "$cn,$cubeside,$max_MB"
fi



# # what's wrong with paste ?
# paste -d, ascent-*.csv.csv > ascent-.csv
# paste -d, ascent+*.csv.csv > ascent+.csv
# # echo -e "g0-\tg1-\tg2-\tg3-\tg0+\tg1+\tg2+\tg3+" > ascent.csv
# echo -e "g0-,g1-,g2-,g3-,g0+,g1+,g2+,g3+" > ascent.csv
# paste -d, ascent-.csv ascent+.csv >> ascent.csv

# no: because not same number of rows|samples: paste _ascent*.csv.csv > _ascent.tsv
