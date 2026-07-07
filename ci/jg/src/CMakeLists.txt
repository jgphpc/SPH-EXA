cmake_minimum_required(VERSION 3.10)
# usv prgenv-gnu/26.3:v1
# cmake -B build -S src -DCMAKE_C_COMPILER=mpicc -DCMAKE_BUILD_TYPE=Debug \
# "-DMPIEXEC_EXTRA_FLAGS=--uenv=prgenv-gnu/26.3:v1;--view=default;-u"
# "-DMPIEXEC_EXTRA_FLAGS=--uenv=prgenv-gnu/26.3:v1;--view=default;-u;--overlap;--ntasks-per-node=288;--reservation=uss140-shs131-nv590-staging;--gpus-per-node=4;--account=djenkssl;-t2"
# --- CSCS_RUNNER_MODE baremetal
# cmake --build build -j
# ctest --test-dir build -N -V # -j
# srun --gpus-per-node=4 -A djenkssl -n 10 --reservation=uss140-shs131-nv590-staging -t1 ./build/sleep_mpi_2a 2
#ok export SLURM_TIMELIMIT='00:02:00'
#ok export SLURM_JOB_NUM_NODES=1
#ok export SLURM_JOB_RESERVATION='uss140-shs131-nv590-staging'
#ok export SLURM_GPUS_PER_NODE=4
#ok export SLURM_JOB_ACCOUNT='djenkssl'

project(sleep C)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

find_package(MPI)
include(CTest)

function(cstone_add_performance_test sourcename testname seconds)
    add_executable(${testname} ${sourcename})
    # target_include_directories(${testname} PRIVATE ${PROJECT_SOURCE_DIR}/include)
    # target_include_directories(${testname} PRIVATE ${PROJECT_SOURCE_DIR}/test)
    # target_link_libraries(${testname} PRIVATE OpenMP::OpenMP_CXX)
    add_test(NAME ${testname} COMMAND ${testname} ${seconds})
    set_tests_properties(${testname} PROPERTIES LABELS "01r;cpu")
    # install(TARGETS ${testname} RUNTIME DESTINATION ${CMAKE_INSTALL_SBINDIR}/performance)
endfunction()

cstone_add_performance_test(sleep_arg.c sleep1a 1)
cstone_add_performance_test(sleep_arg.c sleep2a 2)
cstone_add_performance_test(sleep_arg.c sleep3a 3)
#ok 
#ok cstone_add_performance_test(sleep_arg.c sleep1b 1)
#ok cstone_add_performance_test(sleep_arg.c sleep2b 2)
#ok cstone_add_performance_test(sleep_arg.c sleep3b 3)
#ok 
#ok cstone_add_performance_test(sleep_arg.c sleep1c 1)
#ok cstone_add_performance_test(sleep_arg.c sleep2c 2)
#ok cstone_add_performance_test(sleep_arg.c sleep3c 3)

# domain/test/integration_mpi/CMakeLists.txt
function(add_mpi_test sourcename testname seconds ranks)
    add_executable(${testname} ${sourcename})
    # target_include_directories(${testname} PRIVATE ${PROJECT_SOURCE_DIR}/include)
    # target_include_directories(${testname} PRIVATE ${PROJECT_SOURCE_DIR}/test)
    # target_include_directories(${testname} PRIVATE ${MPI_CXX_INCLUDE_PATH})
    # target_compile_options(${testname} PRIVATE -Wno-unknown-pragmas)
    # target_link_libraries(${testname} PRIVATE ${MPI_CXX_LIBRARIES} GTest::gtest_main)
    # cstone_add_test(${testname} EXECUTABLE ${testname} RANKS ${ranks})
    # install(TARGETS ${testname} RUNTIME DESTINATION ${CMAKE_INSTALL_SBINDIR}/integration_mpi)
    target_link_libraries(${testname} PRIVATE ${MPI_C_LIBRARIES})
    # set(cmd ${_exe})
    # list(PREPEND cmd "${MPIEXEC_EXECUTABLE}" "${MPIEXEC_NUMPROC_FLAG}" "${${name}_RANKS}")
    # add_test(NAME "${name}" COMMAND ${cmd} ${args})
    add_test(NAME ${testname} COMMAND ${MPIEXEC_EXECUTABLE} ${MPIEXEC_EXTRA_FLAGS} ${MPIEXEC_NUMPROC_FLAG} ${ranks} ${testname} ${seconds})
    #2 add_test(NAME ${testname} COMMAND ${testname} ${seconds})
    if (${ranks} LESS 10)
        set_tests_properties(${testname} PROPERTIES LABELS "0${ranks}r;cpu")
    else()
        set_tests_properties(${testname} PROPERTIES LABELS "${ranks}r;cpu")
    endif()
endfunction()

add_mpi_test(sleep_arg_mpi.c sleep_mpi_01a 01 8)
add_mpi_test(sleep_arg_mpi.c sleep_mpi_02a 02 8)
add_mpi_test(sleep_arg_mpi.c sleep_mpi_03a 03 8)
add_mpi_test(sleep_arg_mpi.c sleep_mpi_04a 04 8)
# add_mpi_test(sleep_arg_mpi.c sleep_mpi_05a 05 8)
# add_mpi_test(sleep_arg_mpi.c sleep_mpi_06a 06 8)
# add_mpi_test(sleep_arg_mpi.c sleep_mpi_07a 07 8)
# add_mpi_test(sleep_arg_mpi.c sleep_mpi_08a 08 8)
# add_mpi_test(sleep_arg_mpi.c sleep_mpi_09a 09 8)
# add_mpi_test(sleep_arg_mpi.c sleep_mpi_10a 10 8)
# add_mpi_test(sleep_arg_mpi.c sleep_mpi_11a 11 8)
# add_mpi_test(sleep_arg_mpi.c sleep_mpi_12a 12 8)
# add_mpi_test(sleep_arg_mpi.c sleep_mpi_13a 13 8)
# add_mpi_test(sleep_arg_mpi.c sleep_mpi_14a 14 8)
# add_mpi_test(sleep_arg_mpi.c sleep_mpi_15a 15 8)
# add_mpi_test(sleep_arg_mpi.c sleep_mpi_16a 16 8)
# add_mpi_test(sleep_arg_mpi.c sleep_mpi_17a 17 8)
# add_mpi_test(sleep_arg_mpi.c sleep_mpi_18a 18 8)
# add_mpi_test(sleep_arg_mpi.c sleep_mpi_19a 19 8)
# add_mpi_test(sleep_arg_mpi.c sleep_mpi_20a 20 8)
# add_mpi_test(sleep_arg_mpi.c sleep_mpi_21a 21 8)
# add_mpi_test(sleep_arg_mpi.c sleep_mpi_22a 22 8)
# add_mpi_test(sleep_arg_mpi.c sleep_mpi_23a 23 8)
# add_mpi_test(sleep_arg_mpi.c sleep_mpi_24a 24 8)
# add_mpi_test(sleep_arg_mpi.c sleep_mpi_25a 25 8)
# add_mpi_test(sleep_arg_mpi.c sleep_mpi_26a 26 8)
# add_mpi_test(sleep_arg_mpi.c sleep_mpi_27a 27 8)
# add_mpi_test(sleep_arg_mpi.c sleep_mpi_28a 28 8)
# add_mpi_test(sleep_arg_mpi.c sleep_mpi_29a 29 8)
# add_mpi_test(sleep_arg_mpi.c sleep_mpi_30a 30 8)
# add_mpi_test(sleep_arg_mpi.c sleep_mpi_31a 31 8)
# add_mpi_test(sleep_arg_mpi.c sleep_mpi_32a 32 8)
# add_mpi_test(sleep_arg_mpi.c sleep_mpi_33a 33 8)
# add_mpi_test(sleep_arg_mpi.c sleep_mpi_34a 34 8)
# add_mpi_test(sleep_arg_mpi.c sleep_mpi_35a 35 8)
# add_mpi_test(sleep_arg_mpi.c sleep_mpi_36a 36 8)
