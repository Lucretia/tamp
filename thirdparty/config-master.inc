################################################################################
# Filename          # config-master.inc
# Purpose           # Defines the Toolchain source versions/mirrors
# Copyright         # Copyright (C) 2011 Luke A. Guest, David Rees,
# Depends           # http://gcc.gnu.org/install/prerequisites.html
# Description       # 1) cp config-master.inc config.inc
#                   # 2) edit config.inc as required for your machine.
#                   # 3) ./build-tools.sh --help
################################################################################

export TOP=`pwd`
export SRC=$TOP/src
export LOG=$TOP/build/logs
export BLD=$TOP/build

################################################################################
# Is the host machine 64 bit? Used for LD_LIBRARY_PATH, leave blank for 32.
################################################################################
export BITS=64

################################################################################
# Installation directory
################################################################################
export INSTALL_DIR=$HOME/opt/gnat

################################################################################
# Parallel Make Threads/Jobs
################################################################################
# How many 'make' threads do you want to have going during the build?
# In most cases using a value greater than the number of processors
# in your machine will result in fewer and shorter I/O latency hits,
# thus improving overall throughput; this is especially true for
# slow drives and network filesystems.
# Load-average Threshold tells 'make' to spawn new jobs only when the load
# average is less than or equal to it's value. If the load average becomes
# greater, 'make' will wait until the average drops below this number,
# or until all the other jobs finish. Use only one of the options;
# Static Jobs, Scaled Jobs, or Dynamic or Static Load-average Threshold.
################################################################################
CORES=`grep 'model name' /proc/cpuinfo | wc -l`

# Static Jobs
# 1 = No Parallel Make Jobs (slow)
#export JOBS="-j 1"

# Scaled Jobs, 2 jobs per cpu core (fast)
export JOBS="-j $(($CORES*2))"

# Dynamic Load-average Threshold (slow, but can reduce cpu hammering)
# Spawn parallel processes only at < 100% core utilization
#export JOBS=--load-average=$(echo "scale=2; $CORES*100/100" | bc)

# Static Load-average Threshold
#export JOBS=--load-average=3.5


# Edit package versions/mirrors as required.

################################################################################
# BINUTILS #####################################################################
################################################################################

export BINUTILS_SNAPSHOT=n

if [ $BINUTILS_SNAPSHOT == "y" ]; then
	# Snapshot
	export BINUTILS_VERSION=2.22.51 # filename version
	BINUTILS_SRC_VERSION=2.22.51 # extracted version
	BINUTILS_TARBALL=ftp://sourceware.org/pub/binutils/snapshots/binutils-$BINUTILS_VERSION.tar.bz2
else
	# Release
	export BINUTILS_VERSION=2.21.1a # filename version
	BINUTILS_SRC_VERSION=2.21.1 # extracted version
	export BINUTILS_MIRROR=http://ftp.gnu.org/gnu/binutils
	BINUTILS_TARBALL=$BINUTILS_MIRROR/binutils-$BINUTILS_VERSION.tar.bz2
fi

export BINUTILS_TARBALL
export BINUTILS_SRC_VERSION

################################################################################
# GDB ##########################################################################
################################################################################
export GDB_VERSION=7.3a # filename version
export GDB_SRC_VERSION=7.3 # extracted version
export GDB_MIRROR=http://ftp.gnu.org/gnu/gdb
export GDB_TARBALL=$GDB_MIRROR/gdb-$GDB_VERSION.tar.bz2

################################################################################
# GCC ##########################################################################
################################################################################

	# OPTION: 'yes' to use svn (overrides GCC_SRC_TYPE)
	export GCC_FROM_REPO=y

	# OPTION: 'release' or 'snapshot' tarballs if not using svn
	export GCC_SRC_TYPE=release

	export NATIVE_LANGUAGES="c,c++,ada"


if [ $GCC_FROM_REPO == "y" ]; then

	# GCC Trunk
	# http://gcc.gnu.org/git/?p=gcc.git;a=shortlog;h=refs/heads/trunk
	export GCC_REPO=svn://gcc.gnu.org/svn/gcc/trunk

	# GCC-4_6-Branch
	# http://gcc.gnu.org/git/?p=gcc.git;a=shortlog;h=refs/heads/gcc-4_6-branch
	#export GCC_REPO=svn://gcc.gnu.org/svn/gcc/branches/gcc-4_6-branch

	# OPTION: 4_6-branch, or trunk
	export GCC_VERSION="trunk"

	export EXTRA_NATIVE_GCC_CONFIGURE_FLAGS="--with-gmp=$INSTALL_DIR --with-ppl=$INSTALL_DIR --with-cloog=$INSTALL_DIR"

	export GCC_DIR=$SRC/gcc-$GCC_VERSION

else

	if [ $GCC_SRC_TYPE == "release" ]; then
		# Release Version
		# git-svn-id: svn+ssh://gcc.gnu.org/svn/gcc/branches/gcc-4_6-branch@175472
		# 138bc75d-0d04-0410-961f-82ee72b054a4
		GCC_VERSION=4.6.1
		GCC_MIRROR=ftp://ftp.mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-$GCC_VERSION
	elif [ $GCC_SRC_TYPE == "snapshot" ]; then
		# Snapshot Version
		GCC_VERSION=4.6-20110930
		GCC_MIRROR=ftp://gcc.gnu.org/pub/gcc/snapshots/$GCC_VERSION
	fi

	export $EXTRA_NATIVE_GCC_CONFIGURE_FLAGS="--without-ppl --without-cloog"
	export GCC_VERSION
	export GCC_MIRROR
	export GCC_DIR=$SRC/gcc-$GCC_VERSION
fi

################################################################################
# Additional Options
################################################################################

# export U_BOOT_VERSION=1.3.4
export NEWLIB_VERSION=1.19.0
export PPL_VERSION=0.11.2
export CLOOG_PPL_VERSION=0.15.11

# GNU Multiple Precision Arithmetic Library
export GMP_VERSION=5.0.1

# Multiple Precision Floating Point Computations With Correct Rounding
export MPFR_VERSION=3.0.1

export MPC_VERSION=0.8.2

export BINUTILS_MIRROR=http://ftp.gnu.org/gnu/binutils
export GMP_MIRROR=ftp://ftp.gmplib.org/pub/gmp-$GMP_VERSION
export MPFR_MIRROR=http://www.mpfr.org/mpfr-$MPFR_VERSION
export MPFR_PATCHES=http://www.mpfr.org/mpfr-$MPFR_VERSION/allpatches
export MPC_MIRROR=http://www.multiprecision.org/mpc/download
# export U_BOOT_MIRROR=ftp://ftp.denx.de/pub/u-boot
export NEWLIB_MIRROR=ftp://sources.redhat.com/pub/newlib
# export PPL_MIRROR=ftp://gcc.gnu.org/pub/gcc/infrastructure
export PPL_MIRROR=ftp://ftp.cs.unipr.it/pub/ppl/releases/$PPL_VERSION
export CLOOG_PPL_MIRROR=ftp://gcc.gnu.org/pub/gcc/infrastructure
# export SPARK_FILE=spark-gpl-2011-x86_64-pc-linux-gnu.tar.gz

export STLINK_MIRROR=git://github.com/texane/stlink.git

################################################################################
# Implementation specific tuning
################################################################################

# Versions of the GNU C library up to and including 2.11.1 included an incorrect
# implementation of the cproj function. GCC optimizes its builtin cproj according
# to the behavior specified and allowed by the ISO C99 standard. If you want to
# avoid discrepancies between the C library and GCC's builtin transformations
# when using cproj in your code, use GLIBC 2.12 or later. If you are using an
# older GLIBC and actually rely on the incorrect behavior of cproj, then you can
# disable GCC's transformations using -fno-builtin-cproj.

#export EXTRA_NATIVE_CFLAGS="-mtune="

################################################################################
# GMP, MPFR, MPC static lib installation directory
################################################################################
# export STAGE1_LIBS_PREFIX=$STAGE1_PREFIX/opt/libs
# export STAGE2_LIBS_PREFIX=$STAGE2_PREFIX/opt/libs
