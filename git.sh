#!/bin/sh

GIT=`git log --pretty=format:'%h' -n 1 $1`

echo $GIT
