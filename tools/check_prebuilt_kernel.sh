#!/bin/sh
set -u
image=$1
expected=$2
[ -f "$image" ] && [ -f "$expected" ] || { echo "M5s selected kernel or EXPECTED.txt missing"; exit 0; }
want=$(awk '$1=="MD5"{print $2}' "$expected")
got=$(md5sum "$image" | cut -d' ' -f1)
[ "$want" = "$got" ] && exit 0
echo "M5s selected source-built 3.18 kernel mismatch: $got != $want; rebuild the pinned m5s_defconfig source and check the own compiled DTB. Do not append an unrelated stock DTB."
