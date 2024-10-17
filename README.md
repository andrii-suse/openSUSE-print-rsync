# opensuse-rsync
-----------------------

opensuse-rsync provides systemd services to sync openSUSE repositories to mirrors

## Motivation

openSUSE infrastructure provides rsync modules, which are big and contain both dynamic and stale file sets.
download.opensuse.org has the concept of projects available in /app/project, which might be a useful abstraction for managing the content of mirror instead of current rsync modules.


The purpose of opensuse-rsync:
- Let users choose which projects they want to sync and estimate approximate total disk usage;
- Preview and customize generated rsync commands;
- Using API on download.opensuse.org skip the sync whatsoever if no files were changed in the project;
- Use named locks and log files for each project;
- Use cache file for each project to skip sync if API shows nothing was published;
- Potentially define a common way to sync openSUSE mirrors and integrate it with MirrorCache.

## Synopsis

```
# alternatively use opensuse-rsync-typical or opensuse-rsync-big
# or opensuse-rsync-huge or opensuse-rsync-everything
zypper in opensuse-rsync-minimal

# Preview which timers will be enabled according to the installed package
opensuse-rsync-timers-enabled --dry

# Preview which timers will be enabled according to the installed package and disk usage required
opensuse-rsync-timers-enabled --dry --preview

# enable timers according to the installed package
opensuse-rsync-timers-enabled

# Customize host to sync from
echo OPENSUSE_RSYNC_ADDRESS=rsync://provo-mirror.opensuse.org/opensuse/ >> /etc/opensuse-rsync.env
echo "OPENSUSE_RSYNC_EXTRA_PARAMS='--max-size=4k'" >> /etc/opensuse-rsync.env

opensuse-rsync-timers-disable
```

## Approximate expected disk usage

- minimal: 212G
- typical: 1.2T
- big: 1.8T
- huge: 36T
- everything: 38T


## How it works

- package opensuse-rsync provides the scripts and systemd services and timers;
- packages opensuse-rsync-* (minimal, typical, big, huge, everything) are mutually exclusive;
- script opensuse-rsync-timers-enable detects the desired layout according to installed packages and enables corresponding systemd timers (one per project);
- the timers call corresponding systemd units;
- the units check if anything changed in the corresponding project and trigger rsync if needed;
- the sync is started and the files should be delivered to /srv/opensuse/

## TODO

- report expected disk usage according to enabled projects and stats at https://download.opensuse.org/app/project;
- customize destination (currently hardcoded /srv/opensuse);
- deb package.

## Project status

2024 Oct - initial alpha version

## How to report issues or ask questions:

Write an email to andrii.nikitin on domain suse.com or use the issue tracker at https://github.com/andrii-suse/opensuse-rsync/
