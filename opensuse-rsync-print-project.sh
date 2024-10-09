#!/bin/bash -eu

thisdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

set -ea
source "${thisdir}"/opensuse-rsync-common.sh
set +a
proj=$1

test -n "${proj}" || (
    >& echo 'Expected project as first parameter';
    exit 1
)

set -euo pipefail
print_project "$@"

