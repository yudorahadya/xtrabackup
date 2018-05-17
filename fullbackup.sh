#!/bin/bash
data_dir=/var/log/xtrabackup
day=$(date +\%Y-\%m-\%d)

rm -rf $data_dir/*

sleep 3

/bin/sh /opt/script/xtrabackup.sh full

sleep 3

cd $data_dir/$day

tar -zcvf FULL.bz2 $data_dir/$day/FULL/

sleep 3

rsync -r $data_dir/$day/FULL.bz2 root@192.168.2.76:/data/backup_mysql/$day/

sleep 3

rm -rf $data_dir/$day/FULL.bz2
