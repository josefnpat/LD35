#!/bin/sh

GIT_COUNT=`git log --pretty=format:'' $1 | wc -l`

echo $GIT_COUNT
