#!/bin/bash

#/bin/sh /opt/script/xtrabackupnewrev1.sh incremental
/bin/sh /opt/script/xtrabackupnewrev2.sh incremental

sleep 3

#get_hour=`date +%H`
data_dir=/var/lib/xtrabackup/
archiver=/var/lib/xtrabackup/archiver
data_inc=last_incremental_number
message="sending file ..."
done="done !"
namefile=`cat /tmp/fullbackup`

a="inc";
cd $data_dir
last_update="$(ls -td -- */ | head -n 1 | cut -d'/' -f1)";
#echo $data_dir$last_update
#echo $last_update
var_tar="$last_update"
f=${var_tar}.bz2
tar -zcvf $f $var_tar

sleep 3

echo $message

rsync -r $f root@192.168.56.11:/var/lib/all_xtrabackup/INC/
#rsync -r $f root@192.168.56.11:/root/xtrabackup/INC/
#rsync -r $f root@192.168.56.5:/root/xtrabackup/INC/

sleep 3

rsync -r ${namefile}_last_incremental_number root@192.168.56.11:/var/lib/all_xtrabackup/log/
#rsync -r ${namefile}_last_incremental_number root@192.168.56.11:/root/xtrabackup/log/
#rsync -r $data_inc root@192.168.56.11:/root/xtrabackup/log/
#rsync -r $data_inc root@192.168.56.5:/root/xtrabackup/log/


echo $done

sleep 3

echo "clear file..."

rm -rf $f

echo $done
