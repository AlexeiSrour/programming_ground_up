WIP, to add chapter summary, binary summary, and build instructions


# Chapter 3. Your First Programs (Part 1)
## Overview
This directory is reserved for the introductory first assembly programs introduced in the text.

The text kept matters simple, only introducing 2 programs, of which I have only bothered to transcribe the one. Later portions of the chapter introduce
more compelling programs, however those exercises have been reserved for Part 2 (branch 01_sort_list).

Time is dedicated outlining the assembling and linking process for a 32 bit Linux architecture, of which I will outline the build process for a 64 bit
architecture, and time spent explaining the skeleton pieces (e.g. labels) and the basic units of computation (e.g. adding, branching, etc.) for an
assembly program, of which I will delve deeper.

## Programs in this directory
    -   ./exit

### ./exit
The ./exit program is the first assembly program introduced to the reader, and very simply exits once run but returns a (32 bit) exit code to the shell.
The author uses this program to outline the structure of an assembly program and some of the basic units of computation, reserving more complex units
for later in the chapter (i.e. branching).

The source code is exit.s, and it has no external dependancies.

To build on x86_64 Linux machine, the one-liner
```bash
as --32 -g exit.s -o exit.0 && ld -m elf_i386 exit.o -o exit
```
will suffice. On a 32 bit machine, you would use
```bash
as -g exit.s -o exit.0 && ld exit.o -o exit
```

To trace execution with a debugger, it is recommended to run GDB with the following arguments:
```bash
gdb -tui -ex "layout regs" exit
```

An alternative exercise is to modify and rebuild the code with different exit codes, which can be inspected with
```bash
echo $?
```

## Summary
### Summary of the contents up to this point
i.e. breakdown of a program, what the different labels mean

### Beyond the book
Much of a program's user-visible functionality comes from its interaction with facilities provided by the operating system - the OS is effectively an
abstraction layer over the hardware after all.

The primary means by which programs and the operating system interact is via *system calls*, with which each operating system has its own preferential
way of implementing such calls. There's even a difference between the 32 and 64 bit Linux implementation of system calls, you can check out
[these](https://faculty.nps.edu/cseagle/sys_calls.html) [two](https://filippo.io/linux-syscall-table/) websites for the calling codes of 32 bit and 64 bit Linux Kernals respectively.

The specifics of how system calls are implemented are beyond the scope of this text, however I find the differences between the 32 bit and 64 bit calls
fascinating and worth elaborating upon.

First, it is worth noting that the hardware itself, the computer chip, comes with a number of features without which modern day operating systems could
not exist. We're talking about hardware timers, memory virtualisation, priviledge rings, debug registers, etc, there's an entire facet of all modern day chips that userspace
programmers simply do not see by design. Should you be interested in having a quick peek, consider cehking out
[Intel Software Developer's Manual Volumes 3A to 3D](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html) and flicking
through some of the pages. The sheer volume of the number of pages alone should hint had just how much heavy lifting the hardware is doing just to enable
an operating system to run.

In summation, there exists special purpose hardware to make system calls possible.

On a 32 bit Linux Kernal, system calls are implemented via an interupt routine. During the boot process of many classes of chips, ranging from embedded
to super computers, a region of memory is dedicated specifically as a series of function pointers for handling various cases of interrupts. This region
is called the interrupt vector and is responsible for providing the subroutines for a myriad of interupts, ranging from hardware, to timer, to software
interrupts. Each interrupt has an integer ID associated with it, and indexing into the interrupt vector provides the function pointer for how that
specific interrupt wil be handled.

Writing a well behaving Interrupt Service Routine (ISR) is a science in and of itself, but for now it suffices to say that the handler for interrupt id
0x80 is the one associated 
