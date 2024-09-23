myspack_base_dir=`dirname $0`
myspack_base_dir=`realpath $myspack_base_dir`

export SPACK_USER_CONFIG_PATH=$myspack_base_dir/spack-configs/e4s-configs/frontier
. $myspack_base_dir/spack/share/spack/setup-env.sh

myspack_config_name=vis

# This is necessary to prevent Python errors when loading packages containing
# strings with non-ASCII characters.
LC_ALL=en_US.UTF-8

# Set up the spack config file and create an environment from it.
if spack env activate $myspack_config_name ; then
  :
else
  # The configuration in SPACK_USER_CONFIG_PATH sets up a mirror. Loading files
  # from a mirror will fail if you don't build your own keys. Build them now.
  spack buildcache keys --install --trust

  myspack_config_file=$myspack_base_dir/spack-configs/spack.yaml
  spack env create $myspack_config_name $myspack_config_file
  unset myspack_config_file
fi

spack env activate $myspack_config_name

unset myspack_base_dir
unset myspack_config_name
