#!/bin/bash
# Script to check if the variables needed are set

# Specify environment variables needed
declare -a REQUIRED_VARIABLES=(
  "DB_BACKEND" 
  "DB_HOST" 
  "DB_PORT" 
  "DB_USER"  
  "DB_PASSWORD" 
  "ENC_TYPE" 
  "ENC_PASS" 
)
if ["$1" = "L2"]; then
  $REQUIRED_VARIABLES+=('MAX_BACKUPS_L2');
elif ["$1" = "L3"]; then
  $REQUIRED_VARIABLES+=('MAX_BACKUPS_L3');
fi

ALL_SET=true
MISSING_MESSAGE="$1 BACKUP => FAILED => One or more required environment variables are missing: "
MISSING_N=0
for i in "${$REQUIRED_VARIABLES[@]}"
do
  if [ -z "${$i}" ]; then
    ALL_SET=false;
    if ["$MISSING_N" = 0]; then
      MISSING_MESSAGE="$MISSING_MESSAGE $i";
    else
      MISSING_MESSAGE="$MISSING_MESSAGE, $i";
    fi
    MISSING_N=$((MISSING_N+1))
  fi
done
if [ "$ALL_SET" = false ]; then
  echo "$MISSING_MESSAGE";
  exit 1;
fi
exit 0;
