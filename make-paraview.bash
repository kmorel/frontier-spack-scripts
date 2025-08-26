#!/bin/bash

set -e

pv_version=6.0.0

scriptdir=$(dirname $(realpath $0))

. $scriptdir/setup-spack.sh

# We should not need makeinfo or automake, but sometimes mistakes in file
# modification times causes builds to use them. Add these to the path.
package_dir=/ccs/home/kmorel/local/frontier/packages
export PATH=$PATH:$package_dir/texinfo-7.2/bin
export PATH=$PATH:$package_dir/automake-1.16.5/bin
export PATH=$PATH:$package_dir/automake-1.17/bin
export PATH=$PATH:$package_dir/automake-1.18.1/bin

spack concretize -f
# Need to specifically add automake 1.16 to prevent errors from the automake 1.15
# installed on frontier.
# spack install --add automake@1.16
# spack install --add --keep-stage \
spack install --add \
  paraview@$pv_version+raytracing+python+mpi+adios2+fides+visitbridge+rocm amdgpu_target=gfx90a \
  ^ospray~volumes \
  ^mgard+rocm~openmp amdgpu_target=gfx90a \
  ^adios2@master+rocm+mgard+campaign amdgpu_target=gfx90a

# ParaView indirectly depends on lua, and this overrides the lua
# that srun uses. srun needs the luaposix library, so load that,
# too. This is done easiest with lua's own package manager, luarocks.
spack load lua
luarocks install luaposix

# Make a custom server configuration that points to this build.

# This works best if this build directory has the date in it.
build_name=frontier-$(basename $scriptdir)-$pv_version
pvsc_file=$scriptdir/$build_name.pvsc

cp -f $scriptdir/pvsc/ORNL/ORNL-frontier.pvsc $pvsc_file

sed -i "s/ORNL frontier/$build_name/" $pvsc_file
sed -i "s|/sw/frontier/paraview/pvsc|$scriptdir/pvsc|" $pvsc_file
