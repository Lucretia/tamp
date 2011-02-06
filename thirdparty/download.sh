################################################################################
# Filename          # download.sh
# Purpose:          # Downloads source components required for TAMP toolchain
# Description:      # Used by build-tools.sh (not run directly)
# Copyright:        # Luke A. Guest, David Rees Copyright (C) 2011
################################################################################
#!/bin/bash

function check_error_exit()
{
    if [ $? != 0 ]
    then
	echo "** Error - Something went wrong!"
	exit 2;
    fi
}

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

function apply_gcc_patches()
{
    if [ ! -f .patched ]
    then
	PATCHES="gnattools.patch gnattools2.patch"

	echo "  >> Applying gcc patches..."
	for p in $PATCHES
	do
	    patch -p1 < ../../patches/gcc-4.6/$p

	    check_error_exit
	done
    fi
}

function create_gcc_symlinks()
{
    if [ ! -h gmp ]
    then
	echo "  >> Creating symbolic link from gcc source to gmp..."
	ln -s $SRC/gmp-$GMP_VERSION gmp
    fi

    if [ ! -h mpfr ]
    then
	echo "  >> Creating symbolic link from gcc source to mpfr..."
	ln -s $SRC/mpfr-$MPFR_VERSION mpfr
    fi

    if [ ! -h mpc ]
    then
	echo "  >> Creating symbolic link from gcc source to mpc..."
	ln -s $SRC/mpc-$MPC_VERSION mpc
    fi
}

# Start the script.
echo "Downloading required packages..."

DIRS="src downloads"

for d in $DIRS
do
    if [ ! -d $d ]
    then
	mkdir -p $d
    fi
done

#################################################################################
# Download the archives.
#################################################################################
cd $TOP/downloads

#check_for_spark

if [ ! -f binutils-$BINUTILS_VERSION.tar.bz2 ]
then
    echo "  >> Downloading binutils-$BINUTILS_VERSION..."
    wget $BINUTILS_MIRROR/binutils-$BINUTILS_VERSION.tar.bz2

    check_error_exit
else
    echo "  >> Already have binutils-$BINUTILS_VERSION"
fi

if [ $GCC_FROM_REPO != "yes" ]
then
    if [ ! -f gcc-core-$GCC_VERSION.tar.bz2 ]
    then
	echo "  >> Downloading GCC-core-$GCC_VERSION..."
	wget $GCC_MIRROR/gcc-core-$GCC_VERSION.tar.bz2

	check_error_exit
    else
	echo "  >> Already have GCC-core-$GCC_VERSION"
    fi

    if [ ! -f gcc-ada-$GCC_VERSION.tar.bz2 ]
    then
	echo "  >> Downloading GCC-ada-$GCC_VERSION..."
	wget $GCC_MIRROR/gcc-ada-$GCC_VERSION.tar.bz2

	check_error_exit
    else
	echo "  >> Already have GCC-ada-$GCC_VERSION"
    fi

# if [ ! -f gcc-g++-$GCC_VERSION.tar.bz2 ]
# then
#     echo "  >> Downloading GCC-g++-$GCC_VERSION..."
#     wget $GCC_MIRROR/gcc-g++-$GCC_VERSION.tar.bz2

#     check_error_exit
# else
#     echo "  >> Already have GCC-g++-$GCC_VERSION"
# fi

    if [ ! -f gcc-testsuite-$GCC_VERSION.tar.bz2 ]
    then
	echo "  >> Downloading GCC-testsuite-$GCC_VERSION..."
	wget $GCC_MIRROR/gcc-testsuite-$GCC_VERSION.tar.bz2

	check_error_exit
    else
	echo "  >> Already have GCC-testsuite-$GCC_VERSION"
    fi
fi

if [ ! -f gmp-$GMP_VERSION.tar.gz ]
then
    echo "  >> Downloading gmp-$GMP_VERSION..."
    wget $GMP_MIRROR/gmp-$GMP_VERSION.tar.gz

    check_error_exit
else
    echo "  >> Already have gmp-$GMP_VERSION"
fi

if [ ! -f mpfr-$MPFR_VERSION.tar.bz2 ]
then
    echo "  >> Downloading mpfr-$MPFR_VERSION..."
    wget $MPFR_MIRROR/mpfr-$MPFR_VERSION.tar.bz2

    echo "  >> Downloading mpfr-$MPFR_VERSION patches..."
    wget $MPFR_PATCHES
    mv allpatches ../patches/mpfr-$MPFR_VERSION-allpatches.patch

    check_error_exit
else
    echo "  >> Already have mpfr-$MPFR_VERSION"
fi

if [ ! -f mpc-$MPC_VERSION.tar.gz ]
then
    echo "  >> Downloading mpc-$MPC_VERSION..."
    wget $MPC_MIRROR/mpc-$MPC_VERSION.tar.gz

    check_error_exit
else
    echo "  >> Already have mpc-$MPC_VERSION"
fi

if [ ! -f newlib-$NEWLIB_VERSION.tar.gz ]
then
    echo "  >> newlib-$NEWLIB_VERSION.tar.gz..."
    wget $NEWLIB_MIRROR/newlib-$NEWLIB_VERSION.tar.gz

    check_error_exit
else
    echo "  >> Already have newlib-$NEWLIB_VERSION.tar.gz"
fi

# if [ ! -f ppl-$PPL_VERSION.tar.gz ]
# then
#     echo "  >> ppl-$PPL_VERSION.tar.gz..."
#     wget $PPL_MIRROR/ppl-$PPL_VERSION.tar.gz

#     check_error_exit
# else
#     echo "  >> Already have ppl-$PPL_VERSION.tar.gz"
# fi

# if [ ! -f cloog-ppl-$CLOOG_PPL_VERSION.tar.gz ]
# then
#     echo "  >> cloog-ppl-$CLOOG_PPL_VERSION.tar.gz..."
#     wget $CLOOG_PPL_MIRROR/cloog-ppl-$CLOOG_PPL_VERSION.tar.gz

#     check_error_exit
# else
#     echo "  >> Already have cloog-ppl-$CLOOG_PPL_VERSION.tar.gz"
# fi

# if [ ! -f u-boot-$U_BOOT_VERSION.tar.bz2 ]
# then
#     echo "  >> Downloading u-boot-$U_BOOT_VERSION.tar.bz2..."
#     wget $U_BOOT_MIRROR/u-boot-$U_BOOT_VERSION.tar.bz2

#     check_error_exit
# else
#     echo "  >> Already have u-boot-$U_BOOT_VERSION.tar.bz2"
# fi

# TODO: Download and apply patches to other packages.
# mpfr: patch -N -Z -p1 < allpatches

cd $SRC

#################################################################################
# Unpack the downloaded archives.
#################################################################################
if [ ! -d binutils-$BINUTILS_VERSION ]
then
    echo "  >> Unpacking binutils-$BINUTILS_VERSION.tar.bz2..."
    tar -xjpf ../downloads/binutils-$BINUTILS_VERSION.tar.bz2

    check_error_exit
fi

if [ ! -d gmp-$GMP_VERSION ]
then
    echo "  >> Unpacking gmp-$GMP_VERSION.tar.gz..."
    tar -xzpf ../downloads/gmp-$GMP_VERSION.tar.gz

    check_error_exit
fi

if [ ! -d mpfr-$MPFR_VERSION ]
then
    echo "  >> Unpacking mpfr-$MPFR_VERSION.tar.bz2..."
    tar -xjpf ../downloads/mpfr-$MPFR_VERSION.tar.bz2

    check_error_exit
fi

cd mpfr-$MPFR_VERSION

if [ ! -f .patched ]
then
    echo "  >> Applying mpfr patches..."
    patch -N -Z -p1 < ../../patches/mpfr-$MPFR_VERSION-allpatches.patch

    check_error_exit
    check_error .patched
fi

cd ..

if [ ! -d mpc-$MPC_VERSION ]
then
    echo "  >> Unpacking mpc-$MPC_VERSION.tar.gz..."
    tar -xzpf ../downloads/mpc-$MPC_VERSION.tar.gz

    check_error_exit
fi

if [ ! -d newlib-$NEWLIB_VERSION ]
then
    echo "  >> Unpacking newlib-$NEWLIB_VERSION.tar.gz..."
    tar -xzpf ../downloads/newlib-$NEWLIB_VERSION.tar.gz

    check_error_exit
fi

# if [ ! -d ppl-$PPL_VERSION ]
# then
#     echo "  >> Unpacking ppl-$PPL_VERSION.tar.gz..."
#     tar -xzpf ../downloads/ppl-$PPL_VERSION.tar.gz

#     check_error_exit
# fi

# if [ ! -d cloog-ppl-$CLOOG_PPL_VERSION ]
# then
#     echo "  >> Unpacking cloog-ppl-$CLOOG_PPL_VERSION.tar.gz..."
#     tar -xzpf ../downloads/cloog-ppl-$CLOOG_PPL_VERSION.tar.gz

#     check_error_exit

#     cd cloog-ppl-$CLOOG_PPL_VERSION
#     ./autogen.sh

#     check_error_exit
# fi

if [ $GCC_FROM_REPO = "yes" ]
then
    if [ ! -d $GCC_DIR ]
    then
	echo "  >> Downloading GCC from SVN..."
	svn checkout -q $GCC_REPO gcc

	check_error_exit

	cd $GCC_DIR
	svn update -q

	check_error_exit

	apply_gcc_patches
	create_gcc_symlinks
	cd $SRC
    fi
else
    if [ ! -d $GCC_DIR ]
    then
	echo "  >> Unpacking gcc-core-$GCC_VERSION.tar.bz2..."
	tar -xjpf ../downloads/gcc-core-$GCC_VERSION.tar.bz2

	check_error_exit
    fi

    if [ ! -d $GCC_DIR/gcc/ada ]
    then
	echo "  >> Unpacking gcc-ada-$GCC_VERSION.tar.bz2..."
	tar -xjpf ../downloads/gcc-ada-$GCC_VERSION.tar.bz2

	check_error_exit
    fi

# if [ ! -d gcc-$GCC_VERSION/gcc/cp ]
# then
#     echo "  >> Unpacking gcc-g++-$GCC_VERSION.tar.bz2..."
#     tar -xjpf ../downloads/gcc-g++-$GCC_VERSION.tar.bz2

#     check_error_exit
# fi

    if [ ! -d $GCC_DIR/gcc/testsuite ]
    then
	echo "  >> Unpacking gcc-testsuite-$GCC_VERSION.tar.bz2..."
	tar -xjpf ../downloads/gcc-testsuite-$GCC_VERSION.tar.bz2

	check_error_exit
    fi

    cd $GCC_DIR
    apply_gcc_patches
    create_gcc_symlinks
    cd $SRC
fi

# if [ ! -d u-boot-$U_BOOT_VERSION ]
# then
#     echo "  >> Unpacking u-boot-$U_BOOT_VERSION.tar.bz2..."
#     tar -xjpf ../downloads/u-boot-$U_BOOT_VERSION.tar.bz2
# fi

#################################################################################
# Download GRUB from CVS.
#################################################################################
if [ ! -d grub2 ]
then
    echo "  >> Downloading GRUB 2 from CVS..."
    cvs -z3 -d:pserver:anonymous@cvs.savannah.gnu.org:/sources/grub co grub2

    check_error_exit
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

    check_error_exit
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

cd $SRC

#################################################################################
# Download Qemu from Gitorius.
#################################################################################
if [ ! -d u-boot ]
then
    #echo "  >> Downloading u-boot from Denx..."
    # git clone git://git.denx.de/u-boot.git

    # check_error_exit

    #echo "  >> Downloading u-boot for omap3 from Denx..."
    #cd u-boot
    # git checkout --track -b omap3 origin/master

    # check_error_exit

    #cd ..
else
    echo "  >> Already have u-boot from Denx"
fi

#################################################################################
# Download Cloog.
#################################################################################
# if [ ! -d cloog ]
# then
#     echo "  >> Downloading cloog..."
#     git clone git://repo.or.cz/cloog.git

#     check_error_exit

#     cd cloog
#     ./get_submodules.sh
#     ./autogen.sh

#     check_error_exit

#     cd ..
# else
#     echo "  >> Already have cloog"
# fi

#################################################################################
# Download PPL.
#################################################################################
# if [ ! -d ppl ]
# then
#     echo "  >> Downloading ppl..."
#     git clone git://git.cs.unipr.it/ppl/ppl.git

#     check_error_exit

#     cd ppl
#     autoreconf

#     check_error_exit

#     cd ..
# else
#     echo "  >> Already have ppl"
# fi

# Get back to the src directory.
cd $SRC
