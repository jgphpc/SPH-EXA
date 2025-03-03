#pragma once

#include <iostream>
#include "sph/particles_data.hpp"

#ifdef SPH_EXA_USE_CATALYST2
#include "catalyst_adaptor.h"
#endif

#ifdef SPH_EXA_USE_ASCENT
#include "ascent_adaptor.h"
#include <chrono>
#endif

namespace viz
{

void init_catalyst([[maybe_unused]] int argc, [[maybe_unused]] char** argv)
{
#ifdef SPH_EXA_USE_CATALYST2
    CatalystAdaptor::Initialize(argc, argv);
    std::cout << "CatalystInitialize\n";
#endif
}

template<class DataType>
void init_ascent([[maybe_unused]] DataType& d, [[maybe_unused]] long startIndex)
{
#ifdef SPH_EXA_USE_ASCENT
    AscentAdaptor::Initialize(d, startIndex);
    std::cout << "AscentInitialize\n";
#endif
}

template<class DataType>
void execute([[maybe_unused]] DataType& d, [[maybe_unused]] long startIndex, [[maybe_unused]] long endIndex)
{
#ifdef SPH_EXA_USE_CATALYST2
    CatalystAdaptor::Execute(d, startIndex, endIndex);
#endif
#ifdef SPH_EXA_USE_ASCENT
    typedef std::chrono::high_resolution_clock Clock;
    auto now_a = Clock::now();
    std::time_t now_a_time = std::chrono::system_clock::to_time_t(now_a); // now2time
    std::tm *now_a_tm = std::localtime(&now_a_time); // time2stdtime
    auto now_a_ms = std::chrono::duration_cast<std::chrono::milliseconds>(now_a.time_since_epoch()) % 1000;
    std::cout << "# ascent_t0 " << std::put_time(now_a_tm, "%Y-%m-%d %H:%M:%S")
        << "." << std::setfill('0') << std::setw(3) << now_a_ms.count() << " "; //std::endl;

    AscentAdaptor::Execute(d, startIndex, endIndex);

    now_a_time = std::chrono::system_clock::to_time_t(Clock::now()); // now2time
    now_a_tm = std::localtime(&now_a_time); // time2stdtime
    now_a_ms = std::chrono::duration_cast<std::chrono::milliseconds>(now_a.time_since_epoch()) % 1000;
    std::cout << "# ascent_t1 " << std::put_time(now_a_tm, "%Y-%m-%d %H:%M:%S")
        << "." << std::setfill('0') << std::setw(3) << now_a_ms.count() << std::endl;
#endif
}

void finalize()
{
#ifdef SPH_EXA_USE_CATALYST2
    CatalystAdaptor::Finalize();
#endif
#ifdef SPH_EXA_USE_ASCENT
    AscentAdaptor::Finalize();
#endif
}

} // namespace viz
