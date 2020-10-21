#! /usr/bin/env python
#
# Copyright (C) 2020 Rumen G. Bogdanovski
# All rights reserved.
#
# You can use this software under the terms of MIT license (see LICENSE).
#
# Based on gdb-automatic-deadlock-detector by Damian Ziobro <damian@xmementoit.com>

"""
This script shows blocked C/C++ threads in gdb.

Instruction:
1) Create following gdb_deadclock_script:
'
python
import gdb_deadlock_detector
end

thread apply all bt

blocked
'
2. Run this command:
gdb -p <PID> -x gdb_deadclock_script -batch

3. You should see all backtraces from your process followd by deadlock info:

DEADLOCK -> Thread 172687 waits for thread 172686
DEADLOCK -> Thread 172686 waits for thread 172687

"""

import gdb


class Thread():
    def __init__(self):
        self.frames = []
        self.waitOnThread = None
        self.threadId = None

    def __getitem__(self):
        return self.waitOnThread


class gdb_deadlock_detector(gdb.Command):
    def __init__(self):
        super (gdb_deadlock_detector, self).__init__("blocked", gdb.COMMAND_SUPPORT,gdb.COMPLETE_NONE,True)
        print (self.__doc__)

    def invoke(self, arg, from_tty):
        print ("\nBlocked threads:")
        print ("*****************************************************")
        threads = {}
        for process in gdb.inferiors():
            for thread in process.threads():
                trd = Thread()
                trd.threadId = thread.ptid[1]
                thread.switch()
                frame = gdb.selected_frame()
                while frame:
                    frame.select()
                    name = frame.name()
                    if name is None:
                        name = "??"
                    if "pthread_mutex_lock" in name:
                        trd.waitOnThread = int(gdb.execute("print mutex.__data.__owner", to_string=True).split()[2])
                    trd.frames.append(name)
                    frame = frame.older()
                threads[trd.threadId] = trd

        for (tid, thread) in threads.items():
            if thread.waitOnThread:
                if thread.waitOnThread in threads and threads[thread.waitOnThread].waitOnThread == thread.threadId:
                    if thread.threadId == thread.waitOnThread:
                        print ("SELFLOCK -> Thread {0} locked itself".format(thread.threadId))
                    else:
                        print ("DEADLOCK -> Thread {0} waits for thread {1}".format(thread.threadId, thread.waitOnThread))
                else:
                    print ("BLOCKED  -> Thread {0} is blocked by thread {1}".format(thread.threadId, thread.waitOnThread))

        print ("*****************************************************\n")

gdb_deadlock_detector()
