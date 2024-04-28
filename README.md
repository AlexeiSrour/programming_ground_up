TODO: Add instruction and explanation on how to split out all the branches into separate worktrees/folders
NOTE: probably should clone this as a bare repo, that seems to help
TODO: add instruction on how to build these items on x86 *and* x86_64

A one liner to unpack all of the branches into worktree folders after doing a git clone --bare
git --git-dir=programming_ground_up.git branch | grep "^[^*+]" | awk '{system("git --git-dir=programming_ground_up.git worktree add " $1)}'

# Programming from the Ground Up Chapter Programs and Exercises

This repository is a collection of the various programming exercises found in Jonathan Bartlett's "Programming from the Ground Up".

The repository's structure is unconventional, with each chapter's contents being isolated into an individual branch, with the Master/Main branch
acting as a landing page whose only content is this README file.

As per the book, all code is written for the **GNU Assembler** `as` in AT&T syntax, and linked with the **GNU Linker** `ld`. The assembly is written
with x86_32 bit architectures in mind running Linux, again as per the book, however all executables were built and verified with x86_64 bit architecture.

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
