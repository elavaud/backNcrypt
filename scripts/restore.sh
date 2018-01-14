#!/bin/bash
# Restore backup script
# $1: Path to restore file

# First check if all environment variables
if /backncrypt/check_variables.sh 'RESTORE'; then

  # Check if a backup file has been provided
  if [ "$#" -ne 1 ]; then
    echo "RESTORE BACKUP => FAILED => You must pass the path of the backup file to restore."
    exit 1;
  fi

  # Start restore process
  echo "RESTORE BACKUP => STARTED => File $1"
  set -o pipefail

  # Decrypt file
  if /backncrypt/decrypt.sh $1; then

    # Import sql file
    if ! /backncrypt/import.sh; then
      echo "RESTORE BACKUP => FAILED => Import"
      rm -rf "/tmp/restore.sql"
      exit 1;
    fi
  else
    echo "RESTORE BACKUP => FAILED => Decrypt"
    exit 1;
  fi
else
  echo "RESTORE BACKUP => FAILED => Environment variables"
  exit 1;
fi
echo "RESTORE BACKUP => SUCCESS"
exit 0;



if openssl aes-192-cbc -d -pass pass:$MYSQL_ROOT_PASSWORD -in $1 -out "/backup/restore.sql.gz"
then
  gzip -d -9 /backup/restore.sql.gz
  echo "=> Restore succeeded"
else
  echo "=> Restore failed"
fi

        # And then 
        mysql -h "easynut_mysql" -P "$DB_PORT" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" < /backup/restore.sql
        rm -rf /backup/restore.sql.gz
        rm -rf /backup/restore.sql
        echo "=> Restore succeeded"
