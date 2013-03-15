#!/bin/bash
#

test $# -gt 0 || ! echo "usage: $0 <filename>" || exit 1

orig=$(stat --printf=%s $1)
size=$(~/ng/bin/lcs --compress --window 50 --fastlz /tmp/test --output - | wc -c)
echo $[($size*10000)/$orig] | sed -e 's/\(..\)$/\.\1%/'
