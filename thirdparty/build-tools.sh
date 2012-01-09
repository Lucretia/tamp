################################################################################
# Filename         # build-tools.sh
# Purpose          # Download and batch build toolchain components
# Description      #
# Copyright        # Copyright (C) 2011 Luke A. Guest, David Rees,
# Depends          # http://gcc.gnu.org/install/prerequisites.html
################################################################################
#!/bin/bash

VERSION="build-tools.sh (2012-01-06)"

usage="\
$VERSION
Copyright (C) 2011 Luke A. Guest, David Rees. All Rights Reserved.

Automate the download and build of compiler toolchains.

Usage: $0 [-t] TARGET

Options:

     --help         Display this help and exit
     --version      Display version info and exit
     -t TARGET      Build for specified TARGET

                    Valid values for TARGET
                    -----------------------
                    native (default without -t)
                    arm-none-eabi
                    i386-elf
                    mips-elf
"

################################################################################
# Commandline parameters
################################################################################

while test $# -ne 0; do

	case "$1" in

	# Target
	-t) operation=$2
        
        case $operation in
          native) targ="native"; break;;
          arm-none-eabi) targ="arm-none-eabi"; break;;
          i386-elf) targ="i386-elf"; break;;
          *) break ;;
        esac
        exit $? ;;


	# Version
	--version) echo "$VERSION
Copyright (C) 2011 Luke A. Guest, David Rees. All Rights Reserved.
"; exit $?;;

	# Help
	--help) echo "$usage"; exit $?;;

	# Invalid
	-*)	echo "$0: invalid option: $1" >&2 ;	exit 1;;

	# Default
	*) break ;;
	esac

done

clear
cat <<START

  You are about to build and install a compiler toolchain (Native or Cross).
  For basic usage information, please run:

  ./build-tools.sh --help

  Logs from the build process are placed in a build/logs directory with a
  standardised naming, i.e. [description]-[config|make|check|install].txt

  THIS SOFTWARE IS PROVIDED BY THE  COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY  EXPRESS OR IMPLIED WARRANTIES,  INCLUDING, BUT NOT LIMITED  TO, THE
  IMPLIED WARRANTIES OF  MERCHANTABILITY AND FITNESS FOR  A PARTICULAR PURPOSE
  ARE  DISCLAIMED. IN  NO EVENT  SHALL  THE COPYRIGHT  HOLDER OR  CONTRIBUTORS
  BE  LIABLE FOR  ANY  DIRECT, INDIRECT,  INCIDENTAL,  SPECIAL, EXEMPLARY,  OR
  CONSEQUENTIAL  DAMAGES  (INCLUDING,  BUT  NOT  LIMITED  TO,  PROCUREMENT  OF
  SUBSTITUTE GOODS  OR SERVICES; LOSS  OF USE,  DATA, OR PROFITS;  OR BUSINESS
  INTERRUPTION)  HOWEVER CAUSED  AND ON  ANY THEORY  OF LIABILITY,  WHETHER IN
  CONTRACT,  STRICT LIABILITY,  OR  TORT (INCLUDING  NEGLIGENCE OR  OTHERWISE)
  ARISING IN ANY WAY  OUT OF THE USE OF THIS SOFTWARE, EVEN  IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE.

  Copyright (C) 2011 Luke A. Guest, David Rees. All Rights Reserved.
  
  Press ENTER to continue...
START

read x

#exit

source ./errors.inc

################################################################################
# Enforce a personalised configuration
################################################################################

if [ ! -f ./config.inc ]; then
	display_no_config_error
else
	source ./config.inc
fi

################################################################################
# Handle pre-existing build directories
################################################################################
if [ -d $BLD ]; then
	while true; do
		echo    "  -----------------------------------------------------"
		echo    "  -- NOTE: Toolchain build directories exist! ---------"
		echo    "  -----------------------------------------------------"
		read -p "  (R)emove all build directories, (c)ontinue, or (e)xit script? " builddir
	case $builddir in
		[R]*) rm -Rf $BLD; break;;
		[Cc]*) break;;
		[Ee]*) exit;;
		*) echo "  Please answer 'R', '[C/c]' or '[E/e]'.";;
	esac
	done
fi

################################################################################
# Handle pre-existing installation directories
################################################################################

if [ -d $INSTALL_DIR ]; then
	while true; do
		echo    "  -----------------------------------------------------"
		echo    "  -- ATTENTION: Toolchain install directories exist! --"
		echo    "  -----------------------------------------------------"
		read -p "  (R)emove all install directories, (c)ontinue, or (e)xit? " installdir
	case $installdir in
		[R]*) rm -Rf $INSTALL_DIR; break;;
		[Cc]*) break;;
		[Ee]*) exit;;
		*) echo "  Please answer 'R', '[C/c]' or '[E/e]'.";;
	esac
	done
fi

################################################################################
# Reverse gcc patches (if needed)
################################################################################
function reverse_patches()
{
	echo "  >> Reversing patches that were previously applied to src/gcc"
	cat $TOP/patches/gcc-$GCC_VERSION/* | patch -p1 -s -t -d $GCC_DIR -i -;
	rm -f $GCC_DIR/.patched;
}


if [ -f $GCC_DIR/.patched ]; then
	while true; do

cat<<REVERSE_PATCHES

  WARNING: Patches already applied in src/gcc

  If you have to build the 'native' compiler again following a cross build
  then reverse the patches, as they're incompatible with the native build.
  Otherwise ignoring should be fine.

  Note: This script will automatically try to re-apply them for cross builds.

REVERSE_PATCHES

	read -p "  Try to (R)everse the patches and continue, (I)gnore, or (e)xit script? " rpatches
		case $rpatches in
			[R]*) reverse_patches; break;;
			[I]*) break ;;
			[Ee]*) exit;;
			*) echo "  Please answer 'R', 'I' or '[E/e]'.";;
		esac
	done
fi


################################################################################
# Display some build configuration details
################################################################################

cd $TOP
echo "  Directories"
echo "  -----------"
echo "  Source        : " $SRC
echo "  Build         : " $BLD
echo "  Log           : " $LOG
echo "  Install       : " $INSTALL_DIR
echo "  GCC Source    : " $GCC_DIR
echo "  Cross         : " $CROSS_PREFIX
echo ""
echo "  Versions"
echo "  --------"
echo "  GMP           : " $GMP_VERSION
echo "  PPL           : " $PPL_VERSION
echo "  Cloog-PPL     : " $CLOOG_PPL_VERSION
echo "  MPFR          : " $MPFR_VERSION
echo "  MPC           : " $MPC_VERSION
echo "  NewLib        : " $NEWLIB_VERSION
echo "  Binutils      : " $BINUTILS_VERSION
echo "  GCC           : " $GCC_VERSION
echo "  ST-Link       : GitHub"

echo "  Other"
echo "  -----"
echo "  Parallelism   : " $JOBS

echo ""

################################################################################
# Native GCC patches and symlinks
#################################################################################

function apply_native_gcc_patches()
{
	# Patch gcc trunk sources
#	if [ $GCC_FROM_REPO = "y" ]; then

		cd $GCC_DIR

#		if [ ! -f .patched ]; then
#			local PATCHES="gnatvsn.patch"

#			echo "  >> Applying Patches to GNAT/GCC (Native)..."
#			for p in $PATCHES; do
#				patch -p1 -s -d $GCC_DIR < $TOP/patches/gcc-$GCC_VERSION/$p
#				check_error .patched
#			done
#		fi


	# Patching a gcc snapshot or release
#    else

		#cd $GCC_DIR

		#if [ ! -f .patched ]; then
			#local PATCHES="ada-symbolic-tracebacks.diff"
			#echo "  >> Patching GNAT/GCC (Native)..."

			#if [ $GCC_VERSION == "4.6.1" ]; then
			#
			#fi

			#for p in $PATCHES; do
			#	patch -p1 -s -d $GCC_DIR < $TOP/patches/gcc-$GCC_VERSION/$p
			#done

			#	check_error .patched
		#fi

#	fi
}

function apply_cross_gcc_patches()
{
	# Patch gcc trunk source
	if [ $GCC_FROM_REPO = "y" ]; then

		cd $GCC_DIR
		local PATCHES="gcc-$GCC_VERSION.diff"

		if [ ! -f .patched ]; then
			echo "  >> Applying Patches to GNAT/GCC Cross..."
			for p in $PATCHES; do
				patch -p1 -s -d $GCC_DIR < $TOP/patches/gcc-$GCC_VERSION/$p
				check_error .patched
			done
		fi
	# Patch gcc snapshots or releases
	else

		cd $GCC_DIR
		local PATCHES="gcc-$GCC_VERSION.diff"

		if [ ! -f .patched ]; then
			echo "  >> Applying Patches to GNAT/GCC Cross..."
			for p in $PATCHES; do
				patch -p1 -s -d $GCC_DIR < $TOP/patches/gcc-$GCC_VERSION/$p
				check_error .patched
			done
		fi
	fi
}

function create_gmp_symlink()
{
	if [ ! -h gmp ]; then
		echo "  >> Creating symbolic link to GMP source..."
		ln -s $SRC/gmp-$GMP_VERSION gmp
	fi
}

function create_gcc_symlinks()
{
	if [ ! -h $GCC_DIR/mpfr ]; then
		echo "  >> Creating symbolic link to MPFR source..."
		ln -s $SRC/mpfr-$MPFR_VERSION mpfr
	fi

	if [ ! -h mpc ]; then
		echo "  >> Creating symbolic link to MPC source..."
		ln -s $SRC/mpc-$MPC_VERSION mpc
	fi

	if [ ! -h gdb ]; then
		echo "  >> Creating symbolic link to GDB source..."
		ln -s $SRC/gdb-$GDB_SRC_VERSION gdb
	fi
}

################################################################################
# Build GMP, PPL and Cloog-PPL Arithmetic/Optimisation Libs
################################################################################

function build_arithmetic_libs()
{
	echo "  ( ) Start Processing GMP, PPL, and Cloog-PPL"

	# Constants
	local TASK_COUNT_TOTAL=11
	VER="native"
	DIRS="gmp-$GMP_VERSION ppl-$PPL_VERSION cloog-ppl-$CLOOG_PPL_VERSION"
	LOGPRE=$LOG/native
	OBD=$BLD/$VER

	echo "  >> [1/$TASK_COUNT_TOTAL] Creating Directories (if needed)..."

	cd $BLD
	for d in $DIRS; do
	if [ ! -d $VER/$d ]; then
		mkdir -p $VER/$d
	fi
	done

	# GMP ######################################################################
	cd $OBD/gmp-$GMP_VERSION

	if [ ! -f .config ]; then
		echo "  >> [2/$TASK_COUNT_TOTAL] Configuring GMP..."
		$SRC/gmp-$GMP_VERSION/configure \
		--prefix=$INSTALL_DIR \
		--enable-cxx \
		&> $LOGPRE-gmp-$GMP_VERSION-configure.txt
		check_error .config
	fi

	if [ ! -f .make ]; then
		echo "  >> [3/$TASK_COUNT_TOTAL] Building GMP..."
		make $JOBS &> $LOGPRE-gmp-$GMP_VERSION-make.txt
		check_error .make
	fi

	if [ ! -f .make-install ]; then
		echo "  >> [4/$TASK_COUNT_TOTAL] Installing GMP..."
		make install &> $LOGPRE-gmp-$GMP_VERSION-install.txt
		check_error .make-install
	fi

	if [ ! -f .make-check ]; then
		echo "  >> [5/$TASK_COUNT_TOTAL] Logging GMP Check..."
		make check &> $LOGPRE-gmp-$GMP_VERSION-check.txt
		check_error .make-check
	fi

	# PPL ######################################################################

	cd $OBD/ppl-$PPL_VERSION

	if [ ! -f .config ]; then
		echo "  >> [6/$TASK_COUNT_TOTAL] Configuring PPL..."

		$SRC/ppl-$PPL_VERSION/configure \
		--with-gmp-build=$OBD/gmp-$GMP_VERSION \
		--prefix=$INSTALL_DIR \
		&> $LOGPRE-ppl-$PPL_VERSION-configure.txt
		check_error .config
	fi

	if [ ! -f .make ]; then
		echo "  >> [7/$TASK_COUNT_TOTAL] Building PPL..."
		make $JOBS &> $LOGPRE-ppl-$PPL_VERSION-make.txt
		check_error .make
	fi

	if [ ! -f .make-install ]; then
		echo "  >> [8/$TASK_COUNT_TOTAL] Installing PPL..."
		make install &> $LOGPRE-ppl-$PPL_VERSION-install.txt
		check_error .make-install
	fi

	# Cloog-ppl ################################################################
	cd $OBD/cloog-ppl-$CLOOG_PPL_VERSION

	if [ ! -f .config ]; then
		echo "  >> [9/$TASK_COUNT_TOTAL] Configuring Cloog-PPL..."
		$SRC/cloog-ppl-$CLOOG_PPL_VERSION/configure \
		--prefix=$INSTALL_DIR \
		--with-gmp=$INSTALL_DIR \
		--with-ppl=$INSTALL_DIR \
		&> $LOGPRE-cloog-ppl-$CLOOG_PPL_VERSION-configure.txt
		check_error .config
	fi

	if [ ! -f .make ]; then
		echo "  >> [10/$TASK_COUNT_TOTAL] Building Cloog-PPL..."
		make $JOBS &> $LOGPRE-cloog-ppl-$CLOOG_PPL_VERSION-make.txt
		check_error .make
	fi

	if [ ! -f .make-install ]; then
		echo "  >> [11/$TASK_COUNT_TOTAL] Installing Cloog-PPL..."
		make install &> $LOGPRE-cloog-ppl-$CLOOG_PPL_VERSION-install.txt
		check_error .make-install
	fi

	#export LD_LIBRARY_PATH="$INSTALL_DIR/lib:$LD_LIBRARY_PATH"
	#export LD_LIBRARY_PATH="$INSTALL_DIR/lib$BITS:$LD_LIBRARY_PATH"

	echo "  (x) Finished Processing GMP, PPL and Cloog-PPL"
}


################################################################################
# Build Binutils for the Native Toolchain
################################################################################

function build_native_binutils(){

	# Build BinUtils.
	cd $CBD/binutils-$BINUTILS_SRC_VERSION

	if [ ! -f .config ]; then
		echo "  >> [1/$TASK_COUNT_TOTAL] Configuring Binutils (Native)..."
		$SRC/binutils-$BINUTILS_SRC_VERSION/configure \
		--prefix=$INSTALL_DIR \
		--enable-multilib \
		--disable-nls \
		--disable-shared \
		--disable-threads \
		--with-gcc \
		--with-gnu-as \
		--with-gnu-ld \
		--with-gmp=$INSTALL_DIR \
		--with-ppl=$INSTALL_DIR \
		--with-cloog=$INSTALL_DIR \
		&> $LOGPRE-binutils-config.txt
#		--target=x86_64-unknown-linux \
#		--enable-64-bit-bfd \
#		--without-ppl \
#		--without-cloog \

		check_error .config
	fi

	if [ ! -f .make ]
	then
		echo "  >> [2/$TASK_COUNT_TOTAL] Building Binutils (Native)..."
		make $JOBS &> $LOGPRE-binutils-make.txt
		check_error .make
	fi

	if [ ! -f .make-install ]
	then
		echo "  >> [3/$TASK_COUNT_TOTAL] Installing Binutils (Native)..."
		make install &> $LOGPRE-binutils-install.txt
		check_error .make-install
	fi
	echo "  >> Binutils (Native) Installed"

}

################################################################################
# Build the Native Compiler (using the compiler found on PATH).
################################################################################

function build_native_toolchain()
{
	echo "  ( ) Start Processing GNAT/GCC for $NATIVE_LANGUAGES (Native)"

	# Apply patches to GCC
	apply_native_gcc_patches

	# Constants
	TASK_COUNT_TOTAL=7
	VER="native"
	DIRS="binutils-$BINUTILS_SRC_VERSION gcc-$GCC_VERSION"
	LOGPRE=$LOG/native
	CBD=$BLD/$VER

	echo "  >> Creating Directories (if needed)..."
	cd $BLD
	for d in $DIRS; do
		if [ ! -d $VER/$d ]; then
			mkdir -p $VER/$d
		fi
    done

	# Paths
	export PATH=$INSTALL_DIR/bin:$PATH
	export LD_LIBRARY_PATH=$INSTALL_DIR/lib:$INSTALL_DIR/lib$BITS:$LD_LIBRARY_PATH

	# Build native binutils
	build_native_binutils

	# mpfr and mpc built from in gcc tree
	cd $GCC_DIR
	create_gcc_symlinks

	# Build native GCC compiler
	cd $CBD/gcc-$GCC_VERSION

	if [ ! -f .config ]; then
	echo "  >> [4/$TASK_COUNT_TOTAL] Configuring GNAT/GCC (Native)..."
	$GCC_DIR/configure \
		--prefix=$INSTALL_DIR \
		--enable-multilib \
		--enable-threads=posix \
		--enable-shared \
		--with-gnu-as \
		--with-gnu-ld \
		--enable-languages=$NATIVE_LANGUAGES \
		--with-system-zlib \
		--disable-libgomp \
		--without-libffi \
		--without-libiconv-prefix \
		--disable-libmudflap \
		--disable-nls \
		--disable-libstdcxx-pch \
		--with-gmp=$INSTALL_DIR \
		--with-ppl=$INSTALL_DIR \
		--with-cloog=$INSTALL_DIR \
		CFLAGS="$EXTRA_NATIVE_CFLAGS" \
		$EXTRA_NATIVE_GCC_CONFIGURE_FLAGS \
		&> $LOGPRE-gcc-$GCC_VERSION-configure.txt

	check_error .config
	fi

	if [ ! -f .make ]; then
		echo "  >> [5/$TASK_COUNT_TOTAL] Building and Bootstrapping GNAT/GCC (Native)..."
		make $JOBS &> $LOGPRE-gcc-$GCC_VERSION-make.txt

	check_error .make
	fi

	if [ ! -f .make-install ]; then
		echo "  >> [6/$TASK_COUNT_TOTAL] Installing GNAT/GCC (Native)..."
		make install &> $LOGPRE-gcc-$GCC_VERSION-install.txt

	check_error .make-install
	fi

	if [ ! -f .test-gcc ]; then
		echo "  >> [7/$TASK_COUNT_TOTAL] Testing GNAT/GCC (Native)..."
		make -k check-gcc &> $LOGPRE-gcc-$GCC_VERSION-test.txt

	check_error .test-gcc
	fi

	echo "  (x) Finished Processing GNAT/GCC for C/C++/Ada (Native)"

	# Get back to the build directory.
	cd $BLD
}

################################################################################
# $1 = Target.
# $2 = Any extra configure parameters.
################################################################################
function build_cross_toolchain()
{
	echo "  ( ) Start Processing GNAT/GCC for $1"

	apply_cross_gcc_patches

	cd $BLD

	VER=$1
	STAGE="$VER"
	DIRS="binutils-$BINUTILS_SRC_VERSION gcc1 newlib gcc2"
    
	local TASK_COUNT_TOTAL=13
	echo "  >> [1/$TASK_COUNT_TOTAL] Creating Directories (if needed)..."

	for d in $DIRS; do
		if [ ! -d $STAGE/$d ]; 	then
			mkdir -p $STAGE/$d
		fi
	done

	LOGPRE=$LOG/$1
	CBD=$BLD/$STAGE

	export PATH=$INSTALL_DIR/bin:$PATH
	export LD_LIBRARY_PATH=$INSTALL_DIR/lib:$INSTALL_DIR/lib$BITS:$LD_LIBRARY_PATH

	# Build Cross version of BinUtils.
	cd $CBD/binutils-$BINUTILS_SRC_VERSION

	if [ ! -f .config ]; then
		echo "  >> [2/$TASK_COUNT_TOTAL] Configuring Binutils for $1..."
		$SRC/binutils-$BINUTILS_SRC_VERSION/configure \
		--prefix=$INSTALL_DIR \
		--target=$1 \
		$2 \
		--enable-multilib \
		--disable-nls \
		--disable-shared \
		--disable-threads \
		--with-gcc \
		--with-gnu-as \
		--with-gnu-ld \
		--with-gmp=$INSTALL_DIR \
		--with-ppl=$INSTALL_DIR \
		--with-cloog=$INSTALL_DIR \
		&> $LOGPRE-binutils-config.txt
#		--without-ppl \
#		--without-cloog \

		check_error .config
	fi

	if [ ! -f .make ]; then
		echo "  >> [3/$TASK_COUNT_TOTAL] Building Binutils for $1..."
		make $JOBS &> $LOGPRE-binutils-make.txt
		check_error .make
	fi

	if [ ! -f .make-install ]; then
		echo "  >> [4/$TASK_COUNT_TOTAL] Installing Binutils for $1..."
		make install &> $LOGPRE-binutils-install.txt
		check_error .make-install
	fi
	echo "  >> Binutils Installed"

	LAST=`pwd`

	# Build stage 1 GCC with C only.
	cd $CBD/gcc1

	if [ -f $LAST/.make-install ]; then
	if [ ! -f .config ]; then
		echo "  >> [5/$TASK_COUNT_TOTAL] Configuring Cross Stage 1 GCC (C Only)..."
		$GCC_DIR/configure \
		--prefix=$INSTALL_DIR \
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
		--with-gmp=$INSTALL_DIR \
		--with-ppl=$INSTALL_DIR \
		--with-cloog=$INSTALL_DIR \
		&> $LOGPRE-gcc1-config.txt
#		--without-ppl \
#		--without-cloog \

		check_error .config
	fi

	if [ ! -f .make ]; then
		echo "  >> [6/$TASK_COUNT_TOTAL] Building Cross Stage 1 GCC (C Only)..."
		# use all-gcc, otherwise libiberty fails as it requires sys/types.h
		# which doesn't exist and tbh, shouldn't even be getting built, it's
		# a bug which has been reported here:
		#   http://gcc.gnu.org/bugzilla/show_bug.cgi?id=43073
		make $JOBS all-gcc &> $LOGPRE-gcc1-make.txt

		check_error .make
	fi

	if [ ! -f .make-install ]; then
		echo "  >> [7/$TASK_COUNT_TOTAL] Installing Cross Stage 1 GCC (C Only)..."
		make install-gcc &> $LOGPRE-gcc1-install.txt

	    check_error .make-install
	fi
	fi
	echo "  (x) Cross Stage 1 GCC (C Only) Installed"

	LAST=`pwd`

	# Build NewLib
	cd $CBD/newlib

	if [ -f $LAST/.make-install ]; then
		if [ ! -f .config ]; then
			echo "  >> [8/$TASK_COUNT_TOTAL] Configuring Newlib for $1..."
			$SRC/newlib-$NEWLIB_VERSION/configure \
			--prefix=$INSTALL_DIR \
			--target=$1 \
			$2 \
			--enable-multilib \
			--with-gnu-as \
			--with-gnu-ld \
			--disable-nls \
		--with-gmp=$INSTALL_DIR \
		--with-ppl=$INSTALL_DIR \
		--with-cloog=$INSTALL_DIR \
			&> $LOGPRE-newlib-config.txt
#			--without-ppl \
#			--without-cloog \

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

	# Build Stage 2 GCC with C, C++ & Ada
	cd $CBD/gcc2

	if [ -f $LAST/.make-install ]; then
	if [ ! -f .config ]; then
		echo "  >> [11/$TASK_COUNT_TOTAL] Configuring Cross Stage 2 GCC (C/Ada)..."
		$GCC_DIR/configure \
		--prefix=$INSTALL_DIR \
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
		--enable-languages=c,c++,ada \
		--disable-libssp \
		--with-gmp=$INSTALL_DIR \
		--with-ppl=$INSTALL_DIR \
		--with-cloog=$INSTALL_DIR \
		&> $LOGPRE-gcc2-config.txt
#		--without-ppl \
#		--without-cloog \
# this next line actually forces gnattools not to build!
#		--disable-libada \

		check_error .config
	fi

	if [ ! -f .make ]; then
		echo "  >> [12/$TASK_COUNT_TOTAL] Building Cross Stage 2 GCC (C/Ada)..."
		make $JOBS &> $LOGPRE-gcc2-make.txt

		check_error .make
	fi

	# if [ ! -f .make-gnattools ]; then
	# 	echo "  >> [13/$TASK_COUNT_TOTAL] Building Cross Stage 2 GCC (GNAT Tools)..."
	# 	make $JOBS all-gnattools &> $LOGPRE-gcc2-make-gnattools.txt

	# 	check_error .make-gnattools
	# fi

	if [ ! -f .make-install ]; then
		echo "  >> [13/$TASK_COUNT_TOTAL] Installing Cross Stage 2 GCC (C/Ada)..."
		make install &> $LOGPRE-gcc2-install.txt

		check_error .make-install
	fi
	fi

	echo "  (x) Cross Stage 2 GCC (C/Ada) Installed"

	# Get back to the build directory.
	cd $BLD
}

function build_stlink()
{
    echo "  ( ) Start Processing stlink for $1"

    cd $BLD

    VER=$1
    STAGE="$VER"
    DIRS="stlink"
    
    echo "  >> Creating Directories (if needed)..."

    for d in $DIRS; do
	if [ ! -d $STAGE/$d ]; 	then
	    mkdir -p $STAGE/$d
	fi
    done

    LOGPRE=$LOG/$1
    CBD=$BLD/$STAGE

    cd $CBD/stlink

    make

    if [ ! -f .make ]; then
	echo "  >> [1] Building stlink for $1..."
	make &> $LOGPRE-stlink-make.txt
	check_error .make
    fi

    if [ ! -f .make-install ]; then
	echo "  >> [2] Installing stlink..."
	cp gdbserver/st-util $INSTALL_DIR/bin &> $LOGPRE-stlink-install.txt

	check_error .make-install
    fi
}

function build_qemu()
{
    cd $BLD

    if [ ! -d qemu ]
    then
	mkdir -p qemu
    fi

    cd qemu

    if [ ! -f .config ]
    then
	echo "  >> Configuring qemu..."

	$SRC/qemu/configure --prefix=$INSTALL_DIR \
	    --extra-cflags="-Wunused-function" \
	    --disable-werror \
	    &> $LOG/qemu-config.txt

	check_error .config
    fi

    if [ ! -f .make ]
    then
	echo "  >> Building qemu..."

	make config-host.h all &> $LOG/qemu-make.txt

	check_error .make
    fi

    if [ ! -f .make-install  ]
    then
	echo "  >> Installing qemu..."

	make install &> $LOG/qemu-make-install.txt

	check_error .make-install
    fi
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

################################################################################
# Install GNAT wrappers where we cannot build cross versions
# of the gnattools
# $1 = target (i.e. arm-none-eabi)
# $2 = install directory
################################################################################

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

################################################################################
# Download and unpack sources
################################################################################

$TOP/download.sh

################################################################################
# Prepare log directory, start building
################################################################################

if [ ! -d $LOG ]; then
    mkdir -p $LOG
fi

TIMEFORMAT=$'  Last Process Took: %2lR';
# Begin the specified build operation
case "$targ" in
	native)	 		{ time {
#						if [ $GCC_VERSION == "trunk" ]; then
							build_arithmetic_libs;
#						fi
							build_native_toolchain;
} }
					;;

	arm-none-eabi)	 { time { build_cross_toolchain arm-none-eabi --enable-interwork; } }
					#build_u_boot arm-none-eabi
					#install_wrappers arm-none-eabi $PREFIX/bin
					;;

	i386-elf)		{ time { build_cross_toolchain i386-elf; } }
					;;

	mips-elf)		{ time { build_cross_toolchain mips-elf; } }
					;;

	*)				# Default
					{ time {

#						if [ $GCC_VERSION == "trunk" ]; then
							build_arithmetic_libs;
#						fi

							build_native_toolchain;
							#time ( build_cross_toolchain arm-none-eabi --enable-interwork );
							#build_cross_toolchain i386-elf;
							#build_cross_toolchain mips-elf;
					} }
					;;
esac

#build_u_boot arm-none-eabi
#install_wrappers arm-none-eabi $PREFIX/bin

exit 0
