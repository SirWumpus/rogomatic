#!/usr/bin/env bash
#
# mstop_rogo.sh - stop rerun cycles started by mrerun_rogo
#
# Copyright (c) 2026 by Landon Curt Noll.  All Rights Reserved.
#
# Permission to use, copy, modify, and distribute this software and
# its documentation for any purpose and without fee is hereby granted,
# provided that the above copyright, this permission notice and text
# this comment, and the disclaimer below appear in all of the following:
#
#       supporting documentation
#       source copies
#       source works derived from this source
#       binaries derived from this source or from derived source
#
# LANDON CURT NOLL DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
# INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO
# EVENT SHALL LANDON CURT NOLL BE LIABLE FOR ANY SPECIAL, INDIRECT OR
# CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF
# USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.
#
# chongo (Landon Curt Noll) /\oo/\
#
# http://www.isthe.com/chongo/index.html
# https://github.com/lcn2
#
# Share and enjoy!  :-)


# setup
#
export VERSION="1.0.0 2026-08-10"
NAME=$(basename "$0")
export NAME
#
export SCRIPT_PID="$$"
#
export V_FLAG=0
export SECS=""
#
export NOOP=
export DO_NOT_PROCESS=


# NOTE: The following BASE_RGMDIR is NOT the default for rogomatic (/var/tmp/rogomatic)
#       This means you can run rogue(6) and rogomatic by hand
#       while a rogomatic rerun loop is running without interference.
#
export BASE_RGMDIR="/var/tmp/mrogo"


# usage
#
export USAGE="usage: $0
        [-h] [-v level] [-V] [-n] [-N]
        [-D base_rgmdir] [ID ...]

    -h          print help message and exit
    -v level    set verbosity level (def level: $V_FLAG)
    -V          print version string and exit
    -n          go thru the actions, but do not update any files (def: do the action)
    -N          do not process anything, just parse arguments (def: process something)

    -D base_rgmdir      base dir under which a rogo.ID sub-dirs will used (def: $BASE_RGMDIR)

    [ID ...]    create a .stopfile for mrerun_rodo IDs (def: create for all sub-dirs under $BASE_RGMDIR)

Exit codes:
     0         all OK
     1         player already running, or failed to test the lock
     2         -h and help string printed or -V and version string printed
     3         command line error
     4         base_rgmdir, or computed rogomatic directory is not a valid writable directory
     5         failed to create a stopfile
 >= 10         internal error

$NAME version: $VERSION"


# parse command line
#
while getopts :hv:VnND: flag; do
  case "$flag" in
    h) echo "$USAGE"
	exit 2
	;;
    v) V_FLAG="$OPTARG"
	;;
    V) echo "$VERSION"
	exit 2
	;;
    n) NOOP="-n"
	;;
    N) DO_NOT_PROCESS="-N"
	;;

    D) BASE_RGMDIR="$OPTARG"
	;;

    \?) echo "$0: ERROR: invalid option: -$OPTARG" 1>&2
	echo 1>&2
	echo "$USAGE" 1>&2
	exit 3
	;;
    :) echo "$0: ERROR: option -$OPTARG requires an argument" 1>&2
	echo 1>&2
	echo "$USAGE" 1>&2
	exit 3
	;;
    *) echo "$0: ERROR: unexpected value from getopts: $flag" 1>&2
	echo 1>&2
	echo "$USAGE" 1>&2
	exit 3
	;;
  esac
done
if [[ $V_FLAG -ge 3 ]]; then
    echo "$0: debug[3]: debug level: $V_FLAG" 1>&2
fi
#
# remove the options
#
shift $(( OPTIND - 1 ));


# verify the rogomatic directory
#
if [[ ! -d $BASE_RGMDIR ]]; then
    mkdir -p "$BASE_RGMDIR"
fi
if [[ ! -e $BASE_RGMDIR ]]; then
    echo "$0: ERROR: non-existent rogomatic directory path: $BASE_RGMDIR" 1>&2
    exit 4
fi
if [[ ! -d $BASE_RGMDIR ]]; then
    echo "$0: ERROR: not a directory: $BASE_RGMDIR" 1>&2
    exit 4
fi
if [[ ! -w $BASE_RGMDIR ]]; then
    echo "$0: ERROR: not a writable directory: $BASE_RGMDIR" 1>&2
    exit 4
fi


# print running info if verbose
#
# If -v 3 or higher, print exported variables in order that they were exported.
#
if [[ $V_FLAG -ge 3 ]]; then
    echo "$0: debug[3]: VERSION=$VERSION" 1>&2
    echo "$0: debug[3]: NAME=$NAME" 1>&2
    echo "$0: debug[3]: SCRIPT_PID=$SCRIPT_PID" 1>&2
    echo "$0: debug[3]: V_FLAG=$V_FLAG" 1>&2
    echo "$0: debug[3]: SECS=$SECS" 1>&2
    echo "$0: debug[3]: NOOP=$NOOP" 1>&2
    echo "$0: debug[3]: DO_NOT_PROCESS=$DO_NOT_PROCESS" 1>&2
    echo "$0: debug[3]: BASE_RGMDIR=$BASE_RGMDIR" 1>&2
    if [[ $# -eq 0 ]]; then
	echo "$0: debug[3]: no ID args given, process all rogo.ID subdirs of: $BASE_RGMDIR" 1>&2
    else
	for ID in "$@"; do
	    echo "$0: debug[3]: process ID: $ID" 1>&2
	done
    fi
fi


# -N stops early before any processing is performed
#
if [[ -n $DO_NOT_PROCESS ]]; then
    if [[ $V_FLAG -ge 3 ]]; then
	echo "$0: debug[3]: arguments parsed, -N given, exiting 0" 1>&2
    fi
    exit 0
fi


# case: 1 or more ID args given
#
export RGMDIR=
if [[ $# -gt 0 ]]; then

    # sanity check: each ID has a writable sub-directory
    #
    for ID in "$@"; do

	# determine proper rogomatic directory for this ID
	#
	RGMDIR="$BASE_RGMDIR/rogo.$ID"

	# verify the rogomatic directory for this ID is a writable directory
	#
	if [[ ! -d $RGMDIR || ! -w $RGMDIR ]]; then
	    echo "$0: ERROR: ID: $ID does not have a valid writable sub-directory: $RGMDIR" 1>&2
	    exit 6
	fi
    done

    # form stopfiles for each ID
    #
    for ID in "$@"; do

	# determine proper rogomatic directory for this ID
	#
	STOP_FILE="$BASE_RGMDIR/rogo.$ID/.stopfile"

	# create stopfile for this ID
	#
	if [[ -z $NOOP ]]; then

	    # form stopfile
	    #
	    touch "$STOP_FILE" >/dev/null 2>&1
	    if [[ ! -e $STOP_FILE ]]; then
		echo "$0: ERROR: failed to create stopfile: $STOP_FILE" 1>&2
		exit 5
	    elif [[ $V_FLAG -ge 1 ]]; then
		echo "$0: notice: created stopfile: $STOP_FILE" 1>&2
	    fi

	elif [[ $V_FLAG -ge 3 ]]; then
	    echo "$0: debug[3]: because of -n, did not create: $STOP_FILE" 1>&2
	fi
    done

# case: no ID args
#
# Create .stopfile under all sub-directories under $BASE_RGMDIR
#
else

    # look for rogo.ID sub-directories under $BASE_RGMDIR
    #
    RMGDIR_SET="$(find "$BASE_RGMDIR" -mindepth 1 -maxdepth 1 -type d -name 'rogo.*' 2>/dev/null | LC_ALL=C sort)"
    if [[ -z $RMGDIR_SET ]]; then
	echo "$0: ERROR: no rogo.ID sub-directories found under: $BASE_RGMDIR" 1>&2
	exit 6
    fi

    # sanity check: all sub-directory is a writable directory
    #
    for RGMDIR in $RMGDIR_SET; do

	# verify a writable rogomatic directory for this sub-directory
	#
	if [[ ! -d $RGMDIR || ! -w $RGMDIR ]]; then
	    echo "$0: ERROR: not a writable sub-directory: $RGMDIR" 1>&2
	    exit 6
	fi
    done

    # create stopfile for this sub-directory
    #
    for RGMDIR in $RMGDIR_SET; do

	# determine proper rogomatic directory for this sub-directory
	#
	STOP_FILE="$RGMDIR/.stopfile"

	# create stopfile
	#
	if [[ -z $NOOP ]]; then

	    # form stopfile
	    #
	    touch "$STOP_FILE" >/dev/null 2>&1
	    if [[ ! -e $STOP_FILE ]]; then
		echo "$0: ERROR: failed to form stopfile: $STOP_FILE" 1>&2
		exit 5
	    elif [[ $V_FLAG -ge 1 ]]; then
		echo "$0: notice: formed stopfile: $STOP_FILE" 1>&2
	    fi

	elif [[ $V_FLAG -ge 3 ]]; then
	    echo "$0: debug[3]: because of -n, did not create: $STOP_FILE" 1>&2
	fi
    done
fi


# All Done!!! -- Jessica Noll, Age 2
#
exit 0
