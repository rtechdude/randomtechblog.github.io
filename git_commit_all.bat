@echo off
cd "C:\Users\j\Documents\git\randomtechblog.github.io"
git add --all
git commit -m 'Updates'
GIT_SSH_COMMAND='ssh -i /c/Users/j/Documents/git/rtech' git push

pause