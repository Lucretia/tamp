################################################################################
# Filename         # build-rts.sh
# Purpose          # Build the Zero-Footprint-Profile Runtime System.
# Description      #
# Copyright        # Luke A. Guest, David Rees Copyright (C) 2011
################################################################################
#!/bin/sh
clear
source ./errors.inc

# This defines the boards we currently support. This will also define where
# the RTS is built.
BOARDS="stm32f4"

function list_boards()
{
    echo "  Boardname is one of:"

    for b in $BOARDS
    do
	echo "  $b"
    done
}

if [ ! -f ./config.inc ]; then

cat << 'NOCONFIG_ERR'

  ERROR: No config.inc found.

  1) cp config-master.inc config.inc
  2) Edit config.inc for your system
  3) ./build-tools.sh
  4) Run this script again

NOCONFIG_ERR

    exit 2

else
    source ./config.inc
fi

if [ $# == 0 ]
then
    echo "  Usage:"
    echo "  ./build-rts.sh <boardname>"
    echo "  or"
    echo "  ./build-rts.sh <boardname> rebuild"
    echo "  or"
    echo "  ./build-rts.sh clean"
    echo ""

    list_boards

    exit 2
fi

echo "  Creating RTS with GCC-$GCC_VERSION for '$1' board"

export PATH=$INSTALL_DIR/bin:$PATH
export LD_LIBRARY_PATH=$INSTALL_DIR/lib:$INSTALL_DIR/lib$BITS:$LD_LIBRARY_PATH

RTS=$TOP/../rts


# $1 = board name
function check_board_name()
{
    if [[ ! $BOARDS =~ $1 ]]
    then
	echo "  ERROR: Incorrect board name selected"
	echo ""

	list_boards

	exit 2
    fi
}

function create_dirs()
{
    cd $RTS

    echo "  >> Creating RTS dirs..."

    if [ ! -d  obj ]
    then
	mkdir -p obj
    fi

    if [ ! -d  boards ]
    then
	mkdir -p boards
    fi

    for b in $BOARDS
    do
	if [ ! -d boards/$b ]
	then
	    mkdir -p boards/$b/adainclude
	    mkdir -p boards/$b/adalib
	fi
    done
}

# i-c.ads i-c.adb 
SPECS="ada.ads a-unccon.ads a-uncdea.ads gnat.ads g-souinf.ads interfac.ads s-stoele.ads s-atacco.ads s-maccod.ads"
BODIES="s-stoele.adb s-atacco.adb"

# function copy_rts_files()
# {
#     if [ ! -f $RTS/.rts_copied ]
#     then
# 	FILES="$SPECS $BODIES"

# 	for f in $FILES
# 	do
# 	    echo "  >> Copying $GCC_DIR/gcc/ada/$f to $RTS/src/common..."

# 	    cp $GCC_DIR/gcc/ada/$f $RTS/src/common

# 	    check_error_exit
# 	done

# 	check_error $RTS/.rts_copied
#     fi
# }

# $1 = board name
function create_symlinks()
{
    cd $RTS/boards/$1/adainclude

    if [ ! -f .symlinks ]
    then
	FILES=$SPECS

	for f in $FILES
	do
	    echo "  >> Linking $f to $RTS/src/common/$f..."

	    ln -s $RTS/src/common/$f $f

	    check_error_exit
	done

	FILES=$BODIES

	for f in $FILES
	do
	    echo "  >> Linking $f to $RTS/src/common/$f..."

	    ln -s $RTS/src/common/$f $f

	    check_error_exit
	done

	echo "  >> Linking system.ads to $RTS/src/boards/$1/system.ads..."

	ln -s $RTS/src/boards/$1/system.ads system.ads

	check_error .symlinks
    fi
}

# $1 = board name
function build_rts()
{
#    export PATH=$INSTALL_DIR/bin:$PATH
#    export LD_LIBRARY_PATH=$INSTALL_DIR/lib$BITS:$LD_LIBRARY_PATH

    cd $RTS

    GNATMAKE=""

    case $1 in
	"pc")
	    GNATMAKE="gnatmake"
	    ;;
	"stm32f4")
	    GNATMAKE="arm-none-eabi-gnatmake"
	    ;;
    esac

    FLAGS="-gnatf -gnatv"

#    $GNATMAKE --RTS=$RTS/boards/$1 -XBoard=$1 -Pgnat.gpr

    BOARD=$1 make
}


function clean_objs()
{
    cd $RTS

    rm obj/*
}


# copy_rts_files

if [ $1 = "clean" ]
then
    rm -rf obj
    rm -rf boards
else
    if [ $2 = "rebuild" ]
    then
	cd $RTS

	BOARD=$1 make clean
    fi

    check_board_name $1
    create_dirs
    create_symlinks $1
    echo "Using : " `which arm-none-eabi-gnatmake`
    build_rts $1
    clean_objs
fi

cd $TOP
