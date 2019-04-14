#!/bin/bash
# Script to check if the variables needed are set
# $1: Backup level (choices: L1, L2 or L3)

: "${DB_PASSWORD:=${POSTGRES_PASSWORD}}"

# Specify environment variables needed
declare -a REQUIRED_VARIABLES=(
  "DB_PASSWORD" 
  "ENC_PASS" 
  "BACKUP_NAME"
)

ALL_SET=true
MISSING_MESSAGE="One or more required environment variables are missing: "
MISSING_N=0
for i in "${REQUIRED_VARIABLES[@]}"
do
  if [ -z "${!i}" ]; then
    ALL_SET=false;
    if [ $MISSING_N = 0 ]; then
      MISSING_MESSAGE="$MISSING_MESSAGE $i";
    else
      MISSING_MESSAGE="$MISSING_MESSAGE, $i";
    fi
    MISSING_N=$((MISSING_N+1))
  fi
done
if [ $ALL_SET = false ]; then
  echo "$MISSING_MESSAGE";
  exit 1;
fi
exit 0;
