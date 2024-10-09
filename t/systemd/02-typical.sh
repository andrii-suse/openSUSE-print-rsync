#!../lib/test-in-container-systemd.sh

set -exo pipefail

zypper -n ar -f http://cdn.opensuse.org/repositories/home:andriinikitin:opensuse-rsync/rpm o7rsync

zypper --gpg-auto-import-keys -vvv ref
# install the package, so the user and folders are created
zypper -vvvn in opensuse-rsync-typical
# now overwrite the scripts with local copies
make install

echo "OPENSUSE_RSYNC_EXTRA_PARAMS='--max-size=4k'" >> /etc/opensuse-rsync.env

opensuse-rsync-timers-status
opensuse-rsync-timers-enable --dry
# systemctl enable --now opensuse-rsync-1min@lp156-update.timer
opensuse-rsync-timers-enable
systemctl | grep opensuse
sleep 30
ls -la /srv/opensuse/

ls -la /srv/opensuse/ | grep update

journalctl -u opensuse-rsync@lp156-update
journalctl -u opensuse-rsync@tw-iso

ls -la /srv/opensuse/update/leap/15.6/
ls -la /srv/opensuse/tumbleweed/iso/ | tail

opensuse-rsync-timers-disable
opensuse-rsync-timers-status
opensuse-rsync-timers-enable
opensuse-rsync-timers-status

bash -x /usr/bin/opensuse-rsync-services-status

echo success

