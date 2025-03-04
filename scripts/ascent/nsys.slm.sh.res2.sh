#!/bin/bash

in=$1  # o.with
part=1 # $2

if [ $part -eq 1 ] ;then
# for ii in 1 2 4 8 16 32 64 128 256 384 ;do cd $ii+100+ascent ;../res.sh o.with ;cd ..;done |sort |snk 1
# for ii in 1 2 4 8 16 ;do cd $ii+50+ascent ; ../nsys.slm.sh.res2.sh oo.cn* 1 ;cd ..;done

if [ -f $in ] ;then
    # 4 MPI-3.1 process(es) with 64 OpenMP-201511 thread(s)/process
    # Data generated for 4037726 global particles
    # Total execution time of 101 iterations of wind-shock up to t = 0.000017: 8.96836s
    testname=`grep 'Total execution time of' $in |awk '{print $9}'`
    mpi=`grep process $in |awk '{print $2}'`
    omp=`grep process $in |awk '{print $6}'`
    np_global=`grep 'global particles' $in |awk '{print $4}'`
    steps=`grep 'Total execution time of' $in |awk '{print $6}'`
    elapsed=`grep 'Total execution time of' $in |awk '{print $15}' |tr -d s`
    #
    nodes=`grep nodes= *.slm |cut -d= -f2`
    if [ $nodes == 1 ] ;then
        echo '$dir;$in;$testname;$np_global;$steps;$mpi;$omp;$ntasks_per_node;$nodes;$elapsed'
    fi
    ntasks_per_node=`grep ntasks-per-node= *.slm |cut -d= -f2`
    # i/o:
    if [ -f dump_wind-shock.h5 ] ;then
    ls -l dump_wind-shock.h5 > dump_wind-shock.h5.txt
    /capstor/scratch/cscs/jfavre/Ascent-cuda/install/hdf5-1.14.1-2/bin/h5ls dump_wind-shock.h5 >> dump_wind-shock.h5.txt
    iobytes=`grep dump_wind-shock.h5 dump_wind-shock.h5.txt |awk '{print $5}'`
    ioGbytes=`echo $iobytes |awk '{print $0/1024^3}'`
    iosteps=`grep ^Step dump_wind-shock.h5.txt |wc -l`
    # FileOutput: 0.154071s
    grep FileOutput: oo.cn* > io.txt
    if [ -s io.txt ] ;then
        io_avg_t=`awk '{print $3}' io.txt |tr -d s |awk '{s=s+$0}END{print s/NR}'`
    fi
    fi
    # ascent:
    grep -A1 MomentumAndEnergy: oo.cn* |grep ascent_t0 > ascent.txt
    if [ -s ascent.txt ];then
    while read a b c t0 e f g t1 ; do
        t0_min2ms=`echo $t0 |cut -d: -f2 |awk '{print $0*60*1000}'`
        t0_sec2ms=`echo $t0 |cut -d: -f3 |awk -F\. '{print $1*1000+$2}'`
        t0_ms=`echo $t0_min2ms $t0_sec2ms |awk '{print $1+$2}'`

        t1_min2ms=`echo $t1 |cut -d: -f2 |awk '{print $0*60*1000}'`
        t1_sec2ms=`echo $t1 |cut -d: -f3 |awk -F\. '{print $1*1000+$2}'`
        t1_ms=`echo $t1_min2ms $t1_sec2ms |awk '{print $1+$2}'`

        s=`echo $t0_ms $t1_ms |awk '{print ($2-$1)/1000}'`
        # echo $t0 $t1 $s
        echo $s
    done < ascent.txt |awk '$1>0.015{s=s+$1}END{print s/NR}' > .ascent.txt.eff
    ascent_avg_t=`cat .ascent.txt.eff`
    fi
    # --- i/o checkpoint: x,y,z, vx,vy,vz, alpha, du_m1, h, m, temp, x_m1, y_m1, z_m1
    # echo "$(basename `pwd`);$in;test=$testname;np=$np_global;s=$steps;mpi=$mpi;omp=$omp;npcn=$ntasks_per_node;cn=$nodes;sec=$elapsed ; debug"
    echo "$(basename `pwd`);$in;$testname;$np_global;$steps;$mpi;$omp;$ntasks_per_node;$nodes;$elapsed;$ascent_avg_t;$io_avg_t;$iobytes;$ioGbytes;$iosteps"
    # |awk '{printf "%s;%s;%s;%s;%s;%s;%s;%s;%s",$1,$2,$3,$4,$5,$6,$7,$8,$9}'
else
    echo "$(basename `pwd`);$in;$testname;$np_global;$steps;$mpi;$omp;$ntasks_per_node;$nodes;$elapsed;$ascent_avg_t;$io_avg_t;$iobytes;$ioGbytes;$iosteps"
    echo "in=$in not found"
fi

fi
