#!/bin/sh

# Download binaries, and unpack

cd dev/build_data
VERSION=0.10.1

# windows 32 bit
wget -t 2 -c https://bitbucket.org/rude/love/downloads/love-$VERSION\-win32.zip
unzip love-$VERSION\-win32.zip

# windows 64 bit
wget -t 2 -c https://bitbucket.org/rude/love/downloads/love-$VERSION\-win64.zip
unzip love-$VERSION\-win64.zip

# os x universal
wget -t 2 -c https://bitbucket.org/rude/love/downloads/love-$VERSION\-macosx-x64.zip
unzip love-$VERSION\-macosx-x64.zip
