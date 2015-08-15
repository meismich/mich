#!/bin/ksh

chown -R root:wheel data/restore/*

cp data/restore/etc/rc.local /etc/.
cp data/restore/etc/apeagers.conf /etc/.
cp data/restore/etc/rc.conf /etc/.
cp data/restore/etc/resolv.conf /etc/.
cp data/restore/etc/sysctl.conf /etc/.
cp data/restore/etc/mygate /etc/.
cp data/restore/etc/hostname.vic0 /etc/.
cp data/restore/etc/hostname.vic1 /etc/.
cp data/restore/etc/hostname.vic2 /etc/.
cp data/restore/etc/hostname.vic3 /etc/.

cp data/restore/mail/relay-domains /etc/mail/.
cp data/restore/mail/access /etc/mail/.

cp data/restore/bin/monitor-pf /usr/bin/.
cp data/restore/bin/grep-pf /usr/bin/.
cp data/restore/bin/restart-pf /usr/bin/.
