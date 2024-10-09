#!/bin/bash -eu

echo=

test "${1:-}" != --dry || echo="echo "

res=0

for t in $(systemctl --all | grep -oE 'opensuse-rsync@.*service'); do
    rc=0
    $echo systemctl status $t || rc=$?
    test $rc != 3 || rc=0
    test $rc == 0 || res=$rc
    # todo some aggregation and summary
done

( exit $res )
