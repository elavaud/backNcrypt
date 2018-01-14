#!/bin/bash
# Start backup

# If all variables are set, backup can start
if ./check_variables.sh $1 $2; then
  
  # Start backup process
  DATE=$(date +%Y%m%d%H%M)
  echo "$1 BACKUP => STARTED => $DATE"
  
  # Set files' names
  if ["$1" = "L1"]; then
    BACKUP_FILE_PATH=/backups/L1/backup.gz.enc
    TMP_FILE_PATH=/tmp/backups/backup
  elif ["$1" = "L2"]; then
    BACKUP_FILE_PATH=/backups/L2/$DATE.backup.gz.enc
    TMP_FILE_PATH=/tmp/backups/$DATE.backup
  else
    BACKUP_FILE_PATH=/backups/L3/$DATE.backup.gz.enc
    TMP_FILE_PATH=/tmp/backups/$DATE.backup
  fi
  
  # If sql dump successful
  if ./dump.sh $1 "$TMP_FILE_PATH"; then
    # Encrypt backup
    if ./encrypt.sh $1 "$TMP_FILE_PATH" "$BACKUP_FILE_PATH"; then
      echo "$1 BACKUP => SUCCESS"
    else
      echo "$1 BACKUP => FAILED => Encryption"
      exit 1;
    fi
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
  ./clean.sh $1
fi
exit 0;
