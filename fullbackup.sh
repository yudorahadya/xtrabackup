#!/bin/bash
data_dir=/var/lib/xtrabackup
date_sync=$(date +%Y%m%d)
#day=$(date +\%Y-\%m-\%d)

echo $date_sync > /tmp/fullbackup

rm -rf $data_dir/*

sleep 3

/bin/sh /opt/script/xtrabackupnewrev1.sh full

sleep 3

cd $data_dir/

tar -zcvf $date_sync-FULL.bz2 FULL/

sleep 3

#rsync -r $data_dir/$date_sync-FULL.bz2 root@192.168.56.5:/root/xtrabackup/FULL/
rsync -r $data_dir/$date_sync-FULL.bz2 root@192.168.56.11:/root/xtrabackup/FULL/

sleep 3

rm -rf $data_dir/$date_sync-FULL.bz2
