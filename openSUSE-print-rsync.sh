config=${OPENSUSE_RSYNC_CONFIG_FILE}

test -n "${config}" || {
    if [ -r ./openSUSE-print-rsync.env ]; then
        config=./openSUSE-print-rsync.env
    else
        config=/etc/openSUSE-print-rsync.env
    fi
}

has_numfmt=0
( which numfmt >& /dev/null || : ) && has_numfmt=1

# test -r "${config}" || (
#    >&2 echo "Cannot read config file ${config}"
#    exit 1
# )

PROJECT_TUMBLEWEED="${OPENSUE_RSYNC_PROJECT_TUMBLEWEED:-0}"
PROJECT_TUMBLEWEED_ISO="${OPENSUE_RSYNC_PROJECT_TUMBLEWEED_ISO:-1}"
PROJECT_TUMBLEWEED_REPO="${OPENSUE_RSYNC_PROJECT_TUMBLEWEED_REPO:-0}"
PROJECT_TUMBLEWEED_UPDATE="${OPENSUE_RSYNC_PROJECT_TUMBLEWEED_UPDATE:-0}"
PROJECT_TUMBLEWEED_SOURCE="${OPENSUE_RSYNC_PROJECT_TUMBLEWEED_SOURCE:-0}"
PROJECT_TUMBLEWEED_DEBUG="${OPENSUE_RSYNC_PROJECT_TUMBLEWEED_DEBUG:-0}"
PROJECT_TUMBLEWEED_HISTORY="${OPENSUE_RSYNC_PROJECT_TUMBLEWEED_HISTORY:-0}"

PROJECT_LEAP_156="${OPENSUE_RSYNC_PROJECT_LEAP_156:-0}"
PROJECT_LEAP_156_ISO="${OPENSUE_RSYNC_PROJECT_LEAP_156_ISO:-0}"
PROJECT_LEAP_156_REPO="${OPENSUE_RSYNC_PROJECT_LEAP_156_REPO:-0}"
PROJECT_LEAP_156_UPDATE="${OPENSUE_RSYNC_PROJECT_LEAP_156_UPDATE:-0}"
PROJECT_LEAP_156_PORT="${OPENSUE_RSYNC_PROJECT_LEAP_156_PORT:-0}"
PROJECT_LEAP_156_SOURCE="${OPENSUE_RSYNC_PROJECT_LEAP_156_SOURCE:-0}"
PROJECT_LEAP_156_DEBUG="${OPENSUE_RSYNC_PROJECT_LEAP_156_DEBUG:-0}"

PROJECT_LEAP_155="${OPENSUE_RSYNC_PROJECT_LEAP_155:-0}"
PROJECT_LEAP_155_ISO="${OPENSUE_RSYNC_PROJECT_LEAP_155_ISO:-0}"
PROJECT_LEAP_155_REPO="${OPENSUE_RSYNC_PROJECT_LEAP_155_REPO:-0}"
PROJECT_LEAP_155_UPDATE="${OPENSUE_RSYNC_PROJECT_LEAP_155_UPDATE:-0}"
PROJECT_LEAP_155_PORT="${OPENSUE_RSYNC_PROJECT_LEAP_155_PORT:-0}"
PROJECT_LEAP_155_SOURCE="${OPENSUE_RSYNC_PROJECT_LEAP_155_SOURCE:-0}"
PROJECT_LEAP_155_DEBUG="${OPENSUE_RSYNC_PROJECT_LEAP_155_DEBUG:-0}"

PROJECT_SLOWROLL="${OPENSUE_RSYNC_PROJECT_SLOWROLL:-0}"
PROJECT_SLOWROLL_ISO="${OPENSUE_RSYNC_PROJECT_SLOWROLL_ISO:-0}"
PROJECT_SLOWROLL_REPO="${OPENSUE_RSYNC_PROJECT_SLOWROLL_REPO:-0}"
PROJECT_SLOWROLL_UPDATE="${OPENSUE_RSYNC_PROJECT_SLOWROLL_UPDATE:-0}"

PROJECT_REPOSITORIES="${OPENSUE_RSYNC_PROJECT_REPOSITORIES:-0}"

declare -A paths
paths[tw-iso]=/tumbleweed/iso
paths[tw-repo]=/tumbleweed/repo
paths[tw-update]=/update/tumbleweed
paths[tw-source]=/source/tumbleweed/repo
paths[tw-debug]=/debug/tumbleweed/repo

paths[lp156-iso]=/distribution/leap/15.6/iso
paths[lp156-repo]=/distribution/leap/15.6/repo
paths[lp156-update]=/update/leap/15.6
paths[lp156-source]=/source/distribution/leap/15.6
paths[lp156-debug]=/debug/distribution/leap/15.6
paths[lp156-port]=/ports/aarch64/distribution/leap/15.6

paths[lp155-iso]=/distribution/leap/15.5/iso
paths[lp155-repo]=/distribution/leap/15.5/repo
paths[lp155-update]=/update/leap/15.5
paths[lp155-source]=/source/distribution/leap/15.5
paths[lp155-debug]=/debug/distribution/leap/15.5
paths[lp155-port]=/ports/aarch64/distribution/leap/15.5

paths[sr-iso]=/slowroll/iso
paths[sr-repo]=/slowroll/repo
paths[sr-update]=/update/slowroll

paths[repositories]=/repositories

projects=()

set -ae
test ! -r "${config}" || source ${config}
set +a

test 0 == "${PROJECT_TUMBLEWEED_ISO:${PROJECT_TUMBLEWEED:0}}" || projects+=( tw-iso )
test 0 == "${PROJECT_TUMBLEWEED_REPO:${PROJECT_TUMBLEWEED:0}}" || projects+=( tw-repo )
test 0 == "${PROJECT_TUMBLEWEED_UPDATE:${PROJECT_TUMBLEWEED:0}}" || projects+=( tw-update )
test 0 == "${PROJECT_TUMBLEWEED_SOURCE:0}" || projects+=( tw-source )
test 0 == "${PROJECT_TUMBLEWEED_DEBUG:0}" || projects+=( tw-debug )
test 0 == "${PROJECT_TUMBLEWEED_HISTORY:0}" || projects+=( tw-history )

test 0 == "${PROJECT_LEAP_156_ISO:${PROJECT_LEAP_156:0}}" || projects+=( lp156-iso )
test 0 == "${PROJECT_LEAP_156_REPO:${PROJECT_LEAP_156:0}}" || projects+=( lp156-repo )
test 0 == "${PROJECT_LEAP_156_UPDATE:${PROJECT_LEAP_156:0}}" || projects+=( lp156-update )
test 0 == "${PROJECT_LEAP_156_SOURCE:0}" || projects+=( lp156-source )
test 0 == "${PROJECT_LEAP_156_DEBUG:0}" || projects+=( lp156-debug )
test 0 == "${PROJECT_LEAP_156_PORT:0}" || projects+=( lp156-port )

test 0 == "${PROJECT_LEAP_155_ISO:${PROJECT_LEAP_155:0}}" || projects+=( lp155-iso )
test 0 == "${PROJECT_LEAP_155_REPO:${PROJECT_LEAP_155:0}}" || projects+=( lp155-repo )
test 0 == "${PROJECT_LEAP_155_UPDATE:${PROJECT_LEAP_155:0}}" || projects+=( lp155-update )
test 0 == "${PROJECT_LEAP_155_SOURCE:0}" || projects+=( lp155-source )
test 0 == "${PROJECT_LEAP_155_DEBUG:0}" || projects+=( lp155-debug )
test 0 == "${PROJECT_LEAP_155_PORT:0}" || projects+=( lp155-port )

test 0 == "${PROJECT_SLOWROLL_ISO:${PROJECT_SLOWROLL:0}}" || projects+=( sr-iso )
test 0 == "${PROJECT_SLOWROLL_REPO:${PROJECT_SLOWROLL:0}}" || projects+=( sr-repo )
test 0 == "${PROJECT_SLOWROLL_UPDATE:${PROJECT_SLOWROLL:0}}" || projects+=( sr-update )

address="${OPENSUSE_RSYNC_ADDRESS:-${RSYNC_ADDRESS:-rsync://stage3.opensuse.org/opensuse-full-really-everything/opensuse/}}"
last_modified_url=${LAST_MODIFIED_URL:-http://download.opensuse.org/rest/project_last_modified}
disk_usage_url=${DISK_USAGE_URL:-http://download.opensuse.org/rest/project_disk_usage}

deflt_params="-L -r -t -v"
params="${OPENSUSE_RSYNC_PARAMS:-${RSYNC_PARAMS:-$deflt_params}}"
xtra="${OPENSUSE_RSYNC_EXTRA_PARAMS:-${RSYNC_EXTRA_PARAMS}}"

cachedir="${OPENSUSE_RSYNC_CACHE_DIR:-${CACHE_DIR:-.}}"
lockdir="${OPENSUSE_RSYNC_LOCK_DIR:-${LOCK_DIR:-.}}"
logdir="${OPENSUSE_RSYNC_LOG_DIR:-${LOG_DIR:-.}}"

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

    ## check last sync
    ##
    last_sync=$(cat $cachefile 2>/dev/null) || :
    last_change=''
    test -z "$last_modified_url" || last_change=$(curl -s $last_modified_url?project=$name)

    test "${last_change}" -eq "${last_change}" 2> /dev/null || last_change=

    test "${last_sync:-0}" != "${last_change:-1}" || {
        echo echo skipping $proj because up to date
        continue
    }
    path=${paths[${proj}]}
    test "$path" != "" || continue
    #
    ##

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

    ## generate --include paramaters
    #
    topdir="$path"
    name="$(dirname "$topdir")"

    includes="--include='$path/***' --exclude='*'"

    while [ "$topdir" != "/" ] && [ "$topdir" != '.' ] && [ "$topdir" != "" ]; do
        name="$topdir"
        includes="--include='$name/' $includes"
        topdir="$(dirname ${topdir})"
    done
    #
    ##

    ## print rsync
    #
    (
        echo "echo -- starting asynchronous sync of $proj, expected disk usage $du_text. Refer $logfile for details..."
        echo "flock -n $lockfile rsync $xtra $params $includes \"$address\"" "$@" ">> $logfile 2>&1  & echo ${last_change:-unknown} > $cachefile"
        echo
    )
    #
    ##
done

test "$du_total" -le 0 || {
    test "$has_numfmt" != 1 || du_total=$(numfmt --to=iec $du_total)
    echo "echo total expected disk usage: $du_total"
}

test -z "$du_unknown_projects" || echo "echo Projects with unknown disk usage: $du_unknown_projects"
