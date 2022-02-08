#pragma once

#ifdef USE_PROFILING
#include <nvToolsExt.h>
// std::cout << "USE_PROFILING is ON\n";
#define MARK_BEGIN( x ) nvtxRangePush(x);
#define MARK_END nvtxRangePop();
#else
#define MARK_BEGIN( x )
#define MARK_END
#endif

/*
@performance_function('us', perf_key='01_init')
@performance_function('us', perf_key='02_domain.sync')
@performance_function('us', perf_key='03_updateTasks')
@performance_function('us', perf_key='04_FindNeighbors')
@performance_function('us', perf_key='05_computeDensity')
@performance_function('us', perf_key='06_EquationOfState')
@performance_function('us', perf_key='07_synchronizeHalos1')
@performance_function('us', perf_key='08_IAD')
@performance_function('us', perf_key='09_synchronizeHalos2')
@performance_function('us', perf_key='10_MomentumEnergyIAD')
@performance_function('us', perf_key='11_Timestep')
@performance_function('us', perf_key='12_UpdateQuantities')
@performance_function('us', perf_key='13_EnergyConservation')
@performance_function('us', perf_key='14_UpdateSmoothingLength')
@performance_function('us', perf_key='15_output')
@performance_function('us', perf_key='16_Finalize')
@performance_function('us', perf_key='MPI')        
*/

