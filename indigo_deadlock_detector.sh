#! /bin/bash
#
# Copyright (C) 2020 Rumen G. Bogdanovski
# All rights reserved.
#
# You can use this software under the terms of MIT license (see LICENSE).

# DO NOT CHANGE THIS LINE, matched and changed on install
GDB_SCRIPT_PATH="."

PROC_NAME="indigo_worker"
PRINT_VARS=""

while [[ "$#" -gt 0 ]]; do
	case $1 in
		-v|--print-variables) PRINT_VARS="-full"; shift ;;
		-p|--pid) PID="$2"; shift; shift;;
		*) PROC_NAME="$1"; shift;;
	esac
done

if [ "$PROC_NAME" != "indigo_worker" ] && [ ! -z "$PID" ]; then
	echo "Process ID (-p | --pid) and process name can not be used together"
	exit 1;
fi

if [ -z "$PID" ]; then
	#PID=$(ps -ef | grep "$PROC_NAME" | grep -v grep | grep -v `basename "$0"` | tail -1 | awk '{print $2}')
	PID=$(pidof "$PROC_NAME")
fi

if [ -z "$PID" ]; then
	echo "Process '$PROC_NAME' not found."
	echo "To change process name or specify PID, use:"
	echo "    $0 [-v] <process_name>"
	echo "    $0 [-v] -p <pid>"
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
