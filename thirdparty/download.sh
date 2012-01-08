################################################################################
# Filename    # download.sh
# Purpose     # Downloads source required to build the toolchains
# Description # Used by the build-tools.sh script (run that instead)
# Copyright   # Copyright (C) 2011 Luke A. Guest, David Rees. All Rights Reserved.
################################################################################
#!/bin/bash

source ./errors.inc

function check_for_spark()
{
	if [ ! -f $SPARK_FILE ]; then

cat << SPARK_ERR

  NOTICE: Spark was not found in the downloads directory.
  
  1) Go to http://libre.adacore.com/libre/download/
  2) Download $SPARK_FILE
  3) Place the archive in the downloads directory
  4) Re-run this script

SPARK_ERR
	exit 2;
	fi
}


# Prepare Directories ##########################################################

DIRS="src downloads"
for d in $DIRS; do
	if [ ! -d $d ]; then
		mkdir -p $d
	fi
done

cd $TOP/downloads

#check_for_spark

# Begin Downloading ############################################################

echo "  >> Downloading source packages, this may take quite a while..."

# Binutils #####################################################################

	if [ ! -f binutils-$BINUTILS_VERSION.tar.bz2 ]; then
		echo "  >> Downloading binutils-$BINUTILS_VERSION..."
		wget -c $BINUTILS_TARBALL

		check_error_exit
	else
		echo "  (x) Already have binutils-$BINUTILS_VERSION"
	fi

# GDB Tarballs #####################################################################

	if [ ! -f gdb-$GDB_VERSION.tar.bz2 ]; then
		echo "  >> Downloading gdb-$GDB_VERSION..."
		wget -c $GDB_TARBALL

		check_error_exit
	else
		echo "  (x) Already have gdb-$GDB_VERSION"
	fi

# GCC Tarballs #################################################################

if [ $GCC_FROM_REPO == "n" ]; then

	if [ $GCC_SRC_TYPE == "release" ]; then
	# Begin Release Tarballs
		if [ ! -f gcc-core-$GCC_VERSION.tar.bz2 ]; then
			echo "  >> Downloading GCC-core-$GCC_VERSION..."
			wget -c $GCC_MIRROR/gcc-core-$GCC_VERSION.tar.bz2
			check_error_exit
		else
			echo "  (x) Already have GCC-core-$GCC_VERSION"
		fi

		if [ ! -f gcc-ada-$GCC_VERSION.tar.bz2 ]; then
			echo "  >> Downloading GCC-ada-$GCC_VERSION..."
			wget -c $GCC_MIRROR/gcc-ada-$GCC_VERSION.tar.bz2
			check_error_exit
		else
			echo "  (x) Already have GCC-ada-$GCC_VERSION"
		fi

		if [ ! -f gcc-g++-$GCC_VERSION.tar.bz2 ]; then
			echo "  >> Downloading GCC-g++-$GCC_VERSION..."
			wget $GCC_MIRROR/gcc-g++-$GCC_VERSION.tar.bz2
			check_error_exit
		else
			echo "  (x) Already have GCC-g++-$GCC_VERSION"
		fi
	
		if [ ! -f gcc-testsuite-$GCC_VERSION.tar.bz2 ]; then
			echo "  >> Downloading GCC-testsuite-$GCC_VERSION..."
			wget -c $GCC_MIRROR/gcc-testsuite-$GCC_VERSION.tar.bz2
			check_error_exit
		else
			echo "  (x) Already have GCC-testsuite-$GCC_VERSION"
		fi
	elif [ $GCC_SRC_TYPE == "snapshot" ]; then
	# End Release Tarballs
	# Begin Snapshot Tarball
		if [ ! -f gcc-$GCC_VERSION.tar.bz2 ]; then
			echo "  >> Downloading GCC-$GCC_VERSION..."
			wget -c $GCC_MIRROR/gcc-$GCC_VERSION.tar.bz2
			check_error_exit
		else
			echo "  (x) Already have GCC-$GCC_VERSION"
		fi
	fi # End Snapshot Tarball

fi # End $GCC_FROM_REPO == "n"

# Extras/Optimisation Libraries ################################################
	if [ ! -f gmp-$GMP_VERSION.tar.gz ]; then
		echo "  >> Downloading gmp-$GMP_VERSION..."
		wget -c $GMP_MIRROR/gmp-$GMP_VERSION.tar.gz
		check_error_exit
	else
		echo "  (x) Already have gmp-$GMP_VERSION"
	fi

	if [ ! -f mpfr-$MPFR_VERSION.tar.bz2 ]; then
		echo "  >> Downloading mpfr-$MPFR_VERSION..."
		wget -c $MPFR_MIRROR/mpfr-$MPFR_VERSION.tar.bz2
		check_error_exit
	else
		echo "  (x) Already have mpfr-$MPFR_VERSION"
	fi

	if [ ! -f mpc-$MPC_VERSION.tar.gz ]; then
		echo "  >> Downloading mpc-$MPC_VERSION..."
		wget -c $MPC_MIRROR/mpc-$MPC_VERSION.tar.gz
		check_error_exit
	else
		echo "  (x) Already have mpc-$MPC_VERSION"
	fi

	if [ ! -f newlib-$NEWLIB_VERSION.tar.gz ]; then
		echo "  >> newlib-$NEWLIB_VERSION.tar.gz..."
		wget -c $NEWLIB_MIRROR/newlib-$NEWLIB_VERSION.tar.gz
		check_error_exit
	else
		echo "  (x) Already have newlib-$NEWLIB_VERSION.tar.gz"
	fi

	if [ ! -f ppl-$PPL_VERSION.tar.gz ]
	then
	    echo "  >> ppl-$PPL_VERSION.tar.gz..."
	    wget -c $PPL_MIRROR/ppl-$PPL_VERSION.tar.gz
	    check_error_exit
	else
	    echo "  (x) Already have ppl-$PPL_VERSION.tar.gz"
	fi

	if [ ! -f cloog-ppl-$CLOOG_PPL_VERSION.tar.gz ]
	then
	    echo "  >> cloog-ppl-$CLOOG_PPL_VERSION.tar.gz..."
	    wget -c $CLOOG_PPL_MIRROR/cloog-ppl-$CLOOG_PPL_VERSION.tar.gz
	    check_error_exit
	else
	    echo "  (x) Already have cloog-ppl-$CLOOG_PPL_VERSION.tar.gz"
	fi

	# if [ ! -f u-boot-$U_BOOT_VERSION.tar.bz2 ]
	# then
	#     echo "  >> Downloading u-boot-$U_BOOT_VERSION.tar.bz2..."
	#     wget -c $U_BOOT_MIRROR/u-boot-$U_BOOT_VERSION.tar.bz2

	#     check_error_exit
	# else
	#     echo "  (x) Already have u-boot-$U_BOOT_VERSION.tar.bz2"
	# fi

	# if [ ! -f x-load_revc_v3.bin.ift ]
	# then
	# 	wget http://beagleboard.googlecode.com/files/x-load_revc_v3.bin.ift
	# 	check_error_exit
	# else
	# 	echo "  (x) Already have x-load_revc_v3.bin.ift"
	# fi

	# if [ ! -f u-boot-f_revc_v3.bin ]
	# then
	# 	wget http://beagleboard.googlecode.com/files/u-boot-f_revc_v3.bin
	# 	check_error_exit
	# else
	# 	echo "  (x) Already have u-boot-f_revc_v3.bin"
	# fi

#################################################################################
# Unpack the downloaded archives.
#################################################################################

	cd $SRC

	if [ ! -d binutils-$BINUTILS_SRC_VERSION ]; then
		echo "  >> Unpacking binutils-$BINUTILS_VERSION.tar.bz2..."
		tar -xjpf $TOP/downloads/binutils-$BINUTILS_VERSION.tar.bz2
		check_error_exit
	fi

	if [ ! -d gdb-$GDB_SRC_VERSION ]; then
		echo "  >> Unpacking gdb-$GDB_VERSION.tar.bz2..."
		tar -xjpf $TOP/downloads/gdb-$GDB_VERSION.tar.bz2

		check_error_exit
	fi

	if [ ! -d gmp-$GMP_VERSION ]; then
		echo "  >> Unpacking gmp-$GMP_VERSION.tar.gz..."
		tar -xzpf $TOP/downloads/gmp-$GMP_VERSION.tar.gz
		check_error_exit
	fi

	if [ ! -d mpfr-$MPFR_VERSION ]; then
		echo "  >> Unpacking mpfr-$MPFR_VERSION.tar.bz2..."
		tar -xjpf $TOP/downloads/mpfr-$MPFR_VERSION.tar.bz2
		check_error_exit
	fi

cd mpfr-$MPFR_VERSION

	if [ ! -f .patched ]; then
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

cd $SRC

	if [ ! -d mpc-$MPC_VERSION ]; then
		echo "  >> Unpacking mpc-$MPC_VERSION.tar.gz..."
		tar -xzpf $TOP/downloads/mpc-$MPC_VERSION.tar.gz
		check_error_exit
	fi

	if [ ! -d newlib-$NEWLIB_VERSION ]; then
		echo "  >> Unpacking newlib-$NEWLIB_VERSION.tar.gz..."
		tar -xzpf $TOP/downloads/newlib-$NEWLIB_VERSION.tar.gz
		check_error_exit
	fi

	 if [ ! -d ppl-$PPL_VERSION ]; then
		 echo "  >> Unpacking ppl-$PPL_VERSION.tar.gz..."
		 tar -xzpf ../downloads/ppl-$PPL_VERSION.tar.gz
		 check_error_exit
	 fi

	 if [ ! -d cloog-ppl-$CLOOG_PPL_VERSION ]; then
		 echo "  >> Unpacking cloog-ppl-$CLOOG_PPL_VERSION.tar.gz..."
		 tar -xzpf ../downloads/cloog-ppl-$CLOOG_PPL_VERSION.tar.gz
		 check_error_exit
	 fi

if [ $GCC_FROM_REPO = "y" ]; then
    # export GCC_REPO_REVISION=`svn info svn://gcc.gnu.org/svn/gcc/trunk | sed -ne 's/^Revision: //p'`

    if [ ! -d $TOP/downloads/gcc-$GCC_VERSION ]; then
		echo "  >> Downloading GCC sources from the remote SVN repo, may take a while..."
		svn checkout -q $GCC_REPO $TOP/downloads/gcc-$GCC_VERSION
		cd $TOP/downloads/gcc-$GCC_VERSION
		svn export ./ $GCC_DIR
		check_error_exit

		cd $SRC
    else
    # gcc svn working tree already exists, update it

	    # cd $GCC_DIR
        # export GCC_PREV_REVISION=`cat $GCC_DIR/.revision`

        # if [ -f $GCC_DIR/.revision ] && (( $GCC_REPO_REVISION > $GCC_PREV_REVISION )); then

		echo "  >>>> Updating the local GCC source repository to the latest SVN revision,"
		echo "       then exporting them to the src directory."
		cd $TOP/downloads/gcc-$GCC_VERSION
		rm -Rf $GCC_DIR
		svn update
		svn export ./ $GCC_DIR
		check_error_exit

        #    ./contrib/gcc_update -q
        #    check_error_exit
        #    echo $GCC_REPO_REVISION > .revision
        #    apply_gcc_patches

        # elif [ -f $GCC_DIR/.revision ] && (( $GCC_REPO_REVISION == $GCC_PREV_REVISION )); then
        #    echo "  (x) Local GCC source revision $GCC_PREV_REVISION is up-to-date. Skipping."
        #    apply_gcc_patches
        # else
        #    echo "  >> Couldn't determine local GCC revision status,"
        #    echo "     try deleting the $GCC_DIR directory."
        # fi
	cd $SRC
    fi

else
	#GCC not from repo so extract sources from tarballs
	cd $SRC

	if [ $GCC_SRC_TYPE == "release" ]; then
	# Unpack Release Tarballs
		if [ ! -d $GCC_DIR ]; then
			echo "  >> Unpacking gcc-core-$GCC_VERSION.tar.bz2..."
			tar -xjpf $TOP/downloads/gcc-core-$GCC_VERSION.tar.bz2
			check_error_exit
		fi

		if [ ! -d $GCC_DIR/gcc/ada ]; then
			echo "  >> Unpacking gcc-ada-$GCC_VERSION.tar.bz2..."
			tar -xjpf $TOP/downloads/gcc-ada-$GCC_VERSION.tar.bz2
			check_error_exit
		fi

		 if [ ! -d gcc-$GCC_VERSION/gcc/cp ]; then
			 echo "  >> Unpacking gcc-g++-$GCC_VERSION.tar.bz2..."
			 tar -xjpf ../downloads/gcc-g++-$GCC_VERSION.tar.bz2
			 check_error_exit
		 fi

		if [ ! -d $GCC_DIR/gcc/testsuite ]; then
			echo "  >> Unpacking gcc-testsuite-$GCC_VERSION.tar.bz2..."
			tar -xjpf $TOP/downloads/gcc-testsuite-$GCC_VERSION.tar.bz2
			check_error_exit
		fi
	else
	# Unpack Snapshot Tarball
		if [ ! -d $GCC_DIR ]; then
			echo "  >> Unpacking gcc-$GCC_VERSION.tar.bz2..."
			tar -xjpf $TOP/downloads/gcc-$GCC_VERSION.tar.bz2
			check_error_exit
		fi
	fi

		cd $GCC_DIR
	#   apply_native_gcc_patches
	#   create_gcc_symlinks
		 cd $SRC
fi

# if [ ! -d u-boot-$U_BOOT_VERSION ]
# then
#     echo "  >> Unpacking u-boot-$U_BOOT_VERSION.tar.bz2..."
#     tar -xjpf ../downloads/u-boot-$U_BOOT_VERSION.tar.bz2
# fi

#################################################################################
# Download stlink from GitHub.
#################################################################################
if [ ! -d stlink ]
then
    echo "  >> Downloading stlink from GitHub..."
    git clone $STLINK_MIRROR stlink

    check_error_exit
else
    echo "  >> Already have stlink from GitHub"
fi

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

# Get back to the src directory.
cd $SRC
