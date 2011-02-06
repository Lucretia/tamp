################################################################################
# config-master.inc
# Luke A. Guest (C) 2011
#
# 1) cp config-master.inc config.inc
# 2) edit config.inc as required for your machine.
# 3) ./build-tools.sh
################################################################################

export TOP=`pwd`
export SRC=$TOP/src
export LOG=$TOP/build/logs
export BLD=$TOP/build

################################################################################
# How many jobs do you want to have going during the build?
################################################################################
export JOBS="-j 2"

################################################################################
# Edit package versions/mirrors as required.
#
# Cloog confusion: See http://patchwork.ozlabs.org/patch/80355/
################################################################################
export GCC_FROM_REPO=yes

export GMP_VERSION=5.0.1
export MPFR_VERSION=3.0.0
export MPC_VERSION=0.8.2
export BINUTILS_VERSION=2.21

if [ $GCC_FROM_REPO = "yes" ]
then
    export GCC_REPO=svn://gcc.gnu.org/svn/gcc/trunk
    export GCC_VERSION="svn-trunk"
    export GCC_DIR=$SRC/gcc
else
#    export GCC_VERSION=4.5.2
    export GCC_VERSION=4.6-20110129
    export GCC_DIR=$SRC/gcc-$GCC_VERSION

#    export GCC_MIRROR=ftp://ftp.mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-$GCC_VERSION
    export GCC_MIRROR=ftp://ftp.mirrorservice.org/sites/sourceware.org/pub/gcc/snapshots/LATEST-4.6
fi

#export U_BOOT_VERSION=1.3.4
export NEWLIB_VERSION=1.19.0
export PPL_VERSION=0.11
export CLOOG_PPL_VERSION=0.15.10

export BINUTILS_MIRROR=http://ftp.gnu.org/gnu/binutils
export GMP_MIRROR=ftp://ftp.gmplib.org/pub/gmp-$GMP_VERSION
export MPFR_MIRROR=http://www.mpfr.org/mpfr-$MPFR_VERSION
export MPC_MIRROR=http://www.multiprecision.org/mpc/download
#export U_BOOT_MIRROR=ftp://ftp.denx.de/pub/u-boot
export NEWLIB_MIRROR=ftp://sources.redhat.com/pub/newlib
export PPL_MIRROR=ftp://gcc.gnu.org/pub/gcc/infrastructure
export CLOOG_PPL_MIRROR=ftp://gcc.gnu.org/pub/gcc/infrastructure
export SPARK_FILE=spark-gpl-2010-SMT-src.tar.gz

export MPFR_PATCHES=http://www.mpfr.org/mpfr-3.0.0/allpatches

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

