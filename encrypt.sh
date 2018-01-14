#!/bin/bash
# Dump encryption
ENC_RESULT=false
if ["$ENC_TYPE" = "openssl"]; then
  if gzip -9 "$TMP_FILE_PATH.sql"; then
    if openssl enc -aes-192-cbc -pass pass:$ENC_PASS -out "$BACKUP_FILE_PATH" -in "$TMP_FILE_PATH.sql.gz"; then
      ENC_RESULT=true
elif ["$ENC_TYPE" = "7z"]; then

else
  echo "$1 BACKUP => FAILED => Encryption type not recognized. Values accepted for variable ENC_TYPE are 'openssl' or '7z'."  
fi
rm -rf "$TMP_FILE_PATH.sql"
rm -rf "$TMP_FILE_PATH.sql.gz"
if [ "$ENC_RESULT" = false ]; then
  echo "$1 BACKUP => FAILED => Error of during compression/encryption of the SQL dump. Check the variables you provided.";
  exit 1;
fi
exit 0;
