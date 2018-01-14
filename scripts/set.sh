#!/bin/bash
# Script to set up the file structure and the cron job

# File structure
mkdir -p "/backups/L1"
mkdir -p "/backups/L2"
mkdir -p "/backups/L3"

# Prepare cron jobs
if [ "${CRON_TIME_L1}" ]; then
  echo "${CRON_TIME_L1} /backncrypt/backup.sh 'L1'" >> temp_cron  
fi
if [ "${CRON_TIME_L2}" ]; then
  echo "${CRON_TIME_L2} /backncrypt/backup.sh 'L2'" >> temp_cron  
fi
if [ "${CRON_TIME_L3}" ]; then
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
