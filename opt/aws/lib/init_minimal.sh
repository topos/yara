#!/bin/sh

PATH=/bin:/usr/bin:/usr/sbin:/sbin; export PATH

# add swap
#dd if=/dev/zero of=/.swap bs=1M count=2048
#mkswap /.swap 
#swapon /.swap
#if ! egrep '^/\.swap .*$' /etc/fstab >/dev/null 2>&1; then echo "/.swap   none   swap   sw   0   0" >> /etc/fstab; fi

# turn on sudo for "sudo" group
cat /etc/sudoers | sed 's/^# \(%sudo ALL=NOPASSWD: ALL\)$/\1/g' > /tmp/sudoers.$$
[ -f /tmp/sudoers.$$ ] && mv -f /tmp/sudoers.$$ /etc/sudoers && chmod 0440 /etc/sudoers
