################################################################################
# Filename         # build-tools.sh
# Purpose          # Download and batch build toolchain components
# Description      #
# Copyright        # Luke A. Guest, David Rees Copyright (C) 2011
################################################################################
#!/bin/bash

VERSION="build-tools.sh v1.0 (20110216)"

usage="\
$VERSION
Copyright (C) 2011 Luke A. Guest, David Rees. All Rights Reserved.

Usage: $0 [-t] TARGET

Options:

     --help       display this help and exit.
     --version    display version info and exit.

     -t TARGET    Build AMPC toolchain for specified TARGET

                  Valid values for TARGET
                  -----------------------
                  native
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
          native) targ="native"; break ;;
          arm-none-eabi) targ="arm-none-eabi"; break ;;
          i386-elf) targ="i386-elf"; break ;;
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

  This script is provided to simplify the installation of the Ada Microkernel
  Project Compilers (Native and Cross). For basic usage information, run:

  ./build-tools.sh --help

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
  
  Hit RETURN to continue.
START

read x

#exit

source ./errors.inc

################################################################################
# Logs from various stages of the build process are placed in the build/logs
# directory and has a standardised naming, i.e.
#   [description]-[config|make|check|install].txt
################################################################################

if [ ! -f ./config.inc ]; then
	display_no_config_error
else
	source ./config.inc
fi

# Ask nicely before deleting anything
if [ -d $BLD ]; then
    while true; do
        echo    "  ----------------------------------------------"
		echo    "  -- NOTE: Toolchain build directories exist! --"
		echo    "  ----------------------------------------------"
        read -p "  (R)emove all build directories, (c)ontinue, or (e)xit script? " builddir
	case $builddir in
		[R]* ) rm -Rf $BLD; break;;
		[Cc]* ) break ;;
		[Ee]* ) exit;;
		* ) echo "  Please answer 'R', '[C/c]' or '[E/e]'.";;
	esac
    done
fi

################################################################################
# Reverse patches if needed, before rebuilding native
################################################################################

function reverse_patches()
{
	echo "  >> Reversing patches that were previously applied to src/gcc"
	cat $TOP/patches/gcc-4.6/* | patch -p1 -s -t -d $SRC/gcc -i -;
	rm -f $SRC/gcc/.patched;    
}


if [ -f $SRC/gcc/.patched ]; then
	while true; do

cat<<REVERSE_PATCHES

  WARNING: It appears that patches have already been applied to the src/gcc
  directory!

  If you have to build the native compiler again after having already built
  the cross compilers, you will need to reverse the patches, as they're
  incompatible with the native build.

  Note: This script will try to re-apply them for cross builds.

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
# Display some configuration details
################################################################################

cd $TOP
echo ""
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
echo ""

################################################################################
# GCC patches for AMPC-Cross
#
################################################################################

function apply_cross_gcc_patches()
{   
    # Patch gcc trunk source
	if [ $GCC_FROM_REPO = "yes" ]; then
	    
		cd $SRC/gcc
		if [ ! -f .patched ]; then
			
			local PATCHES="gnattools2.patch gnattools3.patch \
			gnatlib.patch gnatlib2.patch gnatlib3.patch"

			echo "  >> Patching GCC Sources for AMPC-Cross..."
			for p in $PATCHES; do
				patch -p1 -s -d $SRC/gcc < $TOP/patches/gcc-4.6/$p
				check_error .patched
			done
		fi
	# Patch gcc snapshots or releases
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
    DIRS="gcc"
    LOGPRE=$LOG/native
    CBD=$BLD/$VER

    echo "  >> [1/$TASK_COUNT_TOTAL] Creating Directories (if needed)..."

    for d in $DIRS; do
	if [ ! -d $VER/$d ]; then
		mkdir -p $VER/$d
	fi
    done

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
	    CFLAGS="$EXTRA_NATIVE_CFLAGS" \
	    --without-libffi \
	    --without-libiconv-prefix \
	    --disable-libmudflap \
	    --disable-nls \
	    --disable-libstdcxx-pch \
	    &> $LOGPRE-gcc-$GCC_VERSION-configure.txt

	check_error .config
    fi

    if [ ! -f .make ]; then
	    echo "  >> [3/$TASK_COUNT_TOTAL] Building and Bootstrapping AMPC-Native GCC..."
		make $JOBS &> $LOGPRE-gcc-$GCC_VERSION-make.txt

	check_error .make
    fi

    if [ ! -f .make-install ]; then
	    echo "  >> [4/$TASK_COUNT_TOTAL] Installing AMPC-Native GCC..."
		make install &> $LOGPRE-gcc-$GCC_VERSION-install.txt

	check_error .make-install
    fi

    if [ ! -f .test-gcc ]; then
	    echo "  >> [5/$TASK_COUNT_TOTAL] Testing AMPC-Native GCC..."
		make -k check-gcc &> $LOGPRE-gcc-$GCC_VERSION-test.txt

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
	native)				
					time( build_native_toolchain );
					;;

	arm-none-eabi)
					time( build_toolchain arm-none-eabi --enable-interwork );
					#build_u_boot arm-none-eabi
					#install_wrappers arm-none-eabi $PREFIX/bin
					;;
	i386-elf)
					time ( build-toolchain i386-elf );
					;;

	mips-elf)
					time ( build-toolchain mips-elf );
					;;

	*)
					# Default / Batch
					time ( build_native_toolchain );
					time ( build_toolchain arm-none-eabi --enable-interwork );
					#build_toolchain i386-elf;
					#build_toolchain mips-elf;
					;;
esac

#build_u_boot arm-none-eabi
#install_wrappers arm-none-eabi $PREFIX/bin

exit 0
