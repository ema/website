#!/bin/sh

find . -name \*.html -or -name \*.pdf | while read file; do
  echo "put $file $file" | cadaver http://www2.linux.it/davhome/ema
done
