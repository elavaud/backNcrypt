#!/bin/bash

if [ "${CRON_TIME_L1}" ]; then
  echo "${CRON_TIME_L1} /backncrypt/backup.sh 'L1'" >> temp_cron  
fi
if [ "${CRON_TIME_L2}" ]; then
  echo "${CRON_TIME_L2} /backncrypt/backup.sh 'L2'" >> temp_cron  
fi
if [ "${CRON_TIME_L3}" ]; then
  echo "${CRON_TIME_L3} /backncrypt/backup.sh 'L3'" >> temp_cron  
fi

rm -rf /crontab.conf
cat temp_cron > /crontab.conf
crontab /crontab.conf
rm temp_cron
echo "=> Running cron task manager"
exec crond -f
exit 0;
