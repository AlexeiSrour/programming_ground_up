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
The ./exit program is the first assembly program introduced to the reader, and very simply exits once run but returns an (8 bit) exit code to the shell.
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
The key takeaway from the books that this particular exercise is concerned with are:
    - The registers
    - instructions
    - labels and symbols

#### Registers
Our general purpose registers are:
    - eax, ebx, ecx, edx
    - edi, esi

Though these registers are spoken of as "general purpose", it is not unusual for some assembler instructions to make special use of these registers.
Reasons for this are largely historic - in fact, the names of the registers themselves have a bit of a history to them. They were once called A, B,
C, D, and many assigned certain mnemonics matching their name to indicate usage, i.e. A = accumulator register, C = count register etc. This is why
some rather strange instructions (like string instructions) make use of these registers in some rather unconventional ways (e.g. keeping the length of
counted string in the C register).

As the bit width of processors grew, we had the e*X*tended registers, AX, BX, CX, and DX, where one could further select the High or Low byte, AH, AL,
BH, BL, CH, CL, DH, DL. Technology marches ever forwards, our bit width doubles, and now we create our double *E*xtended registers, EAX, EBX, ECX, EDX.
I'm unaware if it's possible to select the upper 2 bytes of the register, not sure why one would be so inclined to do so anyway.

Finally, we jump to the modern day, where AMD extended not only the bit width, but also extended the register set. For our old friends, they go by the name
RAX, RBX, RCX, RDX, and for out newly added regsters, they simply go by the name R8, R9, ..., R15. Rather dull but so much more sensical than what cam prior.
As with out older registers, these new registers can also access their lower halves, e.g. R8d takes the bottom 4 bytes of the register R8, but this
is outside the scope of the book.

Our special purpose registers are:
    - ebp, esp
    - eip, eflags

These are special purpose as many assembly instructions have some level of automatic influence upon these and may automatically set them for us. Registers
like EIP and EFLAGS are in fact protected, and cannot be accessed via normal assembly instructions. These registers have specific uses in the context
of our programs. the base pointer and stack pointer (EBP & ESP) help us track our functions stack frames, and function calls and returns explicitly
make use of this pair to work. Interestingly, optimised compiler code will often make use of these registers not for their intended purpose but for extra
storage and use them as normal registers if it can get away with it - so much for being special.

EIP and EFLAGS are our instruction pointer and flags registers. Both of these have extra protections in an x86 context. In the past, programmers/compilers
would be responsible for managing the instruction pointer themselves and had direct access, but these days the instruction pointer refuses to be accessed
by the programmer.

#### Assembler Directives
We are introduced to a suit of assembler directives which will only expand with time. One can find the list of all GNU assembler directives
[at this site](https://ftp.gnu.org/old-gnu/Manuals/gas-2.9.1/html_chapter/as_7.html), though I've noticed the book appears to use its own directives or
forms not listed here.

Some of the more relevant directives used here were:
    - .section .text, .section .data, .section .bss (*not yet seen)
    - .globl <symbol name>
    - <label>:

Our section data just outlines to our linker, the program responsible for creating the executable, what pieces of our program lie where. This information is
packed into an executable that the operating system then refers to when it first boots up our process.

We also so .global _start, which is technically a special case instance of a global symbol matched up with the default entry point of our program. More info
about this can be found [here](gridbugs.org/if-you-use-a-custom-linker-script-_start-is-not-necessarily-the-entry-point/), but suffice it to say that the
`.globl` (or `.global`) is responsible for flagging to our linker that `<symbol name>` ought to be visible and callable from locations outside of this file.

We also saw an example of a label, `_start`. In our case, this is a special purpose label, but generally speaking, these exist to demarcate sections of our
program that we may branch to and between. Essentially, the assembler and linker will track address of where this label exists, and that may then be used to
streamline the management of jumps (and in some later cases, I make use of it to manage locations of strings stored in a singular string blob).

We have yet more directives to see, but these are the most pertinent to the current example.


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

As far as we should be concerned, system calls fall under the umbrella of OS functionality that is enable directly by the hardware.

On a 32 bit Linux Kernal, system calls are implemented via an interupt routine. During the boot process of many classes of chips, ranging from embedded
to super computers, a region of memory is dedicated specifically as a series of function pointers for handling various cases of interrupts. This region
is called the interrupt vector and is responsible for providing the subroutines for a myriad of interupts, ranging from hardware, to timer, to software
interrupts. Each interrupt has an integer ID associated with it, and indexing into the interrupt vector provides the function pointer for how that
specific interrupt wil be handled.

Writing a well behaving Interrupt Service Routine (ISR) is a science in and of itself, but for now it suffices to say that the handler for interrupt id
0x80 is the one associated to system calls. Hence, as per the 32 bit system call calling convention, we load the relevant registers with the data we need
before invoking `int 0x80` in assembly. After some indeterminite time, the interupt handler returns execution back to our program and we continue on our
merry way.

*An operating system will often take the opportunity to do some other bookkeeping tasks in the background during the system call. For example, the scheduler
may opt to do a context switch during a system call.*

Come the 64 bit era, we now have a dedicated assembly instruction for system calls, `syscall`. Where the earlier interrupt model leveraged the interrupt/
trap functionality provided by the chip, the dedicated instructions exists specifically to avoid much of the overhead and unnecessary checks that come with
interrupt handling in the specific context of system calls. This enables faster, less expensive switches into the kernal.

(*I am also tangentially aware of sysenter. I cannot really comment on these instructions as of now*)

Why have I included this diatribe here? Beyond being interesting, the majority of what follows in the text will involve some level of system calls.
Having some level of understanding as to *what* a system call is will go a long way understanding why a lot of programming works the way it does, and why
we do some things the way we do. Later exercises in the book will help illuminate some of these points, but for now, suffice it to say, computers are
wickedly complicated.

#### References
Some other references for things I'm less confident on (i.e. `sysenter`/`sysexit` on 32 bit architectures_:
[OpenCSF article on system calls in a 64 bit environment](https://w3.cs.jmu.edu/kirkpams/OpenCSF/Books/csf/html/Syscall.html#:~:text=The%20syscall%20instruction%20is%20the,to%20return%20from%20the%20interrupt.)
[Stack Exchange thread discussing some extra deatils](https://stackoverflow.com/questions/15598700/syscall-or-sysenter-on-32-bits-linux#:~:text=Well%2C%20according%20to%20%E2%80%9CSystem%20Calls,the%20overhead%20of%20changing%20mode.)
