This repository contains the Spack configuration required to compile vis
on Frontier as well as scripts to enable the configuration and compile the
code. This repository also has submodules for Spack itself and the E4S
configuration of Spack. Thus, when you check out this repository, you need
to initialize and update the submodules.

``` bash
git clone https://github.com/kmorel/vtkm-frontier-scripts.git
cd vtkm-frontier-scripts
git submodule update --depth=100 --init
```

To set up and load the Spack environment, simply source the
`setup-spack.sh` script.

``` sh
. ./setup-spack.sh
```

To compile, for example, VTK-m, run the `make-vtkm.sh` script.

``` bash
make-vtkm.sh
```

You do not have to source `setup-spack.sh` before running `make-vtkm.sh`,
but you will have to source it before using it. You can load VTK-m into
your environment with

``` bash
spack load vtk-m
```

### Caveats when using the VTK-m Spack module

There are a few caveats to note when using this Spack module on Frontier.
The first is that when you link in a VTK-m library via CMake to your own
code, the package adds the compiler flag `--offload-arch=gfx90a` even when
you do not need it. This flag is only supported on the AMD compilers, so
when configuring your code, make sure you select the AMD compiler. This
must be done the first time you run the `cmake` command.

``` bash
CXX=amdclang cmake #... CMake arguments
```

The second note is that when you link an executable, the rpath to the
`libamdhip64.so` library is not set up, so you have to point to it with the
`LD_LIBRARY_PATH` environment variable. A good way to set this up is to
load the `rocm` system module on Frontier.

``` bash
module load rocm
```
