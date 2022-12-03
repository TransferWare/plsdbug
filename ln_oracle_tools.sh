#!/usr/bin/env sh

top_srcdir=$1

set -e
top_srcdir=`(cd $top_srcdir && pwd)`
dir=$top_srcdir
while [ -d $dir ]
do
    if [ -d $dir/../oracle-tools ]
    then
        break
    fi
    cd ..
    dir=`pwd`
done

if [ "$dir" != "$top_srcdir" ]
then
    set -x
    ln -s $dir/../oracle-tools $top_srcdir/..
fi

echo "=== Location of oracle-tools ==="
ls -ld $dir/../oracle-tools
