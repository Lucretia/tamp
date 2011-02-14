################################################################################
# Filename         # build-tools.sh
# Purpose          # Downloads and Builds the TAMP toolchain components
# Description      #
# Copyright        # Luke A. Guest, David Rees Copyright (C) 2011
################################################################################
#!/bin/bash

source ./errors.inc

# TODO:
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
clear

if [ ! -f ./config.inc ]; then

cat << 'NOCONFIG_ERR'

  ERROR: No config.inc found.

  1) cp config-master.inc config.inc
  2) Edit config.inc for your system
  3) Run this script again

NOCONFIG_ERR
    
    exit 2
fi

source ./config.inc

# Ask nicely before deleting anything
if [ -d $BLD ]; then
    while true; do
	echo    "  WARNING: A TAMP build directory already exists!"
        read -p "  (R)emove it and continue, (I)gnore and continue, or (e)xit script?" builddir
	case $builddir in
		[R]* ) rm -Rf $BLD; break;;
		[I]* ) break ;;
		[Ee]* ) exit;;
		* ) echo "Please answer 'R', 'I' or 'e'.";;
	esac
    done
fi

# Ask nicely about reversing any patches in local gcc, before rebuilding native
if [ -f $SRC/gcc/.patched ]; then
	while true; do
	echo    ""
cat << "REVERSE_PATCHES"
  WARNING: It appears that patches have already been applied to the GCC source directory!

  If you have to build the native compiler again after having already built the cross
  compilers, you will need to reverse the patches, as they're incompatible
  with the native build. Note: The script will re-apply them for cross builds.

REVERSE_PATCHES

	read -p "  (R)everse GCC patches and continue, (I)gnore and continue, or (e)xit script? " rpatches
		case $rpatches in
		    [R]* ) cd $SRC/gcc; cat $TOP/patches/gcc-4.6/* | patch -p1 -i -; rm -f $SRC/gcc/.patched; break;;
	    	[I]* ) break ;;
		    [Ee]* ) exit;;
		    * ) echo "Please answer 'R', 'I' or 'e'.";;
		esac
	done
fi

cd $TOP

echo "  Source Dir       : " $SRC
echo "  Build Dir        : " $BLD
echo "  Log Dir          : " $LOG
echo "  Install Dir      : " $TAMP
echo "  Stage 1 Dir      : " $STAGE1_PREFIX
echo "  Stage 1 Libs Dir : " $STAGE1_LIBS_PREFIX
echo "  Stage 2 Dir      : " $STAGE2_PREFIX
echo "  Cross Dir        : " $CROSS_PREFIX
echo "  Parallelism      : " $JOBS
echo "  GMP Version      : " $GMP_VERSION
echo "  MPFR Version     : " $MPFR_VERSION
echo "  MPC Version      : " $MPC_VERSION
echo "  NewLib Version   : " $NEWLIB_VERSION
echo "  Binutils Version : " $BINUTILS_VERSION
echo "  GCC Version      : " $GCC_VERSION
echo "  GCC Source Dir   : " $GCC_DIR

function apply_cross_gcc_patches()
{
    if [ $GCC_FROM_REPO = "yes" ]; then
	cd $SRC/gcc

	if [ ! -f .patched ]; then
		PATCHES="gnattools.patch gnattools2.patch \
		gnatlib.patch gnatlib2.patch gnatlib3.patch"

		echo "  >> Applying GCC Patches to AMPC Cross..."
		for p in $PATCHES; do
		patch -p1 < $TOP/patches/gcc-4.6/$p

		check_error .patched
	    done
	fi
    else
	cd $SRC/gcc-$GCC_VERSION

	if [ ! -f .patched ]; then
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
    echo "  ( ) Start Processing AMPC-Native GCC (C/Ada)"
    local TASK_COUNT_TOTAL=5
    cd $BLD

    VER="native"
    STAGE="$VER/stage1"
    DIRS="gcc"

    echo "  >> [1/$TASK_COUNT_TOTAL] Creating Directories (if needed)..."

    for d in $DIRS; do
	if [ ! -d $STAGE/$d ]; then
		mkdir -p $STAGE/$d
	fi
    done

    LOGPRE=$LOG/native-stage1
    CBD=$BLD/$STAGE

    # Build the native GCC compiler.
    cd $CBD/gcc

    if [ ! -f .config ]; then
	echo "  >> [2/$TASK_COUNT_TOTAL] Configuring AMPC-Native GCC..."
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
#	    --without-libffi \
#	    --without-libiconv-prefix \
#	    --disable-libmudflap \
#	    --disable-nls \
#	    --disable-libstdcxx-pch \
#	    &> $LOGPRE-gcc-config.txt

	check_error .config
    fi

    if [ ! -f .make ]; then
	    echo "  >> [3/$TASK_COUNT_TOTAL] Building and Bootstrapping AMPC-Native GCC..."
		make $JOBS &> $LOGPRE-gcc-make.txt

	check_error .make
    fi

    if [ ! -f .make-install ]; then
	    echo "  >> [4/$TASK_COUNT_TOTAL] Installing AMPC Native GCC..."
		make install &> $LOGPRE-gcc-install.txt

	check_error .make-install
    fi

    if [ ! -f .test-gcc ]; then
	    echo "  >> [5/$TASK_COUNT_TOTAL] Testing AMPC-Native GCC..."
		make -k check-gcc &> $LOGPRE-gcc-test.txt

	check_error .test-gcc
    fi

    echo "  (x) Finished Processing AMPC-Native GCC (C/Ada)"

    # Get back to the build directory.
    cd $BLD
}

################################################################################
# $1 = Target.
# $2 = Any extra configure parameters.
################################################################################
function build_toolchain()
{
    echo "  ( ) Start Processing AMPC-Cross GCC for $1"

    apply_cross_gcc_patches

    cd $BLD

    VER=$1
    STAGE="$VER"
    DIRS="binutils gcc1 newlib gcc2"
    
    local TASK_COUNT_TOTAL=14
    echo "  >> [1/$TASK_COUNT_TOTAL] Creating Directories (if needed)..."

    for d in $DIRS; do
		if [ ! -d $STAGE/$d ]; 	then
			mkdir -p $STAGE/$d
		fi
    done

    LOGPRE=$LOG/$1
    CBD=$BLD/$STAGE

    export PATH=$TAMP/bin:$PATH
    export LD_LIBRARY_PATH=$TAMP/lib$BITS:$LD_LIBRARY_PATH

    # Build BinUtils.
    cd $CBD/binutils

    if [ ! -f .config ]; then
    	echo "  >> [2/$TASK_COUNT_TOTAL] Configuring Binutils for $1..."
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
    	echo "  >> [3/$TASK_COUNT_TOTAL] Building Binutils for $1..."
    	make $JOBS &> $LOGPRE-binutils-make.txt

    	check_error .make
    fi

    if [ ! -f .make-install ]
    then
    	echo "  >> [4/$TASK_COUNT_TOTAL] Installing Binutils for $1..."
    	make install &> $LOGPRE-binutils-install.txt

    	check_error .make-install
    fi
    echo "  >> Binutils Installed"

    LAST=`pwd`

    # Build stage 2 GCC with C only.
    cd $CBD/gcc1

    if [ -f $LAST/.make-install ]; then
	if [ ! -f .config ]; then
		echo "  >> [5/$TASK_COUNT_TOTAL] Configuring AMPC-Cross Stage2 GCC (C Only)..."
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

	if [ ! -f .make ]; then
		echo "  >> [6/$TASK_COUNT_TOTAL] Building AMPC-Cross Stage2 GCC (C Only)..."
		# use all-gcc, otherwise libiberty fails as it requires sys/types.h
		# which doesn't exist and tbh, shouldn't even be getting built, it's
		# a bug which has been reported here:
		#   http://gcc.gnu.org/bugzilla/show_bug.cgi?id=43073
		make $JOBS all-gcc &> $LOGPRE-gcc1-make.txt

	    check_error .make
	fi

	if [ ! -f .make-install ]; then
		echo "  >> [7/$TASK_COUNT_TOTAL] Installing AMPC-Cross GCC (C Only)..."
		make install-gcc &> $LOGPRE-gcc1-install.txt

	    check_error .make-install
	fi
    fi
    echo "  (x) AMPC-Cross Stage2 GCC (C Only) Installed"

    LAST=`pwd`

    # Build NewLib
    cd $CBD/newlib

    if [ -f $LAST/.make-install ]; then
		if [ ! -f .config ]; then
			echo "  >> [8/$TASK_COUNT_TOTAL] Configuring Newlib for $1..."
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

    	if [ ! -f .make ]; then
    	    echo "  >> [9/$TASK_COUNT_TOTAL] Building Newlib for $1..."
    	    make $JOBS &> $LOGPRE-newlib-make.txt

    	    check_error .make
    	fi

    	if [ ! -f .make-install ]; then
    	    echo "  >> [10/$TASK_COUNT_TOTAL] Installing Newlib for $1..."
    	    make install &> $LOGPRE-newlib-install.txt

    	    check_error .make-install
    	fi
    fi
    echo "  (x) Newlib Installed"
    LAST=`pwd`

    # Build Stage 2 GCC with C & Ada
    cd $CBD/gcc2

    if [ -f $LAST/.make-install ]; then
	if [ ! -f .config ]; then
    	echo "  >> [11/$TASK_COUNT_TOTAL] Configuring AMPC-Cross GCC (C/Ada)..."
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

	if [ ! -f .make ]; then
	    echo "  >> [12/$TASK_COUNT_TOTAL] Building AMPC-Cross GCC (C/Ada)..."
	    make $JOBS all-gcc &> $LOGPRE-gcc2-make.txt

	    check_error .make
	fi

	if [ ! -f .make-gnattools ]; then
	    echo "  >> [13/$TASK_COUNT_TOTAL] Building AMPC-Cross Gnattools..."
	    make $JOBS all-gnattools &> $LOGPRE-gcc2-make-gnattools.txt

	    check_error .make-gnattools
	fi

	if [ ! -f .make-install ]; then
	    echo "  >> [14/$TASK_COUNT_TOTAL] Installing AMPC-Cross GCC (C/Ada)..."
	    make install-gcc &> $LOGPRE-gcc2-install.txt

	    check_error .make-install
	fi
    fi

    echo "  (x) AMPC-Cross Stage2 GCC (C/Ada) Installed"

    # Get back to the build directory.
    cd $BLD
}

# U-Boot requires libgcc!
function build_u_boot()
{
    if [ ! -d $1/u-boot ]; then
    	mkdir -p $1/u-boot
    fi

#    cd ../src/u-boot-$U_BOOT_VERSION
    cd $TOP/src/u-boot

    if [ ! -f .make ]; then
	    echo "  >> Configuring and Building U-Boot for $1..."
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

    echo "  >> Installing Gnat Wrappers..."

    for f in $WRAPPERS; do
		install -m0755 -p $f $2/$1-$f
		sed -i -e s/target/$1/ $2/$1-$f
    done
}

$TOP/download.sh

if [ ! -d $LOG ]; then
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
