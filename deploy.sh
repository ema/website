#!/bin/sh

BASEDIR="_site/"
DESTDIR="."

directories=`find $BASEDIR -type d | sed s#$BASEDIR##g`
files=`find $BASEDIR -type f | sed s#$BASEDIR##g`

do_stuff() {
  echo "$1" 
  echo "$1" | cadaver http://www.linux.it/davhome/ema
}

jekyll --no-server

do_stuff "mkdir $DESTDIR"

for dir in $directories
do
  do_stuff "mkdir $DESTDIR/$dir"
done

for file in $files
do
  do_stuff "put $BASEDIR/$file $DESTDIR/$file"
done
