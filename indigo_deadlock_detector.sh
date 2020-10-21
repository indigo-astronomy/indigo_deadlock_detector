#! /bin/bash

# DO NOT CHANGE THIS LINE, matched and changed on install
GDB_SCRIPT_PATH="."

PROC_NAME="indigo_worker"
PRINT_VARS=""

#!/bin/bash
while [[ "$#" -gt 0 ]]; do
	case $1 in
		-v|--print-variables) PRINT_VARS="-full"; shift ;;
		*) PROC_NAME="$1"; shift;;
	esac
done

PID=$(ps -ef | grep "$PROC_NAME" | grep -v grep | grep -v `basename "$0"` | tail -1 | awk '{print $2}')

if [ -z "$PID" ]; then
	echo "Process '$PROC_NAME' not found."
	echo "To change process name, use: $0 <process_name>"
	exit 1;
fi

echo "Inspecting '$PROC_NAME' (pid = $PID) for deadlocks"

sudo gdb\
	-p $PID\
	-x $GDB_SCRIPT_PATH/gdb_deadlock_script\
	-ex "thread apply all bt $PRINT_VARS"\
	-ex 'blocked'\
	-batch\
	2>/dev/null
