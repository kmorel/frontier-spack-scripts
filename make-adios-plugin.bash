#!/bin/bash
#
# This script should only be run after make-paraview is run.

set -e

scriptdir=$(dirname $(realpath $0))

. ${scriptdir}/setup-spack.sh

spack load git cmake ninja mgard adios2

plugin_dir=${scriptdir}/adios-plugin
mkdir -p ${plugin_dir}

m2goperator_dir=${plugin_dir}/CompressMGARDMeshToGridOperator
if [ ! -d ${m2goperator_dir} ] ; then
  cd ${plugin_dir}
  git clone https://github.com/gqian-coder/CompressMGARDMeshToGridOperator.git
fi

cmake \
  -G Ninja \
  -S ${m2goperator_dir} \
  -B ${m2goperator_dir}/build

cmake --build ${m2goperator_dir}/build
