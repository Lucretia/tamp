################################################################################
# Filename          # build-tools.sh
# Purpose:          # Downloads and Builds the TAMP toolchain components
# Description:      # 
# Copyright:        # Luke A. Guest, David Rees Copyright (C) 2011
################################################################################
#!/bin/sh

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

echo "Installation dir: " $PREFIX
echo "Support libs dir: " $GCC_LIBS_PREFIX
echo "Parallelism     : " $JOBS
echo "GMP Version     : " $GMP_VERSION
echo "MPFR Version    : " $MPFR_VERSION
echo "MPC Version     : " $MPC_VERSION
echo "Binutils Version: " $BINUTILS_VERSION
echo "GCC Version     : " $GCC_VERSION
echo "NewLib Version  : " $NEWLIB_VERSION

TOP=`pwd`

# $1 = Filename to create using touch, used in successive steps to test
#      if the previous step was completed.
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

function build_native_toolchain()
{
    if [ ! -d logs ]
    then
	mkdir -p logs
    fi

    LOGS=`pwd`/logs

    if [ ! -d native/gmp ]
    then
	mkdir -p native/gmp
    fi

    if [ ! -d native/mpfr ]
    then
	mkdir -p native/mpfr
    fi

    if [ ! -d native/mpc ]
    then
	mkdir -p native/mpc
    fi

    if [ ! -d native/cloog ]
    then
	mkdir -p native/cloog
    fi

    if [ ! -d native/ppl ]
    then
	mkdir -p native/ppl
    fi

    if [ ! -d native/gcc ]
    then
	mkdir -p native/gcc
    fi

    # Build gmp
    cd native/gmp

    if [ ! -f .config ]
    then
	echo "Configuring gmp..."
	../../../src/gmp-$GMP_VERSION/configure \
	    --prefix=$GCC_LIBS_PREFIX\
	    --disable-shared \
	    --enable-static &> $LOGS/native-gmp-config.txt

	check_error .config
    fi

    if [ ! -f .make ]
    then
	echo "Building gmp..."
	make $JOBS &> $LOGS/native-gmp-make.txt

	check_error .make
    fi

    if [ ! -f .make-check ]
    then
	echo "Checking gmp..."
	make check $JOBS &> $LOGS/native-gmp-check.txt

	check_error .make-check
    fi

    if [ ! -f .make-install ]
    then
	echo "Installing gmp..."
	make install &> $LOGS/native-gmp-install.txt

	check_error .make-install
    fi

    # Build MPFR
    cd ../mpfr

    if [ -f ../gmp/.make-install ]
    then
	if [ ! -f .config ]
	then
	    echo "Configuring mpfr..."
	    ../../../src/mpfr-$MPFR_VERSION/configure \
		--prefix=$GCC_LIBS_PREFIX \
		--with-gmp=$GCC_LIBS_PREFIX \
		--disable-shared \
		--enable-static &> $LOGS/native-mpfr-config.txt

	    check_error .config
	fi

	if [ ! -f .make ]
	then
	    echo "Building mpfr..."
	    make $JOBS &> $LOGS/native-mpfr-make.txt

	    check_error .make
	fi

	if [ ! -f .make-install ]
	then
	    echo "Installing mpfr..."
	    make install &> $LOGS/native-mpfr-install.txt

	    check_error .make-install
	fi
    fi

    # Build MPC
    cd ../mpc

    if [ -f ../mpfr/.make-install ]
    then
	if [ ! -f .config ]
	then
	    echo "Configuring mpc..."
	    ../../../src/mpc-$MPC_VERSION/configure \
		--prefix=$GCC_LIBS_PREFIX \
		--with-gmp=$GCC_LIBS_PREFIX \
		--with-mpfr=$GCC_LIBS_PREFIX \
		--disable-shared \
		--enable-static &> $LOGS/native-mpc-config.txt

	    check_error .config
	fi

	if [ ! -f .make ]
	then
	    echo "Building mpc..."
	    make $JOBS &> $LOGS/native-mpc-make.txt

	    check_error .make
	fi

	if [ ! -f .make-install ]
	then
	    echo "Installing mpc..."
	    make install &> $LOGS/native-mpc-install.txt

	    check_error .make-install
	fi
    fi

    # Build Cloog
    cd ../cloog

    if [ -f ../mpc/.make-install ]
    then
	if [ ! -f .config ]
	then
	    echo "Configuring cloog..."
	    ../../../src/cloog/configure \
		--prefix=$GCC_LIBS_PREFIX \
		--with-gmp-prefix=$GCC_LIBS_PREFIX \
		--disable-shared &> $LOGS/native-cloog-config.txt

	    check_error .config
	fi

	if [ ! -f .make ]
	then
	    echo "Building cloog..."
	    make $JOBS &> $LOGS/native-cloog-make.txt

	    check_error .make
	fi

	if [ ! -f .make-install ]
	then
	    echo "Installing cloog..."
	    make install &> $LOGS/native-cloog-install.txt

	    check_error .make-install
	fi
    fi

    # Build PPL
    cd ../ppl

    if [ -f ../cloog/.make-install ]
    then
	if [ ! -f .config ]
	then
	    echo "Configuring ppl..."
	    ../../../src/ppl/configure \
		--prefix=$GCC_LIBS_PREFIX \
		--with-gmp-prefix=$GCC_LIBS_PREFIX \
		--disable-shared &> $LOGS/native-ppl-config.txt

	    check_error .config
	fi

	if [ ! -f .make ]
	then
	    echo "Building ppl..."
	    make $JOBS &> $LOGS/native-ppl-make.txt

	    check_error .make
	fi

	if [ ! -f .make-install ]
	then
	    echo "Installing ppl..."
	    make install &> $LOGS/native-ppl-install.txt

	    check_error .make-install
	fi
    fi

    # Build the native GCC compiler.
    cd ../gcc

    if [ -f ../ppl/.make-install ]
    then
	if [ ! -f .config ]
	then
	    echo "Configuring native gcc..."
	    ../../../src/gcc-$GCC_VERSION/configure \
		--prefix=$PREFIX \
		--enable-multilib \
		--with-gnu-as \
		--with-gnu-ld \
		--enable-languages=c,ada \
		--with-gmp=$GCC_LIBS_PREFIX \
		--with-mpfr=$GCC_LIBS_PREFIX \
		--with-mpc=$GCC_LIBS_PREFIX \
		--with-ppl=$GCC_LIBS_PREFIX \
		--with-cloog=$GCC_LIBS_PREFIX &> $LOGS/native-gcc-config.txt

	    check_error .config
	fi

	if [ ! -f .make ]
	then
	    echo "Building native gcc..."
	    make $JOBS &> $LOGS/native-gcc-make.txt

	    check_error .make
	fi

	if [ ! -f .make-install ]
	then
	    echo "Installing native gcc..."
	    make install &> $LOGS/native-gcc-install.txt

	    check_error .make-install
	fi
    fi

    # Get back to the build directory.
    cd ../..
}

# $1 = Target.
# $2 = Any extra configure parameters.
function build_toolchain()
{
    if [ ! -d $1/binutils ]
    then
	mkdir -p $1/binutils
    fi

    if [ ! -d $1/gcc1 ]
    then
	mkdir -p $1/gcc1
    fi

    if [ ! -d $1/newlib ]
    then
	mkdir -p $1/newlib
    fi

    if [ ! -d $1/gcc2 ]
    then
	mkdir -p $1/gcc2
    fi

    export PATH=$PREFIX/bin:$PATH

    # Build binutils.
    cd $1/binutils

    if [ -f ../../native/gcc/.make-install ]
    then
	if [ ! -f .config ]
	then
	    echo "Configuring binutils for $1..."
	    ../../../src/binutils-$BINUTILS_VERSION/configure \
		--prefix=$PREFIX \
		--target=$1 \
		$2 \
		--enable-multilib \
		--disable-nls \
		--disable-shared \
		--disable-threads \
		--with-gcc \
		--with-gnu-as \
		--with-gnu-ld &> $LOGS/$1-binutils-config.txt

	    check_error .config
	fi

	if [ ! -f .make ]
	then
	    echo "Building binutils for $1..."
	    make $JOBS &> $LOGS/$1-binutils-make.txt

	    check_error .make
	fi

	if [ ! -f .make-install ]
	then
	    echo "Installing binutils for $1..."
	    make install &> $LOGS/$1-binutils-install.txt

	    check_error .make-install
	fi

        # Build the first pass GCC compiler (C only).
	cd ../gcc1

	if [ -f ../binutils/.make-install ]
	then
	    if [ ! -f .config ]
	    then
		echo "Configuring stage 1 gcc for $1..."
		../../../src/gcc-$GCC_VERSION/configure \
		    --prefix=$PREFIX \
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
		    --without-headers \
		    --enable-languages=c \
		    --with-gmp=$GCC_LIBS_PREFIX \
		    --with-mpfr=$GCC_LIBS_PREFIX \
		    --with-mpc=$GCC_LIBS_PREFIX \
		    --with-ppl=$GCC_LIBS_PREFIX \
		    --with-cloog=$GCC_LIBS_PREFIX &> $LOGS/$1-stage-1-gcc-config.txt

		check_error .config
	    fi

	    if [ ! -f .make ]
	    then
		echo "Building stage 1 gcc for $1..."
		make $JOBS all-gcc &> $LOGS/$1-stage-1-gcc-make.txt

		check_error .make
	    fi

	    if [ ! -f .make-install ]
	    then
		echo "Installing stage 1 gcc for $1..."
		make install-gcc &> $LOGS/$1-stage-1-gcc-install.txt

		check_error .make-install
	    fi
	fi

        # Build Newlib.
	cd ../newlib

	if [ -f ../gcc1/.make-install ]
	then
	    if [ ! -f .config ]
	    then
		echo "Configuring newlib for $1..."
		../../../src/newlib-$NEWLIB_VERSION/configure \
		    --prefix=$PREFIX \
		    --target=$1 \
		    $2 \
		    --enable-multilib \
		    --with-gnu-as \
		    --with-gnu-ld \
		    --disable-nls &> $LOGS/$1-newlib-config.txt

		check_error .config
	    fi

	    if [ ! -f .make ]
	    then
		echo "Building newlib for $1..."
		make $JOBS &> $LOGS/$1-newlib-make.txt

		check_error .make
	    fi

	    if [ ! -f .make-install ]
	    then
		echo "Installing newlib for $1..."
		make install &> $LOGS/$1-newlib-install.txt

		check_error .make-install
	    fi
	fi

        # Build the second pass GCC compiler (C & Ada).
	cd ../gcc2

	if [ -f ../newlib/.make-install ]
	then
	    if [ ! -f .config ]
	    then
		echo "Configuring stage 2 gcc for $1..."
		../../../src/gcc-$GCC_VERSION/configure \
		    --prefix=$PREFIX \
		    --target=$1 \
		    $2 \
		    --enable-multilib \
		    --with-newlib \
		    --with-headers=../../../src/newlib-$NEWLIB_VERSION/newlib/libc/include \
		    --disable-nls \
		    --disable-shared \
		    --disable-threads \
		    --disable-lto \
		    --with-gnu-as \
		    --with-gnu-ld \
		    --enable-languages=c,ada \
		    --disable-libssp \
		    --disable-libada \
		    --with-gmp=$GCC_LIBS_PREFIX \
		    --with-mpfr=$GCC_LIBS_PREFIX \
		    --with-mpc=$GCC_LIBS_PREFIX \
		    --with-ppl=$GCC_LIBS_PREFIX \
		    --with-cloog=$GCC_LIBS_PREFIX &> $LOGS/$1-stage-2-gcc-config.txt

		check_error .config
	    fi

	    if [ ! -f .make ]
	    then
		echo "Building stage 2 gcc for $1..."
		make $JOBS all-gcc &> $LOGS/$1-stage-2-gcc-make.txt

		check_error .make
	    fi

	    if [ ! -f .make-gnattools ]
	    then
		echo "Building stage 2 gcc (gnattools) for $1..."
		make $JOBS all-gnattools &> $LOGS/$1-stage-2-gcc-make-gnattools.txt

		check_error .make-gnattools
	    fi

	    if [ ! -f .make-install ]
	    then
		echo "Installing stage 2 gcc for $1..."
		make install-gcc &> $LOGS/$1-stage-2-gcc-install.txt

		check_error .make-install
	    fi
	fi
    else
	echo "Error! Native toolchain has not been built yet!"

	exit 2
    fi

    # Back to the build directory
    cd $TOP/build
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
	make O=../../build/$1/u-boot all ARCH=arm CROSS_COMPILE=$1- &> $LOGS/$1-u-boot-make.txt

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

if [ ! -d build ]
then
    mkdir -p build
fi

cd build

build_native_toolchain
build_toolchain arm-none-eabi --enable-interwork
#build_toolchain i386-elf
#build_toolchain mips-elf

#build_u_boot arm-none-eabi

#install_wrappers arm-none-eabi $PREFIX/bin

# Get back to the thirdparty directory.
cd $TOP
