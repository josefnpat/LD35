#!/bin/sh

GIT=`sh ./git.sh $1`
GIT_COUNT=`sh ./git_count.sh $1`

echo "git,git_count = '${GIT}',${GIT_COUNT}" > $1/git.lua
