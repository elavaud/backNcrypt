#!/bin/bash
# Start backup fonction
# $1: Backup level (choices: L1, L2 or L3)

DATE=$(date $DATE_FMT)
#set default

: "${ENC_TYPE:=7z}"
: "${DATE_FMT:=+%Y_%b_%d__%Hh%M}"
: "${TZ:=Europe/Brussels}"

DATE=`TZ=${TZ} date ${DATE_FMT}`
echo "$1 Backup started @ $DATE"

# Set files' extension
if [ $ENC_TYPE = "openssl" ]; then
  FILE_EXTENSION=gz.enc
elif [ $ENC_TYPE =  "7z" ]; then
  FILE_EXTENSION=7z
else
  echo "$1 BACKUP => Encrpytion type not understood. Choices are openssl or 7z."
  exit 1;
fi

# Set files' path
if [ $1 = "L1" ]; then
  BACKUP_FILE_PATH=/backups/${BACKUP_NAME}/L1/${BACKUP_NAME}_bkup.$FILE_EXTENSION
  TMP_FILE_PATH=/tmp/backup
elif [ $1 = "L2" ]; then
  BACKUP_FILE_PATH=/backups/${BACKUP_NAME}/L2/${BACKUP_NAME}_$DATE.bkup.$FILE_EXTENSION
  TMP_FILE_PATH=/tmp/$DATE.backup.l2
else
  BACKUP_FILE_PATH=/backups/${BACKUP_NAME}/L3/${BACKUP_NAME}_$DATE.bkup.$FILE_EXTENSION
  TMP_FILE_PATH=/tmp/$DATE.backup.l3
fi

# If sql dump successful
if /backncrypt/dump.sh $1 "$TMP_FILE_PATH"; then
  # Encrypt backup
  if /backncrypt/encrypt.sh $1 "$TMP_FILE_PATH" "$BACKUP_FILE_PATH"; then
    ln -s -f "$BACKUP_FILE_PATH" /backups/${BACKUP_NAME}/latest
    echo "$1 Local BACKUP => SUCCESS"
    if [ -n "$REMOTE" ]; then
      if [ -n "$REMOTE_PASS" ]; then
        echo Remote backup: ${REMOTE}
        sshpass -p ${REMOTE_PASS} rsync -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" -a /backups/ ${REMOTE_OPTIONS} ${REMOTE}${BACKUP_NAME}/
      fi
    fi
    if [ -n "$REMOTE2" ]; then
      if [ -n "$REMOTE2_PASS" ]; then
        echo Remote2 backup: ${REMOTE2}
        sshpass -p ${REMOTE2_PASS} rsync -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" -a /backups/ ${REMOTE2_OPTIONS} ${REMOTE2}${BACKUP_NAME}/
      fi
    fi
  else
    echo "$1 BACKUP => FAILED => Encryption"
    rm -rf "$TMP_FILE_PATH.sql"
    exit 1;
  fi
  rm -rf "$TMP_FILE_PATH.sql"
else
  echo "$1 BACKUP => FAILED => Dump"
  exit 1;
fi

# Delete old backups
if [ $1 != "L1" ]; then
  /backncrypt/clean.sh $1 $FILE_EXTENSION
fi
exit 0;
