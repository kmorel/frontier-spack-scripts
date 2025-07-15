#!/bin/bash

scriptdir=$(dirname $(realpath $0))

. $scriptdir/setup-spack.sh

#spack concretize -f
spack install --add viskores @1.0.0+rocm~openmp+examples+kokkos+tbb amdgpu_target=gfx90a
