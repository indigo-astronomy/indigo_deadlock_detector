#! /bin/bash

PROC_NAME="indigo_worker"
GDB_SCRIPT_PATH="/usr/local/share/indigo-deadlock-detector/"
#GDB_SCRIPT_PATH="."

if [ ! -z "$1" ]
then
	PROC_NAME="$1"
fi

PID=$(ps -ef | grep "$PROC_NAME" | grep -v grep | grep -v `basename "$0"` | tail -1 | awk '{print $2}')

if [ -z "$PID" ]
then
      echo "Process '$PROC_NAME' not found."
      echo "To change process name use: $0 <process_name>"
      exit 1;
fi

echo "Checking '$PROC_NAME' (pid = $PID) for deadlocks"

gdb -p $PID -x $GDB_SCRIPT_PATH/gdb_deadlock_script -batch 2>/dev/null
