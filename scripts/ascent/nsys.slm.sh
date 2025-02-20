for nnn in 1 ;do
    for sss in 50 ;do
        mkdir -p cn$nnn-size$sss
        cd cn$nnn-size$sss
        sed -e "s-NNN-$nnn-" -e "s-SSS-$sss-" ../nsys.slm.in > nsys.slm
        sbatch nsys.slm
        cd ..
    done
done
