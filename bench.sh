#!/bin/bash
#

test $# -gt 0 || ! echo "usage: $0 <filename>" || exit 1

lcs=../../../bin/lcs
zflowcat=../../../bin/zflowcat
bmz=/ng/sdk/bmz-not-redistributable/1.0/amd64-linux/bin/bmz

windows="25 50 100 200"
methods="none fastlz deflate bzip2"

echo "Please wait .."

# compute md5
md5=$(md5sum ${1} | cut -f1 -d' ')

# uncompressed
cp ${1} ${1}.uncompressed

# test compression
for method in ${methods} ; do
    if test ${method} != "none"; then
        time ${zflowcat} --compress --${method} ${1} --output ${1}.${method}
    fi
done

for window in ${windows} ; do
# test bmz+compression
    printf "bmz-${window} ..\t" 2>&1
    time ${bmz} --fp-len ${window} ${1}
    mv ${1}.bmz ${1}.bmz-${window}.lzo
    echo "[OK]" 2>&1
    
# test lcs+compression
    for method in ${methods} ; do
        printf "lcs-${window}.${method} ..\t" 2>&1
        time ${lcs} --compress --${method} ${1} --window ${window} \
            --output ${1}.lcs-${window}.${method}
        echo "[OK]" 2>&1
        printf "\tchecksum .. " 2>&1
            # verify checksum
        m=$(${lcs} --decompress ${1}.lcs-${window}.${method} \
            | md5sum - | cut -f1 -d' ')
        if test "${m}" != "${md5}"; then
            echo "bad MD5sum for window=${window} method=${method}" 2>&1
            echo "(${m} <=> ${md5})" 2>&1
            exit 1
        fi
        echo "[OK]" 2>&1
    done
done
echo

echo "Summary:"
ls -lh ${1}.* -h --sort=size \
    | sed -e 's/[[:space:]][[:space:]]*/ /g' \
    | cut -f5,9 -d' ' \
    | sed -e "s%${1}\.%%" \
    | tr ' ' '\t'
