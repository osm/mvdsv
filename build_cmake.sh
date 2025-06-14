#!/usr/bin/env bash

# Useful if you willing to stop on first error, also prints what is executed.
#set -ex

BUILDDIR="${BUILDDIR:-build}" # Default build dir.

# Define target platforms, feel free to comment out if you does not require some of it,
# or you can call this script with plaforms list you willing to build on the command line.
DEFAULT_PLATFORMS=(
	freebsd-amd64
	linux-amd64
	linux-arm64
	linux-armhf
	openbsd-amd64
	windows-amd64
)
PLATFORMS=("${@:-${DEFAULT_PLATFORMS[@]}}")


# If V variable is not empty then provide -v argument to cmake --build command (verbose output).
V="${V:-}"
[ ! -z ${V} ] && V="-v"

# Overwrite build type with B variable.
B="${B:-Release}"
[ ! -z ${B} ] && BUILD="-DCMAKE_BUILD_TYPE=${B}"

# The maximum number of concurrent processes to use when building.
export CMAKE_BUILD_PARALLEL_LEVEL="${CMAKE_BUILD_PARALLEL_LEVEL:-8}"

# Use specified (with G variable) CMake generator or use default generator (most of the time its make) or ninja if found.
G="${G:-}"
[ -z "${G}" ] && hash ninja >/dev/null 2>&1 && G="Ninja"
[ ! -z "${G}" ] && export CMAKE_GENERATOR="${G}"

rm -rf ${BUILDDIR}
mkdir -p ${BUILDDIR}

# Build platforms one by one.
for name in "${PLATFORMS[@]}"; do
	P="${BUILDDIR}/$name"
	S="${PWD}"
	mkdir -p "${P}"
	case "${name}" in
	* ) # Build native library.
		pushd "${P}"
		cmake ${BUILD} -DCMAKE_TOOLCHAIN_FILE="tools/cross-cmake/${name}.cmake" "${S}"
		cmake --build . ${V}
		popd
	;;
	esac
done
