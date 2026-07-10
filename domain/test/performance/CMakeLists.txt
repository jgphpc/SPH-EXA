include(cstone_add_performance_test)

cstone_add_performance_test(octree.cpp octree_perf)
cstone_add_performance_test(peers.cpp peers_perf)

set_tests_properties(octree_perf PROPERTIES LABELS "01r;cpu")
set_tests_properties(peers_perf PROPERTIES LABELS "01r;cpu")

if (CMAKE_CUDA_COMPILER)
    cstone_add_performance_test(hilbert.cpp hilbert_perf)
    set_tests_properties(hilbert_perf PROPERTIES LABELS "01r;cpu")
    target_link_libraries(hilbert_perf PRIVATE ThrustOMP)
    # link to cudart to avoid undefined reference to `cudaGetErrorString'
    target_link_libraries(hilbert_perf PRIVATE CUDA::cudart)
endif ()

if(CMAKE_CUDA_COMPILER OR CMAKE_HIP_COMPILER)
    cstone_add_cuda_performance_test(sph_density_driver.cu sph_density_test_gpu)
    cstone_add_cuda_performance_test(octree.cu octree_perf_gpu)
    cstone_add_cuda_performance_test(hilbert.cu hilbert_perf_gpu)

    set_tests_properties(sph_density_test_gpu PROPERTIES LABELS "01r;gpu")
    set_tests_properties(octree_perf_gpu PROPERTIES LABELS "01r;gpu")
    set_tests_properties(hilbert_perf_gpu PROPERTIES LABELS "01r;gpu")
endif()
