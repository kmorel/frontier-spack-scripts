#!/bin/bash

set -e

pv_version=master

scriptdir=$(dirname $(realpath $0))

. $scriptdir/setup-spack.sh

spack concretize -f
# Need to specifically add automake 1.16 to prevent errors from the automat 1.15
# installed on frontier.
spack install --add automake@1.16
spack install --add --keep-stage \
  paraview@$pv_version+raytracing+python+mpi+adios2+fides+visitbridge+rocm amdgpu_target=gfx90a \
  ^gcc@13.3.1 \
  ^mgard+rocm~openmp amdgpu_target=gfx90a \
  ^adios2@master+rocm+mgard amdgpu_target=gfx90a

# ParaView indirectly depends on lua, and this overrides the lua
# that srun uses. srun needs the luaposix library, so load that,
# too. This is done easiest with lua's own package manager, luarocks.
spack load paraview
luarocks install luaposix

# Make a custom server configuration that points to this build.

# This works best if this build directory has the date in it.
build_name=frontier-$(basename $scriptdir)-$pv_version
pvsc_file=$scriptdir/$build_name.pvsc

cp -f $scriptdir/pvsc/ORNL/ORNL-frontier.pvsc $pvsc_file

sed -i "s/ORNL frontier/$build_name/" $pvsc_file
sed -i "s|/sw/frontier/paraview/pvsc|$scriptdir/pvsc|" $pvsc_file
