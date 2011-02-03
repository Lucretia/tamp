################################################################################
# config-master.inc
# Luke A. Guest (C) 2011
#
# 1) cp config-master.inc config.inc
# 2) edit config.inc as required for your machine.
# 3) ./build-tools.sh
################################################################################

################################################################################
# Installation directory
################################################################################
export PREFIX=$HOME/opt/tamp-cross

################################################################################
# GMP, MPFR, MPC static lib installation directory
################################################################################
export GCC_LIBS_PREFIX=$HOME/opt/gcc-4.5.2-maths

################################################################################
# How many jobs do you want to have going during the build?
################################################################################
export JOBS="-j 2"

################################################################################
# Edit package versions/mirrors as required.
################################################################################
export GMP_VERSION=5.0.1
export MPFR_VERSION=3.0.0
export MPC_VERSION=0.8.2
export BINUTILS_VERSION=2.21
export GCC_VERSION=4.5.2
#export U_BOOT_VERSION=1.3.4
export NEWLIB_VERSION=1.19.0

export BINUTILS_MIRROR=http://ftp.gnu.org/gnu/binutils
export GCC_MIRROR=ftp://ftp.mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-$GCC_VERSION
export GMP_MIRROR=ftp://ftp.gmplib.org/pub/gmp-$GMP_VERSION
export MPFR_MIRROR=http://www.mpfr.org/mpfr-$MPFR_VERSION
export MPC_MIRROR=http://www.multiprecision.org/mpc/download
#export U_BOOT_MIRROR=ftp://ftp.denx.de/pub/u-boot
export NEWLIB_MIRROR=ftp://sources.redhat.com/pub/newlib

export SPARK_FILE=spark-gpl-2010-SMT-src.tar.gz

export MPFR_PATCHES=http://www.mpfr.org/mpfr-3.0.0/allpatches
