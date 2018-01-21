#!/bin/bash
sudo mkdir -p /root/move
sudo cp /mnt/bbvolume/movelog.tar.gz.cpt /root/move
sudo ccrypt -d -f -K BBlabSince2012. /root/move/movelog.tar.gz.cpt
sudo tar xvf /root/move/movelog.tar.gz

sudo cat /root/move/root/move/passwd.mig >> /etc/passwd
sudo cat /root/move/root/move/group.mig >> /etc/group
sudo cat /root/move/root/move/shadow.mig >> /etc/shadow
sudo /bin/cp /root/move/root/move/gshadow.mig /etc/gshadow

sudo rm -R /root/move

