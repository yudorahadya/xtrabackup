#!/bin/bash -x
#Tue Jul  2 15:32:21 CEST 2013
#Made by Edward Z.
set -e #stops execution if a variable is not set
set -u #stop execution if something goes wrong

#######################################
#######################################
#######################################
BACKUP_DIR=/var/lib/xtrabackup/
DATA_DIR=/var/lib/mysql
USER_ARGS=" --user=root --password=12345sh!"
filedate=`cat /tmp/fullbackup`

ARGS="--rsync $USER_ARGS --no-timestamp --compress --compress-threads=4"

usage() {
        echo "usage: $(basename $0) [option]"
        echo "option=full: do a full backup of vinnie /var/lib/mysql using innobackupex."
        echo "option=incremental: do a incremental backup"
        echo "option=restore: this will restore the latest backup to vinnie, BE CAREFUL!"
        echo "option=help: show this help"
}

full_backup() {
        date
        if [ ! -d $BACKUP_DIR ]
        then
        mkdir $BACKUP_DIR
                #echo "ERROR: the folder $BACKUP_DIR does not exists"
                #exit 1
        fi
        echo "doing full backup..."
        echo "cleaning the backup folder..."
        rm -rf $BACKUP_DIR/*
        echo "cleaning done! Starting backup"
        innobackupex $ARGS $BACKUP_DIR/FULL
        date
        echo "backup done!" #, now uncompressing the files..."
#        for bf in `find $BACKUP_DIR/FULL -iname "*\.qp"`; do qpress -d $bf $(dirname $bf) ;echo "processing" $bf; rm $bf; done
#        date
#        echo "uncompressing done!, preparing the backup for restore..."
#        innobackupex --apply-log --redo-only $BACKUP_DIR/FULL
#        date
#        echo "preparation done!"
}

incremental_backup()
{
        if [ ! -d $BACKUP_DIR/FULL ]
        then
                echo "ERROR: no full backup has been done before. aborting"
                exit -1
        fi

        #we need the incremental number
        if [ ! -f $BACKUP_DIR/${filedate}_last_incremental_number ]; then
            NUMBER=1
        else
            NUMBER=$(($(cat $BACKUP_DIR/${filedate}_last_incremental_number) + 1))
        fi
        date
        echo "doing incremental number $NUMBER"
        if [ $NUMBER -eq 1 ]
        then
                innobackupex $ARGS --incremental $BACKUP_DIR/${filedate}_inc${NUMBER} --incremental-basedir=$BACKUP_DIR/FULL
        else
                innobackupex $ARGS --incremental $BACKUP_DIR/${filedate}_inc${NUMBER} --incremental-basedir=$BACKUP_DIR/${filedate}_inc$(($NUMBER - 1))
        fi
        date
        echo $NUMBER > $BACKUP_DIR/${filedate}_last_incremental_number
        echo "incremental $NUMBER done!" #, now uncompressing the files..."
#        for bf in `find $BACKUP_DIR/inc$NUMBER -iname "*\.qp"`; do qpress -d $bf $(dirname $bf) ;echo "processing" $bf; rm $bf; done
#        date
#        echo "uncompressing done!, the preparation will be made when the restore is needed"
}

restore()
{
        echo "WARNING: are you sure this is what you want to do? (Enter 1 or 2)"
        select yn in "Yes" "No"; do
            case $yn in
                Yes ) break;;
                No ) echo "aborting... that was close."; exit;;
            esac
        done

        echo "cross your fingers :)"
        date
        echo "decompressing full backup"
        innobackupex --decompress $BACKUP_DIR/FULL
    echo "doing restore..."
        innobackupex --apply-log --redo-only $BACKUP_DIR/FULL

        #we append all the increments
        P=1
        while [ -d $BACKUP_DIR/${filedate}_inc$P ] && [ -d $BACKUP_DIR/${filedate}_inc$(($P+1)) ]
        do
              echo "decompressing incremental $P"
          innobackupex --decompress $BACKUP_DIR/${filedate}_inc$P
              echo "processing incremental $P"
              innobackupex --apply-log --redo-only $BACKUP_DIR/FULL --incremental-dir=$BACKUP_DIR/${filedate}_inc$P
              P=$(($P+1))
        done

        if [ -d $BACKUP_DIR/${filedate}_inc$P ]
        then
        #the last incremental has to be applied without the redo-only flag
        echo "decompressing incremental $P"
                 innobackupex --decompress $BACKUP_DIR/${filedate}_inc$P
                 echo "processing last incremental $P"
                 innobackupex --apply-log $BACKUP_DIR/FULL --incremental-dir=$BACKUP_DIR/${filedate}_inc$P
         fi

         #we prepare the full
         innobackupex --apply-log $BACKUP_DIR/FULL

         #finally we copy the folder
         cp -r $DATA_DIR $DATA_DIR.back
         rm -rf $DATA_DIR/*
         innobackupex --copy-back $BACKUP_DIR/FULL

         chown -R mysql:mysql $DATA_DIR

 }

 if [ $# -eq 0 ]
 then
 usage
 exit 1
 fi

     case $1 in
         "full")
             full_backup
             ;;
         "incremental")
         incremental_backup
             ;;
         "restore")
         restore
             ;;
         "help")
             usage
             break
             ;;
         *) echo "invalid option";;
     esac
