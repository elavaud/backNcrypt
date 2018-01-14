#!/bin/bash
# Dump encryption
# $1: Backup level (choices: L1, L2 or L3)
# $2: Temp file path
# $3: Backup file path

ENC_RESULT=false
if [ $ENC_TYPE = "openssl" ]; then
  if gzip -9 "$2.sql"; then
    if openssl enc -aes-192-cbc -pass pass:$ENC_PASS -out "$3" -in "$2.sql.gz"; then
      ENC_RESULT=true
    fi
  fi
elif [ $ENC_TYPE = "7z" ]; then
  echo "Not yet"
else
  echo "$1 BACKUP => FAILED => Encryption type not recognized. Values accepted for variable ENC_TYPE are 'openssl' or '7z'."  
fi
rm -rf "$2.sql"
rm -rf "$2.sql.gz"
if [ $ENC_RESULT = false ]; then
  echo "$1 BACKUP => FAILED => Error during compression/encryption of the SQL dump. Check the variables you provided.";
  exit 1;
fi
exit 0;
