################################################################################
# Filename         # download.sh
# Purpose          # Downloads source components required for TAMP toolchain
# Description      # Used by build-tools.sh (not run directly)
# Copyright        # Luke A. Guest, David Rees Copyright (C) 2011
################################################################################
#!/bin/bash

source ./errors.inc

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

# function apply_gcc_patches()
# {
#     if [ ! -f .patched ]
#     then
# 	PATCHES="gnattools.patch gnattools2.patch gnatlib.patch gnatlib2.patch"

# 	echo "  >> Applying gcc patches..."
# 	for p in $PATCHES
# 	do
# 	    patch -p1 < ../../patches/gcc-4.6/$p

# 	    check_error_exit
# 	done
#     fi
# }

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
echo "Downloading required source packages, this may take a while..."

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
    wget -c $BINUTILS_MIRROR/binutils-$BINUTILS_VERSION.tar.bz2

    check_error_exit
else
    echo "  >> Already have binutils-$BINUTILS_VERSION"
fi

if [ $GCC_FROM_REPO != "yes" ]
then
    if [ ! -f gcc-core-$GCC_VERSION.tar.bz2 ]
    then
	echo "  >> Downloading GCC-core-$GCC_VERSION..."
	wget -c $GCC_MIRROR/gcc-core-$GCC_VERSION.tar.bz2

	check_error_exit
    else
	echo "  >> Already have GCC-core-$GCC_VERSION"
    fi

    if [ ! -f gcc-ada-$GCC_VERSION.tar.bz2 ]
    then
	echo "  >> Downloading GCC-ada-$GCC_VERSION..."
	wget -c $GCC_MIRROR/gcc-ada-$GCC_VERSION.tar.bz2

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
	wget -c $GCC_MIRROR/gcc-testsuite-$GCC_VERSION.tar.bz2

	check_error_exit
    else
	echo "  >> Already have GCC-testsuite-$GCC_VERSION"
    fi
fi

if [ ! -f gmp-$GMP_VERSION.tar.gz ]
then
    echo "  >> Downloading gmp-$GMP_VERSION..."
    wget -c $GMP_MIRROR/gmp-$GMP_VERSION.tar.gz

    check_error_exit
else
    echo "  >> Already have gmp-$GMP_VERSION"
fi

if [ ! -f mpfr-$MPFR_VERSION.tar.bz2 ]
then
    echo "  >> Downloading mpfr-$MPFR_VERSION..."
    wget -c $MPFR_MIRROR/mpfr-$MPFR_VERSION.tar.bz2

    check_error_exit
else
    echo "  >> Already have mpfr-$MPFR_VERSION"
fi

if [ ! -f mpc-$MPC_VERSION.tar.gz ]
then
    echo "  >> Downloading mpc-$MPC_VERSION..."
    wget -c $MPC_MIRROR/mpc-$MPC_VERSION.tar.gz

    check_error_exit
else
    echo "  >> Already have mpc-$MPC_VERSION"
fi

if [ ! -f newlib-$NEWLIB_VERSION.tar.gz ]
then
    echo "  >> newlib-$NEWLIB_VERSION.tar.gz..."
    wget -c $NEWLIB_MIRROR/newlib-$NEWLIB_VERSION.tar.gz

    check_error_exit
else
    echo "  >> Already have newlib-$NEWLIB_VERSION.tar.gz"
fi

# if [ ! -f ppl-$PPL_VERSION.tar.gz ]
# then
#     echo "  >> ppl-$PPL_VERSION.tar.gz..."
#     wget -c $PPL_MIRROR/ppl-$PPL_VERSION.tar.gz

#     check_error_exit
# else
#     echo "  >> Already have ppl-$PPL_VERSION.tar.gz"
# fi

# if [ ! -f cloog-ppl-$CLOOG_PPL_VERSION.tar.gz ]
# then
#     echo "  >> cloog-ppl-$CLOOG_PPL_VERSION.tar.gz..."
#     wget -c $CLOOG_PPL_MIRROR/cloog-ppl-$CLOOG_PPL_VERSION.tar.gz

#     check_error_exit
# else
#     echo "  >> Already have cloog-ppl-$CLOOG_PPL_VERSION.tar.gz"
# fi

# if [ ! -f u-boot-$U_BOOT_VERSION.tar.bz2 ]
# then
#     echo "  >> Downloading u-boot-$U_BOOT_VERSION.tar.bz2..."
#     wget -c $U_BOOT_MIRROR/u-boot-$U_BOOT_VERSION.tar.bz2

#     check_error_exit
# else
#     echo "  >> Already have u-boot-$U_BOOT_VERSION.tar.bz2"
# fi

cd $SRC

#################################################################################
# Unpack the downloaded archives.
#################################################################################
if [ ! -d binutils-$BINUTILS_VERSION ]
then
    echo "  >> Unpacking binutils-$BINUTILS_VERSION.tar.bz2..."
    tar -xjpf $TOP/downloads/binutils-$BINUTILS_VERSION.tar.bz2

    check_error_exit
fi

if [ ! -d gmp-$GMP_VERSION ]
then
    echo "  >> Unpacking gmp-$GMP_VERSION.tar.gz..."
    tar -xzpf $TOP/downloads/gmp-$GMP_VERSION.tar.gz

    check_error_exit
fi

if [ ! -d mpfr-$MPFR_VERSION ]
then
    echo "  >> Unpacking mpfr-$MPFR_VERSION.tar.bz2..."
    tar -xjpf $TOP/downloads/mpfr-$MPFR_VERSION.tar.bz2

    check_error_exit
fi

cd mpfr-$MPFR_VERSION

if [ ! -f .patched ]
then
    echo "  >> Downloading mpfr-$MPFR_VERSION patches..."
    wget -c $MPFR_PATCHES

    check_error_exit

    mv allpatches $TOP/patches/mpfr-$MPFR_VERSION.patch

    check_error_exit

    echo "  >> Applying mpfr-$MPFR_VERSION patches..."
    # Patch, ignoring patches already applied
    # Work silently unless an error occurs
    patch -s -N -p1 < $TOP/patches/mpfr-$MPFR_VERSION.patch

    check_error_exit
    check_error .patched
fi

cd ..

if [ ! -d mpc-$MPC_VERSION ]
then
    echo "  >> Unpacking mpc-$MPC_VERSION.tar.gz..."
    tar -xzpf $TOP/downloads/mpc-$MPC_VERSION.tar.gz

    check_error_exit
fi

if [ ! -d newlib-$NEWLIB_VERSION ]
then
    echo "  >> Unpacking newlib-$NEWLIB_VERSION.tar.gz..."
    tar -xzpf $TOP/downloads/newlib-$NEWLIB_VERSION.tar.gz

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

# This update repository stuff is breaking my build!
if [ $GCC_FROM_REPO = "yes" ]; then
    # echo "  >> Deciding whether to download, or update, the GCC source code..."
    # export GCC_REPO_REVISION=`svn info svn://gcc.gnu.org/svn/gcc/trunk | sed -ne 's/^Revision: //p'`

    if [ ! -d $GCC_DIR ]; then
	echo "  >>>> Downloading GCC source code from the SVN, this may take a while..."
        svn checkout -q $GCC_REPO gcc
        check_error_exit

	cd $GCC_DIR
        # echo $GCC_REPO_REVISION > .revision

        #Update
        # ./contrib/gcc_update --touch
	# check_error_exit

	# apply_gcc_patches
	create_gcc_symlinks
	cd $SRC
    else
    # gcc svn generated source directory exists already, see if it needs updating

	cd $GCC_DIR
        # export GCC_PREV_REVISION=`cat $GCC_DIR/.revision`

        # if [ -f $GCC_DIR/.revision ] && (( $GCC_REPO_REVISION > $GCC_PREV_REVISION )); then

        #    echo "  >>>> Updating the local GCC source revision from $GCC_PREV_REVISION to $GCC_REPO_REVISION"
        #    ./contrib/gcc_update -q
        #    echo $GCC_REPO_REVISION > .revision

        # elif [ -f $GCC_DIR/.revision ] && (( $GCC_REPO_REVISION == $GCC_PREV_REVISION )); then
        #    echo "  >>>> Local GCC source revision $GCC_PREV_REVISION is up-to-date. Skipping."

        # else
        #    echo "  >>>> Couldn't determine the local GCC status, try deleting the $GCC_DIR directory."
        # fi

        # check_error_exit
         cd $SRC
    fi
else
  #gcc not from svn repository


    if [ ! -d $GCC_DIR ]
    then
	echo "  >> Unpacking gcc-core-$GCC_VERSION.tar.bz2..."
	tar -xjpf $TOP/downloads/gcc-core-$GCC_VERSION.tar.bz2

	check_error_exit
    fi

    if [ ! -d $GCC_DIR/gcc/ada ]
    then
	echo "  >> Unpacking gcc-ada-$GCC_VERSION.tar.bz2..."
	tar -xjpf $TOP/downloads/gcc-ada-$GCC_VERSION.tar.bz2

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
	tar -xjpf $TOP/downloads/gcc-testsuite-$GCC_VERSION.tar.bz2

	check_error_exit
    fi

    cd $GCC_DIR
#    apply_gcc_patches
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
# if [ ! -d grub2 ]
# then
#     echo "  >> Downloading GRUB 2 from CVS..."
#     cvs -z3 -d:pserver:anonymous@cvs.savannah.gnu.org:/sources/grub co grub2

#     check_error_exit
# else
#     echo "  >> Already have GRUB 2 from CVS"
# fi

#################################################################################
# Download Qemu from Gitorius.
#################################################################################
# if [ ! -d qemu ]
# then
#     echo "  >> Downloading qemu from Gitorius..."
#     git clone git://gitorious.org/qemu-maemo/qemu.git

#     check_error_exit
# else
#     echo "  >> Already have qemu from Gitorius"
# fi

# cd qemu

# if [ ! -f .patched ]
# then
#     echo "  >> Applying Qemu patches..."
#     patch -p1 < $TOP/patches/qemu-nandflash.patch

#     check_error .patched
# fi

# cd $SRC

#################################################################################
# Download Qemu from Gitorius.
#################################################################################
# if [ ! -d u-boot ]
# then
#     echo "  >> Downloading u-boot from Denx..."
#     git clone git://git.denx.de/u-boot.git

#     check_error_exit

#     echo "  >> Downloading u-boot for omap3 from Denx..."
#     cd u-boot
#     git checkout --track -b omap3 origin/master

#     check_error_exit

#     cd ..
# else
#     echo "  >> Already have u-boot from Denx"
# fi

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
