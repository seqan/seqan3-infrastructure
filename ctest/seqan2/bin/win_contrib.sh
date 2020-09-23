#!/usr/bin/sh.exe
#
# Author: Rene Rahn <rene.rahn AT fu-berlin.de>
#
# Shell script to clean and download latest contrib package for windows.

cwd="$(pwd)"

# Prepare contrib directory.
mkdir -p $WORKSPACE/seqan-contrib/
cd $WORKSPACE/seqan-contrib
rm -rf *

# export path to contrib directory.
export SEQAN_WIN_CONTRIB_DIRECTORY="$WORKSPACE/seqan-contrib"

# Add zlib and bzip contrib.
echo "Download zlib and bzip contribs."
curl http://ftp.seqan.de/contribs/seqan-contrib-$WIN_SEQAN_CONTRIB_VERSION-x64.zip -o seqan-contrib-$WIN_SEQAN_CONTRIB_VERSION-x64.zip

echo "Extract zlib and bzip contribs."
unzip -qq seqan-contrib-$WIN_SEQAN_CONTRIB_VERSION-x64.zip

echo "DONE."

# Add boost contrib.
echo "Download boost."
curl -L0k https://dl.bintray.com/boostorg/release/1.65.1/source/boost_1_65_1.zip -o boost_1_65_1.zip
echo "Extract boost"
unzip -qq boost_1_65_1.zip
echo "DONE."
# Go back to working directory.
cd $cwd
