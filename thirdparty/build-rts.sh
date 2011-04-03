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
BOARDS="xpresso1769 beagle pc"

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

if [ $# != 1 ]
then
    echo "  Usage:"
    echo "  ./build-rts.sh <boardname>"
    echo ""

    list_boards

    exit 2
fi

echo "  Creating RTS with GCC-$GCC_VERSION for '$1' board"

export PATH=$TAMP/bin:$PATH
export LD_LIBRARY_PATH=$TAMP/lib$BITS:$LD_LIBRARY_PATH

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

# i-c.ads i-c.adb interfac.ads
SPECS="ada.ads a-unccon.ads a-uncdea.ads s-stoele.ads s-atacco.ads s-maccod.ads gnat.ads g-souinf.ads"
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

	echo "  >> Linking system.ads to $RTS/src/boards/$1/system.ads..."

	ln -s $RTS/src/boards/$1/system.ads system.ads

	check_error .symlinks
    fi
}

# $1 = board name
function build_rts()
{
    export PATH=$TAMP/bin:$PATH
    export LD_LIBRARY_PATH=$TAMP/lib$BITS:$LD_LIBRARY_PATH

    cd $RTS

    GNATMAKE=""

    case $1 in
	"pc")
	    GNATMAKE="gnatmake"
	    ;;
	"beagle" | "xpresso1769")
	    GNATMAKE="arm-none-eabi-gnatmake"
	    ;;
    esac

#    $GNATMAKE --RTS=$RTS/boards/$1 -XBoard=$1 -Pgnat.gpr

    BOARD=$1 make
}


function clean_objs()
{
    cd $RTS

    rm obj/*
}


# copy_rts_files

check_board_name $1
create_dirs
create_symlinks $1
build_rts $1
clean_objs

cd $TOP
