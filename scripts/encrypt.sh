#!/bin/bash
# Dump encryption
# $1: Backup level (choices: L1, L2 or L3)
# $2: Temp file path
# $3: Backup file path

: "${ENC_TYPE:=7z}"
 echo "compressing and encrypting to ${ENC_TYPE}"
 
# With OpenSSL
if [ "$ENC_TYPE" = "openssl" ]; then
  #First gunzip
  if gzip -9 "$2.sql"; then
    # Then encrypt
    if ! openssl enc -aes-192-cbc -pass pass:$ENC_PASS -out "$3" -in "$2.sql.gz"; then
      echo "$1 BACKUP => FAILED => OpenSSL failed to encrypt your file. Tips: ensure you provided an encryption pass."
      # Remove tmp files
      rm -rf "$2.sql"
      rm -rf "$2.sql.gz"
      exit 1;
    fi
  else
    echo "$1 BACKUP => FAILED => Gunzip failed to compress the sql file."
    rm -rf "$2.sql"
    exit 1;
  fi
# With 7zip
elif [ "$ENC_TYPE" = "7z" ]; then
  if ! 7z a -p$ENC_PASS "$3" "$2.sql" >/dev/null; then 
    echo "$1 BACKUP => FAILED => 7zip failed to compress the sql file"
    rm -rf "$2.sql"
    exit 1;
  fi
# Encryption type not correct
else
  echo "$1 BACKUP => FAILED => Encryption type not recognized. Values accepted for variable ENC_TYPE are 'openssl' or '7z'."  
  rm -rf "$2.sql"
  exit 1;
fi

# Remove tmp files
rm -rf "$2.sql"
rm -rf "$2.sql.gz"
exit 0;
