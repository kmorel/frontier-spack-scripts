#!/bin/bash

scriptdir=$(dirname $(realpath $0))

. $scriptdir/setup-spack.sh

spack add mgard@git.master=develop+rocm~openmp amdgpu_target=gfx90a
spack concretize -f
spack install
