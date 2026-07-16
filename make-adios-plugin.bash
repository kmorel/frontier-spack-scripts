#!/bin/bash
#
# This script should only be run after make-paraview is run.

set -e

scriptdir=$(dirname $(realpath $0))

. ${scriptdir}/setup-spack.sh

spack load cmake ninja mgard adios2

plugin_dir=${scriptdir}/adios-plugin
mkdir -p ${plugin_dir}

centroid_operator_dir=${plugin_dir}/CompressMGARDCentroidOperator
if [ ! -d ${centroid_operator_dir} ] ; then
  cd ${plugin_dir}
  git clone https://github.com/gqian-coder/CompressMGARDCentroidOperator.git
fi

cmake \
  -G Ninja \
  -S ${centroid_operator_dir} \
  -B ${centroid_operator_dir}/build

cmake --build ${centroid_operator_dir}/build
