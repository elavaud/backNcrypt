#!/bin/bash
# Script to set up the file structure and the cron job

set -e

# Prepare cron jobs
if /backncrypt/check_variables.sh ; then

	if [ "${CRON_TIME_L1}" ]; then
		mkdir -p "/backups/${BACKUP_NAME}/L1"
		echo "${CRON_TIME_L1} /backncrypt/backup.sh 'L1'" >> temp_cron  
	fi
	if [ "${CRON_TIME_L2}" ]; then
		mkdir -p "/backups/${BACKUP_NAME}/L2"
		echo "${CRON_TIME_L2} /backncrypt/backup.sh 'L2'" >> temp_cron  
	fi
	if [ "${CRON_TIME_L3}" ]; then
		mkdir -p "/backups/${BACKUP_NAME}/L3"
		echo "${CRON_TIME_L3} /backncrypt/backup.sh 'L3'" >> temp_cron  
	fi

  # Implement CRON jobs
  rm -rf /crontab.conf
  cat temp_cron > /crontab.conf
  crontab /crontab.conf
  rm temp_cron
  echo "BackNcrypt => Cron task manager started"
  exec crond -f
  exit 0;

else
	echo "$1 BACKUP => FAILED => Environment variables"
	exit 1;
fi