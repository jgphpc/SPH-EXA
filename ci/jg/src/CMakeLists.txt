cmake_minimum_required(VERSION 3.10)
# usv prgenv-gnu/26.3:v1
# cmake -B build -S src -DCMAKE_C_COMPILER=mpicc \
# "-DMPIEXEC_EXTRA_FLAGS=--reservation=uss140-shs131-nv590-staging;--gpus-per-node=4;--account=djenkssl;-t1"
# cmake --build build -j
# ctest --test-dir build -N -V # -j
# srun --gpus-per-node=4 -A djenkssl -n 10 --reservation=uss140-shs131-nv590-staging -t1 ./build/sleep_mpi_2a 2

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
    install(TARGETS ${testname} RUNTIME DESTINATION ${CMAKE_INSTALL_SBINDIR}/performance)
endfunction()

cstone_add_performance_test(sleep_arg.c sleep1a 1)
cstone_add_performance_test(sleep_arg.c sleep2a 2)
#ok cstone_add_performance_test(sleep_arg.c sleep3a 3)
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
endfunction()

add_mpi_test(sleep_arg_mpi.c sleep_mpi_1a 1 10)
add_mpi_test(sleep_arg_mpi.c sleep_mpi_2a 2 10)
add_mpi_test(sleep_arg_mpi.c sleep_mpi_3a 3 10)
