################################################################################
# Filename         # errors.inc
# Purpose          # Common error handling functions.
# Description      #
# Copyright        # Luke A. Guest, David Rees Copyright (C) 2011
################################################################################

function check_error_exit()
{
    if [ $? != 0 ]
    then
        echo "** Error - Something went wrong!"
        exit 2;
    fi
}

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
