#!/bin/bash

scriptdir=$(dirname $(realpath $0))

. $scriptdir/setup-spack.sh

spack concretize -f
spack install --add --keep-stage mgard+rocm~openmp amdgpu_target=gfx90a
