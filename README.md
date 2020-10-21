## INDIGO Deadlock Detector (indigo_deadlock_detector)

Inspects the running INDIGO server process for deadlocks but it can inspect any other process by providing the process name.

It should be executed on the host where indigo server or the examined process is running.

### In case INDIGO server becomes unresponsive

To display the backtrace, and blocked threads execute:

```
indigo_deadlock_detector
```

To display the backtrace, blocked threads, and the local variables execute:

```
indigo_deadlock_detector -v
```

To save the output in a file please redirect the output using ">filename.txt" like this:

```
indigo_deadlock_detector >indigo_deadlock.txt
```

### In case some other INDIGO process becomes unresponsive

To display the backtrace, and blocked threads execute:

```
indigo_deadlock_detector <prcess_name>
```
or
```
indigo_deadlock_detector -p <pid>
```

If local variables are needed:

```
indigo_deadlock_detector -v <prcess_name>
```
or
```
indigo_deadlock_detector -v -p <pid>
```
### Please provide us with the output

Send the output to indigo@cloudmakers.eu accompanied by a problem description and if possible steps to reproduce it.
