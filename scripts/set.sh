#!/bin/bash

temp_cron=$(mktemp)
if [ "${CRON_TIME_L1}" ]; then
  echo "${CRON_TIME_L1} /backup.sh 'L1'" >> temp_cron  
fi
if [ "${CRON_TIME_L2}" ]; then
  echo "${CRON_TIME_L2} /backup.sh 'L2'" >> temp_cron  
fi
if [ "${CRON_TIME_L3}" ]; then
  echo "${CRON_TIME_L3} /backup.sh 'L3'" >> temp_cron  
fi

echo ${temp_cron} > /crontab.conf
crontab /crontab.conf
echo "=> Running cron task manager"
exec crond -f
rm ${temp_cron}
exit 0;
