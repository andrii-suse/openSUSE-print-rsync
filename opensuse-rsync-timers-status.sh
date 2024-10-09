#!/bin/bash -eu

echo=

test "${1:-}" != --dry || echo="echo "

for t in $(systemctl list-timers --all | grep -oE 'opensuse-rsync.*timer'); do
    $echo systemctl status $t
    # todo some aggregation and summary
done
