TODO: Add instruction and explanation on how to split out all the branches into separate worktrees/folders
NOTE: probably should clone this as a bare repo, that seems to help
TODO: add instruction on how to build these items on x86 *and* x86_64

A one liner to unpack all of the branches into worktree folders after doing a git clone --bare
git --git-dir=programming_ground_up.git branch | grep "^[^*+]" | awk '{system("git --git-dir=programming_ground_up.git worktree add " $1)}'
