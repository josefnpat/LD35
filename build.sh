#!/bin/bash

SRC="src"
NAME="dracul"
VERSION=0.10.1

`sh ./gengit.sh $SRC`
GIT=`sh ./git.sh $SRC`
GIT_COUNT=`sh ./git_count.sh $SRC`

# Cleanup
rm builds/*
mkdir -p builds

# *.love
INFO=v${GIT_COUNT}-\[${GIT}\]
BIN_NAME=${NAME}_${INFO}
LOVE="builds/${BIN_NAME}.love"

cd $SRC

zip -r ../$LOVE *
cd ..

# Temp Space
mkdir tmp

# Windows 32 bit
cat dev/build_data/love-$VERSION\-win32/love.exe $LOVE > tmp/${BIN_NAME}.exe
cp dev/build_data/love-$VERSION\-win32/*.dll tmp/
cd tmp
zip -r ../builds/${NAME}_win32_${INFO}.zip *
cd ..
rm tmp/* -rf #tmp cleanup

# Windows 64 bit
cat dev/build_data/love-$VERSION\-win64/love.exe $LOVE > tmp/${BIN_NAME}.exe
cp dev/build_data/love-$VERSION\-win64/*.dll tmp/
cd tmp
zip -r ../builds/${NAME}_win64_${INFO}.zip *
cd ..
rm tmp/* -rf #tmp cleanup

# OS X
cp dev/build_data/love.app tmp/${BIN_NAME}.app -Rv
cp dev/build_data/macosx-64-Info.plist tmp/${BIN_NAME}.app/Contents/Info.plist
sed -i "s/%%GIT%%/${GIT}/" tmp/${BIN_NAME}.app/Contents/Info.plist
cp $LOVE tmp/${BIN_NAME}.app/Contents/Resources/${BIN_NAME}.love
cp dev/build_data/icons/Game.icns tmp/${BIN_NAME}.app/Contents/Resources/
cd tmp
zip -ry ../builds/${NAME}_macosx_${INFO}.zip ${BIN_NAME}.app
cd ..
rm tmp/* -rf #tmp cleanup
