################################################################################
# Filename          # build-tools.sh
# Purpose:          # Downloads and Builds the TAMP toolchain components
# Description:      #
# Copyright:        # Luke A. Guest, David Rees Copyright (C) 2011
################################################################################
#!/bin/bash

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


################################################################################
# Build the first stage $GCC_VERSION (latest/native) compilers using the system
# compilers.
################################################################################
function build_stage1_toolchain()
{
    echo "Building native toolchain..."

    cd $BLD

    VER="native"
    STAGE="$VER/stage1"
#    DIRS="gmp mpfr mpc gcc"
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
    # LIBPRE=$STAGE1_LIBS_PREFIX
    # LIBPRE=$STAGE1_PREFIX

#     # Build gmp
#     cd $CBD/gmp

#     if [ ! -f .config ]
#     then
# 	echo "  >> Configuring gmp..."
# 	$SRC/gmp-$GMP_VERSION/configure \
# 	    --prefix=$LIBPRE/gmp-$GMP_VERSION \
# 	    --enable-cxx \
# 	    &> $LOGPRE-gmp-config.txt
# #	    --enable-static
# #	    --disable-shared

# 	check_error .config
#     fi

#     if [ ! -f .make ]
#     then
# 	echo "  >> Building gmp..."
# 	make $JOBS &> $LOGPRE-gmp-make.txt

# 	check_error .make
#     fi

#     if [ ! -f .make-install ]
#     then
# 	echo "  >> Installing gmp..."
# 	make install &> $LOGPRE-gmp-install.txt

# 	check_error .make-install
#     fi

#     LAST=$CBD/gmp

#     # Build MPFR
#     cd $CBD/mpfr

#     if [ -f $LAST/.make-install ]
#     then
# 	if [ ! -f .config ]
# 	then
# 	    echo "  >> Configuring mpfr..."
# 	    LD_LIBRARY_PATH=$LIBPRE/gmp-$GMP_VERSION/lib:$LD_LIBRARY_PATH \
# 		$SRC/mpfr-$MPFR_VERSION/configure \
# 		--prefix=$LIBPRE/mpfr-$MPFR_VERSION \
# 		--with-gmp=$LIBPRE/gmp-$GMP_VERSION \
# 		&> $LOGPRE-mpfr-config.txt
# #		--enable-static
# #		--disable-shared

# 	    check_error .config
# 	fi

# 	if [ ! -f .make ]
# 	then
# 	    echo "  >> Building mpfr..."
# 	    LD_LIBRARY_PATH=$LIBPRE/gmp-$GMP_VERSION/lib:$LD_LIBRARY_PATH \
# 		make $JOBS &> $LOGPRE-mpfr-make.txt

# 	    check_error .make
# 	fi

# 	if [ ! -f .make-install ]
# 	then
# 	    echo "  >> Installing mpfr..."
# 	    make install &> $LOGPRE-mpfr-install.txt

# 	    check_error .make-install
# 	fi
#     fi

#     LAST=$CBD/mpfr

#     # Build MPC
#     cd $CBD/mpc

#     if [ -f $LAST/.make-install ]
#     then
# 	if [ ! -f .config ]
# 	then
# 	    echo "  >> Configuring mpc..."
# 	    LD_LIBRARY_PATH=$LIBPRE/gmp-$GMP_VERSION/lib:$LIBPRE/mpfr-$MPFR_VERSION/lib:$LD_LIBRARY_PATH \
# 		$SRC/mpc-$MPC_VERSION/configure \
# 		--prefix=$LIBPRE/mpc-$MPC_VERSION \
# 		--with-gmp=$LIBPRE/gmp-$GMP_VERSION \
# 		--with-mpfr=$LIBPRE/mpfr-$MPFR_VERSION \
# 		&> $LOGPRE-mpc-config.txt
# #		--disable-shared
# #		--enable-static

# 	    check_error .config
# 	fi

# 	if [ ! -f .make ]
# 	then
# 	    echo "  >> Building mpc..."
# 	    LD_LIBRARY_PATH=$LIBPRE/gmp-$GMP_VERSION/lib:$LIBPRE/mpfr-$MPFR_VERSION/lib:$LD_LIBRARY_PATH \
# 		make $JOBS &> $LOGPRE-mpc-make.txt

# 	    check_error .make
# 	fi

# 	if [ ! -f .make-install ]
# 	then
# 	    echo "  >> Installing mpc..."
# 	    make install &> $LOGPRE-mpc-install.txt

# 	    check_error .make-install
# 	fi
#     fi

#     LAST=$CBD/mpc

#     # Build PPL
#     cd $CBD/ppl

#     if [ -f $LAST/.make-install ]
#     then
# 	if [ ! -f .config ]
# 	then
# 	    echo "  >> Configuring ppl..."
# 	    $SRC/ppl-$PPL_VERSION/configure \
# 		--prefix=$LIBPRE \
# 		--with-gmp-prefix=$LIBPRE \
# 		--enable-shared \
# 		&> $LOGPRE-ppl-config.txt
# #		--enable-static
# #		--disable-shared

# 	    check_error .config
# 	fi

# 	if [ ! -f .make ]
# 	then
# 	    echo "  >> Building ppl..."
# 	    make $JOBS &> $LOGPRE-ppl-make.txt

# 	    check_error .make
# 	fi

# 	if [ ! -f .make-install ]
# 	then
# 	    echo "  >> Installing ppl..."
# 	    make install &> $LOGPRE-ppl-install.txt

# 	    check_error .make-install
# 	fi
#     fi

#     LAST=$CBD/ppl

#     # Build Cloog
#     cd $CBD/cloog

#     if [ -f $LAST/.make-install ]
#     then
# 	if [ ! -f .config ]
# 	then
# 	    echo "  >> Configuring cloog..."
# 	    $SRC/cloog-ppl-$CLOOG_PPL_VERSION/configure \
# 		--prefix=$LIBPRE \
# 		--with-gmp-prefix=$LIBPRE \
# 		--with-ppl=$LIBPRE \
# 		--enable-shared \
# 		&> $LOGPRE-cloog-config.txt
# #		--enable-static
# #		--disable-shared

# 	    check_error .config
# 	fi

# 	if [ ! -f .make ]
# 	then
# 	    echo "  >> Building cloog..."
# 	    make $JOBS &> $LOGPRE-cloog-make.txt

# 	    check_error .make
# 	fi

# 	if [ ! -f .make-install ]
# 	then
# 	    echo "  >> Installing cloog..."
# 	    make install &> $LOGPRE-cloog-install.txt

# 	    check_error .make-install
# 	fi
#     fi

#     LAST=$CBD/cloog

    # Build the native GCC compiler.
    cd $CBD/gcc

    # if [ -f $LAST/.make-install ]
    # then
	if [ ! -f .config ]
	then
	    echo "  >> Configuring gcc..."
	    # Use --disable-lto because linking ltol gave ppl/C++ link errors.
	    # Turn off CLooG/PPL as we don't want C++.
#	    LD_LIBRARY_PATH=$LIBPRE/gmp-$GMP_VERSION/lib:$LIBPRE/mpfr-$MPFR_VERSION/lib:$LIBPRE/mpc-$MPC_VERSION/lib:$LD_LIBRARY_PATH \
#		--prefix=$STAGE1_PREFIX/gcc-$GCC_VERSION \
	    $GCC_DIR/configure \
		--prefix=$TAMP \
		--disable-multilib \
		--enable-shared \
		--with-gnu-as \
		--with-gnu-ld \
		--enable-languages=c,ada \
		--without-ppl \
		--without-cloog \
		&> $LOGPRE-gcc-config.txt
#		--disable-lto
#		--with-ppl=$LIBPRE
#		--with-cloog=$LIBPRE
#		--with-gmp=$LIBPRE \
#		--with-mpfr=$LIBPRE \
#		--with-mpc=$LIBPRE \

	    check_error .config
	fi

	if [ ! -f .make ]
	then
	    echo "  >> Building gcc..."
#	    LD_LIBRARY_PATH=$LIBPRE/gmp-$GMP_VERSION/lib:$LIBPRE/mpfr-$MPFR_VERSION/lib:$LIBPRE/mpc-$MPC_VERSION/lib:$LD_LIBRARY_PATH \
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
#	    LD_LIBRARY_PATH=$LIBPRE/gmp-$GMP_VERSION/lib:$LIBPRE/mpfr-$MPFR_VERSION/lib:$LIBPRE/mpc-$MPC_VERSION/lib:$LD_LIBRARY_PATH \
	    make $JOBS -k check-gcc &> $LOGPRE-gcc-test.txt

	    check_error .test-gcc
	fi

# 	if [ ! -f .test-ada ]
# 	then
# 	    echo "  >> Testing ada..."
# #	    LD_LIBRARY_PATH=$LIBPRE/gmp-$GMP_VERSION/lib:$LIBPRE/mpfr-$MPFR_VERSION/lib:$LIBPRE/mpc-$MPC_VERSION/lib:$LD_LIBRARY_PATH \
# 	    make $JOBS -k check-ada &> $LOGPRE-gcc-test-ada.txt

# 	    check_error .test-ada
# 	fi
    # fi

    echo "  >> done."

    # Get back to the build directory.
    cd $BLD
}

# $1 = Target.
# $2 = Any extra configure parameters.
function build_toolchain()
{
    echo "Building $1 toolchain..."

    cd $BLD

    VER=$1
    STAGE="$VER"
#    DIRS="gmp mpfr mpc gcc"
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
		--without-ppl \
		--without-cloog \
		&> $LOGPRE-gcc2-config.txt

	    check_error .config
	fi

	if [ ! -f .make ]
	then
	    echo "  >> Building gcc (C, Ada)..."
	    make $JOBS &> $LOGPRE-gcc2-make.txt

	    check_error .make
	fi

	if [ ! -f .make-install ]
	then
	    echo "  >> Installing gcc (C, Ada)..."
	    make install &> $LOGPRE-gcc2-install.txt

	    check_error .make-install
	fi
    fi

    echo "  >> done."

    # Get back to the build directory.
    cd $BLD

    # if [ ! -d $1/gmp ]
    # then
    # 	mkdir -p $1/gmp
    # fi

    # if [ ! -d $1/mpfr ]
    # then
    # 	mkdir -p $1/mpfr
    # fi

    # if [ ! -d $1/mpc ]
    # then
    # 	mkdir -p $1/mpc
    # fi

    # if [ ! -d $1/cloog ]
    # then
    # 	mkdir -p $1/cloog
    # fi

    # if [ ! -d $1/ppl ]
    # then
    # 	mkdir -p $1/ppl
    # fi

    # if [ ! -d $1/binutils ]
    # then
    # 	mkdir -p $1/binutils
    # fi

    # if [ ! -d $1/gcc1 ]
    # then
    # 	mkdir -p $1/gcc1
    # fi

    # if [ ! -d $1/newlib ]
    # then
    # 	mkdir -p $1/newlib
    # fi

    # if [ ! -d $1/gcc2 ]
    # then
    # 	mkdir -p $1/gcc2
    # fi

    # Build gmp
    # cd native/gmp

    # if [ ! -f .config ]
    # then
    # 	echo "Configuring gmp..."
    # 	../../../src/gmp-$GMP_VERSION/configure \
    # 	    --prefix=$GCC_LIBS_PREFIX/gmp \
    # 	    --disable-shared \
    # 	    --enable-static &> $LOG/native-gmp-config.txt

    # 	check_error .config
    # fi

    # if [ ! -f .make ]
    # then
    # 	echo "Building gmp..."
    # 	make $JOBS &> $LOG/native-gmp-make.txt

    # 	check_error .make
    # fi

    # if [ ! -f .make-install ]
    # then
    # 	echo "Installing gmp..."
    # 	make install &> $LOG/native-gmp-install.txt

    # 	check_error .make-install
    # fi

    # # Build MPFR
    # cd ../mpfr

    # if [ -f ../gmp/.make-install ]
    # then
    # 	if [ ! -f .config ]
    # 	then
    # 	    echo "Configuring mpfr..."
    # 	    ../../../src/mpfr-$MPFR_VERSION/configure \
    # 		--prefix=$GCC_LIBS_PREFIX/mpfr \
    # 		--with-gmp=$GCC_LIBS_PREFIX/gmp \
    # 		--disable-shared \
    # 		--enable-static &> $LOG/native-mpfr-config.txt

    # 	    check_error .config
    # 	fi

    # 	if [ ! -f .make ]
    # 	then
    # 	    echo "Building mpfr..."
    # 	    make $JOBS &> $LOG/native-mpfr-make.txt

    # 	    check_error .make
    # 	fi

    # 	if [ ! -f .make-install ]
    # 	then
    # 	    echo "Installing mpfr..."
    # 	    make install &> $LOG/native-mpfr-install.txt

    # 	    check_error .make-install
    # 	fi
    # fi

    # # Build MPC
    # cd ../mpc

    # if [ -f ../mpfr/.make-install ]
    # then
    # 	if [ ! -f .config ]
    # 	then
    # 	    echo "Configuring mpc..."
    # 	    ../../../src/mpc-$MPC_VERSION/configure \
    # 		--prefix=$GCC_LIBS_PREFIX/mpc \
    # 		--with-gmp=$GCC_LIBS_PREFIX/gmp \
    # 		--with-mpfr=$GCC_LIBS_PREFIX/mpfr \
    # 		--disable-shared \
    # 		--enable-static &> $LOG/native-mpc-config.txt

    # 	    check_error .config
    # 	fi

    # 	if [ ! -f .make ]
    # 	then
    # 	    echo "Building mpc..."
    # 	    make $JOBS &> $LOG/native-mpc-make.txt

    # 	    check_error .make
    # 	fi

    # 	if [ ! -f .make-install ]
    # 	then
    # 	    echo "Installing mpc..."
    # 	    make install &> $LOG/native-mpc-install.txt

    # 	    check_error .make-install
    # 	fi
    # fi

    # # Build Cloog
    # cd ../cloog

    # if [ -f ../mpc/.make-install ]
    # then
    # 	if [ ! -f .config ]
    # 	then
    # 	    echo "Configuring cloog..."
    # 	    ../../../src/cloog/configure \
    # 		--prefix=$GCC_LIBS_PREFIX/cloog \
    # 		--with-gmp-prefix=$GCC_LIBS_PREFIX/gmp \
    # 		--disable-shared \
    # 		--with-ppl \
    # 		&> $LOG/native-cloog-config.txt

    # 	    check_error .config
    # 	fi

    # 	if [ ! -f .make ]
    # 	then
    # 	    echo "Building cloog..."
    # 	    make $JOBS &> $LOG/native-cloog-make.txt

    # 	    check_error .make
    # 	fi

    # 	if [ ! -f .make-install ]
    # 	then
    # 	    echo "Installing cloog..."
    # 	    make install &> $LOG/native-cloog-install.txt

    # 	    check_error .make-install
    # 	fi
    # fi

    # # Build PPL
    # cd ../ppl

    # if [ -f ../cloog/.make-install ]
    # then
    # 	if [ ! -f .config ]
    # 	then
    # 	    echo "Configuring ppl..."
    # 	    ../../../src/ppl/configure \
    # 		--prefix=$GCC_LIBS_PREFIX/ppl \
    # 		--with-gmp-prefix=$GCC_LIBS_PREFIX/gmp \
    # 		--disable-shared &> $LOG/native-ppl-config.txt

    # 	    check_error .config
    # 	fi

    # 	if [ ! -f .make ]
    # 	then
    # 	    echo "Building ppl..."
    # 	    make $JOBS &> $LOG/native-ppl-make.txt

    # 	    check_error .make
    # 	fi

    # 	if [ ! -f .make-install ]
    # 	then
    # 	    echo "Installing ppl..."
    # 	    make install &> $LOG/native-ppl-install.txt

    # 	    check_error .make-install
    # 	fi
    # fi

    # # Build binutils.
    # cd $1/binutils

    # if [ -f ../../native/gcc/.make-install ]
    # then
    # 	if [ ! -f .config ]
    # 	then
    # 	    echo "Configuring binutils for $1..."
    # 	    ../../../src/binutils-$BINUTILS_VERSION/configure \
    # 		--prefix=$PREFIX \
    # 		--target=$1 \
    # 		$2 \
    # 		--enable-multilib \
    # 		--disable-nls \
    # 		--disable-shared \
    # 		--disable-threads \
    # 		--with-gcc \
    # 		--with-gnu-as \
    # 		--with-gnu-ld &> $LOG/$1-binutils-config.txt

    # 	    check_error .config
    # 	fi

    # 	if [ ! -f .make ]
    # 	then
    # 	    echo "Building binutils for $1..."
    # 	    make $JOBS &> $LOG/$1-binutils-make.txt

    # 	    check_error .make
    # 	fi

    # 	if [ ! -f .make-install ]
    # 	then
    # 	    echo "Installing binutils for $1..."
    # 	    make install &> $LOG/$1-binutils-install.txt

    # 	    check_error .make-install
    # 	fi

    #     # Build the first pass GCC compiler (C only).
    # 	cd ../gcc1

    # 	if [ -f ../binutils/.make-install ]
    # 	then
    # 	    if [ ! -f .config ]
    # 	    then
    # 		echo "Configuring stage 1 gcc for $1..."
    # 		../../../src/gcc-$GCC_VERSION/configure \
    # 		    --prefix=$PREFIX \
    # 		    --target=$1 \
    # 		    $2 \
    # 		    --enable-multilib \
    # 		    --with-newlib \
    # 		    --disable-nls \
    # 		    --disable-shared \
    # 		    --disable-threads \
    # 		    --disable-lto \
    # 		    --with-gnu-as \
    # 		    --with-gnu-ld \
    # 		    --without-headers \
    # 		    --enable-languages=c \
    # 		    --with-gmp=$GCC_LIBS_PREFIX/gmp \
    # 		    --with-mpfr=$GCC_LIBS_PREFIX/mpfr \
    # 		    --with-mpc=$GCC_LIBS_PREFIX/mpc \
    # 		    --with-ppl=$GCC_LIBS_PREFIX/ppl \
    # 		    --with-cloog=$GCC_LIBS_PREFIX/cloog \
    # 		    &> $LOG/$1-stage-1-gcc-config.txt

    # 		check_error .config
    # 	    fi

    # 	    if [ ! -f .make ]
    # 	    then
    # 		echo "Building stage 1 gcc for $1..."
    # 		make $JOBS all-gcc &> $LOG/$1-stage-1-gcc-make.txt

    # 		check_error .make
    # 	    fi

    # 	    if [ ! -f .make-install ]
    # 	    then
    # 		echo "Installing stage 1 gcc for $1..."
    # 		make install-gcc &> $LOG/$1-stage-1-gcc-install.txt

    # 		check_error .make-install
    # 	    fi
    # 	fi

    #     # Build Newlib.
    # 	cd ../newlib

    # 	if [ -f ../gcc1/.make-install ]
    # 	then
    # 	    if [ ! -f .config ]
    # 	    then
    # 		echo "Configuring newlib for $1..."
    # 		../../../src/newlib-$NEWLIB_VERSION/configure \
    # 		    --prefix=$PREFIX \
    # 		    --target=$1 \
    # 		    $2 \
    # 		    --enable-multilib \
    # 		    --with-gnu-as \
    # 		    --with-gnu-ld \
    # 		    --disable-nls &> $LOG/$1-newlib-config.txt

    # 		check_error .config
    # 	    fi

    # 	    if [ ! -f .make ]
    # 	    then
    # 		echo "Building newlib for $1..."
    # 		make $JOBS &> $LOG/$1-newlib-make.txt

    # 		check_error .make
    # 	    fi

    # 	    if [ ! -f .make-install ]
    # 	    then
    # 		echo "Installing newlib for $1..."
    # 		make install &> $LOG/$1-newlib-install.txt

    # 		check_error .make-install
    # 	    fi
    # 	fi

    #     # Build the second pass GCC compiler (C & Ada).
    # 	cd ../gcc2

    # 	if [ -f ../newlib/.make-install ]
    # 	then
    # 	    if [ ! -f .config ]
    # 	    then
    # 		echo "Configuring stage 2 gcc for $1..."
    # 		../../../src/gcc-$GCC_VERSION/configure \
    # 		    --prefix=$PREFIX \
    # 		    --target=$1 \
    # 		    $2 \
    # 		    --enable-multilib \
    # 		    --with-newlib \
    # 		    --with-headers=../../../src/newlib-$NEWLIB_VERSION/newlib/libc/include \
    # 		    --disable-nls \
    # 		    --disable-shared \
    # 		    --disable-threads \
    # 		    --disable-lto \
    # 		    --with-gnu-as \
    # 		    --with-gnu-ld \
    # 		    --enable-languages=c,ada \
    # 		    --disable-libssp \
    # 		    --disable-libada \
    # 		    --with-gmp=$GCC_LIBS_PREFIX/gmp \
    # 		    --with-mpfr=$GCC_LIBS_PREFIX/mpfr \
    # 		    --with-mpc=$GCC_LIBS_PREFIX/mpc \
    # 		    --with-ppl=$GCC_LIBS_PREFIX/ppl \
    # 		    --with-cloog=$GCC_LIBS_PREFIX/cloog \
    # 		    &> $LOG/$1-stage-2-gcc-config.txt

    # 		check_error .config
    # 	    fi

    # 	    if [ ! -f .make ]
    # 	    then
    # 		echo "Building stage 2 gcc for $1..."
    # 		make $JOBS all-gcc &> $LOG/$1-stage-2-gcc-make.txt

    # 		check_error .make
    # 	    fi

    # 	    if [ ! -f .make-gnattools ]
    # 	    then
    # 		echo "Building stage 2 gcc (gnattools) for $1..."
    # 		make $JOBS all-gnattools &> $LOG/$1-stage-2-gcc-make-gnattools.txt

    # 		check_error .make-gnattools
    # 	    fi

    # 	    if [ ! -f .make-install ]
    # 	    then
    # 		echo "Installing stage 2 gcc for $1..."
    # 		make install-gcc &> $LOG/$1-stage-2-gcc-install.txt

    # 		check_error .make-install
    # 	    fi
    # 	fi
    # else
    # 	echo "Error! Native toolchain has not been built yet!"

    # 	exit 2
    # fi

    # # Back to the build directory
    # cd $TOP/build
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

build_stage1_toolchain
build_toolchain arm-none-eabi --enable-interwork
#build_toolchain i386-elf
#build_toolchain mips-elf

#build_u_boot arm-none-eabi

#install_wrappers arm-none-eabi $PREFIX/bin

# Get back to the thirdparty directory.
cd $TOP
