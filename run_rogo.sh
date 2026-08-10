#!/usr/bin/env bash
#
# run_rogo.sh - run rogomatic
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
export VERSION="1.5.0 2026-08-10"
NAME=$(basename "$0")
export NAME
#
export V_FLAG=0
export SECS=
#
export NOOP=
export DO_NOT_PROCESS=
#
ROGOMATIC_TOOL=$(type -P rogomatic)
if [[ -x ./rogomatic ]]; then
    ROGOMATIC_TOOL="./rogomatic"
fi
export ROGOMATIC_TOOL
#
PLAYER_TOOL=$(type -P player)
if [[ -x ./player ]]; then
    PLAYER_TOOL="./player"
fi
export PLAYER_TOOL
#
ROGUE_TOOL=$(type -P rogue)
if [[ -x ../rogue5.4/rogue ]]; then
    ROGUE_TOOL="../rogue5.4/rogue"
elif [[ -x ./rogue ]]; then
    ROGUE_TOOL="./rogue"
fi
export ROGUE_TOOL
#
export SEED=
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
OS_TYPE="$(uname -s)"
export OS_TYPE
export SCRIPT_PID="$$"


# NOTE: The following RGMDIR is NOT the default for rogomatic (/var/tmp/rogomatic)
#       This means you can run rogue(6) and rogomatic by hand
#       while a rogomatic rerun loop is running without interference.
#
export RGMDIR="/var/tmp/rogo"


# find_progs - find executables, and set the rogomatic tool command line
#
# We search the local directory, nearby directory in case of rogue,
# and along the $PATH.  We do this in case we are building in the source
# code directory and don't want to crash a long running rerun_rogo run.
#
function find_progs
{
    # find run_rogo
    #
    RUN_ROGO_TOOL=$(type -P run_rogo)
    if [[ -z $CAP_Z_FLAG ]]; then
	if [[ -x ./run_rogo ]]; then
	    RUN_ROGO_TOOL="./run_rogo"
	elif [[ -x ./run_rogo.sh ]]; then
	    RUN_ROGO_TOOL="./run_rogo.sh"
	fi
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

    # find rogomatic
    #
    ROGOMATIC_TOOL=$(type -P rogomatic)
    if [[ -z $CAP_Z_FLAG ]]; then
	if [[ -x ./rogomatic ]]; then
	    ROGOMATIC_TOOL="./rogomatic"
	fi
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

    # find player
    #
    PLAYER_TOOL=$(type -P player)
    if [[ -z $CAP_Z_FLAG ]]; then
	if [[ -x ./player ]]; then
	    PLAYER_TOOL="./player"
	fi
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

    # find rogue
    #
    ROGUE_TOOL=$(type -P rogue)
    if [[ -z $CAP_Z_FLAG ]]; then
	if [[ -x ../rogue5.4/rogue ]]; then
	    ROGUE_TOOL="../rogue5.4/rogue"
	elif [[ -x ./rogue ]]; then
	    ROGUE_TOOL="./rogue"
	fi
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

    # build the rogomatic command line options
    #
    unset OPTION
    declare -ag OPTION
    if [[ -n $CAP_H_FLAG || $USLEEP -le 0 ]]; then
	OPTION+=("-H")	# no half time show
    fi
    if [[ -n $CAP_U_FLAG ]]; then
	OPTION+=("-U")		# usec delay (or none)
	OPTION+=("$USLEEP")
    fi
    OPTION+=("-P")		# set player path
    OPTION+=("$PLAYER_TOOL")
    OPTION+=("-f")		# set rogue path
    OPTION+=("$ROGUE_TOOL")
    OPTION+=("-D")		# set rogomatic directory path
    OPTION+=("$RGMDIR")
    if [[ -n $CAP_G_FLAG ]]; then
	OPTION+=("-G")		# set good game level
	OPTION+=("$GOODGAME")
    fi
    if [[ -n $SECS ]]; then
	OPTION+=("-a")		# set sleep time between actions
	OPTION+=("$SECS")
    fi
    if [[ -n $SEED ]]; then
	OPTION+=("-S")		# set seed for pseudo-random number generator
	OPTION+=("$SEED")
    fi
    if [[ -n $D_FLAG ]]; then
	OPTION+=("-d")		# use a UTC date and time sub-directory under rogomatic directory path
    fi
    if [[ -n $E_FLAG ]]; then
	OPTION+=("-e")		# turn OFF rogomatic game logging
    fi
    if [[ -n $QUIET_MODE ]]; then
	OPTION+=("-q")		# turn on quiet mode
    fi

    # found everything
    #
    return 0
}


# Translate a signal number to its canonical signal name
#
# Converts a raw numeric signal value (e.g., 11) into its canonical string representation (e.g., SIGSEGV).
# Uses 'kill -l' for cross-platform compatibility between Linux and macOS.
#
function get_signal_name
{
    local sig_num="$1"
    local name

    # 'kill -l <num>' returns signal names portably across Linux and macOS
    #
    if name="$(kill -l "$sig_num" 2>/dev/null)"; then
        # Ensure the 'SIG' prefix is consistently attached (some systems output 'SEGV' instead of 'SIGSEGV')
        if [[ "$name" != SIG* ]]; then
            name="SIG${name}"
        fi
        echo "$name"
    else
        echo "SIGUNKNOWN"
    fi
}

# Function: find_target_core_file
#
# Locates a generated core dump file specific to the terminated target process PID.
# Handles OS-specific core file naming patterns (macOS /cores/core.<PID> vs Linux local/pattern paths).
#
function find_target_core_file
{
    local pid="$1"

    case "$OS_TYPE" in
        Darwin)
            # macOS kernel strictly names core files as /cores/core.<PID>
            if [[ -f "/cores/core.${pid}" ]]; then
                echo "/cores/core.${pid}"
            fi
            ;;
        Linux)
            # 1. Check current working directory for PID-suffixed or standard core files
            if [[ -f "./core.${pid}" ]]; then
                echo "./core.${pid}"
            elif [[ -f "./core" ]]; then
                echo "./core"
            else
                # 2. Inspect system core_pattern directory if an absolute path pattern is configured
                if [[ -r /proc/sys/kernel/core_pattern ]]; then
                    local pattern pattern_dir
                    pattern="$(cat /proc/sys/kernel/core_pattern)"
                    if [[ "$pattern" == /* ]]; then
                        pattern_dir="$(dirname "$pattern")"
                        if [[ -f "${pattern_dir}/core.${pid}" ]]; then
                            echo "${pattern_dir}/core.${pid}"
                        fi
                    fi
                fi
            fi
            ;;
        *)
            # Fallback for generic Unix environments
            if [[ -f "./core.${pid}" ]]; then
                echo "./core.${pid}"
            elif [[ -f "./core" ]]; then
                echo "./core"
            fi
            ;;
    esac
}


# usage
#
export USAGE="usage: $0
        [-h] [-v level] [-V] [-n] [-N]
        [-a secs] [-C coredir] [-d] [-D rgmdir] [-e] [-f rogue] [-G goodlvl] [-H]
        [-P player] [-q] [-r rogomatic] [-S seed] [-U usec] [-Z]

    -h          print help message and exit
    -v level    set verbosity level (def level: $V_FLAG)
    -V          print version string and exit
    -n          go thru the actions, but do not update any files (def: do the action)
    -N          do not process anything, just parse arguments (def: process something)

    -a secs             set the timeout timer to secs seconds (def: no timeout timer)
    -C coredir          move code dumps under coredir, @ ==> use rgmdir/coredump (def: don't save core dumps)
                            NOTE: To improve the ability to debug core dumps using lldb(1), compile
                                  rogomatic, and player using: make clobber clang
    -d                  use a UTC date and time sub-directory under rogomatic directory path (def: don't)
    -D rgmdir           rogomatic directory (def: $RGMDIR)
                            NOTE: if rgmdir is /var/tmp/rogomatic unstuck_player won't unstick unless -A is used
    -e                  turn off rogomatic game logging (def: rogomatic game log is $RGMDIR/gamelog)
    -f rogue            path to rogue (def: $ROGUE_TOOL)
    -G goodlvl          set the good game level to goodlvl (def: $GOODGAME)
    -H                  disable the so-called rogomatic halftime show (def: show it)

    -P player           path to player (def: $PLAYER_TOOL)
    -q                  quiet mode: do not output rogue game play (def: do)
    -r rogomatic        path to rogomatic (def: $ROGOMATIC_TOOL)
    -S seed             set rogomatic seed (def: use a random seed)
    -U usec             set the sleep time between actions to usec microseconds (def: $USLEEP)
                            NOTE: <=0 ==> no delay and implies -H
    -Z                  search for rogomatic, player, rogue only along \$PATH (def: try in . first)

Exit codes:
     0         all OK
     1         player already running
     2         -h and help string printed or -V and version string printed
     3         command line error
     4         -C dir used and core dump collected
     6         problems found with or in the rogomatic directory, or with core dump collection directory
     7         rogomatic returned an error
 >= 10         internal error

$NAME version: $VERSION"


# parse command line
#
while getopts :hv:VnNa:C:dD:ef:G:HP:qr:S:U:Z flag; do
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

    a) SECS="$OPTARG"
	;;
    C) CRASH_BASE_DIR="$OPTARG"
        ;;
    d) D_FLAG="-d"
        ;;
    D) RGMDIR="$OPTARG"
        ;;
    e) E_FLAG="-e"
        ;;
    f) ROGUE_TOOL="$OPTARG"
        ;;
    G) GOODGAME="$OPTARG"
	CAP_G_FLAG="-G"
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
if [[ $CRASH_BASE_DIR == @ ]]; then
    CRASH_BASE_DIR="$RGMDIR/coredump"
fi
#
# remove the options
#
shift $(( OPTIND - 1 ));
#
# verify arg count
#
if [[ $# -ne 0 ]]; then
    echo "$0: ERROR: expected 0 args, found: $#" 1>&2
    echo "$USAGE" 1>&2
    exit 3
fi


# find the programs, and set the rogomatic tool command line
#
# NOTE: This will reset the locations that were established before
#       the command line was parsed by getopts.
#
find_progs


# verify the rogomatic directory
#
if [[ ! -d $RGMDIR ]]; then
    mkdir -p "$RGMDIR"
fi
if [[ ! -e $RGMDIR ]]; then
    echo "$0: ERROR: non-existent rogomatic directory path: $RGMDIR" 1>&2
    exit 6
fi
if [[ ! -d $RGMDIR ]]; then
    echo "$0: ERROR: not a directory: $RGMDIR" 1>&2
    exit 6
fi
if [[ ! -w $RGMDIR ]]; then
    echo "$0: ERROR: not a writable directory: $RGMDIR" 1>&2
    exit 6
fi


# print running info if verbose
#
# If -v 3 or higher, print exported variables in order that they were exported.
#
if [[ $V_FLAG -ge 3 ]]; then
    echo "$0: debug[3]: VERSION=$VERSION" 1>&2
    echo "$0: debug[3]: NAME=$NAME" 1>&2
    echo "$0: debug[3]: V_FLAG=$V_FLAG" 1>&2
    echo "$0: debug[3]: SECS=$SECS" 1>&2
    echo "$0: debug[3]: NOOP=$NOOP" 1>&2
    echo "$0: debug[3]: DO_NOT_PROCESS=$DO_NOT_PROCESS" 1>&2
    echo "$0: debug[3]: ROGOMATIC_TOOL=$ROGOMATIC_TOOL" 1>&2
    echo "$0: debug[3]: PLAYER_TOOL=$PLAYER_TOOL" 1>&2
    echo "$0: debug[3]: GOODGAME=$GOODGAME" 1>&2
    echo "$0: debug[3]: ROGUE_TOOL=$ROGUE_TOOL" 1>&2
    echo "$0: debug[3]: RGMDIR=$RGMDIR" 1>&2
    echo "$0: debug[3]: SEED=$SEED" 1>&2
    echo "$0: debug[3]: USLEEP=$USLEEP" 1>&2
    echo "$0: debug[3]: CAP_H_FLAG=$CAP_H_FLAG" 1>&2
    echo "$0: debug[3]: CAP_G_FLAG=$CAP_G_FLAG" 1>&2
    echo "$0: debug[3]: CAP_U_FLAG=$CAP_U_FLAG" 1>&2
    echo "$0: debug[3]: D_FLAG=$D_FLAG" 1>&2
    echo "$0: debug[3]: E_FLAG=$E_FLAG" 1>&2
    echo "$0: debug[3]: QUIET_MODE=$QUIET_MODE" 1>&2
    echo "$0: debug[3]: CRASH_BASE_DIR=$CRASH_BASE_DIR" 1>&2
    echo "$0: debug[3]: OS_TYPE=$OS_TYPE" 1>&2
    echo "$0: debug[3]: SCRIPT_PID=$SCRIPT_PID" 1>&2
    for index in "${!OPTION[@]}"; do
        echo "$0: debug[$V_FLAG]: OPTION[$index]=${OPTION[$index]}" 1>&2
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
flock -n -E 1 -o "$RGMDIR/player.lck" true
status="$?"
if [[ $status -eq 1 ]]; then
    echo "$0: ERROR: player appears to be running, file is locked: $RGMDIR/player.lck" 1>&2
    exit 1
elif [[ $status -ne 0 ]]; then
    echo "$0: ERROR: flock -n -E 1 -o $RGMDIR/player.lck failed, error: $status" 1>&2
    exit 1
fi


# If -D dir was used on macOS, verify that /cores is mode 1777
#
if [[ $OS_TYPE == "Darwin" && -n $CRASH_BASE_DIR ]]; then
    if [[ "$(/usr/bin/stat -f "%A" /cores 2>/dev/null)" == "1777" ]]; then
	if [[ $V_FLAG -ge 3 ]]; then
	    echo "$0: debug[3]: macOS /cores correctly set mode 1777" 1>&2
	fi
    else
	echo "$0: ERROR: -D $CRASH_BASE_DIR but /cores is not mode 1777" 1>&2
	ls -ld /cores
	exit 6
    fi
fi


# if -C, set the maximum size of core files created to unlimited
#
if [[ -n $CRASH_BASE_DIR ]]; then

    # Enable unconstrained core file generation for child processes
    #
    if [[ $V_FLAG -ge 1 ]]; then
        echo "$0: debug[1]: ulimit -c unlimited" 1>&2
    fi
    ulimit -c unlimited

    # Create a crash collection directory if it doesn't already exist
    #
    mkdir -p "$CRASH_BASE_DIR"
    if [[ ! -d $CRASH_BASE_DIR || ! -w $CRASH_BASE_DIR ]]; then
	echo "$0: ERROR: failed to crate a writable crash collection directory: $CRASH_BASE_DIR" 1>&2
	exit 6
    fi
    if [[ $V_FLAG -ge 3 ]]; then
        echo "$0: debug[3]: CRASH_BASE_DIR: $CRASH_BASE_DIR" 1>&2
    fi
fi
if [[ -z $QUIET_MODE ]]; then
    trap 'tput reset; reset; exit' EXIT INT TERM
else
    trap 'exit' EXIT INT TERM
fi


# exec the rogomatic code
#
if [[ -z $NOOP ]]; then

    # prep to exec
    #
    export SIGNAL=
    export SIGNAL_NAME=
    export TARGET_BIN=
    export EXIT_CODE=
    export CORE_FILE=
    export BASE_CORE_FILE=
    export TIMESTAMP=
    export ISOLATION_DIR=

    # loop while we look for the programs
    #
    while :; do

	# find the programs, and set the rogomatic tool command line
	#
	find_progs
	status="$?"
	if [[ $status -ne 0 ]]; then

	    # something was not found, wait and try again a bit later
	    #
	    sleep 2
	    continue
	fi

	# run rogomatic
	#
	if [[ $V_FLAG -ge 1 ]]; then
	    echo "$0: debug[5]: about to execute: $ROGOMATIC_TOOL ${OPTION[*]} -- &" 1>&2
	fi
	"$ROGOMATIC_TOOL" "${OPTION[@]}" -- &
	TARGET_PID="$!"

	# wait for rogomatic running in the background to fail
	#
	wait "$TARGET_PID"
	EXIT_CODE="$?"

	if [[ -n $EXIT_CODE && $EXIT_CODE -ne 0 ]]; then

	    # case: exit due to a signal
	    #
	    if [[ $EXIT_CODE -gt 128 ]]; then

		# determine signal number
		#
		SIGNAL=$(( EXIT_CODE - 128 ))
		SIGNAL_NAME="$(get_signal_name "$SIGNAL")"

		# report signal exit
		#
		echo "$0: notice: signal $SIGNAL_NAME ($SIGNAL): $ROGOMATIC_TOOL ${OPTION[*]} --" 1>&2

		# Pause briefly to allow the system kernel time to finish writing the core dump file to disk.
		#
		sleep 1.0

		# Search for core dump file associated with the specific target PID.
		#
		CORE_FILE="$(find_target_core_file "$TARGET_PID")"
		if [[ $V_FLAG -ge 3 ]]; then
		    if [[ -n $CORE_FILE ]]; then
			echo "$0: debug[3]: find_target_core_file found: $CORE_FILE" 1>&2
		    else
			echo "$0: debug[3]: find_target_core_file found nothing" 1>&2
		    fi
		fi
		BASE_CORE_FILE="$(basename "$CORE_FILE")"

		# case: core dump file found
		#
		if [[ -n "$CORE_FILE" && -f "$CORE_FILE" ]]; then

		    # Construct a unique isolation directory name using timestamp, script PID, target PID, and iteration count.
		    #
		    TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
		    ISOLATION_DIR="${CRASH_BASE_DIR}/crash.${TIMESTAMP}.${SCRIPT_PID}.${TARGET_PID}"
		    mkdir -p "$ISOLATION_DIR"
		    if [[ ! -d $ISOLATION_DIR || ! -w $ISOLATION_DIR ]]; then
			echo "$0: ERROR: failed to crate a writable isolation directory: $ISOLATION_DIR" 1>&2
			exit 6
		    fi

		    # move core file into the isolation directory
		    #
		    echo "$0: Warning: moving core file: mv -f $CORE_FILE ISOLATION_DIR/$BASE_CORE_FILE" 1>&2
		    mv -f "$CORE_FILE" "$ISOLATION_DIR/$BASE_CORE_FILE"
		    status="$?"
		    if [[ $status -ne 0 ]]; then
			echo "$0: Warning: cp -v -f $CORE_FILE $ISOLATION_DIR/$BASE_CORE_FILE failed, error: $status" 1>&2
		    fi

		    # save copy of rogomatic in isolation directory
		    #
		    if [[ $V_FLAG -ge 3 ]]; then
			echo "$0: debug[3]: save executable copy to: cp -v -f $ROGOMATIC_TOOL $ISOLATION_DIR/rogomatic" 1>&2
		    fi
		    cp -f "$ROGOMATIC_TOOL" "$ISOLATION_DIR/rogomatic"
		    status="$?"
		    if [[ $status -ne 0 ]]; then
			echo "$0: Warning: cp -v -f $ROGOMATIC_TOOL $ISOLATION_DIR/rogomatic failed, error: $status" 1>&2
		    fi

		    # save copy of player in isolation directory
		    #
		    if [[ $V_FLAG -ge 3 ]]; then
			echo "$0: debug[3]: save executable copy to: cp -v -f $PLAYER_TOOL $ISOLATION_DIR/player" 1>&2
		    fi
		    cp -f "$PLAYER_TOOL" "$ISOLATION_DIR/player"
		    status="$?"
		    if [[ $status -ne 0 ]]; then
			echo "$0: Warning: cp -v -f $PLAYER_TOOL $ISOLATION_DIR/player failed, error: $status" 1>&2
		    fi
		fi

	    # case: non-signal related exit
	    #
	    else
		echo "$0: Warning: $ROGOMATIC_TOOL ${OPTION[*]} -- failed," \
		     "error code: $EXIT_CODE" 1>&2
		exit 7
	    fi
	fi

	# end of loop
	#
	break
    done

elif [[ $V_FLAG -ge 3 ]]; then
    echo "$0: debug[3]: because of -n, execution of $ROGOMATIC_TOOL ${OPTION[*]} -- was disabled" 1>&2
fi


# All Done!!! -- Jessica Noll, Age 2
#
exit 0
