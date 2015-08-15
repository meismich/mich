#!/bin/ksh

cp /etc/rc.local data/backup/etc/.
cp /etc/apeagers.conf data/backup/etc/.
cp /etc/rc.conf data/backup/etc/.
cp /etc/resolv.conf data/backup/etc/.
cp /etc/sysctl.conf data/backup/etc/.
cp /etc/mygate data/backup/etc/.
cp /etc/hostname.vic0 data/backup/etc/.
cp /etc/hostname.vic1 data/backup/etc/.
cp /etc/hostname.vic2 data/backup/etc/.
cp /etc/hostname.vic3 data/backup/etc/.

cp /etc/mail/relay-domains data/backup/mail/.
cp /etc/mail/access data/backup/mail/.

cp /usr/bin/monitor-pf data/backup/bin/.
cp /usr/bin/grep-pf data/backup/bin/.
cp /usr/bin/restart-pf data/backup/bin/.

cp bin/backup.sh data/backup/.

chown -R mspence data/backup/*

