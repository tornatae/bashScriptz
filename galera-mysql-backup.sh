#!/bin/bash
#title         :galera-mysql-backup.sh
#description   :Script for running backups on a 3-node galera cluster.
#                Designed to run from node 3 (most likely slave) and alternatively dump through node 2
#                to prevent excessive resource usage on the Master.
#author        :Roland MacDavid
#date          :2018-07-13
#version       :2
#usage         :(takes no arguments)

#export all variables that we'll be setting
set -a

# MySQL defaults file for logging into g2 if we need to.
BACKUP_PATH="/bs-db-backups"
DATE=$(date +"%m-%d-%y")
TODAYS_BACKUP_PATH=$BACKUP_PATH/$DATE
# Individual databases/schemas to dump
DATABASES=$(mysql -e 'show databases\G' | awk '/Database:/ {printf $2 "\n"};')
# State information we'll need later
STATE=$(cat /var/log/keepalived.log | tail -1 | grep -Eo '(Backup|Master)')
G2_STATE=$(ssh root@galera-2 "cat /var/log/keepalived.log | tail -1 | grep -Eo '(Backup|Master)'")
G2_DEFAULTS_FILE="/root/.backup.my.cnf"
# Only backup if today's backup path is empty. If it isn't, that may mean the backup failed partway through and we don't wanna mess with that.
BACKUP_NOT_DONE=$(ls -la $TODAYS_BACKUP_PATH 2>/dev/null)
YESTERDAY=$(date +"%m-%d-%y" --date="1 days ago")
YESTERDAY_BACKUP_PATH=$BACKUP_PATH/$YESTERDAY
FREE_SPACE=$(df  --output=avail -m /dev/mapper/mysql--backups-mysql--backups -BG | tail -1 | tr -cd '[[:digit:]]._-')

set +a

main () {
## Run the backup locally if we're a Backup Galera node ##
    if [[ "$STATE" == "Backup" && -z "$BACKUP_NOT_DONE" ]]
    then
        touch $BACKUP_PATH/backup-running-$DATE
        mkdir -p $BACKUP_PATH/$DATE
        for DBS in $DATABASES; do
            mysqldump $DBS --single-transaction --quick -r $TODAYS_BACKUP_PATH/$DBS.sql
        done
        if [ $? -eq 0 ]; then echo "backups finished!" && rm -r $BACKUP_PATH/backup-running-$DATE; fi
    else
        echo "Not performing backups locally"
    fi
##########################################################


## Run the backup on g2 if we're a Master Galera node ##
    if [[ "$STATE" == "Master" && -z "$BACKUP_NOT_DONE" && "$G2_STATE" == "Backup" ]]
    then
        touch $BACKUP_PATH/g2-backup-running-$DATE
        mkdir -p $BACKUP_PATH/$DATE
        for DBS in $DATABASES; do
            mysqldump --defaults-file=$G2_DEFAULTS_FILE $DBS --single-transaction --quick -r $TODAYS_BACKUP_PATH/$DBS.sql
        done
        if [ $? -eq 0 ]; then echo "g2 backups finished!" && rm -r $BACKUP_PATH/g2-backup-running-$DATE; fi
    else
        echo "Not performing backups on g2"
    fi
########################################################


## After a successful backup, compress yesterday's backups ##
    if [[ -a "$YESTERDAY_BACKUP_PATH" ]]
    then
        touch $BACKUP_PATH/backups-compressing-$DATE
        echo "Compressing yesterday's backups"
        # Tar yesterday's backup with pigz. Pigz is multi-threaded gzip which is useful for humongous backups
        # Only tar yesterday's backup because today's backup is more likely to be needed for a critical revert.
        tar -cf - $YESTERDAY_BACKUP_PATH | pigz --fast -p 6 > $BACKUP_PATH/$YESTERDAY.tar.gz && rm -rf $YESTERDAY_BACKUP_PATH
        if [ $? -eq 0 ]; then echo "Yesterday's backup compressed successfully!" && rm -r $BACKUP_PATH/backups-compressing-$DATE; fi
    else
        echo "Yesterday's backup not found, not compressing"
    fi
#############################################################

##### BACKUPS RETENTION ###################################
## Check for Backups older than 70 days, then delete them. ##
find $BACKUP_PATH -maxdepth 1 -mtime +70 -type f -delete
############################################################
}

if [[ "$FREE_SPACE" -gt 120 ]];
then
    main
else
    echo "LOW SPACE! Less than 120 GB of free space left on the backup LV. Not running backups."
fi
