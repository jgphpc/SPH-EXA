for nnn in 1 2 4 8 16 32 64 128 ;do
    for sss in 50 100 200 ;do
        mkdir -p cn$nnn-size$sss
        cd cn$nnn-size$sss
        s=`echo $nnn $sss | awk '{print $1*$2}'`
        sed -e "s-NNN-$nnn-" -e "s-SSS-$s-" ../nsys.slm.in > $nnn.$sss.nsys.slm
        sbatch nsys.slm
        cd ..
    done
done
