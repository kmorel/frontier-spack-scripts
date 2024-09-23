#!/bin/bash

scriptdir=$(dirname $(realpath $0))

. $scriptdir/setup-spack.sh

spack concretize -f
spack install --add paraview @5.13.0+raytracing+python+mpi+adios2+visitbridge+use_vtkm+rocm amdgpu_target=gfx90a
