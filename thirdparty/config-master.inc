################################################################################
# Filename          # config-master.inc
# Purpose           # Defines the TAMP Toolchain source versions/mirrors
# Copyright         # Luke A. Guest, David Rees Copyright (C) 2011
#                   #
# Description       # 1) cp config-master.inc config.inc
#                   # 2) edit config.inc as required for your machine.
#                   # 3) ./build-tools.sh
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
# Parallel Make Threads/Jobs
#
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

################################################################################
# Edit package versions/mirrors as required.
#
# Note: Cloog confusion: See http://patchwork.ozlabs.org/patch/80355/
################################################################################
export GCC_FROM_REPO=yes
export BINUTILS_SNAPSHOT=no
export GMP_VERSION=5.0.1
export MPFR_VERSION=3.0.0
export MPC_VERSION=0.8.2
export BINUTILS_VERSION=2.21

##### BINUTILS #################################################################

if [ $BINUTILS_SNAPSHOT == "yes" ]; then
    export BINUTILS_VERSION=2.21.51
    export BINUTILS_TARBALL=ftp://sourceware.org/pub/binutils/snapshots/binutils-$BINUTILS_VERSION.tar.bz2
else
    export BINUTILS_VERSION=2.21
    export BINUTILS_MIRROR=http://ftp.gnu.org/gnu/binutils
    export BINUTILS_TARBALL=$BINUTILS_MIRROR/binutils-$BINUTILS_VERSION.tar.bz2
fi

##### GCC ######################################################################

if [ $GCC_FROM_REPO == "yes" ]; then
    export GCC_REPO=svn://gcc.gnu.org/svn/gcc/trunk
    export GCC_VERSION="svn-trunk"
    export GCC_DIR=$SRC/gcc
else
#   export GCC_VERSION=4.5.2
    export GCC_VERSION=4.6-20110212 # GCC Snapshot
    export GCC_DIR=$SRC/gcc-$GCC_VERSION

#   export GCC_MIRROR=ftp://ftp.mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-$GCC_VERSION
#   export GCC_MIRROR=ftp://ftp.mirrorservice.org/sites/sourceware.org/pub/gcc/snapshots/LATEST-4.6
#   export GCC_MIRROR=ftp://gcc.gnu.org/pub/gcc/snapshots/LATEST-4.6
    export GCC_MIRROR=ftp://gcc.gnu.org/pub/gcc/snapshots/gcc-$GCC_VERSION #GCC Snapshot
fi

# export U_BOOT_VERSION=1.3.4
export NEWLIB_VERSION=1.19.0
# export PPL_VERSION=0.11
# export CLOOG_PPL_VERSION=0.15.10

export BINUTILS_MIRROR=http://ftp.gnu.org/gnu/binutils
export GMP_MIRROR=ftp://ftp.gmplib.org/pub/gmp-$GMP_VERSION
export MPFR_MIRROR=http://www.mpfr.org/mpfr-$MPFR_VERSION
export MPFR_PATCHES=http://www.mpfr.org/mpfr-$MPFR_VERSION/allpatches
export MPC_MIRROR=http://www.multiprecision.org/mpc/download
# export U_BOOT_MIRROR=ftp://ftp.denx.de/pub/u-boot
export NEWLIB_MIRROR=ftp://sources.redhat.com/pub/newlib
# export PPL_MIRROR=ftp://gcc.gnu.org/pub/gcc/infrastructure
# export CLOOG_PPL_MIRROR=ftp://gcc.gnu.org/pub/gcc/infrastructure
# export SPARK_FILE=spark-gpl-2010-SMT-src.tar.gz
# export SPARK_FILE=spark-gpl-2010-SMT-x86_64-pc-linux-gnu.tar.gz

################################################################################
# Add any extra implementation specific tuning you want here
################################################################################

# Versions of the GNU C library up to and including 2.11.1 included an incorrect
# implementation of the cproj function. GCC optimizes its builtin cproj according
# to the behavior specified and allowed by the ISO C99 standard. If you want to
# avoid discrepancies between the C library and GCC's builtin transformations
# when using cproj in your code, use GLIBC 2.12 or later. If you are using an
# older GLIBC and actually rely on the incorrect behavior of cproj, then you can
# disable GCC's transformations using -fno-builtin-cproj.

#export EXTRA_NATIVE_CFLAGS="-fno-builtin-cproj -mtune="

################################################################################
# Installation directory
#
# Stage1 = Latest version of the compilers built with the system compilers.
# Stage2 = Latest version of the compilers built with the stage1 compilers.
# Cross  = Latest version of the cross-compilers built with the stage1 compilers.
################################################################################
export TAMP=$HOME/opt/tamp
# export STAGE1_PREFIX=$TAMP/stage1
# export STAGE2_PREFIX=$TAMP/$GCC_VERSION
# export CROSS_PREFIX=$TAMP/cross

################################################################################
# GMP, MPFR, MPC static lib installation directory
################################################################################
# export STAGE1_LIBS_PREFIX=$STAGE1_PREFIX/opt/libs
# export STAGE2_LIBS_PREFIX=$STAGE2_PREFIX/opt/libs
