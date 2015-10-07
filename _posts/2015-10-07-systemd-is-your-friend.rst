---
layout: post
title: "systemd is your friend"
tags: [systemd, linux, debian]
author_name: Emanuele Rocca
author_uri: http://www.linux.it/~ema
date: 2015-10-07 12:45:00
---

Today I want to talk a bit about some cool features of `systemd`_, the default
Debian init system since the `release of Jessie`_. Ubuntu has also adopted
systemd in 15.04, meaning that you are going to find it literally everywhere.

.. _systemd: https://en.wikipedia.org/wiki/Systemd
.. _release of Jessie: https://www.debian.org/News/2015/20150426

Logging
-------
The component responsible for logging in systemd is called journal. It collects
and stores logs in a structured, indexed journal (hence the name). The journal
can replace traditional syslog daemons such as rsyslog and syslog-ng, or work
together with them. By default Debian keeps on using rsyslog, but if you don't
need to ship logs to a centralized server (or do other fancy things) it is
possible to stop using rsyslog right now and rely on systemd-journal instead.

The obvious question is: why would anybody use a binary format for logs instead
of a bunch of tried and true plain-text files? As it turns out, there are quite
a lot of `good reasons to do so`_.

.. _good reasons to do so: https://docs.google.com/document/pub?id=1IC9yOXj7j6cdLLxWEBAGRL6wl97tFxgjLUEHIX3MSTs

The killer features of `systemd-journald` for me are:

- Index tons of logs while being able to search with good performance:
  O(log(n)) instead of O(n) which is what you get with text files
- No need to worry about log rotation anymore, in any shape or form

The last point in particular is really critical in my opinion. Traditional log
rotation implementations rely on cron jobs to check how much disk space is used
by logs, compressing/removing old files. Log rotation is usually: 1) annoying
to configure; 2) hard to get right; 3) prone to DoS attacks. With journald,
there is pretty much nothing to configure. Log rotation is built into the
daemon disk space allocation logic itself. This also allows to avoid
vulnerability windows due to time-based rotation, which is what you get with
logrotate and friends.

Enough high-level discussions though, here is how to use the journal!

Check if you already have the directory `/var/log/journal`, otherwise create it
(as root). Then restart `systemd-journald` as follows:

**sudo systemctl restart systemd-journald**

You can get all messages produced since the last boot with **journalctl -b**.
All messages produced today can get extracted using **journalctl
--since=today**. Want to get all logs related to ssh? Try with **journalctl
_SYSTEMD_UNIT=ssh.service**.

There are many more filtering options available, you can read all about them
with **man journalctl**.

journald's configuration file is `/etc/systemd/journald.conf`. Two of the most
interesting options are `SystemMaxUse` and `SystemKeepFree`, which can be used
to change the amount of disk space dedicated to logging. They default to 10%
and 15% of the /var filesystem respectively.

Here is a little cheatsheet::

    journalctl -b                # Show all messages since last boot
    journalctl -f                # Tail your logs
    journalctl --since=yesterday # Show all messages produced since yesterday
    journalctl -pcrit            # Filter messages by priority
    journalctl /bin/su           # Filter messages by program
    journalctl --disk-usage      # The amount of space in use for journaling

Further reading:

- http://0pointer.de/blog/projects/systemctl-journal.html
- `journalctl(1)`
- `journald.conf(5)`
- `systemd-journald(8)`

Containers
----------
A relatively little known component of systemd is `systemd-nspawn`. It is a
small, straightforward container manager.

If you don't already have a chroot somewhere, here is how to create a basic
Debian Jessie chroot under `/srv/chroots/jessie`::

    $ debootstrap jessie /srv/chroots/jessie http://http.debian.net/debian/

With systemd-nspawn you can easily run a shell inside the chroot::

    $ sudo systemd-nspawn -D /srv/chroots/jessie
    Spawning container jessie on /srv/chroots/jessie.
    Press ^] three times within 1s to kill container.
    /etc/localtime is not a symlink, not updating container timezone.
    root@jessie:~#

Done. Everything works out of the box: no need for you to mount `/dev`, `/run`
and friends, systemd-nspawn took care of that. Networking also works.

If you want to actually boot the system, just add the **-b** switch to the
previous command::

    $ sudo systemd-nspawn -b -D /srv/chroots/jessie
    Spawning container jessie on /srv/chroots/jessie.
    Press ^] three times within 1s to kill container.
    /etc/localtime is not a symlink, not updating container timezone.
    systemd 215 running in system mode. (+PAM +AUDIT +SELINUX +IMA +SYSVINIT +LIBCRYPTSETUP +GCRYPT +ACL +XZ -SECCOMP -APPARMOR)
    Detected virtualization 'systemd-nspawn'.
    Detected architecture 'x86-64'.

    Welcome to Debian GNU/Linux jessie/sid!

    Set hostname to <orion>.
    [  OK  ] Reached target Remote File Systems (Pre).
    [  OK  ] Reached target Encrypted Volumes.
    [  OK  ] Reached target Paths.
    [  OK  ] Reached target Swap.
    [  OK  ] Created slice Root Slice.
    [  OK  ] Created slice User and Session Slice.
    [  OK  ] Listening on /dev/initctl Compatibility Named Pipe.
    [  OK  ] Listening on Delayed Shutdown Socket.
    [  OK  ] Listening on Journal Socket (/dev/log).
    [  OK  ] Listening on Journal Socket.
    [  OK  ] Created slice System Slice.
    [  OK  ] Created slice system-getty.slice.
    [  OK  ] Listening on Syslog Socket.
             Mounting POSIX Message Queue File System...
             Mounting Huge Pages File System...
             Mounting FUSE Control File System...
             Starting Copy rules generated while the root was ro...
             Starting Journal Service...
    [  OK  ] Started Journal Service.
    [  OK  ] Reached target Slices.
             Starting Remount Root and Kernel File Systems...
    [  OK  ] Mounted Huge Pages File System.
    [  OK  ] Mounted POSIX Message Queue File System.
    [  OK  ] Mounted FUSE Control File System.
    [  OK  ] Started Copy rules generated while the root was ro.
    [  OK  ] Started Remount Root and Kernel File Systems.
             Starting Load/Save Random Seed...
    [  OK  ] Reached target Local File Systems (Pre).
    [  OK  ] Reached target Local File Systems.
             Starting Create Volatile Files and Directories...
    [  OK  ] Reached target Remote File Systems.
             Starting Trigger Flushing of Journal to Persistent Storage...
    [  OK  ] Started Load/Save Random Seed.
             Starting LSB: Raise network interfaces....
    [  OK  ] Started Create Volatile Files and Directories.
             Starting Update UTMP about System Boot/Shutdown...
    [  OK  ] Started Trigger Flushing of Journal to Persistent Storage.
    [  OK  ] Started Update UTMP about System Boot/Shutdown.
    [  OK  ] Started LSB: Raise network interfaces..
    [  OK  ] Reached target Network.
    [  OK  ] Reached target Network is Online.
    [  OK  ] Reached target System Initialization.
    [  OK  ] Listening on D-Bus System Message Bus Socket.
    [  OK  ] Reached target Sockets.
    [  OK  ] Reached target Timers.
    [  OK  ] Reached target Basic System.
             Starting /etc/rc.local Compatibility...
             Starting Login Service...
             Starting LSB: Regular background program processing daemon...
             Starting D-Bus System Message Bus...
    [  OK  ] Started D-Bus System Message Bus.
             Starting System Logging Service...
    [  OK  ] Started System Logging Service.
             Starting Permit User Sessions...
    [  OK  ] Started /etc/rc.local Compatibility.
    [  OK  ] Started LSB: Regular background program processing daemon.
             Starting Cleanup of Temporary Directories...
    [  OK  ] Started Permit User Sessions.
             Starting Console Getty...
    [  OK  ] Started Console Getty.
    [  OK  ] Reached target Login Prompts.
    [  OK  ] Started Login Service.
    [  OK  ] Reached target Multi-User System.
    [  OK  ] Reached target Graphical Interface.
             Starting Update UTMP about System Runlevel Changes...
    [  OK  ] Started Cleanup of Temporary Directories.
    [  OK  ] Started Update UTMP about System Runlevel Changes.

    Debian GNU/Linux jessie/sid orion console

    orion login:

That's it! Just one command to start a shell in your chroot or boot the
container, again zero configuration needed.

Finally, systemd provides a command called `machinectl` that allows you to
introspect and control your container::

    $ sudo machinectl status jessie
    jessie
               Since: Wed 2015-10-07 11:22:56 CEST; 55min ago
              Leader: 32468 (systemd)
             Service: nspawn; class container
                Root: /srv/chroots/jessie
             Address: fe80::8e70:5aff:fe81:2290
                      192.168.122.1
                      192.168.1.13
                  OS: Debian GNU/Linux jessie/sid
                Unit: machine-jessie.scope
                      ├─32468 /lib/systemd/systemd
                      └─system.slice
                        ├─dbus.service
                        │ └─32534 /usr/bin/dbus-daemon --system --address=systemd: --nofork --nopidfile -...
                        ├─cron.service
                        │ └─32539 /usr/sbin/cron
                        ├─systemd-journald.service
                        │ └─32487 /lib/systemd/systemd-journald
                        ├─systemd-logind.service
                        │ └─32532 /lib/systemd/systemd-logind
                        ├─console-getty.service
                        │ └─32544 /sbin/agetty --noclear --keep-baud console 115200 38400 9600 vt102
                        └─rsyslog.service
                          └─32540 /usr/sbin/rsyslogd -n

With machinectl you can also reboot, poweroff, terminate your containers and
more. There are so many things to learn about systemd and containers! Here are
some references.

- systemd-nspawn(1)
- machinectl(1)
- http://0pointer.net/blog/systemd-for-administrators-part-xxi.html

This stuff is pretty exciting. Now that all major distributions use systemd by
default, we can expect to have access to tools like journalctl and
systemd-nspawn everywhere!
