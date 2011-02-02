#!/bin/bash

# These mirrors can be changed to your local mirror if necessary.
BINUTILS_MIRROR=http://ftp.gnu.org/gnu/binutils
GCC_MIRROR=ftp://ftp.mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-$GCC_VERSION
GMP_MIRROR=ftp://ftp.gmplib.org/pub/gmp-$GMP_VERSION
MPFR_MIRROR=http://www.mpfr.org/mpfr-$MPFR_VERSION
MPC_MIRROR=http://www.multiprecision.org/mpc/download
U_BOOT_MIRROR=ftp://ftp.denx.de/pub/u-boot
NEWLIB_MIRROR=ftp://sources.redhat.com/pub/newlib

SPARK_FILE=spark-gpl-2010-SMT-src.tar.gz

function check_error()
{
    if [ $? != 0 ]
    then
	echo "** Error - Something went wrong!"
	exit 2;
    else
	touch $1
    fi
}

function check_for_spark()
{
    if [ ! -f $SPARK_FILE ]
    then
	echo "** Error - Please go to http://libre.adacore.com/libre/download/" \
	    " and download " $SPARK_FILE " and place this archive in the " \
	    "downloads directory."
	exit 2;
    fi
}

# Start the script.
echo "Downloading required packages..."

if [ ! -d src ]
then
    mkdir -p src
fi

if [ ! -d downloads ]
then
    mkdir -p downloads
fi

#################################################################################
# Download the archives.
#################################################################################
cd downloads

check_for_spark

if [ ! -f binutils-$BINUTILS_VERSION.tar.bz2 ]
then
    echo "  >> Downloading binutils-$BINUTILS_VERSION..."
    wget $BINUTILS_MIRROR/binutils-$BINUTILS_VERSION.tar.bz2

    check_error
else
    echo "  >> Already have binutils-$BINUTILS_VERSION"
fi

if [ ! -f gcc-core-$GCC_VERSION.tar.bz2 ]
then
    echo "  >> Downloading GCC-core-$GCC_VERSION..."
    wget $GCC_MIRROR/gcc-core-$GCC_VERSION.tar.bz2

    check_error
else
    echo "  >> Already have GCC-core-$GCC_VERSION"
fi

if [ ! -f gcc-ada-$GCC_VERSION.tar.bz2 ]
then
    echo "  >> Downloading GCC-ada-$GCC_VERSION..."
    wget $GCC_MIRROR/gcc-ada-$GCC_VERSION.tar.bz2

    check_error
else
    echo "  >> Already have GCC-ada-$GCC_VERSION"
fi

if [ ! -f gmp-$GMP_VERSION.tar.gz ]
then
    echo "  >> Downloading gmp-$GMP_VERSION..."
    wget $GMP_MIRROR/gmp-$GMP_VERSION.tar.gz

    check_error
else
    echo "  >> Already have gmp-$GMP_VERSION"
fi

if [ ! -f mpfr-$MPFR_VERSION.tar.bz2 ]
then
    echo "  >> Downloading mpfr-$MPFR_VERSION..."
    wget $MPFR_MIRROR/mpfr-$MPFR_VERSION.tar.bz2

    check_error
else
    echo "  >> Already have mpfr-$MPFR_VERSION"
fi

if [ ! -f mpc-$MPC_VERSION.tar.gz ]
then
    echo "  >> Downloading mpc-$MPC_VERSION..."
    wget $MPC_MIRROR/mpc-$MPC_VERSION.tar.gz

    check_error
else
    echo "  >> Already have mpc-$MPC_VERSION"
fi

if [ ! -f newlib-$NEWLIB_VERSION.tar.gz ]
then
    echo "  >> newlib-$NEWLIB_VERSION.tar.gz..."
    wget $NEWLIB_MIRROR/newlib-$NEWLIB_VERSION.tar.gz

    check_error
else
    echo "  >> Already have newlib-$NEWLIB_VERSION.tar.gz"
fi

# if [ ! -f u-boot-$U_BOOT_VERSION.tar.bz2 ]
# then
#     echo "  >> Downloading u-boot-$U_BOOT_VERSION.tar.bz2..."
#     wget $U_BOOT_MIRROR/u-boot-$U_BOOT_VERSION.tar.bz2

#     check_error
# else
#     echo "  >> Already have u-boot-$U_BOOT_VERSION.tar.bz2"
# fi

cd ../src

#################################################################################
# Unpack the downloaded archives.
#################################################################################
if [ ! -d binutils-$BINUTILS_VERSION ]
then
    echo "  >> Unpacking binutils-$BINUTILS_VERSION.tar.bz2..."
    tar -xjpf ../downloads/binutils-$BINUTILS_VERSION.tar.bz2
fi

if [ ! -d gcc-$GCC_VERSION ]
then
    echo "  >> Unpacking gcc-core-$GCC_VERSION.tar.bz2..."
    tar -xjpf ../downloads/gcc-core-$GCC_VERSION.tar.bz2
fi

if [ ! -d gcc-$GCC_VERSION/gcc/ada ]
then
    echo "  >> Unpacking gcc-ada-$GCC_VERSION.tar.bz2..."
    tar -xjpf ../downloads/gcc-ada-$GCC_VERSION.tar.bz2
fi

# cd gcc-$GCC_VERSION

# if [ ! -f .patched ]
# then
#     echo "  >> Applying gcc patches..."
#     patch -p1 < ../../patches/gcc-gnattools.patch

#     check_error .patched
# fi

# cd ..

if [ ! -d gmp-$GMP_VERSION ]
then
    echo "  >> Unpacking gmp-$GMP_VERSION.tar.gz..."
    tar -xzpf ../downloads/gmp-$GMP_VERSION.tar.gz
fi

if [ ! -d mpfr-$MPFR_VERSION ]
then
    echo "  >> Unpacking mpfr-$MPFR_VERSION.tar.bz2..."
    tar -xjpf ../downloads/mpfr-$MPFR_VERSION.tar.bz2
fi

if [ ! -d mpc-$MPC_VERSION ]
then
    echo "  >> Unpacking mpc-$MPC_VERSION.tar.gz..."
    tar -xzpf ../downloads/mpc-$MPC_VERSION.tar.gz
fi

if [ ! -d newlib-$NEWLIB_VERSION ]
then
    echo "  >> Unpacking newlib-$NEWLIB_VERSION.tar.gz..."
    tar -xzpf ../downloads/newlib-$NEWLIB_VERSION.tar.gz
fi

# if [ ! -d u-boot-$U_BOOT_VERSION ]
# then
#     echo "  >> Unpacking u-boot-$U_BOOT_VERSION.tar.bz2..."
#     tar -xjpf ../downloads/u-boot-$U_BOOT_VERSION.tar.bz2
# fi

# cd gcc-$GCC_VERSION

# if [ ! -h gmp ]
# then
#     echo "  >> Creating symbolic link from gcc source to gmp..."
#     ln -s ../gmp-$GMP_VERSION gmp
# fi

# if [ ! -h mpfr ]
# then
#     echo "  >> Creating symbolic link from gcc source to mpfr..."
#     ln -s ../mpfr-$MPFR_VERSION mpfr
# fi

# if [ ! -h mpc ]
# then
#     echo "  >> Creating symbolic link from gcc source to mpc..."
#     ln -s ../mpc-$MPC_VERSION mpc
# fi
# cd ../

#################################################################################
# Download GRUB from CVS.
#################################################################################
if [ ! -d grub2 ]
then
    echo "  >> Downloading GRUB 2 from CVS..."
    cvs -z3 -d:pserver:anonymous@cvs.savannah.gnu.org:/sources/grub co grub2

    check_error
else
    echo "  >> Already have GRUB 2 from CVS"
fi

#################################################################################
# Download Qemu from Gitorius.
#################################################################################
if [ ! -d qemu ]
then
    echo "  >> Downloading qemu from Gitorius..."
    git clone git://gitorious.org/qemu-maemo/qemu.git

    check_error
else
    echo "  >> Already have qemu from Gitorius"
fi

cd qemu

if [ ! -f .patched ]
then
    echo "  >> Applying Qemu patches..."
    patch -p1 < ../../patches/qemu-nandflash.patch

    check_error .patched
fi

cd ..

#################################################################################
# Download Qemu from Gitorius.
#################################################################################
if [ ! -d u-boot ]
then
    echo "  >> Downloading u-boot from Denx..."
    git clone git://git.denx.de/u-boot.git

    check_error

    echo "  >> Downloading u-boot for omap3 from Denx..."
    cd u-boot
    git checkout --track -b omap3 origin/master

    check_error

    cd ..
else
    echo "  >> Already have u-boot from Denx"
fi

# Get back to the src directory.
cd ..
