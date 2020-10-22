#! /bin/bash
#
# Copyright (C) 2020 Rumen G. Bogdanovski
# All rights reserved.
#
# You can use this software under the terms of MIT license (see LICENSE).

# DO NOT CHANGE THESE LINES, matched and changed on install
GDB_SCRIPT_PATH="."
VERSION=""
SCRIPT_NAME=$(basename $0)

PROC_NAME="indigo_worker"
PRINT_VARS=""

print_help () {
	echo "INDIGO Deadlock Detector v.$VERSION" 1>&2
	echo "Usage: $SCRIPT_NAME [-v][-h][-p pid] [process_name]" 1>&2
	echo "    -p | --pid <pid>        : specify pid of the process to inspect" 1>&2
	echo "    -v | --print-variables  : print local variables along with the backtrace" 1>&2
	echo "    -h | --help             : print this help" 1>&2
	echo "    <process_name>          : name of the process to inspect defaut: 'indigo_worker'" 1>&2
}

while [[ "$#" -gt 0 ]]; do
	case $1 in
		-v|--print-variables) PRINT_VARS="full"; shift ;;
		-p|--pid) PID="$2"; shift; shift;;
		-h|--help) print_help; exit 0;;
		*) PROC_NAME="$1"; shift;;
	esac
done

if [ "$PROC_NAME" != "indigo_worker" ] && [ ! -z "$PID" ]; then
	echo "Process ID (-p | --pid) and process name can not be used together" 1>&2
	exit 1;
fi

if [ -z "$PID" ]; then
	#PID=$(ps -ef | grep "$PROC_NAME" | grep -v grep | grep -v `basename "$0"` | tail -1 | awk '{print $2}')
	PID=$(pidof "$PROC_NAME")
fi

if [ -z "$PID" ]; then
	echo "Process '$PROC_NAME' not found." 1>&2
	echo "To change default process name or specify PID, use:" 1>&2
	echo "    $SCRIPT_NAME [-v] <process_name>" 1>&2
	echo "    $SCRIPT_NAME [-v] -p <pid>" 1>&2
	exit 1;
fi

PROC_NAME=$(ps -q $PID -o comm=)

echo "Inspecting '$PROC_NAME' (pid = $PID) for deadlocks"

sudo gdb\
	-p $PID\
	-x $GDB_SCRIPT_PATH/gdb_deadlock_script\
	-ex "thread apply all bt $PRINT_VARS"\
	-ex 'blocked'\
	-batch\
	2>/dev/null
