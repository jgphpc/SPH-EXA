#pragma once

#ifdef USE_PROFILING_NVTX
#include <nvToolsExt.h>
// std::cout << "USE_PROFILING is ON\n";
#define MARK_BEGIN( xx ) nvtxRangePush(xx);
#define MARK_END nvtxRangePop();
#endif

#ifdef USE_PROFILING_SCOREP
#include "scorep/SCOREP_User.h"
/* scorep --user
//no SCOREP_USER_REGION_DEFINE( solve )
//no ...
//no SCOREP_USER_REGION_BEGIN( solve, "xx", SCOREP_USER_REGION_TYPE_LOOP )
//no for (i = 0; i < 100; i++) { [...] }
//no SCOREP_USER_REGION_END( solve )
# -------- or:
{SCOREP_USER_REGION( "xx", SCOREP_USER_REGION_TYPE_LOOP )    <------
for (i = 0; i < 100; i++) { [...] } 
}                                                            <------
# --------
# SCOREP_RECORDING_OFF() // must be _after_ mpi_init
# NOTE: SCOREP_RECORDING_OFF() before mpi_finalize will report
# negative values (wrong): mpi_finalize must be profiled/traced.
*/
#define MARK_BEGIN( xx ) {SCOREP_USER_REGION(xx, SCOREP_USER_REGION_TYPE_COMMON)
#define MARK_END }
// SCOREP_RECORDING_ON()
#endif

#ifndef USE_PROFILING_SCOREP
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

