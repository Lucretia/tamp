################################################################################
# build-tools.sh
# Luke A. Guest (C) 2011
################################################################################
#!/bin/sh

source ./config.inc

echo "Installation dir: " $PREFIX
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

# $1 = Target.
# $2 = Any extra configure parameters.
function build_toolchain()
{
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

    if [ ! -d native/gcc ]
    then
	mkdir -p native/gcc
    fi

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

    # Build gmp
    cd native/gmp

    if [ ! -f .config ]
    then
	echo "Configuring gmp..."
	../../../src/gmp-$GMP_VERSION/configure \
	    --prefix=$GCC_LIBS_PREFIX/gmp \
	    --disable-shared \
	    --enable-static &> log.config.txt

	check_error .config
    fi

    if [ ! -f .make ]
    then
	echo "Building gmp..."
	make $JOBS &> log.make.txt

	check_error .make
    fi

    if [ ! -f .make-install ]
    then
	echo "Installing gmp..."
	make install &> log.make.install.txt

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
		--prefix=$GCC_LIBS_PREFIX/mpfr \
		--with-gmp=$GCC_LIBS_PREFIX/gmp \
		--disable-shared \
		--enable-static &> log.config.txt

	    check_error .config
	fi

	if [ ! -f .make ]
	then
	    echo "Building mpfr..."
	    make $JOBS &> log.make.txt

	    check_error .make
	fi

	if [ ! -f .make-install ]
	then
	    echo "Installing mpfr..."
	    make install &> log.make.install.txt

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
		--prefix=$GCC_LIBS_PREFIX/mpc \
		--with-gmp=$GCC_LIBS_PREFIX/gmp \
		--with-mpfr=$GCC_LIBS_PREFIX/mpfr \
		--disable-shared \
		--enable-static &> log.config.txt

	    check_error .config
	fi

	if [ ! -f .make ]
	then
	    echo "Building mpc..."
	    make $JOBS &> log.make.txt

	    check_error .make
	fi

	if [ ! -f .make-install ]
	then
	    echo "Installing mpc..."
	    make install &> log.make.install.txt

	    check_error .make-install
	fi
    fi

    # Build the first pass GCC compiler.
    cd ../gcc

    if [ -f ../mpc/.make-install ]
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
		--with-gmp=$GCC_LIBS_PREFIX/gmp \
		--with-mpfr=$GCC_LIBS_PREFIX/mpfr \
		--with-mpc=$GCC_LIBS_PREFIX/mpc &> log.config.txt

	    check_error .config
	fi

	if [ ! -f .make ]
	then
	    echo "Building native gcc..."
	    make $JOBS &> log.make.txt

	    check_error .make
	fi

	if [ ! -f .make-install ]
	then
	    echo "Installing native gcc..."
	    make install &> log.make.install.txt

	    check_error .make-install
	fi
    fi

    export PATH=$PREFIX/bin:$PATH

    # Build binutils.
    cd ../../$1/binutils

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
		--with-gnu-ld &> log.config.txt

	    check_error .config
	fi

	if [ ! -f .make ]
	then
	    echo "Building binutils for $1..."
	    make $JOBS &> log.make.txt

	    check_error .make
	fi

	if [ ! -f .make-install ]
	then
	    echo "Installing binutils for $1..."
	    make install &> log.make.install.txt

	    check_error .make-install
	fi
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
		--with-gnu-as \
		--with-gnu-ld \
		--without-headers \
		--enable-languages=c \
		--with-gmp=$GCC_LIBS_PREFIX/gmp \
		--with-mpfr=$GCC_LIBS_PREFIX/mpfr \
		--with-mpc=$GCC_LIBS_PREFIX/mpc &> log.config.txt

	    check_error .config
	fi

	if [ ! -f .make ]
	then
	    echo "Building stage 1 gcc for $1..."
	    make $JOBS all-gcc &> log.make.txt

	    check_error .make
	fi

	if [ ! -f .make-install ]
	then
	    echo "Installing stage 1 gcc for $1..."
	    make install-gcc &> log.make.install.txt

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
		--disable-nls &> log.config.txt

	    check_error .config
	fi

	if [ ! -f .make ]
	then
	    echo "Building newlib for $1..."
	    make $JOBS &> log.make.txt

	    check_error .make
	fi

	if [ ! -f .make-install ]
	then
	    echo "Installing newlib for $1..."
	    make install &> log.make.install.txt

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
		--with-gnu-as \
		--with-gnu-ld \
		--enable-languages=c,ada \
		--disable-libssp \
		--disable-libada \
		--with-gmp=$GCC_LIBS_PREFIX/gmp \
		--with-mpfr=$GCC_LIBS_PREFIX/mpfr \
		--with-mpc=$GCC_LIBS_PREFIX/mpc &> log.config.txt

	    check_error .config
	fi

	if [ ! -f .make ]
	then
	    echo "Building stage 2 gcc for $1..."
	    make $JOBS &> log.make.txt

	    check_error .make
	fi

	if [ ! -f .make-install ]
	then
	    echo "Installing stage 2 gcc for $1..."
	    make install &> log.make.install.txt

	    check_error .make-install
	fi
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
	make O=../../build/$1/u-boot all ARCH=arm CROSS_COMPILE=$1- &> ../../build/$1/u-boot/log.make.txt

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

build_toolchain arm-none-eabi --enable-interwork
#build_toolchain i386-elf
#build_toolchain mips-elf

#build_u_boot arm-none-eabi

install_wrappers arm-none-eabi $PREFIX/bin

# Get back to the thirdparty directory.
cd $TOP
