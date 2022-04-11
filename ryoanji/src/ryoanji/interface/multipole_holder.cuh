/*
 * MIT License
 *
 * Copyright (c) 2021 CSCS, ETH Zurich
 *               2021 University of Basel
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

/*! @file
 * @brief  Interface for calculation of multipole moments
 *
 * @author Sebastian Keller <sebastian.f.keller@gmail.com>
 */

#pragma once

#include <memory>

#include "cstone/focus/octree_focus_mpi.hpp"
#include "ryoanji/nbody/types.h"

namespace ryoanji
{

template<class Tc, class Tm, class Tf, class KeyType, class MType>
class MultipoleHolder
{
public:
    MultipoleHolder();

    ~MultipoleHolder();

    void upsweep(const Tc* x, const Tc* y, const Tc* z, const Tm* m, const cstone::Octree<KeyType>& globalOctree,
                 const cstone::FocusedOctree<KeyType, Tf>& focusTree, const cstone::LocalIndex* layout,
                 MType* multipoles);

    float compute(LocalIndex firstBody, LocalIndex lastBody, const Tc* x, const Tc* y, const Tc* z, const Tm* m,
                  const Tm* h, Tc G, Tc* ax, Tc* ay, Tc* az);

private:
    class Impl;
    std::unique_ptr<Impl> impl_;
};

//extern template class MultipoleHolder<double, double, double, SphericalMultipole<double, 4>>;
//extern template class MultipoleHolder<double, float, double, SphericalMultipole<double, 4>>;
//extern template class MultipoleHolder<double, float, double, SphericalMultipole<float, 4>>;
//extern template class MultipoleHolder<float, float, float, SphericalMultipole<float, 4>>;


} // namespace ryoanji