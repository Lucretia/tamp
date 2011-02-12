################################################################################
# Filename          # build-tools.sh
# Purpose:          # Downloads and Builds the TAMP toolchain components
# Description:      #
# Copyright:        # Luke A. Guest, David Rees Copyright (C) 2011
################################################################################
#!/bin/bash

# TOOD:
#
# Add command line options for specifying which compiler to build and also
# whether to apply (or undo) the patches:
#   --native --arm
#
# Get rid of the STAGE1* stuff as it was only put in due to thinking we may
# need to build more than one stage of native compiler, but this is done by
# GCC anyway.

################################################################################
# Logs from various stages of the build process are placed in the build/logs
# directory and has a standardised naming, i.e.
#   [description]-[config|make|check|install].txt
################################################################################

if [ ! -f ./config.inc ]
then
    echo "Error! No config.inc"
    echo "  cp config-master.inc config.inc"
    echo ""
    echo "  Edit config.inc for your system and run this script again."

    exit 2
fi

source ./config.inc

echo "Source dir      : " $SRC
echo "Build dir       : " $BLD
echo "Log dir         : " $LOG
echo "Install dir     : " $TAMP
echo "Stage 1 dir     : " $STAGE1_PREFIX
echo "Stage 1 libs dir: " $STAGE1_LIBS_PREFIX
echo "Stage 2 dir     : " $STAGE2_PREFIX
echo "Cross dir       : " $CROSS_PREFIX
echo "Parallelism     : " $JOBS
echo "GMP Version     : " $GMP_VERSION
echo "MPFR Version    : " $MPFR_VERSION
echo "MPC Version     : " $MPC_VERSION
echo "NewLib Version  : " $NEWLIB_VERSION
echo "Binutils Version: " $BINUTILS_VERSION
echo "GCC Version     : " $GCC_VERSION
echo "GCC source dir  : " $GCC_DIR

################################################################################
# $1 = Filename to create using touch, used in successive steps to test
#      if the previous step was completed.
################################################################################
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


function apply_cross_gcc_patches()
{
    if [ $GCC_FROM_REPO = "yes" ]
    then
	cd $SRC/gcc

	if [ ! -f .patched ]
	then
	    PATCHES="gnattools.patch" \
		"gnattools2.patch" \
		"gnatlib.patch" \
		"gnatlib2.patch" \
		"gnatlib3.patch"

	    echo "  >> Applying gcc patches for cross compiler..."
	    for p in $PATCHES
	    do
		patch -p1 < $TOP/patches/gcc-4.6/$p

		check_error .patched
	    done
	fi
    else
	cd $SRC/gcc-$GCC_VERSION

	if [ ! -f .patched ]
	then
	    patch -p1 < $TOP/patches/gcc-4.5.2-cross-arm.patch

	    check_error .patched
	fi
    fi
}

################################################################################
# Build the first stage $GCC_VERSION (latest/native) compilers using the system
# compilers.
################################################################################
function build_native_toolchain()
{
    echo "Building native toolchain..."

    cd $BLD

    VER="native"
    STAGE="$VER/stage1"
    DIRS="gcc"

    echo "  >> Creating directories..."

    for d in $DIRS
    do
	if [ ! -d $STAGE/$d ]
	then
	    mkdir -p $STAGE/$d
	fi
    done

    LOGPRE=$LOG/native-stage1
    CBD=$BLD/$STAGE

    # Build the native GCC compiler.
    cd $CBD/gcc

    if [ ! -f .config ]
    then
	echo "  >> Configuring gcc..."
	# Turn off CLooG/PPL as we don't want C++.
	$GCC_DIR/configure \
	    --prefix=$TAMP \
	    --enable-multilib \
	    --enable-shared \
	    --with-gnu-as \
	    --with-gnu-ld \
	    --enable-languages=c,ada \
	    --without-ppl \
	    --without-cloog \
	    --with-system-zlib \
	    --disable-libgomp \
	    CFLAGS="-fno-builtin-cproj $EXTRA_NATIVE_CFLAGS" \
	    &> $LOGPRE-gcc-config.txt

	check_error .config
    fi

    if [ ! -f .make ]
    then
	echo "  >> Building gcc..."
	make $JOBS &> $LOGPRE-gcc-make.txt

	check_error .make
    fi

    if [ ! -f .make-install ]
    then
	echo "  >> Installing gcc..."
	make install &> $LOGPRE-gcc-install.txt

	check_error .make-install
    fi

    if [ ! -f .test-gcc ]
    then
	echo "  >> Testing gcc..."
	make -k check-gcc &> $LOGPRE-gcc-test.txt

	check_error .test-gcc
    fi

    echo "  >> done."

    # Get back to the build directory.
    cd $BLD
}

################################################################################
# $1 = Target.
# $2 = Any extra configure parameters.
################################################################################
function build_toolchain()
{
    echo "Building $1 toolchain..."

    apply_cross_gcc_patches

    cd $BLD

    VER=$1
    STAGE="$VER"
    DIRS="binutils gcc1 newlib gcc2"

    echo "  >> Creating directories..."

    for d in $DIRS
    do
	if [ ! -d $STAGE/$d ]
	then
	    mkdir -p $STAGE/$d
	fi
    done

    LOGPRE=$LOG/$1
    CBD=$BLD/$STAGE

    export PATH=$TAMP/bin:$PATH
    export LD_LIBRARY_PATH=$TAMP/lib64:$LD_LIBRARY_PATH

    # Build BinUtils.
    cd $CBD/binutils

    if [ ! -f .config ]
    then
    	echo "  >> Configuring binutils for $1..."
    	$SRC/binutils-$BINUTILS_VERSION/configure \
    	    --prefix=$TAMP \
    	    --target=$1 \
    	    $2 \
    	    --enable-multilib \
    	    --disable-nls \
    	    --disable-shared \
    	    --disable-threads \
    	    --with-gcc \
    	    --with-gnu-as \
    	    --with-gnu-ld \
	    --without-ppl \
	    --without-cloog \
	    &> $LOGPRE-binutils-config.txt

    	check_error .config
    fi

    if [ ! -f .make ]
    then
    	echo "  >> Building binutils for $1..."
    	make $JOBS &> $LOGPRE-binutils-make.txt

    	check_error .make
    fi

    if [ ! -f .make-install ]
    then
    	echo "  >> Installing binutils for $1..."
    	make install &> $LOGPRE-binutils-install.txt

    	check_error .make-install
    fi

    LAST=`pwd`

    # Build stage 2 GCC with C only.
    cd $CBD/gcc1

    if [ -f $LAST/.make-install ]
    then
	if [ ! -f .config ]
	then
	    echo "  >> Configuring gcc (C)..."
	    $GCC_DIR/configure \
		--prefix=$TAMP \
    		--target=$1 \
    		$2 \
    		--enable-multilib \
    		--with-newlib \
    		--disable-nls \
    		--disable-shared \
    		--disable-threads \
    		--disable-lto \
		--with-gnu-as \
		--with-gnu-ld \
		--enable-languages=c \
		--disable-libssp \
    		--without-headers \
		--without-ppl \
		--without-cloog \
		&> $LOGPRE-gcc1-config.txt

	    check_error .config
	fi

	if [ ! -f .make ]
	then
	    echo "  >> Building gcc (C)..."
	    # use all-gcc, otherwise libiberty fails as it requires sys/types.h
	    # which doesn't exist and tbh, shouldn't even be getting built, it's
	    # a bug which has been reported here:
	    #   http://gcc.gnu.org/bugzilla/show_bug.cgi?id=43073
	    make $JOBS all-gcc &> $LOGPRE-gcc1-make.txt

	    check_error .make
	fi

	if [ ! -f .make-install ]
	then
	    echo "  >> Installing gcc (C)..."
	    make install-gcc &> $LOGPRE-gcc1-install.txt

	    check_error .make-install
	fi
    fi

    LAST=`pwd`

    # Build NewLib
    cd $CBD/newlib

    if [ -f $LAST/.make-install ]
    then
    	if [ ! -f .config ]
    	then
    	    echo "  >> Configuring newlib for $1..."
    	    $SRC/newlib-$NEWLIB_VERSION/configure \
    		--prefix=$TAMP \
    		--target=$1 \
    		$2 \
    		--enable-multilib \
    		--with-gnu-as \
    		--with-gnu-ld \
    		--disable-nls \
		--without-ppl \
		--without-cloog \
		&> $LOGPRE-newlib-config.txt

    	    check_error .config
    	fi

    	if [ ! -f .make ]
    	then
    	    echo "  >> Building newlib for $1..."
    	    make $JOBS &> $LOGPRE-newlib-make.txt

    	    check_error .make
    	fi

    	if [ ! -f .make-install ]
    	then
    	    echo "  >> Installing newlib for $1..."
    	    make install &> $LOGPRE-newlib-install.txt

    	    check_error .make-install
    	fi
    fi

    LAST=`pwd`

    # Build stage 2 GCC with C & Ada
    cd $CBD/gcc2

    if [ -f $LAST/.make-install ]
    then
	if [ ! -f .config ]
	then
	    echo "  >> Configuring gcc (C, Ada)..."
	    $GCC_DIR/configure \
		--prefix=$TAMP \
    		--target=$1 \
    		$2 \
    		--enable-multilib \
    		--with-newlib \
    		--with-headers=$SRC/newlib-$NEWLIB_VERSION/newlib/libc/include \
    		--disable-nls \
    		--disable-shared \
    		--disable-threads \
    		--disable-lto \
		--with-gnu-as \
		--with-gnu-ld \
		--enable-languages=c,ada \
		--disable-libada \
		--disable-libssp \
		--without-ppl \
		--without-cloog \
		&> $LOGPRE-gcc2-config.txt

	    check_error .config
	fi

	if [ ! -f .make ]
	then
	    echo "  >> Building gcc (C, Ada)..."
	    make $JOBS all-gcc &> $LOGPRE-gcc2-make.txt

	    check_error .make
	fi

	if [ ! -f .make-gnattools ]
	then
	    echo "  >> Building gnattools..."
	    make $JOBS all-gnattools &> $LOGPRE-gcc2-make-gnattools.txt

	    check_error .make-gnattools
	fi

	if [ ! -f .make-install ]
	then
	    echo "  >> Installing gcc (C, Ada)..."
	    make install-gcc &> $LOGPRE-gcc2-install.txt

	    check_error .make-install
	fi
    fi

    echo "  >> done."

    # Get back to the build directory.
    cd $BLD
}

# U-Boot requires libgcc!
function build_u_boot()
{
    if [ ! -d $1/u-boot ]
    then
	mkdir -p $1/u-boot
    fi

#    cd ../src/u-boot-$U_BOOT_VERSION
    cd $TOP/src/u-boot

    if [ ! -f .make ]
    then
	echo "Configuring and building U-Boot for $1..."
	make O=../../build/$1/u-boot distclean
	make O=../../build/$1/u-boot omap3_beagle_config ARCH=arm CROSS_COMPILE=$1-
	make O=../../build/$1/u-boot all ARCH=arm CROSS_COMPILE=$1- &> $LOG/$1-u-boot-make.txt

	check_error .make
    fi

    # Back to the thirdparty directory
    cd $TOP
}

# Installation of the GNAT wrappers where we cannot build cross versions
# of the gnattools
# $1 = target (i.e. arm-none-eabi)
# $2 = install directory
function install_wrappers()
{
    WRAPPERS="gnatmake gnatlink"

    cd $TOP/../tools/gcc

    echo "Installing gnat wrappers..."

    for f in $WRAPPERS
    do
	install -m0755 -p $f $2/$1-$f
	sed -i -e s/target/$1/ $2/$1-$f
    done
}

./download.sh

if [ ! -d $LOG ]
then
    mkdir -p $LOG
fi

build_native_toolchain
build_toolchain arm-none-eabi --enable-interwork
#build_toolchain i386-elf
#build_toolchain mips-elf

#build_u_boot arm-none-eabi

#install_wrappers arm-none-eabi $PREFIX/bin

# Get back to the thirdparty directory.
cd $TOP
