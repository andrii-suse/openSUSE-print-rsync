#!/bin/bash -e

config="${OPENSUSE_RSYNC_CONFIG_FILE:-''}"

test -n "${config}" || {
    if [ -r ./openSUSE-print-rsync.env ]; then
        config=./openSUSE-print-rsync.env
    else
        config=/etc/openSUSE-print-rsync.env
    fi
}

RSYNC_EXTRA_PARAMS="${RSYNC_EXTRA_PARAMS:-''}"

has_numfmt=0
( which numfmt >& /dev/null || : ) && has_numfmt=1

# test -r "${config}" || (
#    >&2 echo "Cannot read config file ${config}"
#    exit 1
# )

PROJECT_TUMBLEWEED="${OPENSUSE_RSYNC_PROJECT_TUMBLEWEED:-0}"
PROJECT_TUMBLEWEED_ISO="${OPENSUSE_RSYNC_PROJECT_TUMBLEWEED_ISO:-1}"
PROJECT_TUMBLEWEED_REPO="${OPENSUSE_RSYNC_PROJECT_TUMBLEWEED_REPO:-0}"
PROJECT_TUMBLEWEED_UPDATE="${OPENSUSE_RSYNC_PROJECT_TUMBLEWEED_UPDATE:-0}"
PROJECT_TUMBLEWEED_SOURCE="${OPENSUSE_RSYNC_PROJECT_TUMBLEWEED_SOURCE:-0}"
PROJECT_TUMBLEWEED_DEBUG="${OPENSUSE_RSYNC_PROJECT_TUMBLEWEED_DEBUG:-0}"
PROJECT_TUMBLEWEED_HISTORY="${OPENSUSE_RSYNC_PROJECT_TUMBLEWEED_HISTORY:-0}"

PROJECT_LEAP_156="${OPENSUSE_RSYNC_PROJECT_LEAP_156:-0}"
PROJECT_LEAP_156_ISO="${OPENSUSE_RSYNC_PROJECT_LEAP_156_ISO:-0}"
PROJECT_LEAP_156_REPO="${OPENSUSE_RSYNC_PROJECT_LEAP_156_REPO:-0}"
PROJECT_LEAP_156_UPDATE="${OPENSUSE_RSYNC_PROJECT_LEAP_156_UPDATE:-0}"
PROJECT_LEAP_156_PORT="${OPENSUSE_RSYNC_PROJECT_LEAP_156_PORT:-0}"
PROJECT_LEAP_156_SOURCE="${OPENSUSE_RSYNC_PROJECT_LEAP_156_SOURCE:-0}"
PROJECT_LEAP_156_DEBUG="${OPENSUSE_RSYNC_PROJECT_LEAP_156_DEBUG:-0}"

PROJECT_LEAP_155="${OPENSUSE_RSYNC_PROJECT_LEAP_155:-0}"
PROJECT_LEAP_155_ISO="${OPENSUSE_RSYNC_PROJECT_LEAP_155_ISO:-0}"
PROJECT_LEAP_155_REPO="${OPENSUSE_RSYNC_PROJECT_LEAP_155_REPO:-0}"
PROJECT_LEAP_155_UPDATE="${OPENSUSE_RSYNC_PROJECT_LEAP_155_UPDATE:-0}"
PROJECT_LEAP_155_PORT="${OPENSUSE_RSYNC_PROJECT_LEAP_155_PORT:-0}"
PROJECT_LEAP_155_SOURCE="${OPENSUSE_RSYNC_PROJECT_LEAP_155_SOURCE:-0}"
PROJECT_LEAP_155_DEBUG="${OPENSUSE_RSYNC_PROJECT_LEAP_155_DEBUG:-0}"

PROJECT_SLOWROLL="${OPENSUSE_RSYNC_PROJECT_SLOWROLL:-0}"
PROJECT_SLOWROLL_ISO="${OPENSUSE_RSYNC_PROJECT_SLOWROLL_ISO:-0}"
PROJECT_SLOWROLL_REPO="${OPENSUSE_RSYNC_PROJECT_SLOWROLL_REPO:-0}"
PROJECT_SLOWROLL_UPDATE="${OPENSUSE_RSYNC_PROJECT_SLOWROLL_UPDATE:-0}"

PROJECT_REPOSITORIES="${OPENSUSE_RSYNC_PROJECT_REPOSITORIES:-0}"

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

test 0 == "${PROJECT_REPOSITORIES:0}" || projects+=( repositories )

address="${OPENSUSE_RSYNC_ADDRESS:-${RSYNC_ADDRESS:-rsync://stage3.opensuse.org/opensuse-full-really-everything/opensuse/}}"
last_modified_url=${LAST_MODIFIED_URL:-http://download.opensuse.org/rest/project_last_modified}
disk_usage_url=${DISK_USAGE_URL:-http://download.opensuse.org/rest/project_disk_usage}

deflt_params="-L -r -t --info=skip0"
params="${OPENSUSE_RSYNC_PARAMS:-${RSYNC_PARAMS:-$deflt_params}}"
xtra="${OPENSUSE_RSYNC_EXTRA_PARAMS:-${RSYNC_EXTRA_PARAMS}}"

cachedir="${OPENSUSE_RSYNC_CACHE_DIR:-${CACHE_DIR:-.}}"
lockdir="${OPENSUSE_RSYNC_LOCK_DIR:-${LOCK_DIR:-.}}"
logdir="${OPENSUSE_RSYNC_LOG_DIR:-${LOG_DIR:-.}}"

_validate_project() {
    local proj=$1
    test $proj != tumbleweed || proj=tw
    local path=${paths[${proj}]}
    test "$path" != "" || (
        >&2 echo "Unknown project $proj, expected one of";
        for i in "${!paths[@]}"; do
            >&2 echo -n " $i"
        done
        >&2 echo ""
        exit 1
    )
}

function print_project() {
    local proj=$1
    _validate_project $proj
    shift
    local path=${paths[${proj}]}
    ## generate --include paramaters
    #
    local topdir="$path"
    local name="$(dirname "$topdir")"

    local includes="--include='$path/***' --exclude='*'"

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
        echo "rsync $xtra $params $includes \"$address\"" "$@"
    )
}

function print_project_if_needed() {
    local proj=$1
    _validate_project $proj
    local cachefile=$cachedir/opensuse-rsync-$proj.mtime
    local name=$proj
    name=${name//tw/TW}
    name=${name//sr/SR}
    name=${name//lp/}
    name=${name//15/15.}
    name=${name//16/16.}
    name=${name//-/+}

    if test -n "$last_modified_url"; then
        echo -n "test \"\$(cat '$cachefile' 2>/dev/null)\" == \"\$(curl -s '$last_modified_url?project=$name' | tee '$cachefile' )\" || "
    fi
    print_project "$@"
}

