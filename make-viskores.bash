#!/bin/bash

scriptdir=$(dirname $(realpath $0))

. $scriptdir/setup-spack.sh

#spack concretize -f
spack install --add viskores @1.1+rocm~openmp+examples+kokkos+tbb amdgpu_target=gfx90a
