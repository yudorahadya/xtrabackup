#!/bin/bash

day="$(date +\%Y-\%m-\%d)";
data_dir="/var/log/xtrabackup/";
data_inc="/last_incremental_number";
a="inc";


/bin/sh /opt/script/xtrabackup.sh incremental

sleep 3

cd $data_dir

last_update="$(ls -td -- */ | head -n 1 | cut -d'/' -f1)";
basefile="$(echo $data_dir$last_update$data_inc)";
movefolder="$(echo $data_dir$last_update)";
counter="$(more $data_dir$last_update$data_inc)";

#echo $counter
#echo inc$counter
#echo $basefile

basefiletar="$(echo $data_dir$last_update/$a$counter)";

#echo $basefiletar

cd $movefolder

tar -zcvf inc$counter.bz2 $basefiletar

sleep 3

rsync -a $movefolder/inc$counter.bz2 root@192.168.2.76:/data/backup_mysql/$last_update/

rsync -a $basefile root@192.168.2.76:/data/backup_mysql/$last_update/

