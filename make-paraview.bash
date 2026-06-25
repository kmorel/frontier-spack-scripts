#!/bin/bash
#SBATCH -A CSC143
#SBATCH -J pv-compile
#SBATCH -o %x-%j.log
#SBATCH -N 1
#SBATCH -t 02:00:00
#SBATCH -p batch
#SBATCH -q normal
#SBATCH --threads-per-core=1
#SBATCH --mail-user=morelandkd@ornl.gov
#SBATCH --mail-type=ALL

set -e

pv_version=6.1.0

use_queue=false

usage() {
  echo "Usage: $0 [-q|--queue]"
}

while [ $# -gt 0 ] ; do
  case "$1" in
    -q|--queue)
      use_queue=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

if [ -n "$SLURM_JOB_ID" ] ; then
  echo "Running in batch job."
  in_batch=true
  scriptdir=${SLURM_SUBMIT_DIR}
else
  in_batch=false
  scriptdir=$(dirname $(realpath $0))
fi

cd ${scriptdir}

. $scriptdir/setup-spack.sh

# We should not need makeinfo or automake, but sometimes mistakes in file
# modification times causes builds to use them. Add these to the path.
package_dir=/ccs/home/kmorel/local/frontier/packages
export PATH=$PATH:$package_dir/texinfo-7.2/bin
export PATH=$PATH:$package_dir/automake-1.16.5/bin
export PATH=$PATH:$package_dir/automake-1.17/bin
export PATH=$PATH:$package_dir/automake-1.18.1/bin

# Need to specifically add autoconf to prevent errors from reconfigured stuff
# installed on frontier.
spack add autoconf
spack install autoconf
spack load autoconf

spack add \
  paraview@$pv_version+raytracing~x~qt+python+mpi+adios2+fides+visitbridge+rocm amdgpu_target=gfx90a \
  ^ospray~volumes \
  ^hwloc~gl \
  ^viskores~openmp \
  ^mgard@git.master+rocm~openmp amdgpu_target=gfx90a \
  ^adios2@master+rocm+mgard+campaign+sodium amdgpu_target=gfx90a

mirrordir=${scriptdir}/spack-mirror
spack concretize
if [ "$in_batch" = false ] ; then
  spack mirror create -d ${mirrordir} -a
fi

if [ "$use_queue" = true ] ; then
  echo "Queuing build job"
  sbatch $0
  exit 0
fi

# spack mirror add local file://${mirrordir} # Should already be added.
# spack install --keep-stage
if [ "$in_batch" = true ] ; then
  echo "Running spack install on compute node."
  srun -n 1 -c 56 spack install
else
  echo "Running spack install locally."
  spack install
fi

# ParaView indirectly depends on lua, and this overrides the lua
# that srun uses. srun needs the luaposix library, so load that,
# too. This is done easiest with lua's own package manager, luarocks.
# spack load lua
# luarocks install luaposix

# Make a custom server configuration that points to this build.

# This works best if this build directory has the date in it.
build_name=frontier-$(basename $scriptdir)-$pv_version
pvsc_file=$scriptdir/$build_name.pvsc

# Create standard pvsc file to connect to this build.
cp -f $scriptdir/pvsc/ORNL/ORNL-frontier.pvsc $pvsc_file
sed -i "s/ORNL frontier/$build_name/" $pvsc_file
sed -i "s|/sw/frontier/paraview/pvsc|$scriptdir/pvsc|" $pvsc_file

# GE's security does not allow DNS lookup to the frontier hostname from their
# internal network on a Linux machine. Instead, they have to connect directly to
# an IP. Weirdly, the IP address they connect to is different from other
# networks. (They must be going through a proxy.)
pvsc_file_ge=${scriptdir}/${build_name}-ge-linux.pvsc
cp -f ${pvsc_file} ${pvsc_file_ge}
sed -i "s/${build_name}/${build_name}-ge-linux/" ${pvsc_file_ge}
sed -i "s/frontier.olcf.ornl.gov/10.75.33.123/" ${pvsc_file_ge}
