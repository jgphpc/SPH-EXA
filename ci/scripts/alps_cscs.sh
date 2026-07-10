#!/bin/bash
 
# vim: set foldmethod=marker foldmarker={,} :

_build_clone_uenv_spack() {
    git clone --depth=1 https://github.com/eth-cscs/uenv-spack.git uenv-spack.git
}

_build_config_sphexa_cuda() {
    build_type=$1

    ./uenv-spack.git/uenv-spack --uarch=gh200 \
      --specs="sphexa@develop +hdf5 +gpu_aware_mpi +cuda cuda_arch=90 build_type=${build_type}" \
      --name=sphexa \
      sphexa+spack

    # use local commit:
    cat << EOF >> ./sphexa+spack/env/spack.yaml
  develop:
    sphexa:
      spec: sphexa@develop +hdf5 +gpu_aware_mpi +cuda cuda_arch=90 build_type=${build_type}
      path: $PWD
EOF
    # boost parallel make:
    sed -i "s@make -j32@make -j200@" ./sphexa+spack/build
    # match cray-mpich version of the uenv:
    sed -i "s-8.1.32-9.1.0-" ./sphexa+spack/config/system/packages.yaml
    # keep build dir for ctest:
    echo "  build_stage: $PWD/sphexa+spack/build_ctest" >> ./sphexa+spack/config/user/config.yaml
    # show config:
    ln -fs ./sphexa+spack/env/spack.yaml .
    ln -fs ./sphexa+spack/config/user/config.yaml .
    cat ./spack.yaml ./config.yaml
 }

_build_sphexa_cuda() {
    tar xf ~/eff.tar
    # for ii in $(grep -rl mpiexec sphexa+spack/build_ctest/spack-stage-sphexa-*/spack-build-*/ |grep CTestTestfile.cmake) ; do
    for ii in $(find sphexa+spack/build_ctest/spack-stage-sphexa-*/spack-build-*/ -name CTestTestfile.cmake) ;do
        # sed 's@/[^"]*/mpiexec\"@/usr/bin/srun\" \"--overlap\"@' $ii > /tmp/eff # |grep srun
        sed -i 's@/[^"]*/mpiexec\"@srun\" \"--overlap\"@' $ii
    done
##    cd sphexa+spack
##    SPACK_INSTALL_FLAGS="--keep-stage" ./build
##    cd ..
}

_build_python_deps() {
    if [ "$SLURM_PROCID" -eq 0 ]; then
        pip_path=$(find /user-environment/ -name site-packages |grep py-pip)
        PYTHONPATH=${pip_path}:$PYTHONPATH /user-environment/env/default/bin/python3 -m pip install --target $PWD/external numpy
        PYTHONPATH=$PWD/external:$PYTHONPATH /user-environment/env/default/bin/python3 -c 'import numpy ; print(numpy.__version__)'
        # 2.5.1
    fi
    wait
}


_run_prerun() {
    if [ "$SLURM_PROCID" -eq 0 ]; then

        arg=$1
        if [ $arg = "grackle" ] ; then
            # https://github.com/grackle-project/grackle_data_files/blob/928696482fbe15d9bac4382de6134d95568f099c/input/CloudyData_UVB%3DHM2012.h5
            wget --quiet https://jfrog.svc.cscs.ch/artifactory/cscs-reframe-tests/sphexa/CloudyData_UVB%3DHM2012.h5
            mkdir -p extern/grackle/grackle_repo/input
            mv CloudyData_UVB=HM2012.h5 extern/grackle/grackle_repo/input/
            export GRACKLE_DATA_FILE="$PWD/extern/grackle/grackle_repo/input/CloudyData_UVB=HM2012.h5"
        fi

        if [ $arg = "h5" ] ; then
            if [ ! -f 50c.h5 ]; then
                wget --quiet -O 50c.h5 https://zenodo.org/records/8369645/files/50c.h5
            fi    
        fi

    fi
    wait
}

_run_ctests() {
    if [ "$SLURM_PROCID" -eq 0 ]; then

        # 01r 02r 06r 10r 12r
        ranks="$1"
        ctest_dir=$(dirname $(find sphexa+spack/build_ctest -name DartConfiguration.tcl |awk -F/ '{print NF,$0}' |sort -nk 1 |head -1 |awk '{print $2}'))

        if [ "$SLURM_PROCID" -eq 0 ]; then
            echo "ranks=$ranks NUM_KEYS=$NUM_KEYS"
            echo "ctest_dir=$ctest_dir"
            pwd

            for ii in $(grep -rl mpiexec sphexa+spack/build_ctest/spack-stage-sphexa-*/spack-build-*/ |grep CTestTestfile.cmake) ; do
                # sed 's@/[^"]*/mpiexec\"@/usr/bin/srun\" \"--overlap\"@' $ii > /tmp/eff # |grep srun
                sed -i 's@/[^"]*/mpiexec\"@srun\" \"--overlap\"@' $ii # > /tmp/eff # |grep srun
                # mv /tmp/eff $ii
                #0 sed 's@\"/usr/bin/srun\"@\"/usr/bin/srun\" \"--overlap\"@' $ii > /tmp/eff # |grep srun
                # mv /tmp/eff $ii
            done

        fi

        if [ $ranks = "01r" ] ; then
            ctest --test-dir $ctest_dir -N -L "$ranks" -V
            ctest --test-dir $ctest_dir -j -L "$ranks" -V
        else
            ctest --test-dir $ctest_dir -L "$ranks" -L "cpu" -j
            ctest --test-dir $ctest_dir -L "$ranks" -L "gpu"
#del             ctest --test-dir $ctest_dir -L "$ranks" --show-only=json-v1 | jq -r .tests[]
#del             ctest --test-dir $ctest_dir -L "$ranks" --show-only=json-v1 | jq -r .tests[].command[-1] &> eff.sh
#del             # bash ./eff.sh
        fi

        date

    fi
    wait
}
#{{{
    # 01
#     - $TEST_INSTALL_DIR/coord_samples/coordinate_test
#     - $TEST_INSTALL_DIR/hydro/turbulence_tests
#     - ln -fs $TEST_INSTALL_DIR/hydro/example_data.txt .
#     - $TEST_INSTALL_DIR/hydro/sph_tests
#     - $TEST_INSTALL_DIR/performance/octree_perf
#     - $TEST_INSTALL_DIR/performance/peers_perf
#     - NUM_KEYS=320000 $TEST_INSTALL_DIR/performance/hilbert_perf
#     - $TEST_INSTALL_DIR/ryoanji/cpu_unit_tests
#     - $TEST_INSTALL_DIR/ryoanji/gpu_unit_tests
#     - $TEST_INSTALL_DIR/unit/component_units_omp
#     - $TEST_INSTALL_DIR/unit/component_units
#     # GPU tests:
#     - $TEST_INSTALL_DIR/performance/octree_perf_gpu
#     - $TEST_INSTALL_DIR/performance/hilbert_perf_gpu
#     - $TEST_INSTALL_DIR/hydro/sph_gpu_tests
#     - $TEST_INSTALL_DIR/performance/sph_density_test_gpu
#     - $TEST_INSTALL_DIR/unit_cuda/component_units_cuda
#
#
#
# 02    
#     - $TEST_INSTALL_DIR/integration_mpi/box_mpi
#     - $TEST_INSTALL_DIR/integration_mpi/domain_2ranks
#     - $TEST_INSTALL_DIR/integration_mpi/domain_resize
#     - $TEST_INSTALL_DIR/integration_mpi/exchange_focus
#     - $TEST_INSTALL_DIR/integration_mpi/exchange_halos
#     - $TEST_INSTALL_DIR/integration_mpi/exchange_keys
#     - $TEST_INSTALL_DIR/integration_mpi/globaloctree
#     - $TEST_INSTALL_DIR/integration_mpi/hdf5io
#     - $TEST_INSTALL_DIR/ryoanji/global_upsweep_cpu
#     - $TEST_INSTALL_DIR/ryoanji/ryoanji_demo
#     - $TEST_INSTALL_DIR/ryoanji/ryoanji_demo_mpi
#     - $TEST_INSTALL_DIR/physics/disk_tests
#     # GPU tests:
#     - $TEST_INSTALL_DIR/integration_mpi/assignment_gpu
#     - $TEST_INSTALL_DIR/integration_mpi/domain_gpu
#     - $TEST_INSTALL_DIR/integration_mpi/exchange_domain_gpu
#     - $TEST_INSTALL_DIR/integration_mpi/exchange_halos_gpu
# 
#     04 
#     - $TEST_INSTALL_DIR/integration_mpi/exchange_general_gpu # was -n5
#     - $TEST_INSTALL_DIR/ryoanji/global_forces_gpu
#     - $TEST_INSTALL_DIR/ryoanji/global_upsweep_gpu
# 
#     12
#     - $TEST_INSTALL_DIR/integration_mpi/exchange_domain
#     - $TEST_INSTALL_DIR/integration_mpi/exchange_general
#     - $TEST_INSTALL_DIR/integration_mpi/focus_tree
#     - $TEST_INSTALL_DIR/integration_mpi/treedomain
#     - $TEST_INSTALL_DIR/integration_mpi/domain_nranks
#     }}}

_run_sphexa-cuda() {
    APP_INSTALL_DIR="$1"
    device="$2"
    # OMP_NUM_THREADS=$4

    if [ "$SLURM_PROCID" -eq 0 ]; then
        source ci/scripts/alps_cscs.sh
        _run_prerun h5
        _build_python_deps
    fi
    wait

    if [ $device = "gpu" ] ; then
        exe=sphexa-cuda
    else
        exe=sphexa
    fi

    # --glass ./50c.h5 -> H5PartGetNumParticles: Iteration is invalid! Have you set the time step?
    $APP_INSTALL_DIR/$exe --init sedov --G 1.0 -n 40 -s 100 -w 10 --quiet

    if [ "$SLURM_PROCID" -eq 0 ]; then mv constants.txt constants_ref.txt; fi
    wait

    $APP_INSTALL_DIR/$exe --init dump_sedov.h5:4 -s 100 --quiet

    if [ "$SLURM_PROCID" -eq 0 ]; then
      awk 'start||$1==50 {print; start=1}' constants_ref.txt > constants_ref_tail.txt
      PYTHONPATH=$PWD/external:$PYTHONPATH \
          /user-environment/env/default/bin/python3 ci/scripts/compare_constants.py \
          constants_ref_tail.txt constants.txt "7,8"
      if [ $? -ne 0 ]; then exit 1 ; fi
    fi
    wait
    date
}

_run_get_build_artifact() {
    if [ "$SLURM_PROCID" -eq 0 ]; then

        CI_PIPELINE_ID=$1
        in_file="${SCRATCH}/gitlab-runner/f7t/sphexa+spack_${CI_PIPELINE_ID}.tar"
        out_file="sphexa+spack_${CI_PIPELINE_ID}.tar.$$"
        ls -l ${SCRATCH}/gitlab-runner/f7t/sphexa+spack*.tar
        # mv is an atomic operation
        if [ -f "$in_file" ] ;then
            if mv "$in_file" "$out_file" ; then
                tar xf $out_file
                touch sphexa+spack/ready
            else
                while [ ! -f sphexa+spack/ready ]; do sleep 1; done
            fi
        fi

    fi
    wait
}
