#!/bin/bash -eu

echo=
preview=0

while [[ $# > 0 ]] ; do
    case $1 in
        --dry)
            echo='echo '
        ;;
        --preview)
            preview=1
        ;;
        *)
    esac
    shift
done

declare -A projects
declare -A frequency

for p in tw sr lp156 lp155; do
    declare "${p}_essential=${p}-iso ${p}-repo ${p}-update"
    declare "${p}_rest=${p}-debug ${p}-source ${p}-port"
done

projects[minimal]="lp156-update"
projects[typical]="lp156-update lp155-update $tw_essential"
projects[big]="$lp156_essential $lp155_essential $tw_essential"
projects[huge]="${projects[big]} $sr_essential repositories"
projects[everything]="${projects[huge]} $tw_rest $lp156_rest $lp155_rest"

frequency[tw-iso]=15min
frequency[tw-repo]=1min
frequency[tw-update]=15min
frequency[tw-source]=hourly
frequency[tw-debug]=hourly

frequency[lp156-iso]=hourly
frequency[lp156-repo]=hourly
frequency[lp156-update]=1min
frequency[lp156-source]=hourly
frequency[lp156-debug]=hourly

frequency[lp155-iso]=hourly
frequency[lp155-repo]=hourly
frequency[lp155-update]=15min
frequency[lp155-source]=hourly
frequency[lp155-debug]=hourly

du_total=0
du_unknown_projects=''
disk_usage_url="${OPENSUSE_RSYNC_DISK_USAGE_URL:-http://download.opensuse.org/rest/project_disk_usage}"
has_numfmt=0

if test "$preview" == 0; then
  disk_usage_url=''
else
    { numfmt --help >& /dev/null && has_numfmt=1; } || :
fi

for t in $(rpm -qa | grep opensuse-rsync); do
    t=${t#opensuse-rsync-}
    t=${t%%[0-9].*}
    t=${t%-}
    test -n "$t" || continue
    prjs="${projects[$t]}"
    test -n "$prjs" || continue
    for p in $prjs; do
        f=${frequency[$p]:-}
        test -n "$f" || f=hourly
        $echo systemctl enable --now opensuse-rsync-$f@$p.timer
        ## check disk usage
        #
        test "$preview" != 0 || continue
        disk_usage=
        name=$p
        name=${name//tw/TW}
        name=${name//sr/SR}
        name=${name//lp/}
        name=${name//15/15.}
        name=${name//16/16.}
        name=${name//-/+}
        test -z "$disk_usage_url" || disk_usage=$(curl -s $disk_usage_url?project=$name)
        du_text='Unknown'
        if test "${disk_usage:-0}" -eq "${disk_usage:-1}" 2>/dev/null && test "${disk_usage}" -gt 0; then
            du_total=$(($du_total + $disk_usage))
            du_text=$disk_usage
            test "$has_numfmt" != 1 || du_text=$(numfmt --to=iec $disk_usage)
            echo "# $p disk usage : $du_text"
        else
            du_unknown_projects="$du_unknown_projects $p"
        fi
        #
        ##
    done
done

test "$du_total" -le 0 || {
    test "$has_numfmt" != 1 || du_total=$(numfmt --to=iec $du_total)
    echo "echo total expected disk usage: $du_total"
}

test -z "$du_unknown_projects" || echo "echo Projects with unknown disk usage: $du_unknown_projects"
