# Programming from the Ground Up Chapter Programs and Exercises

This repository is a collection of the various programming exercises found in Jonathan Bartlett's "Programming from the Ground Up".

The repository's structure is unconventional, with each chapter's contents being isolated into an individual branch, with the Master/Main branch
acting as a landing page whose only content is this README file. Branches each indivudally have their own specific READMEs, it is recommended to
use GitHubs "Switch Branch" option to inspect each of the branches independently for further information.

As per the book, all code is written for the **GNU Assembler** `as` in AT&T syntax, and linked with the **GNU Linker** `ld`. The assembly is written
with x86_32 bit architectures in mind running Linux - again, as per the book - however all executables were built and verified with x86_64 bit architecture.

Currently, the book is incomplete, and the repo is still a work in progress.

## Downloading the Git Repo

It is recommended to clone this repo as a bare repo and construct each of the branches as their own independant directories via the worktree command.

The cloning process is as follows:

```bash
mkdir programming_ground_up; cd programming_ground_up
git clone --bare https://github.com/AlexeiSrour/programming_ground_up.git
git --git-dir=programming_ground_up.git branch | grep "^[^*+]" | awk '{system("git --git-dir=programming_ground_up.git worktree add " $1)}'

```

After running the above commands, you directory structure should look like so:

```bash
/programming_ground_up
├── programming_ground_up.git
├── 00_exit
├── 01_sort_list
├── 02_functions
└── ...
```

Each of these individual directories is an individual branch for that particular chapter's exercises. `cd` into the directory to access all of 
the git commands as usual.

## Building the code samples
The binaries built within each of the chapters normally had one or two context specific additional steps (i.e. shared objects or linking against
external objects), please refer to the README.md within each of the individual branches for the specific build instructions.

Below outlines the general build process for purposes of documentation and self reference.

### Assembling
As all assembly is written using x86_32 bit registers, a few additional arguments are required during the assembling and linking phases if being
built on an x86_64 machine.

For assembling:
```bash
as --32 -g program.s -o program.o
```

The `--32` option targets 32 bit x86 architectures specifically. The `-g` option is a personal recommendation that enables debug symbols amongst
other debug conveniences. This makes it much easier to trace execution in gdb when running `gdb -tui program`. 

### Linking
For linking:
```
ld -m elf_i386 program.o <all other external dependancies> -o program
```

The `-m elf_i386` option dictates the target platform to link for will be a 32bit i386 binary (untested if `-m elf32_x86_64` is functional).
As in all cases with linking, be sure to also specify all other external object files required for a successful link.

### Typical Build Workflow
To summarise the above, the majority of builds performed within each chapter was a one-liner of the form:
```bash
as -32 -g program.s -o program.o && ld -m elf_i386 program.o -o program
```

To ease the typing burden, liberal use of `bash`/`zsh` string substitution was used when "updating" the build process for a new file, e.g.:
```bash
# Initial line builds the <first_program> binary
as -32 -g first_program.s -o first_program.o && ld -m elf_i386 first_program.o -o first_program
# Using string substitution, we can update the above command to build the <second_program>
!!:gs/first_program/second_program
```

Additional edits are made after the resolution of string substitution in instances where the build fails due to missing linker dependancies.

Build scripts/Makefiles for individual chapters are eventually introduced to streamline the building process, however the majority of the chapters
were completed prior to creating this git repo and prior to thorough documentation, thus reference to the above instructions + chapter specific
context will be required to reverse engineer the build process of some of the binaries. Binaries for these chapters are available as part of the branch
in these cases with debug information, this makes it viable to trace execution using gdb and determine the files and link dependancies.

## Closing remarks
It may be worth linking to a blog post of mine outlining the motivation and explanation of using git worktrees in this manner, though the
posts are yet to be completed.

Documentation for each of the chapters is a work in progress, but the majority of this repo is moreso for archival purposes, thus build
automation for early chapters will likely never be realised.

A further result of this archival mindset is that many of the early chapters only have an initial commit and nothing more. Later chapters will
have more thorough and complete documentation, build processes, and commit history.
