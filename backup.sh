#!/bin/bash

#import env file
source .env

#created my backup directory
sudo mkdir -p /mysql-backup

#variable pointing to the backup file created at the time, with timestamp attached
BACKUP_FILE=/mysql-backup/backup_"$(date +%Y%m%d_%H%M%S).sql"

#running docker exec mysqldump on my mysql container
docker exec dbsql /usr/bin/mysqldump -u root -p"$MYSQL_ROOT_PASSWORD" accounts > "$BACKUP_FILE"

#uploading the created file to my s3 bucket
aws s3 cp "$BACKUP_FILE" s3://wpress-backup-cd-2026

#checking if backup was successful and printing a success message
if [ $? -eq 0 ]; then
    echo "Backup successful to S3 Bucket at s3://wpress-backup-cd-2026/$BACKUP_FILE"
else
    echo "ERROR: Backup failed"
    exit 1
fi