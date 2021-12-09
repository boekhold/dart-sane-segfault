# Overview

Also see https://groups.google.com/a/dartlang.org/g/misc/c/-w0zIbk8YhM

This repository contains a test of FFI bindings to the SANE library that causes a
SEGFAULT on exit of the `main` function. The Dart code attempts to replicate
the functionality of the included C program `listdevices.c`

Running the Dart version ends with:

```
===== CRASH =====
si_signo=Segmentation fault(11), si_code=1, si_addr=0x7fa0aadb0160
version=2.15.0 (stable) (Fri Dec 3 14:23:23 2021 +0100) on "linux_x64"
pid=930912, thread=930921, isolate_group=(nil)((nil)), isolate=(nil)((nil))
isolate_instructions=0, vm_instructions=55ef14d7b580
Stack dump aborted because GetAndValidateThreadStackBounds failed.
/home/boekhold/local/flutter/bin/internal/shared.sh: line 223: 930912 Aborted                 (core dumped) "$DART" "$@"
```

## How to replicate

This assumes an Ubuntu-based Linux workstation/VM with Dart installed.

1. `sudo apt install gcc gdb sane libsane libsane-dev`
2. `sudo vi /etc/sane.d/dll.conf`

    Uncomment the line containing `#test`

3. `git clone https://github.com/boekhold/dart-sane-segfault.git`
4. `cd dart-sane-segfault`
5. `gcc listdevices.c -o listdevices -lsane`
6. `./listdevices`
7. `dart pub get`
8. `dart listdevices.dart`

## Debug with GDB

1. `gdb --args dart listdevices.dart`
    + Since I am using the Dart SDK that comes with Flutter, I need to run as:<br>
       `gdb --args /home/boekhold/local/flutter/bin/cache/dart-sdk/bin/dart listdevices.dart`
2. `run`
3. `bt`

The backtrace will look like:

```
(gdb) bt
#0  0x00007ffff0eab160 in ?? ()
#1  0x00007ffff7f8c5a1 in __nptl_deallocate_tsd () at pthread_create.c:301
#2  0x00007ffff7f8d62a in __nptl_deallocate_tsd () at pthread_create.c:256
#3  start_thread (arg=<optimized out>) at pthread_create.c:488
#4  0x00007ffff7d65293 in clone () at ../sysdeps/unix/sysv/linux/x86_64/clone.S:95
```
