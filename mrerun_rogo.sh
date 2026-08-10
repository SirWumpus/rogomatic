#!/usr/bin/env bash
#
# mrerun_rogo.sh - run multiple parallel rogomatic over and over again
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
export VERSION="1.0.1 2026-08-10"
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
#
# This next setting is just for the usage message
RERUN_ROGO_TOOL=$(type -P rerun_rogo)
if [[ -x ./rerun_rogo ]]; then
    RERUN_ROGO_TOOL="./rerun_rogo"
elif [[ -x ./rerun_rogo.sh ]]; then
    RERUN_ROGO_TOOL="./rerun_rogo.sh"
fi
export RERUN_ROGO_TOOL
#
# This next setting is just for the usage message
RUN_ROGO_TOOL=$(type -P run_rogo)
if [[ -x ./run_rogo ]]; then
    RUN_ROGO_TOOL="./run_rogo"
elif [[ -x ./run_rogo.sh ]]; then
    RUN_ROGO_TOOL="./run_rogo.sh"
fi
export RUN_ROGO_TOOL
#
# This next setting is just for the usage message
ROGOMATIC_TOOL=$(type -P rogomatic)
if [[ -x ./rogomatic ]]; then
    ROGOMATIC_TOOL="./rogomatic"
fi
export ROGOMATIC_TOOL
#
# This next setting is just for the usage message
PLAYER_TOOL=$(type -P player)
if [[ -x ./player ]]; then
    PLAYER_TOOL="./player"
fi
export PLAYER_TOOL
#
# This next setting is just for the usage message
ROGUE_TOOL=$(type -P rogue)
if [[ -x ../rogue5.4/rogue ]]; then
    ROGUE_TOOL="../rogue5.4/rogue"
elif [[ -x ./rogue ]]; then
    ROGUE_TOOL="./rogue"
fi
export ROGUE_TOOL
#
# This next setting is just for the usage message
UNSTUCK_PLAYER_TOOL=$(type -P unstuck_player)
if [[ -x ./unstuck_player ]]; then
    UNSTUCK_PLAYER_TOOL="./unstuck_player"
elif [[ -x ./unstuck_player.sh ]]; then
    UNSTUCK_PLAYER_TOOL="./unstuck_player.sh"
fi
export UNSTUCK_PLAYER_TOOL
#
export GOODGAME=20
export USLEEP=14000
export CAP_H_FLAG=
export CAP_G_FLAG=
export CAP_U_FLAG=
export D_FLAG=
export E_FLAG=
export CAP_Z_FLAG=
export QUIET_MODE=
export CRASH_BASE_DIR=


# NOTE: The following BASE_RGMDIR is NOT the default for rogomatic (/var/tmp/rogomatic)
#       This means you can run rogue(6) and rogomatic by hand
#       while a rogomatic rerun loop is running without interference.
#
export BASE_RGMDIR="/var/tmp/mrogo"
export S_FLAG=
export STOP_FILE=


# find_progs - find executables, and set run_rogo command line options
#
# We search the local directory, nearby directory in case of rogue,
# and along the $PATH.  We do this in case we are building in the source
# code directory and don't want to crash a long running rerun_rogo run.
#
function find_progs
{
    # verify that the rerun_rogo tool is executable
    #
    if [[ ! -e $RERUN_ROGO_TOOL ]]; then
	echo "$0: Warning: rerun_rogo does not exist: $RERUN_ROGO_TOOL" 1>&2
	return 1
    fi
    if [[ ! -f $RERUN_ROGO_TOOL ]]; then
	echo "$0: Warning: rerun_rogo is not a regular file: $RERUN_ROGO_TOOL" 1>&2
	return 1
    fi
    if [[ ! -x $RERUN_ROGO_TOOL ]]; then
	echo "$0: Warning: rerun_rogo is not an executable file: $RERUN_ROGO_TOOL" 1>&2
	return 1
    fi

    # verify that the run_rogo tool is executable
    #
    if [[ ! -e $RUN_ROGO_TOOL ]]; then
	echo "$0: Warning: run_rogo does not exist: $RUN_ROGO_TOOL" 1>&2
	return 1
    fi
    if [[ ! -f $RUN_ROGO_TOOL ]]; then
	echo "$0: Warning: run_rogo is not a regular file: $RUN_ROGO_TOOL" 1>&2
	return 1
    fi
    if [[ ! -x $RUN_ROGO_TOOL ]]; then
	echo "$0: Warning: run_rogo is not an executable file: $RUN_ROGO_TOOL" 1>&2
	return 1
    fi

    # verify that the rogomatic tool is executable
    #
    if [[ ! -e $ROGOMATIC_TOOL ]]; then
	echo "$0: Warning: rogomatic does not exist: $ROGOMATIC_TOOL" 1>&2
	return 1
    fi
    if [[ ! -f $ROGOMATIC_TOOL ]]; then
	echo "$0: Warning: rogomatic is not a regular file: $ROGOMATIC_TOOL" 1>&2
	return 1
    fi
    if [[ ! -x $ROGOMATIC_TOOL ]]; then
	echo "$0: Warning: rogomatic is not an executable file: $ROGOMATIC_TOOL" 1>&2
	return 1
    fi

    # verify that the player tool is executable
    #
    if [[ ! -e $PLAYER_TOOL ]]; then
	echo "$0: Warning: player does not exist: $PLAYER_TOOL" 1>&2
	return 1
    fi
    if [[ ! -f $PLAYER_TOOL ]]; then
	echo "$0: Warning: player is not a regular file: $PLAYER_TOOL" 1>&2
	return 1
    fi
    if [[ ! -x $PLAYER_TOOL ]]; then
	echo "$0: Warning: player is not an executable file: $PLAYER_TOOL" 1>&2
	return 1
    fi

    # verify that the rogomatic tool is executable
    #
    if [[ ! -e $ROGUE_TOOL ]]; then
	echo "$0: Warning: rogue does not exist: $ROGUE_TOOL" 1>&2
	return 1
    fi
    if [[ ! -f $ROGUE_TOOL ]]; then
	echo "$0: Warning: rogue is not a regular file: $ROGUE_TOOL" 1>&2
	return 1
    fi
    if [[ ! -x $ROGUE_TOOL ]]; then
	echo "$0: Warning: rogue is not an executable file: $ROGUE_TOOL" 1>&2
	return 1
    fi

    # verify that the unstuck_player tool is executable
    #
    if [[ ! -e $UNSTUCK_PLAYER_TOOL ]]; then
	echo "$0: Warning: unstuck_player does not exist: $UNSTUCK_PLAYER_TOOL" 1>&2
	return 1
    fi
    if [[ ! -f $UNSTUCK_PLAYER_TOOL ]]; then
	echo "$0: Warning: unstuck_player is not a regular file: $UNSTUCK_PLAYER_TOOL" 1>&2
	return 1
    fi
    if [[ ! -x $UNSTUCK_PLAYER_TOOL ]]; then
	echo "$0: Warning: unstuck_player is not an executable file: $UNSTUCK_PLAYER_TOOL" 1>&2
	return 1
    fi

    # set the rogomatic directory
    #
    export RGMDIR="$BASE_RGMDIR/rogo.$ID"

    # build unstuck_player command line options
    #
    unset UNSTUCK_PLAYER_OPTION
    declare -ag UNSTUCK_PLAYER_OPTION
    UNSTUCK_PLAYER_OPTION+=("-D")		# set rogomatic directory path
    UNSTUCK_PLAYER_OPTION+=("$RGMDIR")
    UNSTUCK_PLAYER_OPTION+=("-v")		# set verbosity level
    UNSTUCK_PLAYER_OPTION+=("1")
    #
    # must be last
    #
    UNSTUCK_PLAYER_OPTION+=("--")				    # end of options
    UNSTUCK_PLAYER_OPTION+=("$RGMDIR/unstuck.log")    # set unstuck.log path

    # build the rerun_rogo command line options
    #
    unset RERUN_OPTION
    declare -ag RERUN_OPTION
    if [[ -n $CAP_H_FLAG || $USLEEP -le 0 ]]; then
	RERUN_OPTION+=("-H")	# no half time show
    fi
    if [[ -n $CAP_U_FLAG ]]; then
	RERUN_OPTION+=("-U")		# usec delay (or none)
	RERUN_OPTION+=("$USLEEP")
    fi
    RERUN_OPTION+=("-P")		# set player path
    RERUN_OPTION+=("$PLAYER_TOOL")
    RERUN_OPTION+=("-R")		# set player path
    RERUN_OPTION+=("$RUN_ROGO_TOOL")
    RERUN_OPTION+=("-f")		# set rogue path
    RERUN_OPTION+=("$ROGUE_TOOL")
    RERUN_OPTION+=("-D")		# set rogomatic directory path
    RERUN_OPTION+=("$RGMDIR")
    RERUN_OPTION+=("-s")		# set rogomatic directory path
    if [[ -z $S_FLAG || -z $STOP_FILE ]]; then
	RERUN_OPTION+=("$RGMDIR/.stopfile")
    elif [[ -n $STOP_FILE ]]; then
	RERUN_OPTION+=("$STOP_FILE")
    else
	echo "$0: Warning: STOP_FILE is empty and -s was used" 1>&2
	return 1
    fi
    if [[ -n $CAP_G_FLAG ]]; then
	RERUN_OPTION+=("-G")		# set good game level
	RERUN_OPTION+=("$GOODGAME")
    fi
    if [[ -n $SECS ]]; then
	RERUN_OPTION+=("-a")		# set sleep time between actions
	RERUN_OPTION+=("$SECS")
    fi
    if [[ -n $SEED ]]; then
	RERUN_OPTION+=("-S")		# set seed for pseudo-random number generator
	RERUN_OPTION+=("$SEED")
    fi
    if [[ -n $D_FLAG ]]; then
	RERUN_OPTION+=("-d")		# use a UTC date and time sub-directory under rogomatic directory path
    fi
    if [[ -n $E_FLAG ]]; then
	RERUN_OPTION+=("-e")		# turn OFF rogomatic game logging
    fi
    if [[ -n $CAP_Z_FLAG ]]; then
	RERUN_OPTION+=("-Z")		# search for rogomatic, player, rogue only along $PATH
    fi
    if [[ -n $QUIET_MODE ]]; then
	RERUN_OPTION+=("-q")		# turn on quiet mode
    fi
    if [[ -n $CRASH_BASE_DIR ]]; then
	RERUN_OPTION+=("-C")		# set collect generated cores directory
	RERUN_OPTION+=("$CRASH_BASE_DIR")
    fi

    # found everything
    #
    return 0
}


# usage
#
export USAGE="usage: $0
        [-h] [-v level] [-V] [-n] [-N]
        [-o unstuck_player] [-O rerun_rogo] [-R run_rogo] [-s stopfile]
        [-a secs] [-C ccoredir] [-d] [-D base_rgmdir] [-e] [-f rogue] [-G goodlvl] [-H]
        [-P player] [-q] [-r rogomatic] [-S seed] [-U usec] [-Z] ID

    -h          print help message and exit
    -v level    set verbosity level (def level: $V_FLAG)
    -V          print version string and exit
    -n          go thru the actions, but do not update any files (def: do the action)
    -N          do not process anything, just parse arguments (def: process something)

    -o unstuck_player   path to the unstuck_player tool (def: $UNSTUCK_PLAYER_TOOL)
    -O rerun_rogo       path to the rerun_rogo tool (def: $RERUN_ROGO_TOOL)
    -R run_rogo         path to the run_rogo tool (def: $RUN_ROGO_TOOL)
    -s stopfile         stop the rerun cycle if stopfile exists (def: $BASE_RGMDIR/rogo.ID/.stopfile)

    -a secs             set the timeout timer to secs seconds (def: no timeout timer)
    -C coredir          move code dumps under coredir, @ ==> use base_rgmdir/rogo.ID/coredump (def: don't save core dumps)
                            NOTE: To improve the ability to debug core dumps using lldb(1), compile
                                  rogomatic, and player using: make clobber clang
    -d                  use a UTC date and time sub-directory under rogomatic directory path (def: don't)
    -D base_rgmdir      base rogomatic directory under which a sub-directory rogo.id will be created (def: $BASE_RGMDIR)
                            NOTE: This implies: -s $BASE_RGMDIR/rogo.ID/.stopfile
    -e                  turn off rogomatic game logging (def: rogomatic game log is $BASE_RGMDIR/rogo.ID/gamelog)
    -f rogue            path to rogue (def: $ROGUE_TOOL)
    -G goodlvl          set the good game level to goodlvl (def: $GOODGAME)
    -H                  disable the so-called rogomatic halftime show (def: show it)

    -P player           path to player (def: $PLAYER_TOOL)
    -q                  quiet mode: do not output rogue game play (def: do)
                            NOTE: rerun_rogo stdout & stderr appended to rgmdir/rogo.ID/rerun_rogo.log
    -r rogomatic        path to rogomatic (def: $ROGOMATIC_TOOL)
    -S seed             set rogomatic seed (def: use a random seed)
    -U usec             set the sleep time between actions to usec microseconds (def: $USLEEP)
                            NOTE: 0 ==> no delay, and implies -H
    -Z                  search for run_rogo, rogomatic, player, rogue only along \$PATH (def: try in . first)

    ID                  create sub-directory rogo.id under base_rgmdir

Exit codes:
     0         all OK
     1         player already running, or failed to test the lock
     2         -h and help string printed or -V and version string printed
     3         command line error
     4         base_rgmdir, or computed rogomatic directory is not a valid writable directory
     5         some internal tool is not found or not an executable file
 >= 10         internal error

$NAME version: $VERSION"


# parse command line
#
while getopts :hv:VnNo:O:R:s:a:C:dD:ef:G:HP:qr:S:U:Z flag; do
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

    o) UNSTUCK_PLAYER_TOOL="$OPTARG"
	;;
    O) RERUN_ROGO_TOOL="$OPTARG"
	;;
    R) RUN_ROGO_TOOL="$OPTARG"
	;;
    s) STOP_FILE="$OPTARG"
	S_FLAG="-s"
	;;

    a) SECS="$OPTARG"
	;;
    C) CRASH_BASE_DIR="$OPTARG"
        ;;
    d) D_FLAG="-d"
        ;;
    D) BASE_RGMDIR="$OPTARG"
	;;
    e) E_FLAG="-e"
        ;;
    f) ROGUE_TOOL="$OPTARG"
	;;
    G) GOODGAME="$OPTARG"
	;;
    H) CAP_H_FLAG="-H"
        ;;

    P) PLAYER_TOOL="$OPTARG"
	;;
    q) QUIET_MODE="-q"
        ;;
    r) ROGOMATIC_TOOL="$OPTARG"
	;;
    S) SEED="$OPTARG"
        ;;
    U) USLEEP="$OPTARG"
	CAP_U_FLAG="-U"
	;;
    Z) CAP_Z_FLAG="-Z"
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
if [[ $V_FLAG -ge 1 ]]; then
    echo "$0: debug[1]: debug level: $V_FLAG" 1>&2
fi
if [[ $USLEEP -lt 0 ]]; then
    echo "$0: ERROR: -U $USLEEP must be >= 0" 1>&2
    echo "$USAGE" 1>&2
    exit 3
fi
#
# remove the options
#
shift $(( OPTIND - 1 ));
#
# verify arg count
#
if [[ $# -ne 1 ]]; then
    echo "$0: ERROR: expected 1 arg, found: $#" 1>&2
    echo "$USAGE" 1>&2
    exit 3
fi
export ID="$1"
if [[ -z $ID ]]; then
    echo "$0: ERROR: id cannot be empty" 1>&2
    echo "$USAGE" 1>&2
    exit 3
fi


# find the programs
#
# NOTE: This will reset the locations that were established before
#       the command line was parsed by getopts.
#
find_progs
status="$?"
if [[ $status -ne 0 ]]; then
    echo "$0: ERROR: find_progs failed," \
	 "error code: $status" 1>&2
    exit 5
fi


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
if [[ ! -d $RGMDIR ]]; then
    mkdir -p "$RGMDIR"
fi
if [[ ! -e $RGMDIR ]]; then
    echo "$0: ERROR: non-existent rogomatic directory path: $RGMDIR" 1>&2
    exit 4
fi
if [[ ! -d $RGMDIR ]]; then
    echo "$0: ERROR: not a directory: $RGMDIR" 1>&2
    exit 4
fi
if [[ ! -w $RGMDIR ]]; then
    echo "$0: ERROR: not a writable directory: $RGMDIR" 1>&2
    exit 4
fi


# set the .stopfile if -s was not used
#
if [[ -z $S_FLAG ]]; then
    STOP_FILE="$RGMDIR/.stopfile"
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
    echo "$0: debug[3]: RERUN_ROGO_TOOL=$RERUN_ROGO_TOOL" 1>&2
    echo "$0: debug[3]: RUN_ROGO_TOOL=$RUN_ROGO_TOOL" 1>&2
    echo "$0: debug[3]: ROGOMATIC_TOOL=$ROGOMATIC_TOOL" 1>&2
    echo "$0: debug[3]: PLAYER_TOOL=$PLAYER_TOOL" 1>&2
    echo "$0: debug[3]: GOODGAME=$GOODGAME" 1>&2
    echo "$0: debug[3]: ROGUE_TOOL=$ROGUE_TOOL" 1>&2
    echo "$0: debug[3]: UNSTUCK_PLAYER_TOOL=$UNSTUCK_PLAYER_TOOL" 1>&2
    echo "$0: debug[3]: BASE_RGMDIR=$BASE_RGMDIR" 1>&2
    echo "$0: debug[3]: S_FLAG=$S_FLAG" 1>&2
    echo "$0: debug[3]: STOP_FILE=$STOP_FILE" 1>&2
    echo "$0: debug[3]: USLEEP=$USLEEP" 1>&2
    echo "$0: debug[3]: CAP_H_FLAG=$CAP_H_FLAG" 1>&2
    echo "$0: debug[3]: CAP_G_FLAG=$CAP_G_FLAG" 1>&2
    echo "$0: debug[3]: CAP_U_FLAG=$CAP_U_FLAG" 1>&2
    echo "$0: debug[3]: D_FLAG=$D_FLAG" 1>&2
    echo "$0: debug[3]: E_FLAG=$E_FLAG" 1>&2
    echo "$0: debug[3]: CAP_Z_FLAG=$CAP_Z_FLAG" 1>&2
    echo "$0: debug[3]: QUIET_MODE=$QUIET_MODE" 1>&2
    echo "$0: debug[3]: CRASH_BASE_DIR=$CRASH_BASE_DIR" 1>&2
    echo "$0: debug[3]: ID=$ID" 1>&2
    echo "$0: debug[3]: RGMDIR=$RGMDIR" 1>&2
    for index in "${!RERUN_OPTION[@]}"; do
	echo "$0: debug[$V_FLAG]: RERUN_OPTION[$index]=${RERUN_OPTION[$index]}" 1>&2
    done
    for index in "${!UNSTUCK_PLAYER_OPTION[@]}"; do
	echo "$0: debug[$V_FLAG]: UNSTUCK_PLAYER_OPTION[$index]=${UNSTUCK_PLAYER_OPTION[$index]}" 1>&2
    done
fi


# -N stops early before any processing is performed
#
if [[ -n $DO_NOT_PROCESS ]]; then
    if [[ $V_FLAG -ge 3 ]]; then
	echo "$0: debug[3]: arguments parsed, -N given, exiting 0" 1>&2
    fi
    exit 0
fi


# verify that player isn't already running
#
if [[ -z $NOOP ]]; then
    flock -n -E 1 -o "$RGMDIR/player.lck" true
    status="$?"
    if [[ $status -eq 1 ]]; then
	echo "$0: ERROR: player appears to be running, file is locked: $RGMDIR/player.lck" 1>&2
	exit 1
    elif [[ $status -ne 0 ]]; then
	echo "$0: ERROR: flock -n -E 1 -o $RGMDIR/player.lck failed, error: $status" 1>&2
	exit 10
    fi
elif [[ $V_FLAG -ge 3 ]]; then
    echo "$0: debug[3]: because of -n, if not test lock: $RGMDIR/player.lck" 1>&2
fi


# report any SIGHUP received
#
trap 'tput reset; reset; exit 129' HUP


# run unstuck_player tool in the background
#
export WATCHER_PID=
if [[ -z $NOOP ]]; then
    (
	# run unstuck_player in the background
	#
	if [[ $V_FLAG -ge 3 ]]; then
	    echo "$0: debug[3]: about to execute: $UNSTUCK_PLAYER_TOOL ${UNSTUCK_PLAYER_OPTION[*]}" 1>&2
	fi
	exec "$UNSTUCK_PLAYER_TOOL" "${UNSTUCK_PLAYER_OPTION[@]}"
    ) &
    WATCHER_PID="$!"
    if [[ $V_FLAG -ge 3 ]]; then
	echo "$0: debug[3]: background watcher pid: $WATCHER_PID"
    fi

elif [[ $V_FLAG -ge 3 ]]; then
    echo "$0: debug[3]: because of -n, execution of $UNSTUCK_PLAYER_TOOL ${UNSTUCK_PLAYER_OPTION[*]} was disabled" 1>&2
fi


# run rerun_rogo tool
#
if [[ -z $NOOP ]]; then

    # case: -q quiet mode, append rerun_rogo output to $RGMDIR/rerun_rogo.log
    #
    if [[ -n $QUIET_MODE ]]; then

	if [[ $V_FLAG -ge 1 ]]; then
	    echo "$0: debug[5]: about to execute: $RERUN_ROGO_TOOL ${RERUN_OPTION[*]} >> $RGMDIR/rerun_rogo.log 2>&1" 1>&2
	fi
	"$RERUN_ROGO_TOOL" "${RERUN_OPTION[@]}" >> "$RGMDIR/rerun_rogo.log" 2>&1
	RERUN_EXIT="$?"
	if [[ $RERUN_EXIT -ne 0 ]]; then
	    echo "$0: ERROR: $RERUN_ROGO_TOOL ${RERUN_OPTION[*]} >> $RGMDIR/rerun_rogo.log 2>&1 failed," \
		 "error code: $RERUN_EXIT" 1>&2
	fi

    # case: normal (non quiet) mode
    #
    else

	if [[ $V_FLAG -ge 1 ]]; then
	    echo "$0: debug[5]: about to execute: $RERUN_ROGO_TOOL ${RERUN_OPTION[*]}" 1>&2
	fi
	"$RERUN_ROGO_TOOL" "${RERUN_OPTION[@]}"
	RERUN_EXIT="$?"
	if [[ $RERUN_EXIT -ne 0 ]]; then
	    echo "$0: ERROR: $RERUN_ROGO_TOOL ${RERUN_OPTION[*]} failed," \
		 "error code: $RERUN_EXIT" 1>&2
	fi

    fi

    # cleanup trap
    #
    trap - HUP

    # terminate unstuck_player tool
    #
    if [[ -n $WATCHER_PID && $WATCHER_PID -ne $SCRIPT_PID ]]; then
	if [[ $V_FLAG -ge 3 ]]; then
	    echo "$0: debug[3]: kill -TERM $WATCHER_PID 2>/dev/null" 1>&2
	fi
	kill -TERM "$WATCHER_PID" 2>/dev/null || true
    fi
    tput reset
    reset

elif [[ $V_FLAG -ge 3 ]]; then
    echo "$0: debug[3]: because of -n, execution of $RERUN_ROGO_TOOL ${RERUN_OPTION[*]} was disabled" 1>&2
fi


# All Done!!! -- Jessica Noll, Age 2
#
exit 0
