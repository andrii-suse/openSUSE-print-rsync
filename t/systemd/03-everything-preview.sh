#!../lib/test-in-container-systemd.sh

set -exo pipefail

zypper -n ar -f http://cdn.opensuse.org/repositories/home:andriinikitin:opensuse-rsync/rpm o7rsync

zypper --gpg-auto-import-keys -vvv ref
# now overwrite the scripts with local copies

# install the package, preview size required
zypper -vvvn in opensuse-rsync-everything

make install

opensuse-rsync-timers-enable --dry --preview

# install other packages, preview size required
zypper -vvvn in --force-resolution opensuse-rsync-huge
opensuse-rsync-timers-enable --dry --preview

zypper -vvvn in --force-resolution opensuse-rsync-big
opensuse-rsync-timers-enable --dry --preview

zypper -vvvn in --force-resolution opensuse-rsync-typical
opensuse-rsync-timers-enable --dry --preview

zypper -vvvn in --force-resolution opensuse-rsync-minimal
opensuse-rsync-timers-enable --dry --preview

echo success

