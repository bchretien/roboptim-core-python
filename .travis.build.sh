#!/bin/sh
set -e

# Directories.
root_dir=`pwd`
build_dir="$root_dir/_travis/build"
install_dir="$root_dir/_travis/install"
core_dir="$build_dir/roboptim-core"

# Shortcuts.
git_clone="git clone --quiet --recursive"

# Create layout.
rm -rf "$build_dir" "$install_dir"
mkdir -p "$build_dir"
mkdir -p "$install_dir"

# Setup environment variables.
export LD_LIBRARY_PATH="$install_dir/lib:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="$install_dir/lib/$(dpkg-architecture -qDEB_BUILD_MULTIARCH):$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="$install_dir/lib/roboptim-core:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="$install_dir/lib/$(dpkg-architecture -qDEB_BUILD_MULTIARCH)/roboptim-core:$LD_LIBRARY_PATH"
export PKG_CONFIG_PATH="$install_dir/lib/pkgconfig:$PKG_CONFIG_PATH"
export PKG_CONFIG_PATH="$install_dir/lib/$(dpkg-architecture -qDEB_BUILD_MULTIARCH)/pkgconfig:$PKG_CONFIG_PATH"

pythonsite_dir=`python -c "import sys, os; print os.sep.join(['lib', 'python' + sys.version[:3], 'site-packages'])"`
export PYTHONPATH="$install_dir/$pythonsite_dir:$PYTHON_PATH"

# Checkout Eigen.
cd "$build_dir"
wget "http://bitbucket.org/eigen/eigen/get/3.2.0.tar.gz"
tar xzvf 3.2.0.tar.gz
cd "$build_dir/eigen-eigen-ffa86ffb5570/"
mkdir -p "$build_dir/eigen-eigen-ffa86ffb5570/_build"
cd "$build_dir/eigen-eigen-ffa86ffb5570/_build"
cmake .. -DCMAKE_INSTALL_PREFIX:STRING="$install_dir" \
         -Dpkg_config_libdir:STRING="$install_dir/lib/$(dpkg-architecture -qDEB_BUILD_MULTIARCH)"
make
make install

# Checkout roboptim-core
echo "Installing dependencies..."
cd "$build_dir"
$git_clone "git://github.com/roboptim/roboptim-core.git"
cd "$core_dir"
cmake . -DCMAKE_INSTALL_PREFIX:STRING="$install_dir"
make install

# Build package
echo "Building package..."
cd "$build_dir"
cmake "$root_dir" -DCMAKE_INSTALL_PREFIX="$install_dir"		\
		  -DCMAKE_CXX_FLAGS="--coverage"		\
		  -DCMAKE_EXE_LINKER_FLAGS="--coverage"		\
		  -DCMAKE_MODULE_LINKER_FLAGS="--coverage"
make
make install
$root_dir/tests/wrap.py
$root_dir/tests/function.py
make test
