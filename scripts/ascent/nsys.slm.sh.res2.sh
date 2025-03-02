#!/bin/bash

in=$1  # o.with
part=1 # $2

if [ $part -eq 1 ] ;then
# for ii in 1 2 4 8 16 32 64 128 256 384 ;do cd $ii+100+ascent ;../res.sh o.with ;cd ..;done |sort |snk 1

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
    # i/o
    if [ -f dump_wind-shock.h5.txt ] ;then
        iobytes=`grep dump_wind-shock.h5 dump_wind-shock.h5.txt |awk '{print $5}'`
        ioGbytes=`echo $iobytes |awk '{print $0/1024^3}'`
        iosteps=`grep ^Step dump_wind-shock.h5.txt |wc -l`
    fi
    # cubeside=
    # uenv=
    # --- i/o checkpoint: x,y,z, vx,vy,vz, alpha, du_m1, h, m, temp, x_m1, y_m1, z_m1
    # echo "$(basename `pwd`);$in;test=$testname;np=$np_global;s=$steps;mpi=$mpi;omp=$omp;npcn=$ntasks_per_node;cn=$nodes;sec=$elapsed ; debug"
    echo "$(basename `pwd`);$in;$testname;$np_global;$steps;$mpi;$omp;$ntasks_per_node;$nodes;$elapsed;$iobytes;$ioGbytes;$iosteps"
    # |awk '{printf "%s;%s;%s;%s;%s;%s;%s;%s;%s",$1,$2,$3,$4,$5,$6,$7,$8,$9}'
else
    echo "$(basename `pwd`);$in;$testname;$np_global;$steps;$mpi;$omp;$ntasks_per_node;$nodes;$elapsed;$iobytes;$ioGbytes;$iosteps"
    echo "in=$in not found"
fi

fi
