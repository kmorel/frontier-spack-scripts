#!/bin/bash

set -e

pv_version=5.13.0

scriptdir=$(dirname $(realpath $0))

. $scriptdir/setup-spack.sh

spack concretize -f
spack install --add --keep-stage paraview @$pv_version+raytracing+python+mpi+adios2+visitbridge+rocm amdgpu_target=gfx90a

# Make a custom server configuration that points to this build.

# This works best if this build directory has the date in it.
build_name=frontier-$(basename $scriptdir)-$pv_version
pvsc_file=$scriptdir/$build_name.pvsc

cp -f $scriptdir/pvsc/ORNL/ORNL-frontier.pvsc $pvsc_file

sed -i "s/ORNL frontier/$build_name/" $pvsc_file
sed -i "s|/sw/frontier/paraview/pvsc|$scriptdir/pvsc|" $pvsc_file
