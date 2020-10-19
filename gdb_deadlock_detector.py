#! /usr/bin/env python
#
# Created by Rumen G. Bogdanovski <rumen@skyarchive.org>
# Based on gdb-automatic-deadlock-detector by Damian Ziobro <damian@xmementoit.com>

"""
This script shows blocking C/C++ threads in gdb based on data from core file.

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
    #"""custom command => blocked - command show how threads blocks themselves waiting on mutexes"""
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
                        lock_str = "SELFLOCK"
                    else:
                        lock_str = "DEADLOCK"
                else:
                    lock_str = "--------"
                print ("{0} -> Thread {1} waits for thread {2}".format(lock_str, thread.threadId, thread.waitOnThread))

        print ("*****************************************************\n")

gdb_deadlock_detector()
