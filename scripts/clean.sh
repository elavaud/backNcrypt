#!/bin/bash
# Scripts to delete old backups
# $1: Backup level (choices: L1, L2 or L3)
# $2: File extension ('gz.enc' or '7z')

if [ $1 = "L2" ]; then
  MAX_B=$MAX_BACKUPS_L2
elif [ $1 = "L3" ]; then
  MAX_B=$MAX_BACKUPS_L3
fi

if [ -n "$MAX_B" ]
then
  while [ "$(find /backups/$1 -maxdepth 1 -name "*.$2" | wc -l)" -gt "$MAX_B" ]
  do
    TARGET=$(find /backups/$1 -maxdepth 1 -name "*.$2" | sort | head -n 1)
    echo "$1 Backup => $TARGET is deleted"
    rm -rf "$TARGET"
  done
fi
