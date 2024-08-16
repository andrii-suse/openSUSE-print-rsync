thisdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

set -ea
if test -f "${thisdir}"/opensuse-rsync-common.sh; then
    source "${thisdir}"/opensuse-rsync-common.sh
elif test -f "${thisdir}"/opensuse-rsync-common; then
    source "${thisdir}"/opensuse-rsync-common
else
    >&2 echo "Cannot find opensuse-rsync-common"
fi

has_numfmt=0
( which numfmt >& /dev/null || : ) && has_numfmt=1

set -euo pipefail

du_total=0
du_unknown_projects=""

for proj in ${projects[@]}; do
    cachefile=$cachedir/opensuse-rsync-$proj.mtime
    lockfile=$lockdir/opensuse-rsync-$proj.lock
    logfile=$logdir/opensuse-rsync-$proj.log
    name=$proj
    name=${name//tw/TW}
    name=${name//sr/SR}
    name=${name//lp/}
    name=${name//15/15.}
    name=${name//16/16.}
    name=${name//-/+}

    ## check disk usage
    #
    disk_usage=
    test -z "$disk_usage_url" || disk_usage=$(curl -s $disk_usage_url?project=$name)
    du_text='Unknown'
    if test "${disk_usage:-0}" -eq "${disk_usage:-1}" 2>/dev/null && test "${disk_usage}" -gt 0; then
        du_total=$(($du_total + $disk_usage))
        du_text=$disk_usage
        test "$has_numfmt" != 1 || du_text=$(numfmt --to=iec $disk_usage)
    else
        du_unknown_projects="$du_unknown_projects $proj"
    fi
    #
    ##

    echo "echo -- $proj, expected disk usage $du_text. Refer $logfile for details..."
    print_project_if_needed $proj ">> $logfile"
done

test "$du_total" -le 0 || {
    test "$has_numfmt" != 1 || du_total=$(numfmt --to=iec $du_total)
    echo "echo total expected disk usage: $du_total"
}

test -z "$du_unknown_projects" || echo "echo Projects with unknown disk usage: $du_unknown_projects"
