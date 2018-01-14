#!/bin/bash
# Start backup fonction
# $1: Backup level (choices: L1, L2 or L3)

# If all variables are set, backup can start
if /backncrypt/check_variables.sh $1; then
  DATE=$(date +%Y%m%d%H%M)
  echo "$1 BACKUP => STARTED => $DATE"
  
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
    BACKUP_FILE_PATH=/backups/L1/backup.$FILE_EXTENSION
    TMP_FILE_PATH=/tmp/backup
  elif [ $1 = "L2" ]; then
    BACKUP_FILE_PATH=/backups/L2/$DATE.backup.l2.$FILE_EXTENSION
    TMP_FILE_PATH=/tmp/$DATE.backup.l2
  else
    BACKUP_FILE_PATH=/backups/L3/$DATE.backup.l3.$FILE_EXTENSION
    TMP_FILE_PATH=/tmp/$DATE.backup.l3
  fi
  
  # If sql dump successful
  if /backncrypt/dump.sh $1 "$TMP_FILE_PATH"; then
    # Encrypt backup
    if /backncrypt/encrypt.sh $1 "$TMP_FILE_PATH" "$BACKUP_FILE_PATH"; then
      echo "$1 BACKUP => SUCCESS"
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
else
  echo "$1 BACKUP => FAILED => Environment variables"
  exit 1;
fi

# Delete old backups
if [ $1 != "L1" ]; then
  /backncrypt/clean.sh $1 $FILE_EXTENSION
fi
exit 0;
