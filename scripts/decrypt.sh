#!/bin/bash
# Decrypt and un-compress the backup
# $1: Path to restore file

# If openssl
if [ $ENC_TYPE = "openssl" ]; then

  # Try first to decrypt with OpenSSL
  if openssl aes-192-cbc -d -pass pass:$ENC_PASS -in $1 -out "/tmp/restore.sql.gz"; then

    # Then try to unzip the file with gunzip
    if ! gzip -d -9 /tmp/restore.sql.gz; then
      echo "RESTORE BACKUP => FAILED => Gunzip couldn't unzip the file."
      rm -rf "/tmp/restore.sql.gz"
      exit 1;
    fi
  else
    echo "RESTORE BACKUP => FAILED => OpenSSL couldn't decrypt the backup. Tips: ensure you provided the right ENC_TYPE and ENC_PASS."
    exit 1;
  fi
  rm -rf "/tmp/restore.sql.gz"

# If 7-zip
elif [ $ENC_TYPE = "7z" ]; then
  if ! 7z e -p$ENC_PASS -o"/tmp" $1; then 
    echo "RESTORE BACKUP => FAILED => 7z failed to decompress the file. Tips: ensure you provided the right ENC_TYPE and ENC_PASS."
    exit 1;
  fi
else
  echo "RESTORE BACKUP => FAILED => Encryption type not recongized. Choices are 'openssl' or '7z'"    
  exit 1;
fi
exit 0;
